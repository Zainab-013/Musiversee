package com.musiverse.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
            // disable CSRF (important for Flutter / mobile)
            .csrf(csrf -> csrf.disable())

            // allow requests
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                        "/api/auth/**"
                ).permitAll()   // allow register & login
                .anyRequest().permitAll()
            )

            // disable default login form
            .formLogin(form -> form.disable())

            // disable http basic auth
            .httpBasic(basic -> basic.disable());

        return http.build();
    }
}
