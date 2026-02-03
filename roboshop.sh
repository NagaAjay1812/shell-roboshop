#!/bin/bash

SG_ID="sg-0b1f7c3d25067bf9a"
AMI_ID="ami-0220d79f3f480ecf5"
SUBNET_ID="subnet-0bb417478919bf408"

for INSTANCE in "$@"; do
  if [[ "$INSTANCE" == "frontend" ]]; then
    aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --instance-type t3.micro \
      --subnet-id "$SUBNET_ID" \
      --security-group-ids "$SG_ID" \
      --associate-public-ip-address \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
      --query "Instances[].{InstanceId:InstanceId,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress}" \
      --output text
  else
    aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --instance-type t3.micro \
      --subnet-id "$SUBNET_ID" \
      --security-group-ids "$SG_ID" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
      --query "Instances[].{InstanceId:InstanceId,PrivateIP:PrivateIpAddress}" \
      --output text
  fi
done
