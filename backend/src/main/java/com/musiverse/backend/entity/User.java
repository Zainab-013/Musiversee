package com.musiverse.backend.entity;

import jakarta.persistence.*;
import java.util.HashSet;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    private String password;

    // =========================
    // LIKED SONGS (Many-to-Many)
    // =========================
    @ManyToMany
    @JoinTable(
        name = "user_liked_songs",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "song_id")
    )
    @JsonIgnore // ✅ prevents infinite recursion
    private Set<Song> likedSongs = new HashSet<>();

    // =========================
    // CONSTRUCTORS
    // =========================
    public User() {
    }

    // =========================
    // GETTERS & SETTERS
    // =========================
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    // ❗ REQUIRED for register/login
    public void setPassword(String password) {
        this.password = password;
    }

    public Set<Song> getLikedSongs() {
        return likedSongs;
    }

    public void setLikedSongs(Set<Song> likedSongs) {
        this.likedSongs = likedSongs;
    }

    // =========================
    // HELPER METHODS (IMPORTANT)
    // =========================
    public void likeSong(Song song) {
        likedSongs.add(song);
    }

    public void unlikeSong(Song song) {
        likedSongs.remove(song);
    }
}
