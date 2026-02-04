package com.musiverse.backend.service.impl;

import com.musiverse.backend.entity.Song;
import com.musiverse.backend.repository.SongRepository;
import com.musiverse.backend.service.SongService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SongServiceImpl implements SongService {

    private final SongRepository songRepository;

    public SongServiceImpl(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    // =========================
    // CREATE / SAVE SONG
    // =========================
    @Override
    public Song saveSong(Song song) {
        return songRepository.save(song);
    }

    // =========================
    // GET ALL SONGS
    // =========================
    @Override
    public List<Song> getAllSongs() {
        return songRepository.findAll();
    }

    // =========================
    // GET SONGS BY CATEGORY
    // =========================
    @Override
    public List<Song> getSongsByCategory(String category) {
        return songRepository.findByCategoryIgnoreCase(category);
    }

    // =========================
    // SEARCH SONGS
    // =========================
    @Override
    public List<Song> searchSongs(String query) {
        return songRepository
                .findBySongNameContainingIgnoreCaseOrArtistContainingIgnoreCase(
                        query, query
                );
    }

    // =========================
    // UPDATE SONG
    // =========================
    @Override
    public Song updateSong(Long id, Song updatedSong) {
        Song existingSong = songRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        existingSong.setSongName(updatedSong.getSongName());
        existingSong.setMovie(updatedSong.getMovie());
        existingSong.setActor(updatedSong.getActor());
        existingSong.setActress(updatedSong.getActress());
        existingSong.setArtist(updatedSong.getArtist());
        existingSong.setComposer(updatedSong.getComposer());
        existingSong.setLyricist(updatedSong.getLyricist());
        existingSong.setCategory(updatedSong.getCategory());
        existingSong.setImageUrl(updatedSong.getImageUrl());
        existingSong.setSongUrl(updatedSong.getSongUrl());

        return songRepository.save(existingSong);
    }
    @Override
public Song getSongById(Long id) {
    return songRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Song not found"));
}

    // =========================
    // DELETE SONG
    // =========================
    @Override
    public void deleteSong(Long id) {
        songRepository.deleteById(id);
    }
}
