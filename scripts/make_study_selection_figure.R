suppressPackageStartupMessages({
  library(ggplot2)
})

script_path_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_path_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", script_path_arg[1]), winslash = "/", mustWork = TRUE)
  root_dir <- dirname(dirname(script_path))
} else {
  root_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

output_dir <- file.path(root_dir, "results", "figures")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

boxes <- data.frame(
  x = c(0, 0, 0, 0),
  y = c(3, 2, 1, 0),
  label = c(
    "Records identified through database searching\nGoogle Scholar, PubMed, and EBSCO\n(1998 to February 2025)",
    "Title and abstract screening\nPeer-reviewed NICU music-intervention studies",
    "Eligibility assessment\nExcluded when not relevant, non-English/non-Korean,\nor lacking a clear intervention description",
    "Studies included in the text-mining corpus\nn = 83"
  )
)

arrows <- data.frame(
  x = c(0, 0, 0),
  xend = c(0, 0, 0),
  y = c(2.72, 1.72, 0.72),
  yend = c(2.28, 1.28, 0.28)
)

p <- ggplot() +
  geom_label(
    data = boxes,
    aes(x = x, y = y, label = label),
    size = 4.2,
    linewidth = 0.6,
    label.padding = grid::unit(0.35, "lines"),
    fill = c("#EAF2FB", "#F6F8FB", "#F6F8FB", "#D8E9F8"),
    color = "#1F1F1F",
    fontface = c("plain", "plain", "plain", "bold")
  ) +
  geom_segment(
    data = arrows,
    aes(x = x, y = y, xend = xend, yend = yend),
    arrow = grid::arrow(length = grid::unit(0.22, "inches"), type = "closed"),
    linewidth = 0.8,
    color = "#4E6E8E"
  ) +
  annotate(
    "text",
    x = 0.95,
    y = 1.55,
    label = "Exact counts for pre-inclusion stages\nwere not retained in the analytic workbook.",
    hjust = 0,
    vjust = 0.5,
    size = 4,
    color = "#5A5A5A"
  ) +
  coord_cartesian(xlim = c(-1.7, 2.2), ylim = c(-0.45, 3.45), clip = "off") +
  labs(
    title = "Study Selection Overview",
    subtitle = "Available documentation confirms the final analytic corpus of 83 studies"
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.02),
    plot.subtitle = element_text(size = 11, color = "#555555", hjust = 0.02),
    plot.margin = margin(18, 40, 18, 20)
  )

ggsave(
  filename = file.path(output_dir, "00_study_selection_overview.png"),
  plot = p,
  width = 10.5,
  height = 7.2,
  dpi = 320,
  bg = "white"
)
