enum FirebaseErrorCodeDescription : String {
    
    //Login
    case getCustomToken = "An error occurred while trying to login to the database."
    case migrateDataToken = "An error occurred while trying to manage the new data. Please close the app and try again."
    
    //User
    case getUser = "An error occurred while getting the user information."
    case saveUser = "An error occurred while saving the user information."
    case deleteUser = "An error occurred while deleting the user information."
    case getFavoriteGenres = "An error occurred while fetching the user's favorite genres."
    case saveFavoriteGenres = "An error occurred while saving the user's favorite genres."
    case deleteFavoriteGenres = "An error occurred while deleting the user's favorite genres."
    case updateGenreCount = "An error occurred while updating the selected genre count."
    case getSettings = "An error occurred while getting the user settings information."
    case saveSettings = "An error occurred while saving the user settings information."
    
    //Track
    case getLikedTracks = "An error occurred while fetching your liked tracks."
    case saveLikedTracks = "An error occurred while saving your liked tracks."
    case deleteLikedTracks = "An error occurred while deleting your liked tracks."
    case setSuggestedSong = "An error occurred while updating your suggested tracks."
    
    //Mood
    case getMoodInfo = "An error occurred while fetching your saved mood information."
    case saveMoodInfo = "An error occurred while saving the current mood information."
    case deleteMoodInfo = "An error occurred while deleting the current mood information."
    case getMoodInfoDefaultTrack = "An error occurred while fetching the default mood settings."
    case getTrackFeatures = "An error occurred while fetching the track list audio features."
    case getTrackListForEmotion = "An error occurred while fetching the track list for the current mood."
    
    //Artist
    case getArtist = "An error occurred while fetching the artist information."
    case saveArtist = "An error occurred while saving the artist information."
    case deleteArtist = "An error occurred while deleting the artist information."
    
    //Genre
    case getGenre = "An error occurred while fetching the genre information."
    case saveGenre = "An error occurred while saving the genre information."
    case deleteGenre = "An error occurred while deleting the genre information."
    
    //Playlist
    case getPlaylist = "An error occurred while fetching the playlist information."
    case savePlaylist = "An error occurred while saving the playlist information."
    case deletePlaylist = "An error occurred while deleting the playlist information."
    case addNewPlaylist = "An error occurred while adding the new playlist information."
}
