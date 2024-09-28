#!/bin/bash

# Get the list of load balancer ARNs
lbs=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text)

# Loop through the load balancer ARNs
for lb in $lbs; do
  # Get the tags for the load balancer
  tags=$(aws elbv2 describe-tags --resource-arns $lb --query 'TagDescriptions[*].Tags[?Key==`elbv2.k8s.aws/cluster`].Value' --output text) && echo $tags

  # Check if the tag exists in the tags list
  if [[ $tags == *"M2M-EksCluster-"* ]]; then
    # If the tag exists, delete the load balancer
    echo "Deleting ELB ${lb} with tags ${tags}"
    aws elbv2 delete-load-balancer --load-balancer-arn $lb
  fi
done
