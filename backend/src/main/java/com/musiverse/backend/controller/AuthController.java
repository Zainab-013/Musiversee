package com.musiverse.backend.controller;

import com.musiverse.backend.config.JwtUtil;
import com.musiverse.backend.entity.User;
import com.musiverse.backend.repository.UserRepository;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // =========================
    // REGISTER
    // =========================
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> body) {

        String name = body.get("name");
        String email = body.get("email");
        String rawPassword = body.get("password");

        if (email == null || rawPassword == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email and password are required"));
        }

        // check if email already exists
        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "Email already exists"));
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(rawPassword));

        User savedUser = userRepository.save(user);

        String token = jwtUtil.generateToken(savedUser.getEmail(), savedUser.getId(), savedUser.getName());

        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "id", savedUser.getId(),
                "name", savedUser.getName(),
                "email", savedUser.getEmail(),
                "token", token));
    }

    // =========================
    // LOGIN
    // =========================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {

        String email = body.get("email");
        String rawPassword = body.get("password");

        if (email == null || rawPassword == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email and password are required"));
        }

        Optional<User> userOptional = userRepository.findByEmail(email);

        if (userOptional.isEmpty()) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        User user = userOptional.get();

        if (!passwordEncoder.matches(rawPassword, user.getPassword())) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        String token = jwtUtil.generateToken(user.getEmail(), user.getId(), user.getName());

        return ResponseEntity.ok(Map.of(
                "id", user.getId(),
                "name", user.getName(),
                "email", user.getEmail(),
                "token", token));
     }

    // =========================
    // UPDATE PROFILE
    // =========================
    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody Map<String, String> body) {
        try {
            var authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Unauthorized"));
            }
            String currentEmail = (String) authentication.getPrincipal();
            User user = userRepository.findByEmail(currentEmail)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            String name = body.get("name");
            String email = body.get("email");
            String password = body.get("password");

            if (name != null && !name.trim().isEmpty()) {
                user.setName(name);
            }
            if (email != null && !email.trim().isEmpty()) {
                if (!email.equalsIgnoreCase(currentEmail) && userRepository.findByEmail(email).isPresent()) {
                    return ResponseEntity.badRequest().body(Map.of("error", "Email already exists"));
                }
                user.setEmail(email);
            }
            if (password != null && !password.trim().isEmpty()) {
                user.setPassword(passwordEncoder.encode(password));
            }

            User updatedUser = userRepository.save(user);
            String token = jwtUtil.generateToken(updatedUser.getEmail(), updatedUser.getId(), updatedUser.getName());

            return ResponseEntity.ok(Map.of(
                    "id", updatedUser.getId(),
                    "name", updatedUser.getName(),
                    "email", updatedUser.getEmail(),
                    "token", token));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
