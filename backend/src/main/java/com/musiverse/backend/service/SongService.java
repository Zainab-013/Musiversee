package com.musiverse.backend.service;

import com.musiverse.backend.entity.Song;
import java.util.List;


public interface SongService {

    Song saveSong(Song song);

    List<Song> getAllSongs();

    List<Song> getSongsByCategory(String category);

    List<Song> searchSongs(String query);

    Song updateSong(Long id, Song song);
    Song getSongById(Long id);


    void deleteSong(Long id);
}
