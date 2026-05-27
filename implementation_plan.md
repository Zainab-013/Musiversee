# Implementation Plan: Soft-Delete (Hide) Songs Per User (No Guest Mode)

This plan details the changes to support hiding songs on a per-user basis. When a user deletes a song, it will only be removed from their own view (and database associations) but will remain visible for other users and exist in the main database. 

Since **Guest Mode is removed**, every user is fully authenticated with a database record, simplifying session management.

---

## Proposed Changes

### Backend Component

#### [MODIFY] [User.java](file:///c:/Users/Zainab/OneDrive/Documents/Desktop/ZDesktop/Musiverse/backend/src/main/java/com/musiverse/backend/entity/User.java)
- Add a new many-to-many relationship `hiddenSongs` referencing `Song`:
  ```java
  @ManyToMany
  @JoinTable(name = "user_hidden_songs", joinColumns = @JoinColumn(name = "user_id"), inverseJoinColumns = @JoinColumn(name = "song_id"))
  @JsonIgnore
  private Set<Song> hiddenSongs = new HashSet<>();
  ```
- Implement getter/setter methods for `hiddenSongs`.

#### [MODIFY] [SongController.java](file:///c:/Users/Zainab/OneDrive/Documents/Desktop/ZDesktop/Musiverse/backend/src/main/java/com/musiverse/backend/controller/SongController.java)
- Modify `getAllSongs`, `getByCategory`, and `searchSongs` to get the authenticated user and filter out any songs that match the user's `hiddenSongs`.
- Modify `deleteSong` (`DELETE /api/songs/{id}`) to find the authenticated user, add the specified song to their `hiddenSongs` list, and save the user. (This replaces the global database deletion).

---

### Frontend Component

#### [MODIFY] [login_screen.dart](file:///c:/Users/Zainab/OneDrive/Documents/Desktop/ZDesktop/Musiverse/frontend/lib/screens/auth/login_screen.dart)
- Remove the "Continue as Guest" button to ensure only authenticated login is allowed.

#### [MODIFY] [auth_provider.dart](file:///c:/Users/Zainab/OneDrive/Documents/Desktop/ZDesktop/Musiverse/frontend/lib/providers/auth_provider.dart)
- Remove the `guestLogin()` method.

#### [MODIFY] [music_provider.dart](file:///c:/Users/Zainab/OneDrive/Documents/Desktop/ZDesktop/Musiverse/frontend/lib/providers/music_provider.dart)
- Add a `deleteSong(int songId)` method that:
  - Immediately removes the song from the local states (`_allSongs`, `_likedSongs`, `_recentlyPlayed`) to update the UI instantly.
  - Calls `ApiService.deleteSong` to sync the soft-delete/hidden state to the backend database.
  - Calls `notifyListeners()`.

#### [MODIFY] [upload_screen.dart](file:///c:/Users/Zainab/OneDrive/Documents/Desktop/ZDesktop/Musiverse/frontend/lib/screens/upload_screen.dart)
- Update `_deleteSong` to invoke the `MusicProvider.deleteSong(song.id)` method.

---

## Verification Plan

### Manual Verification
1. Launch the application backend and frontend.
2. Sign in as **User A** (e.g. `userA@test.com`) and **User B** (e.g. `userB@test.com`) on two clients.
3. Upload a new song from **User A** and verify that it is immediately visible in the song lists of both **User A** and **User B**.
4. Logged in as **User A**, click the delete button on the uploaded song:
   - Verify the song is immediately hidden from **User A**'s list.
   - Verify the song is **still visible** to **User B**.
   - Check the PostgreSQL database and verify that the song row in the `songs` table still exists.
Hidden / Privacy Flow:
Delete/Hide a song on the home screen.
Go to Profile -> Privacy.
Verify that the song is listed under "Hidden Songs".
Click "Unhide".
Verify that the song disappears from the Hidden list and reappears on the Home Screen/Library.