#!/bin/bash

# Install
pushd terragrunt/live || exit
terragrunt run-all plan
terragrunt run-all apply
popd || exit

# REQUIRED FOR KARPETENER
# https://karpenter.sh/v0.10.1/getting-started/getting-started-with-terraform/#create-the-ec2-spot-service-linked-role
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
# If the role has already been successfully created, you will see:
# An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.

pushd terragrunt/live/us-east-1 || exit
ECRURL=$(terragrunt output ecr_repository_url | tr -d \")
echo "$ECRURL"
CLUSTER_ID=$(terragrunt output cluster_id | tr -d \")
AWS_ACCOUNT=$(echo "$ECRURL" | cut -d . -f 1)
AWS_REGION=$(echo "$ECRURL" | cut -d . -f 4)
ECR_PASSWORD=$(aws ecr get-login-password --region "$AWS_REGION")
export AWS_ACCOUNT
export AWS_REGION
export ECR_PASSWORD
export NAMESPACE=weather
export MAIL=aly.vusal@gmail.com
popd || exit

# Login ECR Private container repo
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "$ECRURL"

# update kubeconfig to add new cluster
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_ID"
