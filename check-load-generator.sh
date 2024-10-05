#!/bin/bash

# Pod 이름 설정
POD_NAME="load-generator"

# 상태 확인 함수
check_pod_status() {
    kubectl get pod $POD_NAME -o jsonpath='{.status.phase}'
}

# Pod가 완료될 때까지 루프
while true; do
    STATUS=$(check_pod_status)

    if [ "$STATUS" = "Succeeded" ]; then
        echo "Pod $POD_NAME has completed successfully."
        break
    elif [ "$STATUS" = "Failed" ]; then
        echo "Pod $POD_NAME has failed."
        break
    elif [ -z "$STATUS" ]; then
        echo "Pod $POD_NAME not found. It may have been deleted."
        break
    else
        echo "Pod $POD_NAME is still running. Current status: $STATUS"
    fi

    # 5초 대기
    sleep 5
done

# Pod 삭제
if [ "$STATUS" = "Succeeded" ] || [ "$STATUS" = "Failed" ]; then
    echo "Deleting pod $POD_NAME"
    kubectl delete pod $POD_NAME
else
    echo "Pod $POD_NAME was not found or is in an unexpected state. Skipping deletion."
fi
