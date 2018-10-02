#!/usr/bin/env bash

set -e
set -x

usage="Usage ./docker-build-and-push.sh <aws region> <aws profile (Optional)>"

if test $# -ne 1 && test $# -ne 2
then
    echo "$usage"
    exit 1
fi

region=$1
aws_cmd="aws --region $region"

# Add the profile to the aws_cmd
! test -z "$2" && aws_cmd="$aws_cmd --profile $2"

echo "Building app"
./gradlew build

# Get the account id
account_id=$( ${aws_cmd} sts get-caller-identity --output text --query 'Account' )

# If repository doesn't exist, create one
echo "Checking if ECR repository exists"
${aws_cmd} ecr describe-repositories --repository-names simple-app && repository_exists="true" || repository_exists="false"

if test "$repository_exists" = "false"
then
    echo "ECR repository doesn't exist, creating one"
    ${aws_cmd} ecr create-repository --repository-name "simple-app"
fi

echo "Authorizing ECR with Docker"
${aws_cmd} ecr get-login --no-include-email --region ap-southeast-2 | bash

echo "Building and pushing docker image"
docker build -t simple-app .
docker tag simple-app:latest "$account_id".dkr.ecr."$region".amazonaws.com/simple-app:latest
docker push "$account_id".dkr.ecr."$region".amazonaws.com/simple-app:latest
