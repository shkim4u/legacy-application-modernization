#!/bin/bash

# `terraform output`을 통해 VPC ID를 확인하고 이를 사용하여 Security Group을 삭제합니다.

# VPC ID 확인
VPC_ID=`terraform output -raw network_vpc_id` && echo $VPC_ID

# Loop through all security groups from the VPC ID and delete them.
sgids=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --query 'SecurityGroups[*].GroupId' --output text)
for sg in $sgids; do
  echo "Deleting security group ${sg} (If it's default security group, then error message will be shown. But it's okay.)"
  aws ec2 delete-security-group --group-id $sg
done
