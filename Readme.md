---
editor_options: 
  markdown: 
    wrap: sentence
---

# Proposal for Semester Project

**Patterns & Trends in Environmental Data / Computational Movement Analysis / Geo 880**

| Semester:    | FS26                                                  |
|:-------------|:------------------------------------------------------|
| **Data:**    | Geolife GPS Trajectories                              |
| **Title:**   | Efficency of Trajectories on Different Spacial Scales |
| **Student:** | Manuel Oberhänsli                                     |

## Abstract

This project investigates the efficiency and directness of human movement trajectories using the GeoLife GPS Trajectory Dataset.
By comparing actual travel distances with direct Euclidean distances between trajectory endpoints, the study analyzes how trajectory efficiency varies across different spatial scales.
Statistical and spatial analyses will be used to identify patterns and relationships in human movement behavior.

## Research Questions

This project investigates the efficiency and directness of human movement trajectories within the GeoLife GPS Trajectory Dataset.
The study is guided by two main research questions: *How direct are the trajectories of different travellers when connecting their start and end points?* and *Does the degree of trajectory directness vary across different spatial scales?* To answer these questions, actual travel distances will be compared with the direct Euclidean distance between trajectory endpoints.
The resulting ratio will provide a measure of trajectory efficiency for each journey.
By analyzing these relationships statistically and visually, the project aims to identify broader movement patterns and determine whether longer trajectories tend to follow relatively more efficient routes than shorter ones.

## Results / products

The project is expected to produce quantitative measures of trajectory efficiency for a range of movements within the GeoLife dataset.
It is anticipated that the ratio between actual travel distance and direct endpoint distance will vary substantially across trajectories, reflecting differences in travel behavior, infrastructure, and movement constraints.
Furthermore, the study hypothesizes a negative correlation between trajectory length and this ratio, suggesting that longer journeys may follow relatively more efficient routes than shorter ones.
The final results will include statistical analyses, visualizations of trajectory efficiency across spatial scales, and maps illustrating selected trajectories and their degree of directness.

## Data

The analysis will use approximately 100 trajectories selected from the GeoLife GPS Trajectory Dataset (Version 1.3), published by Microsoft Research.
The dataset contains detailed GPS recordings of human movement collected over several years and includes information such as geographic coordinates, timestamps, and trajectory structure.
A subset of trajectories representing different travel distances and movement patterns will be extracted for analysis.
No additional external datasets are required, as all necessary spatial and temporal information is contained within the GeoLife dataset itself.

## Analytical concepts

The project applies concepts from computational movement analysis and spatial trajectory modelling to examine the efficiency of human movement patterns.
In a first step, raw GPS trajectories will be segmented into periods of active travel in order to remove stationary intervals and reduce noise in the dataset.
For each resulting movement trajectory, start and end points will be identified and used to calculate both the direct Euclidean distance and the actual travelled distance along the recorded path.
The ratio between these two measures will serve as an indicator of trajectory directness and movement efficiency.

The analysis will further investigate how this ratio changes across different spatial scales by comparing trajectories of varying lengths.
Statistical methods, including correlation analysis and linear regression, will be used to examine potential relationships between travel distance and trajectory efficiency.
Spatial visualization techniques will additionally be applied to display selected trajectories and highlight broader movement patterns within the dataset.

## R concepts

The project will mainly use the R packages `sf`, `dplyr`, `ggplot2`, and `tmap` for spatial data processing, visualization, and analysis.
GPS trajectories will be transformed into spatial objects, filtered by movement characteristics such as speed and time differences, and analyzed using distance calculations between trajectory points.
Statistical relationships between trajectory efficiency and travel distance will be explored using correlation analysis and linear mode

## Risk analysis

One potential challenge of the project is the automated identification of meaningful trajectory start and end points across a large number of GPS recordings, as movement patterns and trajectory structures vary considerably between individuals.
In addition, the dataset does not consistently identify modes of transportation, although travel mode is expected to influence trajectory directness and efficiency.
The workflow also involves several independent preprocessing and analysis steps, each introducing potential sources of error related to data quality, segmentation, and distance calculations.
Detecting, evaluating, and correcting these issues may require substantial time and could limit the scope of the analysis.
To maintain feasibility, trajectories that prove particularly problematic may be excluded from the study.
Remaining limitations and unavoidable uncertainties will be acknowledged and discussed in the final evaluation.

## Questions?

Is my project idea balanced in complexity and workload?

Are there any obvious problems to you that i missed?
