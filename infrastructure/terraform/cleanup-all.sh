#!/bin/bash

# Delete ELBs.
./cleanup-elbs.sh

# Delete all the resources for the EKS cluster production environment.
#unset KUBECONFIG && export KUBECONFIG=$(ls -ltr ~/.kube/config-M2M-EksCluster-*-Production | awk '{print $9}' | tail -n 1) && echo $KUBECONFIG
kubectl config use-context $(kubectl config get-contexts -o name | grep "M2M-EksCluster-Production" | sort -r | head -n 1)
./cleanup-eks-cluster.sh

# For Staging cluster.
#unset KUBECONFIG && export KUBECONFIG=$(ls -ltr ~/.kube/config-M2M-EksCluster-*-Staging | awk '{print $9}' | tail -n 1) && echo $KUBECONFIG
kubectl config use-context $(kubectl config get-contexts -o name | grep "M2M-EksCluster-Staging" | sort -r | head -n 1)
./cleanup-eks-cluster.sh

# Delete VPC security groups.
./cleanup-vpc-security-groups.sh

# Delete the VPC and others.
terraform destroy -auto-approve -refresh=false
