# `Jaeger`를 통한 분산 추적 (Distributed Tracing) 확인

`Jaeger`는 분산 추적 시스템으로, 애플리케이션의 성능을 모니터링하고 디버깅하는 데 사용됩니다. `Jaeger`는 OpenTracing API를 준수하며, 여러 언어로 작성된 애플리케이션에서 사용할 수 있습니다. `Jaeger`는 애플리케이션의 각 구성 요소 간의 상호 작용을 추적하고, 각 구성 요소의 성능을 측정하며, 각 구성 요소 간의 의존성을 시각화합니다.

`Jaeger`는 다음과 같은 주요 기능을 제공합니다:
* 분산 추적: 애플리케이션의 각 구성 요소 간의 상호 작용을 추적합니다.
* 성능 모니터링: 각 구성 요소의 성능을 측정합니다.
* 의존성 시각화: 각 구성 요소 간의 의존성을 시각화합니다.
* 루트 원인 분석: 애플리케이션의 성능 문제를 해결하는 데 도움이 됩니다.
* 통합: 여러 플랫폼과 프레임워크와 통합할 수 있습니다.
* 확장성: 대규모 분산 시스템에서 사용할 수 있습니다.
* 오픈 소스: 오픈 소스로 제공됩니다.
* 클라우드 네이티브: 클라우드 네이티브 환경에서 사용할 수 있습니다.

---

## 1. (Optional) `Jaeger` 설치 확인

`Jaeger`는 테라폼을 통해서 자원을 생성하면서 함께 생성/설치되었습니다.

아래 명령을 통해 `Jaeger` 설치에 사용된 테라폼 코드를 볼 수 있는데 진행자와 함께 살펴보도록 합니다.

```bash
c9 open ~/environment/legacy-application-modernization/infrastructure/terraform/modules/eks/eks-addons/observability/jaeger.tf
c9 open ~/environment/legacy-application-modernization/infrastructure/terraform/modules/eks/eks-addons/observability/jaeger-values.yaml
```

![Jaeger 생성 및 설치를 위한 테라폼 코드](../../images/Observability/Jaeger-Terraform-Code.png)

## 2. `Jaeger` 대시보드 확인

아래 순서로 `Jaeger` 대시보드에 접속할 수 있습니다.

```bash
# Jaeger 대시보드 URL 확인
echo "Jaeger 대시보드 URL: https://$(kubectl get ingress jaeger-query -n observability -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname')"
```

![Jaeger 대시보드 URL 확인](../../images/Observability/Jaeger-URL.png)
