package com.musiverse.backend.entity;

import jakarta.persistence.*;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "songs")
public class Song {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "song_name")
    private String songName;

    private String movie;
    private String actor;
    private String actress;
    private String artist;
    private String composer;
    private String lyricist;
    private String category;

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;

    @Column(name = "song_url", columnDefinition = "TEXT")
    private String songUrl;

    // =========================
    // LIKE / UNLIKE RELATION
    // =========================
    @ManyToMany(mappedBy = "likedSongs")
    @JsonIgnore // ✅ prevents infinite JSON loop
    private Set<User> likedByUsers = new HashSet<>();

    // =========================
    // CONSTRUCTORS
    // =========================
    public Song() {
    }

    public Song(String songName, String movie, String actor, String actress,
            String artist, String composer, String lyricist,
            String category, String imageUrl, String songUrl) {
        this.songName = songName;
        this.movie = movie;
        this.actor = actor;
        this.actress = actress;
        this.artist = artist;
        this.composer = composer;
        this.lyricist = lyricist;
        this.category = category;
        this.imageUrl = imageUrl;
        this.songUrl = songUrl;
    }

    // =========================
    // GETTERS & SETTERS
    // =========================
    public Long getId() {
        return id;
    }

    public String getSongName() {
        return songName;
    }

    public void setSongName(String songName) {
        this.songName = songName;
    }

    public String getMovie() {
        return movie;
    }

    public void setMovie(String movie) {
        this.movie = movie;
    }

    public String getActor() {
        return actor;
    }

    public void setActor(String actor) {
        this.actor = actor;
    }

    public String getActress() {
        return actress;
    }

    public void setActress(String actress) {
        this.actress = actress;
    }

    @JsonProperty("singer")
    public String getArtist() {
        return artist;
    }

    @JsonProperty("singer")
    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getComposer() {
        return composer;
    }

    public void setComposer(String composer) {
        this.composer = composer;
    }

    public String getLyricist() {
        return lyricist;
    }

    public void setLyricist(String lyricist) {
        this.lyricist = lyricist;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getSongUrl() {
        return songUrl;
    }

    public void setSongUrl(String songUrl) {
        this.songUrl = songUrl;
    }

    public Set<User> getLikedByUsers() {
        return likedByUsers;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        Song song = (Song) o;
        return Objects.equals(id, song.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
