# 01_functions.R
#
# Shared functions for the atypical nurturant care behavior manuscript.
# Sourced by both 02_summary_statistics.R and 03_figures.R 
# for data prep and figure styling.
#
# Last updated: 2026-08-26

librarian::shelf(ggplot2, tidyverse, readxl, writexl, dplyr, janitor, ggpubr, scales)

# ---- load_and_prepare_data() -----------------------------------------------
# Imports the raw observations file, cleans column names, and computes the
# Standardized_Gestation_Day column (needed for fig6). Both scripts call this
# so the standardization logic only lives in one place.
#
# rawdir: path to the folder containing "data_konrad_2026.xlsx"
# Returns: cleaned data frame

load_and_prepare_data <- function(rawdir) {

  tab <- as.data.frame(read_excel(file.path(rawdir, "data_konrad_2026.xlsx")))
  tab <- tab %>% clean_names()
  tab$brd <- as.character(tab$brd)

  # ---- standardize gestation cycle day ----
  # Bounds for a valid gestation cycle
  VALID_MIN <- 0
  VALID_MAX <- 225 # 180 + 45-day cushion

  is_valid <- function(x) {
    !is.na(x) & x >= VALID_MIN & x <= VALID_MAX
  }

  tab <- tab %>%
    mutate(
      valid_A = is_valid(days_after_wean_loss),
      valid_B = is_valid(days_before_birth),

      candidate_A = ifelse(valid_A, days_after_wean_loss, NA_real_),
      candidate_B = ifelse(valid_B, 180 - days_before_birth, NA_real_),

      Standardized_Gestation_Day = case_when(
        valid_A & valid_B  ~ (candidate_A + candidate_B) / 2,
        valid_A & !valid_B ~ candidate_A,
        !valid_A & valid_B ~ candidate_B,
        TRUE               ~ NA_real_
      ),
      Standardization_Note = case_when(
        valid_A & valid_B  ~ "Averaged both columns",
        valid_A & !valid_B ~ "Used Days_After_Wean_Loss only",
        !valid_A & valid_B ~ "Used Days_Before_Birth only",
        TRUE               ~ "Not Enough Info"
      ),
      # clip negative results (from averaging near the cushion boundary) to 0
      Standardized_Gestation_Day = ifelse(
        !is.na(Standardized_Gestation_Day) & Standardized_Gestation_Day < 0,
        0, Standardized_Gestation_Day
      )
    ) %>%
    select(-valid_A, -valid_B, -candidate_A, -candidate_B)

  tab
}

# ---- theme_journal() -------------------------------------------------------
# One consistent look for every figure. Adjust here once instead of editing
# theme() calls in each plot.

theme_journal <- function(base_size = 11) {
  theme_minimal(base_size = base_size) %+replace%
    theme(
      text = element_text(size = base_size),
      plot.title = element_text(size = base_size, hjust = 0),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1)
    )
}

# Clean count axis breaks
integer_breaks <- function(n = 5, ...) {
  function(x) {
    breaks <- pretty(x, n = n, ...)
    breaks[breaks == round(breaks)]
  }
}

# Palette used across all figures — keep this the single definition
FILL_COLOR <- "darkseagreen4"
LINE_COLOR <- "#4f6b4a"
