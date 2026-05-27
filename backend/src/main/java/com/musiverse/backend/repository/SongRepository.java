package com.musiverse.backend.repository;

import com.musiverse.backend.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SongRepository extends JpaRepository<Song, Long> {

    // 🎵 Filter by category
    List<Song> findByCategoryIgnoreCase(String category);

    // 🎵 Filter by multiple categories (case-insensitive)
    @org.springframework.data.jpa.repository.Query("SELECT s FROM Song s WHERE LOWER(s.category) IN :categories")
    List<Song> findByCategoryInIgnoreCase(@org.springframework.data.repository.query.Param("categories") List<String> categories);

    // 🔍 Search by song name OR artist
    List<Song> findBySongNameContainingIgnoreCaseOrArtistContainingIgnoreCase(
            String songName,
            String artist
    );
}
