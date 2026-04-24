# NICU Music Text Mining

This repository contains R scripts, processed summary tables, and figure outputs for a text-mining and topic-modeling study of music-based interventions in neonatal intensive care units (NICUs).

## What is included

- Public-facing R scripts used to regenerate the main and supplementary figures
- Processed CSV files needed for figure generation
- High-resolution PNG figure outputs
- A lightweight reproducibility scaffold for readers and reviewers

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
    summarize_effect_phrases.R
  data/
    processed/
      effect_phrase_summary_normalized.csv
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

## Tested environment

- `R` 4.5.0
- macOS Apple Silicon
- Core packages used in the current public workflow:
  `readr`, `dplyr`, `stringr`, `forcats`, `ggplot2`, `tidyr`, `tidytext`, `igraph`, `ggraph`

If package versions differ slightly on another machine, the regenerated figures should remain substantively similar because the public workflow is driven by processed summary tables rather than stochastic refitting from raw text.

## How to run

From the repository root:

```r
Rscript scripts/refresh_figures.R
Rscript scripts/make_study_selection_figure.R
```

The regenerated figures will be written to `results/figures/`.

If you have a local phrase-level extraction file for the supplementary
`effect(s) of ...` analysis, you can also regenerate the normalized phrase
summary used for the supplementary tables:

```r
Rscript scripts/summarize_effect_phrases.R path/to/effect_phrase_extracted.csv
```

For a clean setup, install the required packages first, for example:

```r
install.packages(c(
  "readr", "dplyr", "stringr", "forcats",
  "ggplot2", "tidyr", "tidytext", "igraph", "ggraph"
))
```

## Notes on reproducibility

- Figures 1--4 and most supplementary figures are regenerated directly from processed summary CSV files in `data/processed/`.
- Topic trend and topic-by-intervention figures are reproduced from public summary tables derived from the original analytic workflow, rather than from private raw-text inputs.
- The normalized `effect(s) of ...` phrase summary used for the supplementary tables is included as a processed CSV. A helper script is provided for authors who wish to recompute that summary from a local phrase-level extraction file.
- The study-selection overview is a documentation figure based on retained workflow notes and the final analytic corpus size (`n = 83`).
- The repository is intentionally public-safe: it excludes the private workbook and raw abstract text while retaining the processed outputs needed to inspect and reproduce the published visualizations.
