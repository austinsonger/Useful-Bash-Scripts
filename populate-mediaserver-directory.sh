# Author: Austin Songer
#!/usr/bin/env bash

BASE_DIR="$HOME/PlexMedia"

# Define the directory structure as indexed arrays
MEDIA_DIRS=("Movies:Movies" "TV_Shows:TV_Shows" "Music:Music" "Photos:Photos" "Home_Videos:Home_Videos")
SUBFOLDERS_MOVIES=("Action" "Drama" "Comedy" "Family" "Superhero" "Adventure" "Spy_Thriller" "Martial_Arts" "War" "Fantasy" "Science_Fiction_Action")
SUBFOLDERS_TV_SHOWS=("Drama" "Comedy" "Documentaries" "Cartoons" "Crime_Drama" "Medical_Drama" "Reality_Shows" "Sitcoms" "Animated_Shows")
SUBFOLDERS_MUSIC=("Albums" "Playlists" "Artists" "Genres" "Live_Performances" "Soundtracks")
SUBFOLDERS_PHOTOS=("Vacations" "Events" "Family" "Favorites" "Nature" "Artistic")
SUBFOLDERS_HOME_VIDEOS=("Birthdays" "Holidays" "Vacations" "Family_Reunions" "School_Events")

# Subgenres for Movies
GENRE_SUBFOLDERS_MOVIES_Action=("Superhero" "Adventure" "Spy_Thriller" "Martial_Arts" "War" "Disaster" "Crime_Action" "Science_Fiction_Action" "Western" "Survival_Action" "Chase" "Heist_Action")
GENRE_SUBFOLDERS_MOVIES_Drama=("Historical" "Biographical" "Romantic_Drama" "Psychological_Drama" "Legal_Courtroom" "Medical_Drama" "Period_Drama" "Family_Drama" "Crime_Drama" "Coming_of_Age" "Tragedy" "Mystery_Drama" "Political_Drama")
GENRE_SUBFOLDERS_MOVIES_Comedy=("Romantic_Comedy" "Satire" "Dark_Comedy" "Slapstick" "Parody" "Stand_Up" "Mockumentary" "Teen_Comedy" "Absurdist_Comedy" "Black_Comedy" "Musical_Comedy" "Workplace_Comedy" "Physical_Comedy")
GENRE_SUBFOLDERS_MOVIES_Family=("Animated" "Fantasy" "Live_Action_Family" "Educational" "Animal_Centric" "Musical_Family" "Holiday_Family" "Adventure_Family" "Classic_Family" "Children's_Stories")
GENRE_SUBFOLDERS_MOVIES_Superhero=("Marvel" "DC" "Independent" "Parody_Superhero" "Anti-Hero" "Anime_Superhero")
GENRE_SUBFOLDERS_MOVIES_Adventure=("Epic_Adventure" "Fantasy_Adventure" "Treasure_Hunting" "Survival_Adventure" "Space_Adventure" "Lost_Civilizations" "Island_Adventures" "Arctic_Adventures")
GENRE_SUBFOLDERS_MOVIES_Spy_Thriller=("Espionage" "Military_Spy" "Cold_War_Spy" "Modern_Spy" "Double_Agent_Spy" "Undercover_Spy")
GENRE_SUBFOLDERS_MOVIES_Martial_Arts=("Kung_Fu" "Samurai" "Ninjutsu" "Modern_Martial_Arts" "Tournament_Style" "Self_Defense" "Historical_Martial_Arts" "Anime_Fighting_Styles")
GENRE_SUBFOLDERS_MOVIES_War=("World_War_II" "Vietnam_War" "Modern_Warfare" "Historical_Warfare" "Anti-War" "Post-War" "Guerrilla_Warfare" "Military_Strategy")
GENRE_SUBFOLDERS_MOVIES_Fantasy=("High_Fantasy" "Dark_Fantasy" "Urban_Fantasy" "Magical_Realism" "Mythical_Fantasy" "Alternate_Reality" "Fairy_Tales" "Supernatural_Fantasy" "Steampunk_Fantasy")
GENRE_SUBFOLDERS_MOVIES_Science_Fiction_Action=("Dystopian" "Post-Apocalyptic" "Alien_Invasion" "Time_Travel" "Space_Opera" "Cyberpunk" "Mecha" "Cloning" "Artificial_Intelligence" "Genetic_Modification")
GENRE_SUBFOLDERS_MOVIES_Historical=("Period_Piece" "Historical_Biopic" "War_Era_History" "Historical_Romance" "Historical_Adventure")
GENRE_SUBFOLDERS_MOVIES_Dark_Comedy=("Tragicomedy" "Satirical_Dark_Comedy" "Absurd_Dark_Comedy" "Political_Comedy" "Morbid_Comedy")

