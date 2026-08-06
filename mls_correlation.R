library(dplyr)

#Modifies data to use relevant stats
league_data <- read.csv("data\\mls_season_2026_stats")

league_data <- league_data %>% filter(Status != "Upcoming")

#These are the stats in the form number (percentage), which we must split
split_stats <- c("Accurate passes", "Accurate long balls", "Accurate crosses",
                 "Ground duels won", "Aerial duels won", "Successful dribbles")
split_percentage_columns <- function(df, cols) {
  for (col in cols) {
    if (col %in% names(df)) {
      raw_vals <- as.character(df[[col]])

      count_vals <- suppressWarnings(
        as.numeric(sub("^\\s*(\\d+(?:\\.\\d+)?)\\s*\\((\\d+(?:\\.\\d+)?)%\\)\\s*$", "\\1", raw_vals, perl = TRUE))
      )
      pct_vals <- suppressWarnings(
        as.numeric(sub("^\\s*(\\d+(?:\\.\\d+)?)\\s*\\((\\d+(?:\\.\\d+)?)%\\)\\s*$", "\\2", raw_vals, perl = TRUE)) / 100
      )

      df[[col]] <- count_vals
      df[[paste0(col, " percentage")]] <- pct_vals
    }
  }

  df
}
league_data <- split_percentage_columns(league_data, split_stats)
league_data[["Ball possession percentage"]] <- as.numeric(sub("%", "", league_data[["Ball possession"]])) / 100


#For each team in the league, compute correlation of points vs another metric for each game
for (team in unique(league_data$Team)) {
  
  
}
  