library(dplyr)

league_data <- read.csv("data\\mls_season_2026_stats")

league_data <- league_data %>% filter(Status != "Upcoming")


#These are the stats in the form number (percentage), which we must split
split_stats <- c("Accurate passes", "Accurate long balls", "Accurate crosses",
                 "Ground duels won", "Aerial duels won", "Successful dribbles")



#For each team in the league, compute correlation of points vs another metric for each game
for (team in unique(league_data$Team)) {
  
  
}
  