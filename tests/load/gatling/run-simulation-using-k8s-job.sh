#!/usr/bin/env bash
# pushd/popd, or subshell.
(
  # If the first argument is "rebuild", the script will rebuild the Docker image.
  # Otherwise, it will use the existing Docker image.
  rebuild=${1:-false}
  if [ "${rebuild}" == "true" ]; then
    echo "Rebuilding the Docker image..."
    chmod +x ./mvnw ./docker-entrypoint.sh
    ./mvnw clean package
    docker build -t gatling-java-http:latest .

    # 2. ECR 리포지터리에 업로드
    AWS_REGION=$(aws configure get region) && echo $AWS_REGION
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) && echo $AWS_ACCOUNT_ID
    docker login --username AWS -p $(aws ecr get-login-password --region ${AWS_REGION}) ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/gatling
    docker tag gatling-java-http:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/gatling:latest
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/gatling:latest
  fi

  cd deployment/k8s/helm || exit

  export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) && echo $AWS_ACCOUNT_ID
  cat chart/values-template.yaml | envsubst > chart/values.yaml

  make install

  # "gatling-java-http" Job의 상태가 "Completions"가 1이 될 때까지 기다린다.
  echo "Waiting for the Gatling job to complete with timeout..."
  kubectl wait --for=condition=complete --timeout=7200s job/gatling-java-http

  make uninstall
)
