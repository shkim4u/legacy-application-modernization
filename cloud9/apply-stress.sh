#!/bin/bash

# 매개변수 확인
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <app_name> <namespace>"
    exit 1
fi

# 매개변수 설정
APP_NAME="$1"
NAMESPACE="$2"

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
