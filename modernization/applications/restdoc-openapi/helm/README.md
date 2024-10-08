# restdoc-openapi Helm Chart

이 파일은 `restdoc-openapi` 애플리케이션의 Helm Chart 리소스를 담고 있습니다.
`restdoc-openapi` 애플리케이션은 API 문서화의 대표적인 솔루션인 `Spring RestDoc`과 `OpenAPI (Swagger)`가 각각 가지는 장점을 결합하는 방법을 보여주는 샘플로서 작성되었습니다.

* `Spring RestDoc`
  * 테스트를 통과한 API 명세만 문서화에 포함시킴으로서 테스트 코드 작성을 명문화
  * 프로덕션 코드에 문서화를 위한 Annotation이 섞이지 않음
  * 하지만 문서에서 테스트 호출 불가능
* `OpenAPI`
  * 미려한 문서
  * 문서에서 테스트 호출 가능
  * 하지만 `Swagger` Annotation이 프로덕션 코드에 포함됨
