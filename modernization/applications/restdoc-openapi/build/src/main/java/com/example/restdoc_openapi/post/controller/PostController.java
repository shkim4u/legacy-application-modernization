package com.example.restdoc_openapi.post.controller;

import com.example.restdoc_openapi.global.CommonResponse;
import com.example.restdoc_openapi.post.request.PostCreateRequest;
import com.example.restdoc_openapi.post.request.PostUpdateRequest;
import com.example.restdoc_openapi.post.response.PostCreateResponse;
import com.example.restdoc_openapi.post.response.PostListReadResponse;
import com.example.restdoc_openapi.post.response.PostReadResponse;
import com.example.restdoc_openapi.post.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
public class PostController {

    private final PostService postService;

    @GetMapping("/posts")
    public CommonResponse<PostListReadResponse> getPosts(@RequestParam(required = false) Integer page,
                                                         @RequestParam(required = false) Integer size,
                                                         @RequestParam(required = false) String sort) {

        return CommonResponse.success(postService.getPosts(page, size, sort));
    }

    @GetMapping("/posts/{id}")
    public CommonResponse<PostReadResponse> getPost(@PathVariable Long id) {

        return CommonResponse.success(postService.getPost(id));
    }


    @PostMapping("/posts")
    public CommonResponse<PostCreateResponse> createPost(@RequestBody PostCreateRequest request) {

        return CommonResponse.success(postService.createPost(request));
    }

    @PutMapping("/posts/{id}")
    public CommonResponse<Void> updatePost(@PathVariable Long id, @RequestBody PostUpdateRequest request) {

        postService.updatePost(id, request);
        return CommonResponse.success();
    }

    @DeleteMapping("/posts/{id}")
    public CommonResponse<PostReadResponse> deletePost(@PathVariable Long id) {

        postService.deletePost(id);
        return CommonResponse.success();
    }
}
