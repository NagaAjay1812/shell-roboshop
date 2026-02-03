#!/bin/bash

SG_ID="sg-0b1f7c3d25067bf9a"
AMI_ID="ami-0220d79f3f480ecf5"
SUBNET_ID="subnet-0bb417478919bf408"

for INSTANCE in $@
 do

  INSTANCE_ID=$( aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t3.micro \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
    --query "Instances[0].InstanceId" \
    --output text )

  if [[ "$INSTANCE" == "frontend" ]]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
  fi

  echo "$INSTANCE, Ip adress: $IP"

done
