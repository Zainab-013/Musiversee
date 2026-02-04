package com.musiverse.backend.repository;

import com.musiverse.backend.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SongRepository extends JpaRepository<Song, Long> {

    // 🎵 Filter by category
    List<Song> findByCategoryIgnoreCase(String category);

    // 🔍 Search by song name OR artist
    List<Song> findBySongNameContainingIgnoreCaseOrArtistContainingIgnoreCase(
            String songName,
            String artist
    );
}
