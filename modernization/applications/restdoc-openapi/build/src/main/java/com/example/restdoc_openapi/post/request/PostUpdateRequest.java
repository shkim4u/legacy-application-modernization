package com.example.restdoc_openapi.post.request;

import lombok.Data;

@Data
public class PostUpdateRequest {
    private String title;
    private String content;
}
