suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(forcats)
  library(ggplot2)
  library(tidyr)
  library(tidytext)
})

script_path_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_path_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", script_path_arg[1]), winslash = "/", mustWork = TRUE)
  root_dir <- dirname(dirname(script_path))
} else {
  root_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

input_dir <- file.path(root_dir, "data", "processed")
output_dir <- file.path(root_dir, "results", "figures")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

save_plot <- function(plot, filename, width = 10, height = 6, dpi = 320) {
  ggsave(
    filename = file.path(output_dir, filename),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white"
  )
}

clean_period <- function(x) {
  x %>%
    str_replace_all("[\u2012\u2013\u2014\u2212]", "-") %>%
    str_trim()
}

theme_codex <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 11, color = "#444444"),
      axis.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      strip.text = element_text(face = "bold"),
      legend.title = element_text(face = "bold")
    )
}

# 1. Keyword frequency
top_keywords <- read_csv(file.path(input_dir, "top_keywords.csv"), show_col_types = FALSE) %>%
  slice_max(total_freq, n = 15, with_ties = FALSE) %>%
  mutate(keyword = fct_reorder(keyword, total_freq))

p1 <- ggplot(top_keywords, aes(total_freq, keyword)) +
  geom_col(fill = "#2D5F8B", width = 0.75) +
  labs(
    title = "RAKE-Derived Keyphrase Frequency",
    subtitle = "Top multi-word keyphrases extracted from NICU music intervention abstracts",
    x = "Total frequency across abstracts",
    y = "Keyphrase"
  ) +
  theme_codex()

save_plot(p1, "01_keyword_frequency.png", width = 10.5, height = 6.2)

