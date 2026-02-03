#!/bin/bash
set -euo pipefail

SG_ID="sg-0b1f7c3d25067bf9a"
AMI_ID="ami-0220d79f3f480ecf5"
SUBNET_ID="subnet-0bb417478919bf408"

for NAME in "$@"; do
  ASSOC=""
  Q="Reservations[0].Instances[0].PrivateIpAddress"
  [[ "$NAME" == "frontend" ]] && ASSOC="--associate-public-ip-address" && Q="Reservations[0].Instances[0].PublicIpAddress"

  ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t3.micro \
    --subnet-id "$SUBNET_ID" \
    --security-group-ids "$SG_ID" \
    $ASSOC \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  aws ec2 wait instance-running --instance-ids "$ID"
  IP=$(aws ec2 describe-instances --instance-ids "$ID" --query "$Q" --output text)

  echo "$NAME  $ID  $IP"
done

