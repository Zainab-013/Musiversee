package com.musiverse.backend.controller;

import com.musiverse.backend.entity.Song;
import com.musiverse.backend.service.LikeService;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@RestController
@RequestMapping("/api/likes")
@CrossOrigin
public class LikeController {

    private final LikeService likeService;

    public LikeController(LikeService likeService) {
        this.likeService = likeService;
    }

    // ❤️ LIKE
    @PostMapping("/{userId}/{songId}")
    public void likeSong(@PathVariable Long userId, @PathVariable Long songId) {
        likeService.likeSong(userId, songId);
    }

    // 💔 UNLIKE
    @DeleteMapping("/{userId}/{songId}")
    public void unlikeSong(@PathVariable Long userId, @PathVariable Long songId) {
        likeService.unlikeSong(userId, songId);
    }

    // ❤️ GET LIKED SONGS
    @GetMapping("/{userId}")
    public Set<Song> getLikedSongs(@PathVariable Long userId) {
        return likeService.getLikedSongs(userId);
    }
}
