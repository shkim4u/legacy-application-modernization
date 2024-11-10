#!/bin/bash

#echo "KUBECONFIG: ${KUBECONFIG}"
#
## Check if "KUBECONFIG" has been set and exit if not.
#if [ -z "$KUBECONFIG" ]; then
#  echo "KUBECONFIG is not set."
#  exit 1
#fi
#
## Assign "ENVIRONMENT=Production" if KUBECONFIG contains "Production", or "Staging" if KUBECONFIG contains "Staging".
#if [[ $KUBECONFIG == *"Production"* ]]; then
#  export ENVIRONMENT_NAME="Production" && echo $ENVIRONMENT_NAME
#elif [[ $KUBECONFIG == *"Staging"* ]]; then
#  export ENVIRONMENT_NAME="Staging" && echo $ENVIRONMENT_NAME
#fi

# Set "ENVIRONMENT_NAME" to "Production" or "Staging" based on the "kubectl config current-context" if it contains "Production" or "Staging".
ENVIRONMENT_NAME=""
if [[ $(kubectl config current-context) == *"M2M-EksCluster-Production"* ]]; then
  ENVIRONMENT_NAME="Production" && echo $ENVIRONMENT_NAME
elif [[ $(kubectl config current-context) == *"M2M-EksCluster-Staging"* ]]; then
  ENVIRONMENT_NAME="Staging" && echo $ENVIRONMENT_NAME
fi

# Check if $ENVIRONMENT_NAME is empty and exit if it is.
if [ -z "$ENVIRONMENT_NAME" ]; then
  echo "'kubectl config curreent-context' not evaluated any environment for Production or Staging."
  exit 1
fi

# 1. Ingresses.
kubectl patch ingresses argo-rollouts-dashboard -n argo-rollouts -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ingresses argocd-server -n argocd -p '{"metadata":{"finalizers":null}}' --type=merge
#kubectl patch ingresses defectdojo -n defectdojo -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ingresses grafana -n grafana -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ingresses alb-2048 -n istio-system -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ingresses kiali -n istio-system -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ingresses kubernetes-dashboard -n kubernetes-dashboard -p '{"metadata":{"finalizers":null}}' --type=merge
#kubectl patch ingresses riches-ingress -n riches -p '{"metadata":{"finalizers":null}}' --type=merge
#kubectl patch ingresses webgoat-ingress -n webgoat -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch ingresses hotelspecials-ingress -n hotelspecials -p '{"metadata":{"finalizers":null}}' --type=merge

# 2. Target Group Bindings.
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack=argo-rollouts -n argo-rollouts -o jsonpath='{.items[*].metadata.name}'` -n argo-rollouts -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack=argo -n argocd -o jsonpath='{.items[*].metadata.name}'` -n argocd -p '{"metadata":{"finalizers":null}}' --type=merge
#kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack-name=defectdojo -n defectdojo -o jsonpath='{.items[*].metadata.name}'` -n defectdojo -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack=grafana -n grafana -o jsonpath='{.items[*].metadata.name}'` -n grafana -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack-name=alb-2048 -n istio-system -o jsonpath='{.items[*].metadata.name}'` -n istio-system -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack=kiali -n istio-system -o jsonpath='{.items[*].metadata.name}'` -n istio-system -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack=kubernetes-dashboard  -n kubernetes-dashboard -o jsonpath='{.items[*].metadata.name}'` -n kubernetes-dashboard -p '{"metadata":{"finalizers":null}}' --type=merge
#kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack-name=riches-ingress  -n riches -o jsonpath='{.items[*].metadata.name}'` -n riches -p '{"metadata":{"finalizers":null}}' --type=merge
#kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack-name=webgoat-ingress  -n webgoat -o jsonpath='{.items[*].metadata.name}'` -n webgoat -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch targetgroupbindings `kubectl get targetgroupbindings -l ingress.k8s.aws/stack-name=hotelspecials-ingress  -n hotelspecials -o jsonpath='{.items[*].metadata.name}'` -n webgoat -p '{"metadata":{"finalizers":null}}' --type=merge

# 3. Cluster Add-ons.
# Check the ENVIRONMENT_NAME is "Production" or not.

# Make ENVIRONMENT_NAME to lowercase.
ENVIRONMENT_NAME_LOWER=$(echo $ENVIRONMENT_NAME | tr '[:upper:]' '[:lower:]')

terraform destroy -target module.eks_cluster_"${ENVIRONMENT_NAME_LOWER}".module.eks_addons -auto-approve -refresh=false
terraform destroy -target module.eks_cluster_"${ENVIRONMENT_NAME_LOWER}".kubectl_manifest.nodepool -auto-approve -refresh=false
terraform destroy -target module.eks_cluster_"${ENVIRONMENT_NAME_LOWER}".kubectl_manifest.nodeclass -auto-approve -refresh=false
terraform destroy -target module.eks_cluster_"${ENVIRONMENT_NAME_LOWER}".helm_release.karpenter -auto-approve -refresh=false
terraform destroy -target module.eks_cluster_"${ENVIRONMENT_NAME_LOWER}".module.karpenter -auto-approve -refresh=false
terraform destroy -target module.eks_cluster_"${ENVIRONMENT_NAME_LOWER}" -auto-approve -refresh=false


#if [ "$ENVIRONMENT_NAME" == "Production" ]; then
#  # Delete the cluster add-ons for the production environment.
#  terraform destroy -target module.eks_cluster_production.module.eks_addons -auto-approve -refresh=false
#
#  terraform destroy -target module.eks_cluster_production.kubectl_manifest.nodepool -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_production.kubectl_manifest.nodeclass -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_production.helm_release.karpenter -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_production.module.karpenter -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_production -auto-approve -refresh=false
## Check if the ENVIRONMENT_NAME is "Staging".
#elif [ "$ENVIRONMENT_NAME" == "Staging" ]; then
#  terraform destroy -target module.eks_cluster_staging.module.eks_addons -auto-approve -refresh=false
#
#  terraform destroy -target module.eks_cluster_staging.kubectl_manifest.nodepool -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_staging.kubectl_manifest.nodeclass -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_staging.helm_release.karpenter -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_staging.module.karpenter -auto-approve -refresh=false
#  terraform destroy -target module.eks_cluster_staging -auto-approve -refresh=false
#fi
