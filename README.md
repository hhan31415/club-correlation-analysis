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

This project similarly computes correlation values, this time for specific clubs, to discern which statistic best predicts success for each club. We do this by taking the match statistics for each game a club has played in a season, and applying Pearson and Spearman tests as well as FDR-corrected p-values for each metric vs non-Penalty xG difference. We chose nPxG difference as our dependent variable since it is continuous (rather than loss/draw/win) and is a great metric that takes into account overall team performance in offense, defense, and chance creation.

This project will specifically look at the [MLS match data for the 2026 season](data/mls_season_2026_stats.csv) upto the World Cup break, although the overall pipeline and analysis can be used for any collection of match data.

## Correlation Data
The correlation computation is done via R in [mls_correlatio]

Because we are doing a correlation test for each relevant metric and each club in a league, the numer of tests done can easily reach over a thousand. Thus we will perform the Benhamini-Hochberg procedure to control the False Discovery Rate (FDR). We then filter to discoveries significant at FDR < 0.05. This means that among all tests declared significant, the *expected false discovery proportion* - the average share of those discoveries that are false positives, across repeated sampling - is controlled at or below 5%. 

This is a property of the discovery set as a whole, not a per-test guarantee: it does not mean any individual discovery has a 95% probability of reflecting a real relationship, only that the batch of discoveries as a group is expected to contain few false positives. With that caveat, an FDR of 5% still gives reasonable confidence that the bulk of these discoveries reflect genuine relationships rather than artifacts of testing many hypotheses at once.

