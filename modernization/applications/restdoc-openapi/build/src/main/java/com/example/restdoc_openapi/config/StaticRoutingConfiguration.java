package com.example.restdoc_openapi.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class StaticRoutingConfiguration implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
//        registry.addResourceHandler("/static/**")
//                .addResourceLocations("classpath:/static/");
        registry.addResourceHandler("/swagger-ui/**", "/swagger-ui.html")
                .addResourceLocations("classpath:/static/swagger-ui/");

        // Add this new resource handler for openapi3.json
        registry.addResourceHandler("/openapi3.json")
                .addResourceLocations("classpath:/static/");
    }
}
