/**
 * References
 * - https://github.com/hjacobs/kube-ops-view/blob/master/docs/user-guide.rst
 * - https://archive.eksworkshop.com/beginner/080_scaling/install_kube_ops_view/
 * - https://codeberg.org/hjacobs/kube-ops-view
 * - DO NOT USE THIS, EXCEPT FOR REFERENCE:
 *    ~ https://catalog.us-east-1.prod.workshops.aws/workshops/9c0aa9ab-90a9-44a6-abe1-8dff360ae428/ko-KR/100-scaling/300-kube-ops-view
 * - USE THIS TO INSTALL WITH HELM
 *    ~ https://artifacthub.io/packages/helm/christianknell/kube-ops-view
 *
 * (Use This -> Not Working!) Commands to install:
helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
helm install kube-ops-view christianknell/kube-ops-view

* (Updated!) [2024-09-19]
* Refer to: https://codeberg.org/hjacobs/kube-ops-view
* Or

* (Now Use This) https://base-on.tistory.com/528
helm repo add geek-cookbook https://geek-cookbook.github.io/charts/
helm install kube-ops-view geek-cookbook/kube-ops-view --version 1.2.2 --set env.TZ="Asia/Seoul" --namespace kube-system

 *
 * View Kube Ops View
 * - http://localhost:8080/#scale=3
 */
