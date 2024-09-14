```bash
cd ~/environment/
git clone https://github.com/shkim4u/samsung-fire-eks-evaluation
cd samsung-fire-eks-evaluation
```


```bash
hash -d aws

cd ~/environment/samsung-fire-eks-evaluation/infrastructure/terraform

# 1. Configure Terraform workspace and Private Certificate Authority.
. ./configure.sh samsung-fire-eks-evaluation ap-northeast-2

env | grep TF_VAR

cat <<EOF > terraform.tfvars
ca_arn = "${TF_VAR_ca_arn}"
eks_cluster_production_name = "${TF_VAR_eks_cluster_production_name}"
eks_cluster_staging_name = "${TF_VAR_eks_cluster_staging_name}"
EOF
```

```bash
# 1. IaC 디렉토리로 이동
cd ~/environment/samsung-fire-eks-evaluation/infrastructure/terraform

# terraform init
terraform init

# terraform plan
terraform plan -out tfplan

# terraform apply
terraform apply -auto-approve tfplan
```
