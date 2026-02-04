package com.musiverse.backend.service.impl;

import com.musiverse.backend.entity.Song;
import com.musiverse.backend.entity.User;
import com.musiverse.backend.repository.SongRepository;
import com.musiverse.backend.repository.UserRepository;
import com.musiverse.backend.service.LikeService;
import org.springframework.stereotype.Service;

import java.util.Set;

@Service
public class LikeServiceImpl implements LikeService {

    private final UserRepository userRepository;
    private final SongRepository songRepository;

    public LikeServiceImpl(UserRepository userRepository, SongRepository songRepository) {
        this.userRepository = userRepository;
        this.songRepository = songRepository;
    }

    @Override
    public void likeSong(Long userId, Long songId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        user.getLikedSongs().add(song);
        userRepository.save(user);
    }

    @Override
    public void unlikeSong(Long userId, Long songId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        user.getLikedSongs().remove(song);
        userRepository.save(user);
    }

    @Override
    public Set<Song> getLikedSongs(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return user.getLikedSongs();
    }
}
