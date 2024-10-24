## 클라우드 빌드 및 배포
1. `Helm` 설정
```bash
cd ~/environment/legacy-application-modernization
rm -rf .git || true

# 1. 어플리케이션 Helm Artifact 경로로 이동
cd ~/environment/legacy-application-modernization/modernization/applications/restdoc-openapi/helm

# 2. git 연결
git init
git branch -M main

export HELM_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name restdoc-openapi-configuration --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*' | grep -o '[^"]*$')
echo $HELM_CODECOMMIT_URL

# CodeCommit 배포 리포지터리와 연결
git remote add origin $HELM_CODECOMMIT_URL

# 3. Git 스테이징 영역에 파일을 추가합니다.
git add .

# 4. Commit 및 배포 리포지터리에 Push합니다.
git commit -am "First commit."
git push --set-upstream origin main
```

2. `ArgoCD` 접속 주소 확인
```bash
# ArgoCD 접속 주소 확인
export ARGOCD_SERVER=`kubectl get ingress/argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo https://$ARGOCD_SERVER
```

3. (Optional) `ArgoCD` Helm 리포지터리 사용자 생성
```bash
# IAM User 생성
aws iam create-user --user-name argocd 

# AWSCodeCommitPowerUser 관리형 권한 정책 연결 (arn:aws:iam::aws:policy/AWSCodeCommitPowerUser)
aws iam attach-user-policy --user-name argocd --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitPowerUser

# CodeCommit 접근을 위한 Specific Credential 생성
# (중요) 결과로서 반환되는 "ServiceUserName"과 "ServicePassword"를 기록해 둡니다.
aws iam create-service-specific-credential --user-name argocd --service-name codecommit.amazonaws.com
```

4. `ArgoCD` Helm 리포지터리 URL 확인
```bash
export HELM_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name restdoc-openapi-configuration --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*'|grep -o '[^"]*$')
echo $HELM_CODECOMMIT_URL
```

5. `ArgoCD` Helm 리포지터리 연결

6. `ArgoCD` Application 생성

    * Application Name: `restdoc-openapi`
    * Project: `default`
    * Sync Policy: Manual
    * Repository URL: 앞서 설정한 배포 리포지터리
    * PATH: `.`
    * Destination 섹션 > Cluster URL: https://kubernetes.default.svc
    * Destination 섹션 > Namespace: `restdoc-openapi`를 입력하고 상단의 Create를 클릭합니다.

7. 소스 리포지터리 커밋 및 빌드 파이프라인 실행
```bash
# 1. 어플리케이션 소스 경로로 이동
cd ~/environment/legacy-application-modernization/modernization/applications/restdoc-openapi/build/

# 2. git 연결
git init
git branch -M main

export BUILD_CODECOMMIT_URL=$(aws codecommit get-repository --repository-name restdoc-openapi-application --region ap-northeast-2 | grep -o '"cloneUrlHttp": "[^"]*'|grep -o '[^"]*$')
echo $BUILD_CODECOMMIT_URL

git remote add origin $BUILD_CODECOMMIT_URL

# 3. Git 스테이징 영역에 파일을 추가합니다.
git add .

# 4. Commit 및 Push합니다.
git commit -am "First commit."
git push --set-upstream origin main
```

## 로컬 빌드

1. 소스 빌드
```bash
./gradlew clean copyOasToSwagger
./gradlew bootJar --build-cache -x test
```

2. 컨테이너 이미지 빌드
```bash
docker build -t restdoc-openapi .
```

3. 컨테이너 실행
```bash
docker run --rm -p 8080:8080 -t restdoc-openapi:latest
```

4. `Swagger UI` 접근

http://localhost:8080/swagger-ui/swagger-ui.html

5. `OAS` 파일 로딩

http://localhost:8080/openapi3.json


