package com.musiverse.backend.service;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

public interface CloudinaryService {
    String uploadFile(MultipartFile file, String resourceType) throws IOException;
}
