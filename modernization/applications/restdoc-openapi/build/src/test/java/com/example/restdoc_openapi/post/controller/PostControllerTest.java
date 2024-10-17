package com.example.restdoc_openapi.post.controller;

import com.example.restdoc_openapi.docs.RestDocsTest;
import com.example.restdoc_openapi.post.request.PostCreateRequest;
import com.example.restdoc_openapi.post.request.PostUpdateRequest;
import com.example.restdoc_openapi.post.response.PostCreateResponse;
import com.example.restdoc_openapi.post.response.PostListReadResponse;
import com.example.restdoc_openapi.post.response.PostReadResponse;
import com.example.restdoc_openapi.post.service.PostService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.restdocs.payload.JsonFieldType;

import java.time.LocalDateTime;
import java.util.List;

import static com.epages.restdocs.apispec.MockMvcRestDocumentationWrapper.document;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.restdocs.headers.HeaderDocumentation.headerWithName;
import static org.springframework.restdocs.headers.HeaderDocumentation.requestHeaders;
import static org.springframework.restdocs.operation.preprocess.Preprocessors.*;
import static org.springframework.restdocs.payload.JsonFieldType.STRING;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class PostControllerTest extends RestDocsTest {

    private final PostService postService = mock(PostService.class);

    @Override
    protected Object initializeController() {
        return new PostController(postService);
    }

    @DisplayName("게시글 목록 조회 API")
    @Test
    void getPosts() throws Exception {

        // given
        given(postService.getPosts(any(), any(), any()))
                .willReturn(new PostListReadResponse(
                        1,
                        1,
                        10,
                        1L,
                        List.of(new PostListReadResponse.Post(
                                1L,
                                "title1",
                                "author1",
                                LocalDateTime.of(2023, 10, 9, 12, 0, 0)))));

        // when & then
        mockMvc.perform(RestDocumentationRequestBuilders.get("/posts")
                        .param("page", "0")
                        .param("size", "10")
                        .param("sort", "createdDate,desc"))
                .andDo(print())
                .andExpect(status().isOk())
                .andDo(document("get-posts",
                                preprocessRequest(prettyPrint()),
                                preprocessResponse(prettyPrint()),
                                queryParameters(
                                        parameterWithName("page")
                                                .description("페이지 번호"),
                                        parameterWithName("size")
                                                .description("페이지 당 데이터 개수"),
                                        parameterWithName("sort")
                                                .description("정렬 파라미터,오름차순 또는 내림차순: (예) createdDate,asc (작성일 오름차순) createdDate,desc (작성일 내림차순)")
                                ),
                                responseFields(
                                        fieldWithPath("code").type(JsonFieldType.NUMBER)
                                                .description("상태 코드"),
                                        fieldWithPath("message").type(JsonFieldType.STRING)
                                                .description("상태 메세지"),
                                        fieldWithPath("data.totalPages").type(JsonFieldType.NUMBER)
                                                .description("검색 페이지 수"),
                                        fieldWithPath("data.pageNumber").type(JsonFieldType.NUMBER)
                                                .description("현재 페이지 번호"),
                                        fieldWithPath("data.pageSize").type(JsonFieldType.NUMBER)
                                                .description("한 페이지의 데이터 개수"),
                                        fieldWithPath("data.totalElements").type(JsonFieldType.NUMBER)
                                                .description("검색 데이터 개수"),
                                        fieldWithPath("data.posts[]").type(JsonFieldType.ARRAY)
                                                .description("게시글 목록"),
                                        fieldWithPath("data.posts[].id").type(JsonFieldType.NUMBER)
                                                .description("게시글 ID"),
                                        fieldWithPath("data.posts[].title").type(JsonFieldType.STRING)
                                                .description("게시글 제목"),
                                        fieldWithPath("data.posts[].author").type(JsonFieldType.STRING)
                                                .description("게시글 작성자"),
                                        fieldWithPath("data.posts[].createdTime").type(JsonFieldType.STRING)
                                                .description("게시글 생성일")
                                )
                        )
                );
    }

    @DisplayName("게시글 조회 API")
    @Test
    void getPost() throws Exception {

        // given
        given(postService.getPost(any()))
                .willReturn(new PostReadResponse(
                        1L,
                        "title",
                        "content",
                        "author",
                        LocalDateTime.of(2023, 10, 9, 12, 0, 0)));

        // when & then
        mockMvc.perform(RestDocumentationRequestBuilders.get("/posts/{id}", 1L))
                .andDo(print())
                .andExpect(status().isOk())
                .andDo(document("get-post",
                        preprocessRequest(prettyPrint()),
                        preprocessResponse(prettyPrint()),
                        pathParameters(parameterWithName("id")
                                .description("게시글 ID")),
                        responseFields(
                                fieldWithPath("code").type(JsonFieldType.NUMBER)
                                        .description("상태 코드"),
                                fieldWithPath("message").type(JsonFieldType.STRING)
                                        .description("상태 메세지"),
                                fieldWithPath("data.id").type(JsonFieldType.NUMBER)
                                        .description("게시글 ID"),
                                fieldWithPath("data.title").type(JsonFieldType.STRING)
                                        .description("게시글 제목"),
                                fieldWithPath("data.content").type(JsonFieldType.STRING)
                                        .description("게시글 내용"),
                                fieldWithPath("data.author").type(JsonFieldType.STRING)
                                        .description("게시글 작성자"),
                                fieldWithPath("data.createdTime").type(JsonFieldType.STRING)
                                        .description("게시글 생성일"))));
    }

    @DisplayName("게시글 생성 API")
    @Test
    void createPost() throws Exception {

        // given
        PostCreateRequest request = new PostCreateRequest();
        request.setTitle("title");
        request.setContent("content");

        given(postService.createPost(any()))
                .willReturn(new PostCreateResponse(1L));

        // when & then
        mockMvc.perform(RestDocumentationRequestBuilders.post("/posts")
                        .header("Authorization", "Bearer {AccessToken}")
                        .content(objectMapper.writeValueAsString(request))
                        .contentType(APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andDo(document("create-posts",
                        preprocessRequest(prettyPrint()),
                        preprocessResponse(prettyPrint()),
                        requestHeaders(headerWithName("Authorization")
                                .description("AccessToken")
                        ),
                        requestFields(
                                fieldWithPath("title").type(STRING)
                                        .description("게시글 제목"),
                                fieldWithPath("content").type(STRING)
                                        .description("게시글 내용")
                        ),
                        responseFields(
                                fieldWithPath("code").type(JsonFieldType.NUMBER)
                                        .description("상태 코드"),
                                fieldWithPath("message").type(JsonFieldType.STRING)
                                        .description("상태 메세지"),
                                fieldWithPath("data.id").type(JsonFieldType.NUMBER)
                                        .description("생성된 게시글 ID"))));
    }

    @DisplayName("게시글 업데이트 API")
    @Test
    void updatePost() throws Exception {

        // given
        PostUpdateRequest request = new PostUpdateRequest();
        request.setTitle("title");
        request.setContent("content");

        // when & then
        mockMvc.perform(RestDocumentationRequestBuilders.put("/posts/{id}", 1L)
                        .header("Authorization", "Bearer {AccessToken}")
                        .content(objectMapper.writeValueAsString(request))
                        .contentType(APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andDo(document("update-posts",
                        preprocessRequest(prettyPrint()),
                        preprocessResponse(prettyPrint()),
                        pathParameters(parameterWithName("id")
                                .description("게시글 ID")),
                        requestHeaders(headerWithName("Authorization")
                                .description("AccessToken")
                        ),
                        requestFields(
                                fieldWithPath("title").type(STRING)
                                        .description("게시글 제목"),
                                fieldWithPath("content").type(STRING)
                                        .description("게시글 내용")
                        ),
                        responseFields(
                                fieldWithPath("code").type(JsonFieldType.NUMBER)
                                        .description("상태 코드"),
                                fieldWithPath("message").type(JsonFieldType.STRING)
                                        .description("상태 메세지"),
                                fieldWithPath("data").type(JsonFieldType.NULL)
                                        .description("리턴 데이터 없음"))));
    }

    @DisplayName("게시글 삭제 API")
    @Test
    void deletePost() throws Exception {

        // given

        // when & then
        mockMvc.perform(RestDocumentationRequestBuilders.delete("/posts/{id}", 1L)
                        .header("Authorization", "Bearer {AccessToken}"))
                .andDo(print())
                .andExpect(status().isOk())
                .andDo(document("delete-posts",
                        preprocessRequest(prettyPrint()),
                        preprocessResponse(prettyPrint()),
                        pathParameters(parameterWithName("id")
                                .description("게시글 ID")),
                        requestHeaders(headerWithName("Authorization")
                                .description("AccessToken")
                        ),
                        responseFields(
                                fieldWithPath("code").type(JsonFieldType.NUMBER)
                                        .description("상태 코드"),
                                fieldWithPath("message").type(JsonFieldType.STRING)
                                        .description("상태 메세지"),
                                fieldWithPath("data").type(JsonFieldType.NULL)
                                        .description("리턴 데이터 없음"))));
    }
}