# 2. Keyword frequency by period
period_keywords <- read_csv(file.path(input_dir, "top_period_keywords.csv"), show_col_types = FALSE) %>%
  mutate(period = factor(period, levels = c("Period 1", "Period 2", "Period 3", "Period 4"))) %>%
  group_by(period) %>%
  slice_max(freq, n = 6, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(keyword = reorder_within(keyword, freq, period))

p2 <- ggplot(period_keywords, aes(freq, keyword, fill = period)) +
  geom_col(show.legend = FALSE, width = 0.72) +
  scale_y_reordered() +
  facet_wrap(~period, scales = "free_y") +
  scale_fill_manual(values = c("Period 1" = "#4E79A7", "Period 2" = "#59A14F", "Period 3" = "#E15759", "Period 4" = "#B07AA1")) +
  labs(
    title = "Keyword Frequency Analysis by Period",
    subtitle = "Most frequent keywords within each publication period",
    x = "Frequency",
    y = NULL
  ) +
  theme_codex()

save_plot(p2, "02_keyword_frequency_by_period.png", width = 11.2, height = 7.2)

# 3. Keywords by intervention type
mm <- read_csv(file.path(input_dir, "MM_keyword_summary.csv"), show_col_types = FALSE) %>%
  mutate(group = "Music medicine")
mt <- read_csv(file.path(input_dir, "MT_keyword_summary.csv"), show_col_types = FALSE) %>%
  mutate(group = "Music therapy")

intervention_keywords <- bind_rows(mm, mt) %>%
  group_by(group) %>%
  slice_max(total_freq, n = 10, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(keyword = reorder_within(keyword, total_freq, group))

p3 <- ggplot(intervention_keywords, aes(total_freq, keyword, fill = group)) +
  geom_col(show.legend = FALSE, width = 0.72) +
  scale_y_reordered() +
  facet_wrap(~group, scales = "free_y") +
  scale_fill_manual(values = c("Music medicine" = "#4F7C5A", "Music therapy" = "#1E9BB6")) +
  labs(
    title = "Keywords by Intervention Type",
    subtitle = "Contrasting frequent keyphrases in music medicine and music therapy studies",
    x = "Frequency",
    y = NULL
  ) +
  theme_codex()

save_plot(p3, "03_keywords_by_intervention_type.png", width = 11.4, height = 7.2)

# 4. Topic modeling results
top_terms <- read_csv(file.path(input_dir, "top_terms.csv"), show_col_types = FALSE) %>%
  mutate(topic = factor(topic)) %>%
  group_by(topic) %>%
  slice_max(beta, n = 10, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(term = reorder_within(term, beta, topic))

p4 <- ggplot(top_terms, aes(beta, term, fill = topic)) +
  geom_col(show.legend = FALSE, width = 0.72) +
  scale_y_reordered() +
  facet_wrap(~topic, scales = "free_y") +
  scale_fill_manual(values = c("1" = "#F26D6D", "2" = "#86B300", "3" = "#18B7C5", "4" = "#B77CF2")) +
  labs(
    title = "Top LDA Terms by Topic",
    subtitle = "Highest-probability terms within each latent topic",
    x = "Term probability within topic (beta)",
    y = "Term"
  ) +
  theme_codex()

save_plot(p4, "04_topic_modeling_results.png", width = 12, height = 7.5)

# 5. Topic trends
topic_period <- read_csv(file.path(input_dir, "topic_period_counts.csv"), show_col_types = FALSE) %>%
  mutate(
    period = factor(period, levels = c("Period 1", "Period 2", "Period 3", "Period 4")),
    topic = factor(topic, levels = c("1", "2", "3", "4"), labels = c("Topic 1", "Topic 2", "Topic 3", "Topic 4"))
  ) %>%
  complete(period, topic, fill = list(n = 0))

p5 <- ggplot(topic_period, aes(period, topic, fill = n)) +
  geom_tile(color = "white", linewidth = 1.15, width = 0.96, height = 0.9) +
  geom_text(aes(label = n), size = 4.6, fontface = "bold", color = "#1F1F1F") +
  scale_fill_gradient(
    low = "#E8F1FB",
    high = "#1F5A91"
  ) +
  labs(
    title = "Dominant Topic Assignments by Publication Period",
    subtitle = "Annotated heatmap showing study counts after assigning each abstract to its highest-gamma topic",
    x = "Publication period",
    y = NULL,
    fill = "Study count"
  ) +
  theme_codex() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(face = "bold"),
    axis.text.y = element_text(face = "bold")
  )

save_plot(p5, "05_topic_trends.png", width = 9.6, height = 5.8)

# Appendix A1. Effect-focused phrases by period
intervention_trend <- read_csv(file.path(input_dir, "intervention_trend.csv"), show_col_types = FALSE) %>%
  mutate(
    period = factor(clean_period(period), levels = c("1998-2015", "2016-2020", "2020-2022", "2022-2025")),
    type = factor(
      type,
      levels = c("Music therapy", "Music listening", "Lullaby / Mother voice", "Live music / Singing", "Combined intervention", "Other")
    )
  )

p_a1 <- ggplot(intervention_trend, aes(period, type, fill = n)) +
  geom_tile(color = "white", linewidth = 1.1) +
  geom_text(aes(label = n), size = 4.2, fontface = "bold", color = "#1F1F1F") +
  scale_fill_gradient(
    low = "#E8F1FB",
    high = "#2D6DA3",
    limits = c(0, max(intervention_trend$n, na.rm = TRUE))
  ) +
  labs(
    title = "Effect-Focused Intervention Phrases Across Publication Periods",
    subtitle = "Counts of extracted effect(s) of ... phrases by intervention category and period",
    x = "Publication period",
    y = NULL,
    fill = "Phrase count"
  ) +
  theme_codex() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(face = "bold"),
    axis.text.y = element_text(face = "bold")
  )

save_plot(p_a1, "A1_effect_phrase_by_period.png", width = 10.5, height = 5.8)

# Appendix A2. Topic similarity
topic_matrix <- read_csv(file.path(input_dir, "top_terms.csv"), show_col_types = FALSE) %>%
  select(topic, term, beta) %>%
  pivot_wider(names_from = term, values_from = beta, values_fill = 0)

topic_values <- as.matrix(topic_matrix[, -1, drop = FALSE])
rownames(topic_values) <- paste0("Topic ", topic_matrix$topic)

cosine_sim <- function(a, b) {
  sum(a * b) / (sqrt(sum(a * a)) * sqrt(sum(b * b)))
}

sim_grid <- expand_grid(topic_x = rownames(topic_values), topic_y = rownames(topic_values)) %>%
  rowwise() %>%
  mutate(value = cosine_sim(topic_values[topic_x, ], topic_values[topic_y, ])) %>%
  ungroup()

p_a2 <- ggplot(sim_grid, aes(topic_x, topic_y, fill = value)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f", value)), size = 4) +
  scale_fill_gradient(low = "#4A78B1", high = "#D9412C") +
  coord_equal() +
  labs(
    title = "Topic Similarity",
    x = "Topic",
    y = "Topic",
    fill = "Cosine"
  ) +
  theme_codex()

save_plot(p_a2, "A2_topic_similarity.png", width = 8, height = 6.8)

# Appendix A3. Topic-keyword network analysis
has_network_pkgs <- requireNamespace("igraph", quietly = TRUE) && requireNamespace("ggraph", quietly = TRUE)
if (has_network_pkgs) {
  edges <- read_csv(file.path(input_dir, "top_terms.csv"), show_col_types = FALSE) %>%
    filter(beta > 0.04) %>%
    mutate(topic = paste0("Topic ", topic)) %>%
    select(topic, term, beta)

  if (nrow(edges) > 0) {
    graph <- igraph::graph_from_data_frame(edges)

    p_a3 <- ggraph::ggraph(graph, layout = "fr") +
      ggraph::geom_edge_link(aes(width = beta), alpha = 0.45, color = "gray45") +
      ggraph::geom_node_point(size = 4.2, color = "black") +
      ggraph::geom_node_text(aes(label = name), repel = TRUE, size = 3.8) +
      ggraph::scale_edge_width(range = c(0.4, 2.5)) +
      labs(title = "Topic-Keyword Network Analysis") +
      theme_void()

    save_plot(p_a3, "A3_topic_keyword_network.png", width = 12, height = 6.8)
  }
} else {
  message("Skipping A3_topic_keyword_network.png because igraph/ggraph are not installed.")
}

# Appendix A4. Topic by intervention type
topic_intervention_table <- read_csv(file.path(input_dir, "topic_intervention_counts.csv"), show_col_types = FALSE) %>%
  mutate(
    topic = factor(topic, levels = c("1", "2", "3", "4")),
    type = factor(type, levels = c("etc", "MM", "MT", "PE"))
  ) %>%
  complete(topic, type, fill = list(n = 0))

p_a4 <- ggplot(topic_intervention_table, aes(type, topic, fill = n)) +
  geom_tile(color = "white", linewidth = 1) +
  geom_text(aes(label = n), size = 4.2, fontface = "bold", color = "#1F1F1F") +
  scale_fill_gradient(low = "#E8F1FB", high = "#25476A") +
  labs(
    title = "Topic by Intervention Type",
    subtitle = "Dominant topic assignments by intervention category",
    x = "Intervention type",
    y = "Topic",
    fill = "Count"
  ) +
  theme_codex() +
  theme(panel.grid = element_blank())

save_plot(p_a4, "A4_topic_intervention_heatmap.png", width = 8.8, height = 5.8)

message("Figure refresh completed: ", output_dir)
