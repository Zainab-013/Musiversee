package com.musiverse.backend.repository;

import com.musiverse.backend.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SongRepository extends JpaRepository<Song, Long> {
}
