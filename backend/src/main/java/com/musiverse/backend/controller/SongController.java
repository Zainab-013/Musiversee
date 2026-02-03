package com.musiverse.backend.controller;

import com.musiverse.backend.entity.Song;
import com.musiverse.backend.service.SongService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/songs")
@CrossOrigin
public class SongController {

    private final SongService songService;

    public SongController(SongService songService) {
        this.songService = songService;
    }

    @PostMapping
    public Song addSong(@RequestBody Song song) {
        return songService.saveSong(song);
    }

    @GetMapping
    public List<Song> getAllSongs() {
        return songService.getAllSongs();
    }
}
