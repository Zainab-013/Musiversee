package com.musiverse.backend.service;

import com.musiverse.backend.entity.Song;

import java.util.Set;

public interface LikeService {

    void likeSong(Long userId, Long songId);

    void unlikeSong(Long userId, Long songId);

    Set<Song> getLikedSongs(Long userId);
}
