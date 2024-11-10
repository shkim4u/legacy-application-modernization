# `Istio Service Mesh` 맛보기

`Istio`는 서비스 메시를 구축하고 관리하기 위한 오픈 소스 플랫폼입니다. `Istio`는 서비스 간 통신을 보호하고 제어하며, 서비스 간 통신의 가시성을 제공합니다.

`Istio`의 주요 기능은 다음과 같습니다.

1. **트래픽 관리(Traffic Management)**: `Istio`는 서비스 간의 트래픽을 세밀하게 제어할 수 있게 해줍니다. 이를 통해, 요청을 특정 서비스로 라우팅하거나, 트래픽을 분할하는 등의 작업을 수행할 수 있습니다.

2. **보안(Security)**: `Istio`는 서비스 간 통신을 자동으로 암호화하고, 강력한 인증 및 인가 정책을 적용하여 서비스 간의 보안을 강화합니다.

3. **관찰성(Observability)**: `Istio`는 서비스 간의 트래픽에 대한 자세한 메트릭, 로그, 추적 정보를 제공하여 시스템의 동작 상태를 실시간으로 파악할 수 있게 해줍니다.

4. **서비스 간의 연결(Service Mesh)**: `Istio`는 서비스 메시를 구축하여 마이크로서비스 간의 연결을 관리하고, 복잡한 통신을 단순화하고, 서비스 간의 종속성을 최소화합니다.

이번 워크샵에서는 시간 관계 상 `Istio`의 주요 기능을 두루 살펴보지는 못하겠지만, `Istio`가 어떻게 서비스 메시를 구축하고 관리하는지에 대한 기초적인 이해를 돕는 내용은 다루고자 합니다.

## 1. `Istio` 서비스 메시란?
진행자가 제공한 아래 링크를 참고하여 `Istio` 서비스 메시에 대한 개념을 이해합니다.

[[Istio 서비스 메시 소개]](Istio%20Service%20Mesh%20Introduction.pdf)

## 2. `Istio` 동작 둘러 보기
진행자의 안내에 따라 `Smoke Test`를 수행하고, `Istio`가 어떻게 서비스 간의 통신을 제어하고 관찰하는지 살펴봅니다.

1. `Smoke Test` 수행<br>
```bash
cd ~/environment/eks-workshop

# Smoke Test 수행
make test-all ENV=prod
```

![Smoke Test 결과](./assets/smoke-test-okay.png)

2. `Kiali`를 사용하여 `Istio` 메시를 관찰합니다.<br>
```bash
cd ~/environment/eks-workshop

# Kiali 로그인 토큰 얻기
make get-kiali-login-token

# Kiali 대시보드 URL 얻기
KIALI_SERVER=`kubectl get ingress/kiali -n istio-system -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo "KIALI_SERVER: ${KIALI_SERVER}"

# Kiali 대시보드 접속
echo "Kiali 대시보드 URL: http://${KIALI_SERVER}/kiali"
```
