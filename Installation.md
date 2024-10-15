## 1. `AWS Cloud9` 환경 설치
```bash
export AWS_PAGER=''
curl -fsSL https://raw.githubusercontent.com/shkim4u/m2m-travelbuddy/main/cloud9/bootstrap-v2-with-admin-user-trust.sh | bash -s -- c5.9xlarge

# 기본 VPC 이외의 VPC를 사용하는 경우 아래 명령을 수행합니다.
# VPC ID를 적절하게 수정합니다.
# curl -fsSL https://raw.githubusercontent.com/shkim4u/m2m-travelbuddy/main/cloud9/bootstrap-v2-with-admin-user-trust.sh | bash -s -- c5.9xlarge vpc-02c4febfa59951834
```

## 2. `AWS Cloud9` 환경 설정
```bash
cd ~/environment/

export AWS_PAGER=''
# Cloud9 환경 설정
curl -fsSL https://raw.githubusercontent.com/shkim4u/m2m-travelbuddy/main/cloud9/cloud9.sh | bash

# Amazon Corretto Headless 17 설치
sudo yum install -y java-17-amazon-corretto-headless

# Docker 빌드를 위한 Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# JWT CLI 설치
sudo npm install -g jwt-cli
```

## 3. 프로젝트 소스 다운로드
```bash
cd ~/environment/
git clone https://github.com/shkim4u/samsung-fire-eks-evaluation
```

## 4. 자원 생성을 위한 환경 설정
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

## 5. `Terraform`을 이용한 자원 생성
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

```bash
cd ~/environment/samsung-fire-eks-evaluation/infrastructure/terraform

echo 'export KUBECONFIG=~/.kube/config:$(find ~/.kube/ -type f -name "*M2M-EksCluster*" | tr "\n" ":")' >> ~/.bash_profile 

echo 'alias kcp="kubectl config use-context $(kubectl config get-contexts -o name | grep Production | sort -r | head -n 1)"' >> ~/.bash_profile
echo 'alias kcs="kubectl config use-context $(kubectl config get-contexts -o name | grep Staging | sort -r | head -n 1)"' >> ~/.bash_profile
echo 'alias kcc="kubectl config current-context"' >> ~/.bash_profile

# Terraform helper aliases.
echo 'alias ti="terraform init"' >> ~/.bash_profile
echo 'alias taa="terraform apply -auto-approve"' >> ~/.bash_profile

source ~/.bash_profile
```

```bash
# 아래 명령을 수행하면 ArgoCD 서버의 Admin 암호를 설정하고 이를 AWS Secrets Manager에 동기화 저장합니다.
# AWS Secrets Manager에 동기화 저장된 암호는 어플리케이션의 배포 파이프라인에서 배포 단계에 사용됩니다.
cd ~/environment/samsung-fire-eks-evaluation/cloud9
chmod +x *.sh

# Production 클러스터
kcp
ARGOCD_ADMIN_INITIAL_PASSWORD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGOCD_ADMIN_INITIAL_PASSWORD
./set-argocd-admin-password-argocd-server.sh $ARGOCD_ADMIN_INITIAL_PASSWORD "Abraca00#1"
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" hotelspecials-ci-argocd-admin-password
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" flightspecials-ci-argocd-admin-password
./set-argocd-admin-password-secrets-manager.sh "Abraca00#1" restdoc-openapi-ci-argocd-admin-password
```

## 6. (RDS Bastion) MySQL 설정
1. `RDS-Bastion` 인스턴스에 접속
```bash
export RDS_BASTION_INSTANCE_ID=`aws ec2 describe-instances --filters "Name=tag:Name,Values=RDS-Bastion" --query 'Reservations[*].Instances[*].[InstanceId]' --output text` && echo $RDS_BASTION_INSTANCE_ID
aws ssm start-session --target $RDS_BASTION_INSTANCE_ID
```

2. MySQL 설치
```bash
bash
sudo yum update -y
sudo yum -y install mysql
sudo yum install -y jq
```

