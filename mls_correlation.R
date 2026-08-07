library(dplyr)

#Modifies data to use relevant stats
league_data <- read.csv("data/mls_season_2026_stats.csv")

league_data <- league_data %>% filter(Status != "Upcoming")

#These are the stats in the form number (percentage), which we must split
split_stats <- c("Accurate.passes", "Accurate.long.balls", "Accurate.crosses",
                 "Ground.duels.won", "Aerial.duels.won", "Successful.dribbles")
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
league_data[["Ball.possession"]] <- as.numeric(sub("%", "", league_data[["Ball.possession"]])) / 100

#Also add opponent non-penalty xG
league_data[["Non-penalty xG against"]] <- NA

#for each row, find the other team in the match and get their non-penalty xG
for (i in seq_len(nrow(league_data))) {
  match_val <- league_data[["Match"]][i]
  team_val <- league_data[["Team"]][i]

  match_rows <- which(league_data[["Match"]] == match_val)
  other_rows <- match_rows[league_data[["Team"]][match_rows] != team_val]

  if (length(other_rows) > 0) {
    league_data[["Non-penalty xG against"]][i] <- league_data[["Non.penalty.xG"]][other_rows[1]]
  }
}
league_data[["Non-penalty xG difference"]] <- league_data[["Non.penalty.xG"]] - league_data[["Non-penalty xG against"]]

#cleaned league data for reference
write.csv(league_data, file = "output/cleaned_mls_season_2026_stats.csv", row.names = FALSE)

#league_data

#remove non-numeric columns from the data frame
exclude_cols <- c()
for (col in names(league_data)) {
  if (!is.numeric(league_data[[col]])) {
    exclude_cols <- c(exclude_cols, col)
  }
}
exclude_cols <- c(exclude_cols,
  "Round",
  "No",
  "Non-penalty xG difference",
  "Red.cards",
  "Non.penalty.xG",
  "Non-penalty xG against",
  "Expected.goals..xG.",
  "xG.on.target..xGOT."
)

#For each team in the league, compute correlation of points vs another metric for each game
results_table <- list()

for (team in unique(league_data$Team)) {
    team_data <- league_data %>% filter(Team == team)
    results <- list()
    for (col in setdiff(names(team_data), exclude_cols)) {
        x <- team_data[[col]]
        y <- team_data[["Non-penalty xG difference"]]

        pearson_test <- cor.test(x, y, method = "pearson")
        spearman_test <- cor.test(x, y, method = "spearman")

        results[[col]] <- data.frame(
            stat = col,
            pearson_r = unname(pearson_test$estimate),
            pearson_r2 = unname(pearson_test$estimate)^2,
            pearson_p = pearson_test$p.value,
            spearman_rho = unname(spearman_test$estimate),
            spearman_p = spearman_test$p.value,
            team_name = team
        )
    }
    results_table[[team]] <- do.call(rbind, results)
    #Write individual team results as CSV
    write.csv(results_table[[team]], file = paste0("output/", team, "_correlation_results.csv"), row.names = FALSE)
}

results_table <- do.call(rbind, results_table)

# Reset row names (they'll otherwise be messy from the list names)
rownames(results_table) <- NULL

#Since we are running multiple significance tests simultaneously, we implement FDR adjusted p-values
#First, adjust across all p-values in the full table
#Second, adjust within each stat so each stat gets its own FDR correction
results_table <- results_table %>%
  mutate(pearson_fdr_p = p.adjust(pearson_p, method = "fdr")) %>%
  group_by(stat) %>%
  mutate(pearson_fdr_p_by_stat = p.adjust(pearson_p, method = "fdr")) %>%
  ungroup()

#Write full data as CSV
write.csv(results_table, file = "output/mls_correlation_results.csv", row.names = FALSE)
results_table <- results_table %>% arrange(stat, desc(pearson_r2))
write.csv(results_table, file = "output/mls_correlation_results_sorted_by_stat.csv", row.names = FALSE)