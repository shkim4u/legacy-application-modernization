# 워크샵 환경 프로비저닝

---

## Agenda
1. Overall Architecture
2. Cloud9 통합 환경 (IDE) 생성 (CloudShell)
3. Cloud9 통합 환경 (IDE) 설정 (Cloud9)
4. `Amazon EKS Extended Workshop` Demo Kit 받기
5. EKS 클러스터 생성 (테라폼 사용)

---

## 1. Overall Architecture
![워크샵 아키텍처](./assets/eks-extended-workshop-architecture.png)

## 2. Cloud9 통합 환경 (IDE) 생성

### 2.1. AWS Cloud9 환경 생성 (AWS CLI 사용)
진행자가 제공한 AWS 관리 콘솔에서 ```CloudShell```을 실행한 후 아래 명령을 수행하여 ```Cloud9``` 환경을 생성해 줍니다.<br>
```CloudShell```도 다수의 개발 언어와 런타임, 그리고 클라우드 환경을 다룰 수 있는 CLI를 기본적으로 제공하지만 보다 풍부한 통합 개발 환경을 제공하는 ```Cloud9```을 사용하기로 합니다.<br>
아래 명령은 ```Cloud9``` 환경을 구성하기 위하여 일련의 작업을 수행하므로 완료될 때까 다소 시간이 걸립니다 (1 ~ 2분)<br>
```bash
export AWS_PAGER=''
curl -fsSL https://raw.githubusercontent.com/shkim4u/m2m-travelbuddy/main/cloud9/bootstrap-v2-with-admin-user-trust.sh | bash -s -- c5.4xlarge
```

![`CloudShell`을 통해 `Cloud9` 인스턴스 생성](../../images/Environment/Create-Cloud9-with-CloudShell.png)

`Cloud9` 인스턴스 생성이 정상적으로 완료되면 아래와 같이 표시되고 이제 `CloudShell`은 닫아도 됩니다.

![`CloudShell`에서 `Cloud9` 인스턴스 생성 완료](../../images/Environment/Create-Cloud9-with-CloudShell-Completed.png)

## 3. Cloud9 통합 환경 (IDE) 설정
```Cloud9``` 통합 개발 환경에 접속하여 필요한 설정을 수행합니다.

![`Cloud9` 서비스로 이동](../../images/Environment/Goto-Cloud9-Service.png)

![`Cloud9` 환경 열기](../../images/Environment/Open-Cloud9-Environment.png)

![`Cloud9` 개발 환경](../../images/Environment/Cloud9-IDE.png)

여기에는 다음 사항이 포함됩니다.

1. IDE IAM 설정 확인
2. 쿠버네테스 (Amazon EKS) 작업을 위한 Tooling
    * kubectl 설치
    * eksctl 설치
    * k9s 설치
    * Helm 설치
3. AWS CLI 업데이트
4. AWS CDK 업그레이드
5. 기타 도구 설치 및 구성
    * AWS SSM 세션 매니저 플러그인 설치
    * AWS Cloud9 CLI 설치
    * jq 설치하기
    * yq 설치하기
    * bash-completion 설치하기
6. Cloud9 추가 설정하기
7. 디스크 증설
8. (Optional) CUDA Deep Neural Network (cuDNN) 라이브러리
9. Terraform 설치
10. ArgoCD 설치
11. Python 3.11 설치

> 📌📌📌 (참고) 📌📌📌<br>
> 아래 명령어 뭉치를 `Cloud9` 상에 붙여넣기 하면 마지막 행은 `New Line`이 포함되어 있지 않으므로 자동 실행되지 않고 대기 중입니다.<br>
> `Enter` 키를 눌러 마지막 행을 실행하면 됩니다.

```bash
cd ~/environment/

export AWS_PAGER=''
# Cloud9 환경 설정
curl -fsSL https://raw.githubusercontent.com/shkim4u/m2m-travelbuddy/main/cloud9/cloud9.sh | bash

# Amazon Corretto Headless 17 설치
sudo yum install -y java-17-amazon-corretto-headless

# Docker 빌드를 위한 Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# JWT CLI 설치
sudo npm install -g jwt-cli
```

![`Cloud9` 환경 설정](../../images/Environment/Configure-Cloud9-IDE.png)

## 4. `Legacy Application Modernization (LegMod) 워크샵` 소스 받기 및 자원 배포를 위한 사전 준비
### 4.1. 워크샵 소스 코드 받기

이제부터 모든 작업은 `Cloud9` 상에서 이루어지며, 먼저 `Legacy Application Modernization 워크샵` 소스를 아래와 같이 다운로드합니다.<br>
```bash
cd ~/environment/
git clone https://github.com/shkim4u/legacy-application-modernization legacy-application-modernization
#cd legacy-application-modernization
```

해당 소스 코드에는 테라폼으로 작성된 IaC 코드도 포함되어 있으며 여기에는 `VPC (Virtual Private Cloud)`와 같은 네트워크 자원,  `쿠버네테스` 클러스터 및 클러스터 자원 들 (`ArgoCD`, `Observability` 등), `데이터베이스`, 그리고 간단한 `CI` 파이프라인이 포함되어 있습니다.<br>

우선 이 테라폼 코드를 사용하여 자원을 배포하도록 합니다.

### 4.2. 테라폼을 통한 자원 배포를 위한 사전 준비