3. MySQL 접속
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output=text) && echo $AWS_ACCOUNT_ID
export AWS_DEFAULT_REGION=ap-northeast-2
export DATABASE_SECRETS=$(aws secretsmanager list-secrets --filters Key=tag-value,Values="arn:aws:rds:ap-northeast-2:${AWS_ACCOUNT_ID}:cluster:m2m-general-aurora-mysql" --query "SecretList[0].Name" --output text) && echo $DATABASE_SECRETS
export DATABASE_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $DATABASE_SECRETS --query SecretString --output text) && echo $DATABASE_CREDENTIALS
export DATABASE_USERNAME=$(echo $DATABASE_CREDENTIALS | jq -r '.username') && echo $DATABASE_USERNAME
export DATABASE_PASSWORD=$(echo $DATABASE_CREDENTIALS | jq -r '.password') && echo $DATABASE_PASSWORD
mysql -u ${DATABASE_USERNAME} --password="${DATABASE_PASSWORD}" -h `aws rds describe-db-clusters --db-cluster-identifier m2m-general-aurora-mysql --query "DBClusters[0].Endpoint" --output text`
```

4. MySQL 데이터베이스 생성
```sql
-- Database 생성
CREATE DATABASE travelbuddy;

-- 확인
SHOW DATABASES;
```

5. MySQL 데이터베이스 초기화
```sql
USE travelbuddy;

DROP TABLE IF EXISTS `flightspecial`;
CREATE TABLE `flightspecial` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
`header` varchar(255) NOT NULL DEFAULT '',
`body` varchar(255) DEFAULT NULL,
`origin` varchar(255) DEFAULT NULL,
`originCode` varchar(6) DEFAULT NULL,
`destination` varchar(255) DEFAULT NULL,
`destinationCode` varchar(6) DEFAULT NULL,
`cost` int(11) NOT NULL,
`expiryDate` bigint(16) NOT NULL,
PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT
CHARSET=utf8;

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 200),
'London to Prague',
'Jewel of the East',
'London',
'LHR',
'Paris',
'CDG');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 200),
'Paris to London',
'Weekend getaway!',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 200),
'Dubai to Cairo',
'Middle East adventure',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'Melbourne to Hawaii',
'Escape to the sun this winter',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 200),
'Buenos Aires to Rio',
'Time to carnivale!',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'Sydney to Rome',
'An Italian classic',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'Melbourne to Sydney',
'Well trodden path',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'Hong Kong to Kuala Lumpur',
'Hop step and a jump',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'Lisbon to Madrid',
'Spanish adventure',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'Aswan to Cairo',
'An experience of a lifetime',
'Origin',
'ORG',
'Destination',
'DST');

INSERT INTO `flightspecial` (`expiryDate`, `cost`, `header`, `body`, `origin`, `originCode`, `destination`, `destinationCode`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 500),
'New York to London',
'Trans-Atlantic',
'Origin',
'ORG',
'Destination',
'DST');

#--------------------------------------------------------------------------------------------------------------------- #--------------------------------------------------------------------------------------------------------------------- #--------------------------------------------------------------------------------------------------------------------- #--------------------------------------------------------------------------------------------------------------------- #---------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS `hotelspecial`;
CREATE TABLE `hotelspecial` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `hotel` varchar(255) NOT NULL DEFAULT '',
    `description` varchar(255) DEFAULT NULL,
    `location` varchar(255) DEFAULT NULL,
    `cost` int(11) NOT NULL,
    `expiryDate` bigint(16) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT
CHARSET=utf8;

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Sommerset Hotel',
'Minimum stay 3 nights',
'Sydney');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Freedmom Apartments',
'Pets allowed!',
'Sydney');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Studio City',
'Minimum stay one week',
'Los Angeles');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Le Fleur Hotel',
'Not available weekends',
'Los Angeles');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Classic Hotel',
'Includes breakfast',
'Dallas');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Groundhog Suites',
'Internet access included',
'Florida');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Sophmore Suites',
'Maximum 2 people per room',
'London');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Hotel Sandra',
'Minimum stay two nights',
'Cairo');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Apartamentos de Nestor',
'Pool and spa access included',
'Madrid');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'Kangaroo Hotel',
'Maximum 2 people per room',
'Manchester');

INSERT INTO `hotelspecial` (`expiryDate`, `cost`, `hotel`, `description`, `location`)
VALUES (
(SELECT (UNIX_TIMESTAMP() * 1000)) + 79200 + (RAND() * 20000000), (50 + RAND() * 1000),
'EasyStay Apartments',
'Minimum stay one week',
'Melbourne');
```

6. MySQL 데이터베이스 조회
```sql
-- Hotel Special 테이블 확인
SELECT * FROM hotelspecial;