# Subgenres for TV Shows
GENRE_SUBFOLDERS_TV_Drama=("Crime_Drama" "Historical_Drama" "Political_Drama" "Family_Drama" "Teen_Drama" "Medical_Drama" "Legal_Drama" "Psychological_Drama" "Period_Drama" "Mystery_Drama" "Romantic_Drama" "Military_Drama")
GENRE_SUBFOLDERS_TV_Comedy=("Sitcoms" "Dark_Comedy" "Sketch_Comedy" "Romantic_Comedy" "Mockumentary" "Stand_Up_Comedy" "Parody_Comedy" "Teen_Comedy" "Workplace_Comedy" "Improvisational_Comedy" "Satirical_Comedy")
GENRE_SUBFOLDERS_TV_Documentaries=("Nature_Documentaries" "Historical_Documentaries" "Biographical_Documentaries" "Science_Documentaries" "True_Crime_Documentaries" "Educational_Documentaries" "Travel_Documentaries" "Art_Documentaries" "Social_Documentaries")
GENRE_SUBFOLDERS_TV_Cartoons=("Classic_Cartoons" "Modern_Cartoons" "Superhero_Cartoons" "Educational_Cartoons" "Adult_Animation" "Anime" "Fantasy_Cartoons" "Comedy_Cartoons" "Action_Cartoons")
GENRE_SUBFOLDERS_TV_Crime_Drama=("Police_Procedural" "True_Crime" "Forensic_Drama" "Crime_Thriller" "Mystery_Drama" "Organized_Crime_Drama" "Legal_Crime_Drama" "Spy_Crime_Drama" "Cold_Case_Series")
GENRE_SUBFOLDERS_TV_Reality_Shows=("Competition_Shows" "Makeover_Shows" "Survival_Shows" "Documentary_Reality" "True_Story_Reenactments" "Home_Improvement_Shows" "Cooking_Competitions" "Dating_Shows" "Travel_Reality_Shows")
GENRE_SUBFOLDERS_TV_Sitcoms=("Family_Sitcoms" "Workplace_Sitcoms" "Romantic_Sitcoms" "Classic_Sitcoms" "Teen_Sitcoms" "Improvised_Sitcoms" "Animated_Sitcoms")
GENRE_SUBFOLDERS_TV_Animated_Shows=("Anime" "3D_Animated_Shows" "Stop_Motion_Animation" "Fantasy_Animation" "Sci-Fi_Animation" "Adult_Animation" "Superhero_Animation" "Classic_Animation")

# Function to create directories
create_directories() {
  echo "Creating Plex media directory structure..."
  mkdir -p "$BASE_DIR"

  for entry in "${MEDIA_DIRS[@]}"; do
    IFS=":" read -r category path <<< "$entry"
    category_path="$BASE_DIR/$path"
    mkdir -p "$category_path"
    echo "Created: $category_path"

    # Handle subfolders
    case $category in
      Movies)
        create_subfolders "$category_path" SUBFOLDERS_MOVIES GENRE_SUBFOLDERS_MOVIES_
        ;;
      TV_Shows)
        create_subfolders "$category_path" SUBFOLDERS_TV_SHOWS GENRE_SUBFOLDERS_TV_
        ;;
      Music)
        create_subfolders "$category_path" SUBFOLDERS_MUSIC
        ;;
      Photos)
        create_subfolders "$category_path" SUBFOLDERS_PHOTOS
        ;;
      Home_Videos)
        create_subfolders "$category_path" SUBFOLDERS_HOME_VIDEOS
        ;;
    esac
  done
  echo "Plex media directory structure created successfully at $BASE_DIR."
}

# Function to create subfolders and subgenres
create_subfolders() {
  local parent_path=$1
  local -n subfolders=$2
  local prefix=$3

  for subfolder in "${subfolders[@]}"; do
    subfolder_path="$parent_path/$subfolder"
    mkdir -p "$subfolder_path"
    echo "Created: $subfolder_path"

    # Create subgenres if prefix is provided
    if [[ -n $prefix ]]; then
      local subgenre_var="${prefix}${subfolder}"
      if declare -p "$subgenre_var" &>/dev/null; then
        local -n subgenres=$subgenre_var
        for subgenre in "${subgenres[@]}"; do
          mkdir -p "$subfolder_path/$subgenre"
          echo "Created: $subfolder_path/$subgenre"
        done
      fi
    fi
  done
}

# Run the script
create_directories
