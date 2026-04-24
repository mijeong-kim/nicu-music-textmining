library(readr)
library(dplyr)
library(stringr)
library(tidyr)

args <- commandArgs(trailingOnly = TRUE)

input_path <- if (length(args) >= 1) {
  args[[1]]
} else {
  file.path("data", "processed", "effect_phrase_extracted.csv")
}

output_path <- if (length(args) >= 2) {
  args[[2]]
} else {
  file.path("data", "processed", "effect_phrase_summary_normalized.csv")
}

if (!file.exists(input_path)) {
  stop(
    paste(
      "Input file not found:", input_path,
      "\nThe repository includes a precomputed normalized summary CSV,",
      "but the phrase-level extracted input is not distributed by default."
    ),
    call. = FALSE
  )
}

normalize_effect_phrase <- function(x) {
  x %>%
    str_squish() %>%
    str_to_lower() %>%
    str_replace_all("’", "'") %>%
    str_replace_all(regex("^effects? of\\s+", ignore_case = TRUE), "effect of ") %>%
    str_replace_all(regex("\\(mt\\)", ignore_case = TRUE), "") %>%
    str_replace_all(regex("\\bcmt\\b", ignore_case = TRUE), "creative music therapy") %>%
    str_replace_all(regex("\\blpmt\\b", ignore_case = TRUE), "live-performed music therapy") %>%
    str_replace_all(regex("\\bmt\\b", ignore_case = TRUE), "music therapy") %>%
    str_squish()
}

effect_phrases <- read_csv(input_path, show_col_types = FALSE) %>%
  separate_rows(phrase, sep = "\\|") %>%
  transmute(
    id,
    phrase_raw = str_squish(str_to_lower(phrase)),
    phrase_norm = normalize_effect_phrase(phrase)
  )

summary_table <- effect_phrases %>%
  count(phrase_norm, sort = TRUE, name = "occurrences") %>%
  left_join(
    effect_phrases %>%
      distinct(id, phrase_norm) %>%
      count(phrase_norm, name = "unique_abstracts"),
    by = "phrase_norm"
  )

write_csv(summary_table, output_path)

print(head(summary_table, 15), n = 15, width = Inf)
