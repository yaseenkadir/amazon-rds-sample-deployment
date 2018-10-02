#!/usr/bin/env bash

set -e
set -x

usage="Usage ./deploy-app.sh <template s3 bucket> <app s3 bucket> <keypair name> <database password> <aws region> <aws profile (Optional)>"

if test $# -ne 5 && test $# -ne 6
then
    echo "$usage"
    exit 1
fi

template_bucket="$1"
app_bucket="$1"
keypair_name="$3"
database_password="$4"
aws_region="$5"
aws_profile="${6:-default}"

# Get path to deploy directory
# https://stackoverflow.com/a/11114547
SCRIPT=$( realpath $0 )
DEPLOY_DIR=$( dirname ${SCRIPT} )
BASE_DIR="$DEPLOY_DIR/.."

# Copy templates to S3
aws_cmd="aws --profile $aws_profile"
${aws_cmd} s3 sync "$DEPLOY_DIR/templates/" "s3://$template_bucket/templates"

aws_cmd="aws --region $aws_region --profile $aws_profile"
aws_account_id=$( ${aws_cmd} sts get-caller-identity --output text --query 'Account' )

"$BASE_DIR/docker-build-and-push.sh" "$aws_region" "$aws_profile"

docker_run_file="$BASE_DIR/Dockerrun.aws.json"
docker_run_tmp_file=$( mktemp )

# Create a copy of the file and replace the region and account id
cp "$docker_run_file" "$docker_run_tmp_file"

perl -pi -e "s/%AWS_REGION%/$aws_region/g" "$docker_run_tmp_file"
# Edit the temporary file in place
perl -pi -e "s/%AWS_ACCOUNT_ID%/$aws_account_id/g" "$docker_run_tmp_file"

#md5_sum=$( md5 -q "$docker_run_tmp_file" | cut -c 1-20 )
#docker_run_tmp_file_with_hash="$docker_run_tmp_file.$md5_sum"
timestamp=$( date +%s )

app_s3_key="Dockerrun.aws.json_$timestamp"

${aws_cmd} s3 cp "$docker_run_tmp_file" "s3://$app_bucket/$app_s3_key"

# The full vpc stack name is exported, the db stack needs the full name
vpc_full_stack_name=$(
    ${aws_cmd} cloudformation describe-stacks \
        --stack-name simple-app-vpc-stack \
        --output text \
        --query 'Stacks[0].Outputs[?OutputKey==`VpcStackName`].OutputValue'
)

rds_full_stack_name=$(
    ${aws_cmd} cloudformation describe-stacks \
        --stack-name simple-app-db-stack \
        --output text \
        --query 'Stacks[0].Outputs[?OutputKey==`RdsStackName`].OutputValue'
)

echo "Deploying app stack"
${aws_cmd} cloudformation deploy \
    --template-file "$DEPLOY_DIR/simple-app-app.yml" \
    --stack-name simple-app-app-stack \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
    VpcStackName="$vpc_full_stack_name" \
    DatabaseStackName="$rds_full_stack_name" \
    DatabasePassword="$database_password" \
    TemplateBucket="$template_bucket" \
    AppS3Bucket="$app_bucket" \
    AppS3Key="$app_s3_key" \
    EC2KeyPairName="$keypair_name"
