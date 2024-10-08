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


