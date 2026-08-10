# Correlation Analysis of Various Metrics vs xG Difference for Clubs in the MLS

## by Heechan Han

## Contents
- [Introduction](#introduction)
- [Computing Correlation](#computing-correlation)
- [Comparing Leagues](#comparing-leagues)
- [Interesting Observations](#interesting-observations)
- [Conclusion](#conclusion)

## Introduction
This project is a companion project of my previous project [football-correlation](https://github.com/hhan31415/football-correlation/tree/main). In that project, I computed correlation values between various metrics and points for each league to determine league-wide patterns and determine what metrics best predict success across various leagues. 

This project similarly computes correlation values, this time for specific clubs, to discern which statistic best predicts success for each club. We do this by taking the match statistics for each game a club has played in a season, and applying Pearson and Spearman tests as well as FDR-adjusted p-values for each metric vs non-Penalty xG difference. We chose nPxG difference as our dependent variable since it is continuous (rather than loss/draw/win) and is a great metric that takes into account overall team performance in offense, defense, and chance creation.

The resulting significant discoveries will give us information about which metric likely correlates with on-field success for each club. For example, if a club has high positive correlation for crosses, we can reasonably predict that crossing might the primary successful method that club scores goals and wins matches.

This project will specifically look at the [2025-2026 Premier League Season](data/premier_league_season_2025-2026_stats.csv) [2026 MLS season](data/mls_season_2026_stats.csv) upto the World Cup break, although the overall pipeline and analysis can be used for any collection of match data. The match data itself was scraped from my [FotMob data scraper](https://github.com/hhan31415/fotmob-scraper).

## Correlation Data
The correlation computation is done via R in [mls_correlation.R](mls_correlation.R). We first clean up the table and add metrics "non-penalty xG against" and "non-penalty xG difference". We then compute correlation values for each relevant metric against non-penalty xG difference for each club. The data for each club is stored [here](output/club_results/).

Because we are doing a correlation test for each relevant metric and each club in a league, the number of tests done can easily reach over a thousand. Thus we will perform the Benhamini-Hochberg procedure to control the False Discovery Rate (FDR). We then filter to discoveries significant at FDR < 0.05. This means that among all tests declared significant, the *expected false discovery proportion* - the average share of those discoveries that are false positives, across repeated sampling - is controlled at or below 5%. 

This is a property of the discovery set as a whole, not a per-test guarantee: it does not mean any individual discovery has a 95% probability of reflecting a real relationship, only that the batch of discoveries as a group is expected to contain few false positives. With that caveat, an FDR of 5% still gives reasonable confidence that the bulk of these discoveries reflect genuine relationships rather than artifacts of testing many hypotheses at once.

[This file](output/mls_correlation_significant_results.csv) contains the 85 discoveries significant at FDR < 0.05. We will now analyze this information to point out potential weaknesses and strengths in various clubs which can aid in tactical preparations.

## Analysis
First, why compute correlation and run hypothesis tests instead of simply analyzing the raw data? The reason is that our goal is more than just finding out what metrics clubs put high or low numbers at. The same metric at the same value may account for vastly different match performances. A high number for crosses could be a result of a dominant attacking performance and possession in the final third, but it could also be from a lack of real chance creation leading to desperate crosses. A high number of clearances could be a result of being pushed back and pressed on defense, or it could be a deliberate tactical choice from having strong target men with great hold-up play. 

In either case, the same underlying metric with the same value require vastly different tactical responses. This is why we calculate correlation against npxG difference. If for some club, a metric shows a strong positive correlation against npxG difference, we can predict that both the offensive and defensive performance of the club tends to increase as the underlying metric increases. On the other hand, a lack of strong correlation may imply that increasing or decreasing that metric has little impact on a team's performance.

###
