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
```

## MySQL 설정
```bash
bash
sudo yum update -y
sudo yum -y install mysql
sudo yum install -y jq
```
## MySQL 접속 (RDS Bastion)
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output=text) && echo $AWS_ACCOUNT_ID
export AWS_DEFAULT_REGION=ap-northeast-2
export DATABASE_SECRETS=$(aws secretsmanager list-secrets --filters Key=tag-value,Values="arn:aws:rds:ap-northeast-2:${AWS_ACCOUNT_ID}:cluster:m2m-general-aurora-mysql" --query "SecretList[0].Name" --output text) && echo $DATABASE_SECRETS
export DATABASE_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $DATABASE_SECRETS --query SecretString --output text) && echo $DATABASE_CREDENTIALS
export DATABASE_USERNAME=$(echo $DATABASE_CREDENTIALS | jq -r '.username') && echo $DATABASE_USERNAME
export DATABASE_PASSWORD=$(echo $DATABASE_CREDENTIALS | jq -r '.password') && echo $DATABASE_PASSWORD
mysql -u ${DATABASE_USERNAME} --password="${DATABASE_PASSWORD}" -h `aws rds describe-db-clusters --db-cluster-identifier m2m-general-aurora-mysql --query "DBClusters[0].Endpoint" --output text`
```

## MySQL 데이터베이스 생성
```sql
-- Database 생성
CREATE DATABASE travelbuddy;

-- 확인
SHOW DATABASES;
```

## MySQL 데이터베이스 초기화
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

## MySQL 데이터베이스 조회
```sql
-- Hotel Special 테이블 확인
SELECT * FROM hotelspecial;

-- Flight Special 테이블 확인
SELECT * FROM flightspecial;
```

## MySQL 데이터베이스 종료
```sql
quit;
```

## `TravelBuddy` `GitOps` 리포지터리 (`Helm`) 설정
```bash
cd ~/environment/aws-database-migration
rm -rf .git

# 1. 어플리케이션 Helm Artifact 경로로 이동
cd ~/environment/aws-database-migration/legacy/applications/TravelBuddy/helm

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
