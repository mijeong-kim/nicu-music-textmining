# NICU Music Text Mining

This repository contains R scripts, processed summary tables, and figure outputs for a text-mining and topic-modeling study of music-based interventions in neonatal intensive care units (NICUs).

## What is included

- Public-facing R scripts used to regenerate the main and supplementary figures
- Processed CSV files needed for figure generation
- High-resolution PNG figure outputs

## What is not included

- The private analytic workbook used during manuscript development
- Raw abstract text files
- Any source material that may raise copyright or redistribution concerns

For that reason, the repository is designed around processed summary tables rather than raw text. This keeps the public materials shareable while preserving the main analytic workflow used to produce the figures.

## Repository structure

```text
nicu-music-textmining/
  README.md
  .gitignore
  scripts/
    refresh_figures.R
    make_study_selection_figure.R
  data/
    processed/
      intervention_trend.csv
      MM_keyword_summary.csv
      MT_keyword_summary.csv
      topic_intervention_counts.csv
      topic_period_counts.csv
      top_keywords.csv
      top_period_keywords.csv
      top_terms.csv
  results/
    figures/
      00_study_selection_overview.png
      01_keyword_frequency.png
      02_keyword_frequency_by_period.png
      03_keywords_by_intervention_type.png
      04_topic_modeling_results.png
      05_topic_trends.png
      A1_effect_phrase_by_period.png
      A2_topic_similarity.png
      A3_topic_keyword_network.png
      A4_topic_intervention_heatmap.png
```

## Required R packages

The main plotting script uses:

- `readr`
- `dplyr`
- `stringr`
- `forcats`
- `ggplot2`
- `tidyr`
- `tidytext`

The topic-keyword network figure additionally requires:

- `igraph`
- `ggraph`

## How to run

From the repository root:

```r
Rscript scripts/refresh_figures.R
Rscript scripts/make_study_selection_figure.R
```

The regenerated figures will be written to `results/figures/`.

## Notes on reproducibility

- Figures 1--4 and most supplementary figures are regenerated directly from processed summary CSV files in `data/processed/`.
- Topic trend and topic-by-intervention figures are reproduced from public summary tables derived from the original analytic workflow, rather than from private raw-text inputs.
- The study-selection overview is a documentation figure based on retained workflow notes and the final analytic corpus size (`n = 83`).
