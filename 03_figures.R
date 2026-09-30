# 03_figures.R
#
# Produces figure set for the atypical nurturant care behavior manuscript.
# All figures share one color palette and theme (see 01_functions.R::theme_journal).
#
# Requires: raw/data_konrad_2026.xlsx
# Output:   figures/fig3a.png, fig3b.png, fig4.png,
#           fig5a.png, fig5b.png, fig5c.png, fig6.png
#
# Last updated: 2026-08-26

source(here::here("01_functions.R"))

set.seed(42) # geom_jitter() below is randomized — fixed seed for reproducible output

rawdir <- here::here("raw")
figdir <- here::here("figures")
dir.create(figdir, showWarnings = FALSE, recursive = TRUE)

tab <- load_and_prepare_data(rawdir)
othertab <- as.data.frame(read_xlsx(file.path(rawdir, "nonatypical_data_konrad_2026.xlsx")))

# =============================================================================
# FIGURE 3A-C
# =============================================================================

# fig3a: observations per year (lollipop)
count_year <- tab %>% group_by(year) %>% count()
fig3a <- ggplot(count_year, aes(x = year, y = n)) +
  geom_col(fill = FILL_COLOR) +
  labs(x = "Year", y = "Count") +
  scale_y_continuous(expand = c(0, 0), breaks = integer_breaks()) +
  theme_journal()
ggsave(fig3a, filename = file.path(figdir, "fig3a.png"), bg = "white",
       width = 8, height = 4, units = "in", dpi = 600)

# fig3b: count by behavior type by female age
fig3b <- tab %>% ggplot(aes(x = mom_age)) +
  geom_density(aes(y = after_stat(count)), fill = FILL_COLOR, color = LINE_COLOR, alpha = 0.8) +
  geom_rug(color = LINE_COLOR) + 
  labs(x = "Age of Female (yrs)", y = "Count") +
  scale_y_continuous(expand = c(0, 0), breaks = integer_breaks()) +
  scale_x_continuous(expand = c(0, 0)) +
  facet_grid(~atypical_behavior) +
  theme_minimal()
ggsave(fig3b, filename = file.path(figdir, "fig3b.png"), bg = "white",
       width = 8, height = 4, units = "in", dpi = 600)

# =============================================================================
# FIGURE 4 — adoption duration (Conspecific Care, >1 day observed)
# =============================================================================

fig4 <- tab %>%
  filter(atypical_behavior == "Conspecific Care", days_adopted > 1) %>%
  ggplot(aes(x = days_adopted, y = "")) +
  geom_boxplot(fill = FILL_COLOR, alpha = 0.8, outlier.shape = NA) +
  geom_jitter(color = LINE_COLOR, alpha = 0.5, size = 2.5, position = 
                position_jitter(width = 0, height = 0.1, seed = 42)) +
  labs(y = "", x = "Adoption Duration Observed (days)") +
  theme_journal() 
ggsave(fig4, filename = file.path(figdir, "fig4.png"), bg = "white",
       width = 5, height = 4, units = "in", dpi = 600)

# =============================================================================
# FIGURE 5A-C — carrying dead pup
# =============================================================================

subset_dead <- tab %>% filter(atypical_behavior == "Carrying Dead Pup")

# fig5a: instances per female (by otter ID)
mom_dead <- as.data.frame(subset_dead %>% group_by(brd) %>% count())
fig5a <- ggplot(mom_dead, aes(x = brd, y = n)) +
  geom_col(fill = FILL_COLOR) +
  coord_flip() +
  labs(x = "Female", y = "Instances of Carrying a Dead Pup") +
  theme_journal()
ggsave(fig5a, filename = file.path(figdir, "fig5a.png"), bg = "white",
       width = 4, height = 8, units = "in", dpi = 600)

# fig5b: age of females
fig5b <- subset_dead %>% ggplot(aes(x = mom_age)) +
  geom_density(aes(y = after_stat(count)), fill = FILL_COLOR, alpha = 0.8) +
  geom_rug(color = LINE_COLOR) +
  labs(x = "Age of Female (yrs)", y = "Count") +
  scale_y_continuous(expand = c(0, 0), breaks = integer_breaks()) +
  scale_x_continuous(expand = c(0, 0)) +
  theme_journal()
ggsave(fig5b, filename = file.path(figdir, "fig5b.png"), bg = "white",
       width = 6, height = 4, units = "in", dpi = 600)

# fig5c: duration of carrying a dead pup
fig5c <- subset_dead %>% ggplot(aes(x = days_carcass_carried, y = "")) +
  geom_boxplot(fill = FILL_COLOR, alpha = 0.8, outlier.shape = NA) +
  geom_jitter(color = LINE_COLOR, alpha = 0.5, size = 2.5, position = 
                position_jitter(width = 0, height = 0.1, seed = 42)) +
  labs(x = "Duration of Carrying a Dead Pup (days)", y = "") +
  scale_x_continuous(breaks = seq(2, 10, by = 2)) +
  theme_journal()
ggsave(fig5c, filename = file.path(figdir, "fig5c.png"), bg = "white",
       width = 6, height = 4, units = "in", dpi = 600)

# =============================================================================
# FIGURE 6 — reproductive timing of atypical nurturant care (uses
# Standardized_Gestation_Day, computed in 01_functions.R::load_and_prepare_data())
# =============================================================================

fig6 <- tab %>%
  filter(atypical_behavior != "Carrying Dead Pup", Standardization_Note != "Not Enough Info") %>%
  ggplot(aes(x = Standardized_Gestation_Day)) +
  geom_density(aes(y = after_stat(density) * 100), fill = FILL_COLOR, color = FILL_COLOR, alpha = 0.4) +
  geom_rug(color = LINE_COLOR) +
  geom_vline(xintercept = 14, linetype = "dashed", linewidth = 0.65) +
  geom_vline(xintercept = 90, linetype = "dashed", linewidth = 0.65) +
  labs(x = "Reproductive Timing of Atypical Nurturant Care Event", y = "Density of Occurrences") +
  scale_x_continuous(expand = c(0, 0)) +
  theme_journal()
ggsave(fig6, filename = file.path(figdir, "fig6.png"), bg = "white",
       width = 6, height = 5, units = "in", dpi = 600)

# =============================================================================
# Session info, saved alongside the figures for the reproducibility record
# =============================================================================

writeLines(capture.output(sessionInfo()), file.path(figdir, "sessionInfo.txt"))
cat("Done. Figures written to:", figdir, "\n")

