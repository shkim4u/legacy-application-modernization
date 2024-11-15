package com.example.restdoc_openapi.post.service;

import com.example.restdoc_openapi.post.request.PostCreateRequest;
import com.example.restdoc_openapi.post.request.PostUpdateRequest;
import com.example.restdoc_openapi.post.response.PostCreateResponse;
import com.example.restdoc_openapi.post.response.PostListReadResponse;
import com.example.restdoc_openapi.post.response.PostReadResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class PostService {

    public PostListReadResponse getPosts(Integer page,
                                         Integer size,
                                         String sort) {
        return null;
    }

    public PostReadResponse getPost(Long id) {
        return null;
    }

    public PostCreateResponse createPost(PostCreateRequest request) {
        return null;
    }

    public void updatePost(Long id, PostUpdateRequest request) {
    }

    public void deletePost(Long id) {
    }
}