-- Flight Special 테이블 확인
SELECT * FROM flightspecial;
```

7. MySQL 데이터베이스 종료
```sql
quit;
```
8. `RDS-Basion` SSM 세션 종료
```bash
# Bash 쉘 종료
exit
# Shell 종료
exit
```

## 7. `TravelBuddy` `GitOps` 리포지터리 (`Helm`) 설정
```bash
cd ~/environment/samsung-fire-eks-evaluation
rm -rf .git

# 1. 어플리케이션 Helm Artifact 경로로 이동
cd ~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/helm

# 2. git 연결
git init
git branch -M main

export HELM_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name hotelspecials-configuration --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*' | grep -o '[^"]*$')
echo $HELM_CODECOMMIT_URL

# CodeCommit 배포 리포지터리와 연결
git remote add origin $HELM_CODECOMMIT_URL

# 3. Git 스테이징 영역에 파일을 추가합니다.
git add .

# 4. Commit 및 배포 리포지터리에 Push합니다.
git commit -am "First commit."
git push --set-upstream origin main
```

## 8. `GitOps` 배포 설정 (`ArgoCD`)
1. `ArgoCD` 접속 주소 확인
```bash
# ArgoCD 접속 주소 확인
kcp
export ARGOCD_SERVER=`kubectl get ingress/argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo https://$ARGOCD_SERVER
```

2. `ArgoCD` Helm 리포지터리 사용자 생성
```bash
# IAM User 생성
aws iam create-user --user-name argocd 

# AWSCodeCommitPowerUser 관리형 권한 정책 연결 (arn:aws:iam::aws:policy/AWSCodeCommitPowerUser)
aws iam attach-user-policy --user-name argocd --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitPowerUser

# CodeCommit 접근을 위한 Specific Credential 생성
# (중요) 결과로서 반환되는 "ServiceUserName"과 "ServicePassword"를 기록해 둡니다.
aws iam create-service-specific-credential --user-name argocd --service-name codecommit.amazonaws.com
```

3. `ArgoCD` Helm 리포지터리 URL 확인
```bash
export HELM_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name hotelspecials-configuration --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*'|grep -o '[^"]*$')
echo $HELM_CODECOMMIT_URL
```

4. `ArgoCD` Helm 리포지터리 연결

5. `ArgoCD` Application 생성 (이름으로 `hotelspecials` 사용)

    * Application Name: `hotelspecials`
    * Project: `default`
    * Sync Policy: Manual
    * Repository URL: 앞서 설정한 배포 리포지터리
    * PATH: `.`
    * Destination 섹션 > Cluster URL: https://kubernetes.default.svc
    * Destination 섹션 > Namespace: `hotelspecials`를 입력하고 상단의 Create를 클릭합니다.

6`ArgoCD` Application 생성 (이름으로 `insurance-plannning` 사용)

    * Application Name: `insurance-planning`
    * Project: `default`
    * Sync Policy: Manual
    * Repository URL: 앞서 설정한 배포 리포지터리
    * PATH: `.`
    * Destination 섹션 > Cluster URL: https://kubernetes.default.svc
    * Destination 섹션 > Namespace: `insurance`를 입력하고 상단의 Create를 클릭합니다.

## 9. `eks-node-viewer` 설치

https://github.com/awslabs/eks-node-viewer

```bash
go install github.com/awslabs/eks-node-viewer/cmd/eks-node-viewer@latest
# ~/go/bin/eks-node-viewer -resources cpu,memory
#~/go/bin/eks-node-viewer -resources cpu,memory -node-sort=eks-node-viewer/node-memory-usage=asc
~/go/bin/eks-node-viewer -resources cpu,memory -node-selector=purpose -node-sort=eks-node-viewer/node-memory-usage=asc --extra-labels topology.kubernetes.io/zone,karpenter.sh/nodepool
```

## 10. Karpenter가 Spot 인스턴스 생성 시 `spot.amazonaws.com`가 사용하는 `Service-Linked Role` 생성

```bash
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

## 11. `HotelSpecials` 서비스 빌드

1. (Optional) `servlet-context.xml` 파일 수정

```bash
cd ~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/build
c9 open src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml
```

  * 40번째 줄 근처에 주석처리된 MySQL 드라이버 사용 구문을 주석 해제합니다. (사용)
  * 그 다음 줄에 Oracle 드라이버 사용 구문을 주석 처리합니다. (미사용)
  * 50번째 줄의 select 1 from dual 쿼리를 select 1로 변경합니다. 
  * 66, 67번째 줄 주석 처리 각각 스위치: MySQL Dialect 주석 해제, Hibernate의 Oracle Dialect 주석 처리.

2. 빌드

```bash
# 1. 어플리케이션 소스 경로로 이동
cd ~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/build/

# 2. git 연결
git init
git branch -M main

export BUILD_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name hotelspecials-application --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*'|grep -o '[^"]*$')
echo $BUILD_CODECOMMIT_URL

git remote add origin $BUILD_CODECOMMIT_URL
# (예)
# git remote add origin https://git-codecommit.ap-northeast-2.amazonaws.com/v1/repos/M2M-BuildAndDeliveryStack-SourceRepository

# 3. Git 스테이징 영역에 파일을 추가합니다.
git add .

# 4. Commit 및 Push합니다.
git commit -am "First commit."
git push --set-upstream origin main
```

## 12. (Test) `Pod` 리플리카 수 조정 (`HPA`와 `Keda`)
### 12.1. `HPA`
1. `HPA`의 `minReplicas` 수를 `12`로 늘리면 `x2idn.16xlarge` 인스턴스가 `Karpenter`에 의해 생성되어 `Pod`가 스케쥴링 되는 것을 확인합니다.

    ```bash
    kubectl patch hpa hotelspecials -n hotelspecials --type='merge' -p '{"spec": {"minReplicas": 12}}'
    ```

2. 다시 `HPA`의 `minReplicas`와 `maxReplicas` 수를 `6`으로 줄이면 잠시 후 `x2idn.16xlarge` 인스턴스가 `Karpenter`에 의해 회수 (`Consolidation`)되어 노드가 삭제되며 비용을 줄일 수 있음을 확인합니다.

    ```bash
    kubectl patch hpa hotelspecials -n hotelspecials --type='merge' -p '{"spec": {"minReplicas": 6}}'
    kubectl patch hpa hotelspecials -n hotelspecials --type='merge' -p '{"spec": {"maxReplicas": 6}}'
    ```

### 12.2. `Keda`

1. `Keda`의 `minReplicaCount` 수를 `12`로 늘리면 `x2idn.16xlarge` 인스턴스가 `Karpenter`에 의해 생성되어 `Pod`가 스케쥴링 되는 것을 확인합니다.

   * (참고) Cron 트리거에 의한 확장 영역 실행 시에는 기본 Quota 내에서 스케일 아웃되므로 아래를 실행할 필요가 없습니다. 

   ```bash
   kubectl patch scaledobjects hotelspecials -n hotelspecials --type='merge' -p '{"spec": {"minReplicaCount": 18}}'
   kubectl patch scaledobjects hotelspecials -n hotelspecials --type='merge' -p '{"spec": {"maxReplicaCount": 18}}'
   ```

2. 다시 `HPA`의 `minReplicas` 수를 `6`으로 원복하면 잠시 후 `x2idn.16xlarge` 인스턴스가 `Karpenter`에 의해 회수 (`Consolidation`)되어 노드가 삭제되며 비용을 줄일 수 있음을 확인합니다.

   ```bash
   kubectl patch scaledobjects hotelspecials -n hotelspecials --type='merge' -p '{"spec": {"minReplicaCount": 6}}'
   ```

3. (Optional) `Keda ScaledObject`의 `Replica`수를 0으로 하려면 `Keda.yaml` 파일에서 다음을 설정 (주석 처리) 하면 됩니다.

    ```yaml
    metadata:
      name: {{ .Values.app.name }}
      namespace: {{ .Values.namespace.name }}
    # {{- if .Values.hpa.enabled }}
    # annotations:
    #   scaledobject.keda.sh/transfer-hpa-ownership: "true"
    # {{- end }}
    # (IMPORTANT): Uncomment the following when you need to scale-in the pods to 0 for moeney saving.
      annotations:
        autoscaling.keda.sh/paused-replicas: "0"
        autoscaling.keda.sh/paused: "true"
    ```

    혹은 아래와 같이 명령어를 입력합니다.

    ```bash
   kubectl annotate scaledobject hotelspecials -n hotelspecials autoscaling.keda.sh/paused-replicas="0" autoscaling.keda.sh/paused="false" --overwrite
    ```

    또한 원복 (해당 Annotations 제거)하는 명령어는 아래와 같습니다.

    ```bash
   kubectl annotate scaledobject hotelspecials -n hotelspecials autoscaling.keda.sh/paused-replicas- autoscaling.keda.sh/paused-
    ```

## 13. `Grafana` 대시보드 확인

1. `Grafana` 대시보드 URL 확인

```bash
GRAFANA_SERVER=`kubectl get ingress/grafana -n grafana -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo "GRAFANA_SERVER: https://${GRAFANA_SERVER}"
```

2. `Grafana` 로그인

   * `Username`
     * `admin`
   * `Password`
     * `P@$$w0rd00#1`

3. 필요한 대시보드 임포트

    * 자바 애플리케이션 힙 메모리 대시보드
      * `~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/observability/grafana/(Large Memory Java) JVM Metrics.json`
    * `Karpenter` 용량 대시보드
      * `~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/observability/grafana/Karpenter Capacity v1 and JVM Memory Pool Bytes Committed.json`
    * `Karpenter Controllers` 대시보드
      * `~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/observability/grafana/karpenter-controllers.json`
    * `Karpenter Performance` 대시보드
      * `~/environment/samsung-fire-eks-evaluation/legacy/applications/TravelBuddy/observability/grafana/karpenter-performance-dashboard.json`

## 14. 부하 테스트
### 14.1. `Hey` 사용
1. 부하 생성 (`Hey` 사용)
   * (참고) `Hey` GitHub URL
     * https://github.com/William-Yeh/docker-hey.git
   * 아래 명령은 다음과 같은 형태의 부하를 생성합니다.
     * 동시 사용자 1000
     * 초당 20번 요청
     * 10분간 실행

     ```bash
     export ALB_HOSTNAME=$(kubectl get ingress hotelspecials-ingress -n hotelspecials -o yaml | yq '.status.loadBalancer.ingress[0].hostname') && echo $ALB_HOSTNAME
     ```

     ```bash
     kubectl run load-generator --image=williamyeh/hey:latest --restart=Never -- -c 1000 -q 20 -z 10m http://$ALB_HOSTNAME/travelbuddy/hotelspecials
     ```

     ```bash
     chmod +x ~/environment/samsung-fire-eks-evaluation/check-load-generator.sh
     ```

     ```bash
     ~/environment/samsung-fire-eks-evaluation/check-load-generator.sh
     ``` 

2. `Keda`에 의해 생성된 `HPA` 모니터링
   * `CPU` 상태만 보기 (`hotelspecials` 네임스페이스 사용)

      ```bash
      kubectl get hpa keda-hpa-hotelspecials -n hotelspecials --watch -o custom-columns="NAME:.metadata.name,CPU TARGET:.spec.metrics[?(@.resource.name=='cpu')].resource.target.averageUtilization,CPU CURRENT:.status.currentMetrics[?(@.resource.name=='cpu')].resource.current.averageUtilization"
      ```

   * `CPU` 상태만 보기 (`insurance` 네임스페이스 사용)

      ```bash
      kubectl get hpa keda-hpa-insurance-planning -n insurance --watch -o custom-columns="NAME:.metadata.name,CPU TARGET:.spec.metrics[?(@.resource.name=='cpu')].resource.target.averageUtilization,CPU CURRENT:.status.currentMetrics[?(@.resource.name=='cpu')].resource.current.averageUtilization"
      ```

   * Cron 트리거를 포함한 전체 보기
 
      ```bash
      kubectl get hpa keda-hpa-hotelspecials -n hotelspecials --watch
      ```

3. 테스트가 끝나면 Pod 삭제

   ```bash
   kubectl delete pod load-generator
   ```

4. (참고) `Keda`의 `ScaledObject`의 Replica를 0으로 설정하기
* https://github.com/kedacore/keda/issues/5570

### 14.2. `sress-ng` 유틸리티 사용

이번에는 파드에 직접 접속하여 `stress-ng` 유틸리티를 통해 부하를 생성해 보겠습니다.

1. 파드를 순회하면서 `stress-ng` 유틸리티를 설치하고 실행 (`insurance` 네임스페이스 사용)

```bash
# 매개변수 설정
APP_NAME="insurance-planning"
NAMESPACE="insurance"

echo "Applying stress to pods with app.kubernetes.io/name=$APP_NAME in namespace $NAMESPACE"

# Pod 목록 가져오기
PODS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$APP_NAME -o jsonpath='{.items[*].metadata.name}')

# Pod가 없는 경우 처리
if [ -z "$PODS" ]; then
    echo "No pods found with app.kubernetes.io/name=$APP_NAME in namespace $NAMESPACE"
    exit 1
fi

# 백그라운드 작업을 추적하기 위한 배열
#declare -a pids

# 각 Pod에 대해 루프 실행
echo "$PODS" | tr ' ' '\n' | while read -r POD; do
    echo "Processing Pod: $POD"
    
    # Pod에 명령어 실행 (백그라운드에서)
    kubectl exec $POD -n $NAMESPACE -- /bin/bash -c '
        apt-get update && apt-get install -y stress-ng &&
        nohup stress-ng --cpu 10 --cpu-load 40 --timeout 5m > /dev/null 2>&1 &
    ' &
    
    # 백그라운드 프로세스의 PID 저장
#    pids+=($!)
    
    echo "Started processing Pod: $POD"
done

# 모든 백그라운드 작업이 완료될 때까지 대기
#for pid in "${pids[@]}"; do
#    wait $pid
#done

echo "All Pods processed."
```

## 15. (Test) `Pod` 리플리카 수 조정 (`Deployment`)

```bash
kubectl scale deployment hotelspecials --replicas=6 -n hotelspecials
```

## 16. `FlightSpecials` `GitOps` 리포지터리 (`Helm`) 설정
```bash
# 1. 어플리케이션 Helm Artifact 경로로 이동
cd ~/environment/aws-database-migration/modernization/applications/FlightSpecials/helm

# 2. git 연결
git init
git branch -M main

export HELM_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name flightspecials-configuration --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*' | grep -o '[^"]*$')
echo $HELM_CODECOMMIT_URL

# CodeCommit 배포 리포지터리와 연결
git remote add origin $HELM_CODECOMMIT_URL

# 3. Git 스테이징 영역에 파일을 추가합니다.
git add .

# 4. Commit 및 배포 리포지터리에 Push합니다.
git commit -am "First commit."
git push --set-upstream origin main
```

## 99. (기타) `JVM Heap` 메모리 상태 추척
1. `Grafana` Metrics 설정
`jvm_memory_bytes_used{instance="hotelspecials-service.hotelspecials.svc.cluster.local:9404",job="hotelspecials-jmx"}`

   * Grafana Dashboard: [](./legacy/applications/TravelBuddy/observability/(Large) JVM Memory Usage.json)

2. `Karpenter` Dashboad

   * [Cluster Capacity](https://grafana.com/grafana/dashboards/16237-cluster-capacity/): `16237`
     * Not working
   * [Pod Statistics](https://grafana.com/grafana/dashboards/16236-pod-statistic/): `16236`
     * Not working
   * [Karpenter](https://grafana.com/grafana/dashboards/18862-karpenter/): `18862`
     * Partly working
   * [Karpenter](https://grafana.com/grafana/dashboards/20398-karpenter/): `20398`
     * Not working
   * https://grafana.com/grafana/dashboards/10257-kubernetes-horizontal-pod-autoscaler/
   * https://grafana.com/grafana/dashboards/16698-pods-improved/
   * https://grafana.com/grafana/dashboards/7249-kubernetes-cluster/
   * https://grafana.com/grafana/dashboards/13125-kubernetes-capacity-planning-limits/
   * https://grafana.com/grafana/dashboards/8685-k8s-cluster-summary/
   * https://grafana.com/grafana/dashboards/741-deployment-metrics/
   * Kubernetes / Views / Pods
     * https://grafana.com/grafana/dashboards/15760-kubernetes-views-pods/
   * Kubernetes Dashboards
     * https://github.com/dotdc/grafana-dashboards-kubernetes
     * k8s-addons-prometheus.json: `19105` 
     * k8s-addons-trivy-operator.json: `16337` 
     * k8s-system-api-server.json: `15761`
     * k8s-system-coredns.json: `15762` 
     * k8s-views-global.json: `15757` 
     * k8s-views-namespaces.json: `15758` 
     * k8s-views-nodes.json: `15759` 
     * k8s-views-pods.json: `15760`

https://chatgpt.com/share/66e6f3fa-191c-800c-93ba-0b0f0fc35bf6

https://velog.io/@cks8483/Kubernetes-%ED%99%98%EA%B2%BD%EC%97%90%EC%84%9C-JVM-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0