본격적으로 자원을 생성하기 앞서, 몇몇 ALB (취약 어플리케이션, ArgoCD, Argo Rollouts 등)에서 사용하기 위한 `Amazon Certificate Manager (ACM)` 사설 (Private) CA를 생성하고 `Self-signed Root CA` 인증서를 설치합니다.<br>

```bash
hash -d aws

cd ~/environment/legacy-application-modernization/infrastructure/terraform

# 1. Configure Terraform workspace and Private Certificate Authority.
. ./configure.sh legacy-application-modernization ap-northeast-2

env | grep TF_VAR

cat <<EOF >> terraform.tfvars
ca_arn = "${TF_VAR_ca_arn}"
eks_cluster_production_name = "${TF_VAR_eks_cluster_production_name}"
eks_cluster_staging_name = "${TF_VAR_eks_cluster_staging_name}"
EOF
```

위와 같이 수행하면 ACM에 사설 CA가 생성되는데 진행자와 함께 ACM 콘솔로 이동하여 Private CA를 한번 살펴봅니다.<br>
아래와 같이 Private CA가 활성 상태인 것을 확인합니다.<br>
![Private CA Active](./assets/private-ca-active.png)

> (참고)<br>
> 현재 리포지터를 통해 공유된 테라폼 코드에는 테라폼 상태 공유 및 공동 작업을 위한 백엔드 (S3, DynamoDB)가 포함되어 있지 않은데, 이에 대해서 궁금하시면 관리자나 과정 진행자에게 문의하세요.

## 5. EKS 클러스터 생성 (테라폼 사용)

이제 아래 명령어를 통해 ```Amazon EKS ``` 클러스터 및 기타 자원을 생성합니다. 15 ~ 20분 정도 소요됩니다.<br>

```bash
# 테라폼 디렉토리로 이동
cd ~/environment/legacy-application-modernization/infrastructure/terraform
# terraform init
terraform init
# terraform plan
terraform plan -out tfplan
# terraform apply
terraform apply -auto-approve tfplan
```

모든 자원의 생성이 완료되면 Production과 Staging (테스트 및 검증)을 위한 EKS 클러스터 2개가 생성되며, 우리는 우선 Production 클러스터에서 작업하므로 아래와 같이 환경 변수를 설정합니다.
```bash
cd ~/environment/legacy-application-modernization/infrastructure/terraform

echo 'export KUBECONFIG=~/.kube/config:$(find ~/.kube/ -type f -name "*M2M-EksCluster*" | tr "\n" ":")' >> ~/.bash_profile 

echo 'alias kcp="kubectl config use-context $(kubectl config get-contexts -o name | grep Production | sort -r | head -n 1)"' >> ~/.bash_profile
echo 'alias kcs="kubectl config use-context $(kubectl config get-contexts -o name | grep Staging | sort -r | head -n 1)"' >> ~/.bash_profile
echo 'alias kcc="kubectl config current-context"' >> ~/.bash_profile

# Terraform helper aliases.
echo 'alias ti="terraform init"' >> ~/.bash_profile
echo 'alias taa="terraform apply -auto-approve"' >> ~/.bash_profile

source ~/.bash_profile

# Work with production cluster.
kcp

# Karpenter가 Spot 인스턴스를 정상적으로 생성할 수 있도록 `Service-Linked Role`을 생성합니다.
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com > /dev/null 2>&1 || true

# EKS Node Viewer 설치
go install github.com/awslabs/eks-node-viewer/cmd/eks-node-viewer@latest
```

또한 이후 작업의 편의를 위해 아래와 같이 ArgoCD Admin 암호를 설정합니다.<br>
```bash
# 아래 명령을 수행하면 ArgoCD 서버의 Admin 암호를 설정하고 이를 AWS Secrets Manager에 동기화 저장합니다.
# AWS Secrets Manager에 동기화 저장된 암호는 어플리케이션의 배포 파이프라인에서 배포 단계에 사용됩니다.
cd ~/environment/legacy-application-modernization/cloud9
chmod +x *.sh

# Production 클러스터
kcp
ARGOCD_ADMIN_INITIAL_PASSWORD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGOCD_ADMIN_INITIAL_PASSWORD
./set-argocd-admin-password-argocd-server.sh $ARGOCD_ADMIN_INITIAL_PASSWORD "Abraca00#1"
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" hotelspecials-ci-argocd-admin-password
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" flightspecials-ci-argocd-admin-password
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" restdoc-openapi-ci-argocd-admin-password

# (Staging 환경을 사용하지 않을 경우 실행하지 않아도 됨) Staging 클러스터
kcs
ARGOCD_ADMIN_INITIAL_PASSWORD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGOCD_ADMIN_INITIAL_PASSWORD
./set-argocd-admin-password-argocd-server.sh $ARGOCD_ADMIN_INITIAL_PASSWORD "Abraca00#1"
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" hotelspecials-ci-argocd-admin-password-staging
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" flightspecials-ci-argocd-admin-password-staging
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" restdoc-openapi-ci-argocd-admin-password-staging

# Production 클러스터로 다시 전환
kcp
```

---

# 🎊🎊🎊 축하합니다! 아마존 EKS 클러스터를 성공적으로 프로비저닝하였습니다. 🎊🎊🎊

시간 여유가 있다면 진행자와 함께 테라폼 코드와 이를 통해 생성된 자원을 살펴봅니다.
