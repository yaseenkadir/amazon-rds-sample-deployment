#!/usr/bin/env bash

set -e

usage="Usage ./deploy-infra.sh <template s3 bucket> <keypair name> <database password> <aws profile (Optional)>"

if test $# -ne 3 && test $# -ne 4
then
    echo "$usage"
    exit 1
fi

template_bucket="$1"
keypair_name="$2"
database_password="$3"
aws_profile="${4:-default}"

# Get path to deploy directory
# https://stackoverflow.com/a/11114547
SCRIPT=$( realpath $0 )
DEPLOY_DIR=$( dirname ${SCRIPT} )

# Copy templates to S3
aws_cmd="aws --profile $aws_profile"
${aws_cmd} s3 sync "$DEPLOY_DIR/templates/" "s3://$template_bucket/templates"

# Deploy VPC stack
echo "Deploying VPC stack"
${aws_cmd} cloudformation deploy \
    --template-file "$DEPLOY_DIR/simple-app-vpc.yml" \
    --stack-name simple-app-vpc-stack \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
    KeyName="$keypair_name" \
    TemplateBucket="$template_bucket"

# The full vpc stack name is exported, the db stack needs the full name
vpc_full_stack_name=$(
    ${aws_cmd} cloudformation describe-stacks \
        --stack-name simple-app-vpc-stack \
        --output text \
        --query 'Stacks[0].Outputs[?OutputKey==`VpcStackName`].OutputValue'
)

echo "Deploying db stack"
${aws_cmd} cloudformation deploy \
    --template-file "$DEPLOY_DIR/simple-app-db.yml" \
    --stack-name simple-app-db-stack \
    --parameter-overrides \
    VpcStackName="$vpc_full_stack_name" \
    DatabasePassword="$database_password" \
    TemplateBucket="$template_bucket"
