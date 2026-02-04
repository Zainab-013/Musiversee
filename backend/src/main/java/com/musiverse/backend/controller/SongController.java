package com.musiverse.backend.controller;

import com.musiverse.backend.entity.Song;
import com.musiverse.backend.entity.User;
import com.musiverse.backend.repository.UserRepository;
import com.musiverse.backend.service.SongService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/songs")
@CrossOrigin(origins = "*")
public class SongController {

    private final SongService songService;
    private final UserRepository userRepository;

    public SongController(SongService songService, UserRepository userRepository) {
        this.songService = songService;
        this.userRepository = userRepository;
    }

    // =========================
    // CREATE SONG
    // =========================
    @PostMapping
    public Song addSong(@RequestBody Song song) {
        return songService.saveSong(song);
    }

    // =========================
    // GET ALL SONGS
    // =========================
    @GetMapping
    public List<Song> getAllSongs() {
        return songService.getAllSongs();
    }

    // =========================
    // GET SONGS BY CATEGORY
    // =========================
    @GetMapping("/category/{category}")
    public List<Song> getByCategory(@PathVariable String category) {
        return songService.getSongsByCategory(category);
    }

    // =========================
    // SEARCH SONGS
    // =========================
    @GetMapping("/search")
    public List<Song> searchSongs(@RequestParam String q) {
        return songService.searchSongs(q);
    }

    // =========================
    // UPDATE SONG
    // =========================
    @PutMapping("/{id}")
    public Song updateSong(@PathVariable Long id, @RequestBody Song song) {
        return songService.updateSong(id, song);
    }

    // =========================
    // DELETE SONG
    // =========================
    @DeleteMapping("/{id}")
    public void deleteSong(@PathVariable Long id) {
        songService.deleteSong(id);
    }

    // =========================
    // ❤️ LIKE SONG
    // =========================
    @PostMapping("/{songId}/like/{userId}")
    public void likeSong(@PathVariable Long songId, @PathVariable Long userId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Song song = songService.getSongById(songId);

        user.getLikedSongs().add(song);
        userRepository.save(user);
    }

    // =========================
    // 💔 UNLIKE SONG
    // =========================
    @PostMapping("/{songId}/unlike/{userId}")
    public void unlikeSong(@PathVariable Long songId, @PathVariable Long userId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Song song = songService.getSongById(songId);

        user.getLikedSongs().remove(song);
        userRepository.save(user);
    }

    // =========================
    // ❤️ GET LIKED SONGS
    // =========================
    @GetMapping("/liked/{userId}")
    public Set<Song> getLikedSongs(@PathVariable Long userId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return user.getLikedSongs();
    }
}
