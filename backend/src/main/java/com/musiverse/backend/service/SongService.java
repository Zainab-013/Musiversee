package com.musiverse.backend.service;

import com.musiverse.backend.entity.Song;
import java.util.List;

public interface SongService {
    Song saveSong(Song song);
    List<Song> getAllSongs();
}
