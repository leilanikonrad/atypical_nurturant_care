# 02_summary_statistics.R
#
# Produces the summary statistics reported in the atypical nurturant care behavior manuscript 
# (counts, proportions, means/SDs by group, reproductive-timing windows, etc.).
#
# Requires: raw/data_konrad_2026.xlsx
# Output:   summary_statistics_output.txt (all console output below, saved for
#           the record)
#
# Last updated: 2026-08-26

source(here::here("01_functions.R"))

rawdir <- here::here("raw")
outdir <- here::here("output")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

tab <- load_and_prepare_data(rawdir)

# Send everything below to a text file AND the console, so there's a saved
# record of the exact numbers used in the manuscript.

sink(file.path(outdir, "summary_statistics_output.txt"), split = TRUE) #sink begins

cat("=======4|RESULTS=======\n")
cat("Number of Instances:", length(tab$date_of_care), "\n\n")

cat("\nUnique females (rows by BRD ID):\n")
print(tab %>% distinct(brd) %>% count())

cat("\nCount of Females by Rehab_Research Status\n")
print(tab %>% distinct(brd, rehab_research) %>% count(rehab_research))

cat("\nRange of Years:", max(tab$year) - min(tab$year), "yrs\n")

cat("Count by atypical behavior types:\n")
print(tab %>% group_by(atypical_behavior) %>% count())

cat("\nSummary Statistics: mom_age\n")
cat("Standard deviation:", sd(tab$mom_age, na.rm = TRUE), "\n")
cat("Range:", min(tab$mom_age, na.rm = TRUE), max(tab$mom_age, na.rm = TRUE), "\n")
cat("Mean:", mean(tab$mom_age, na.rm = TRUE), "\n")



cat("\n\n=======4.1|CONSPECIFIC CARE=======\n\n")
cat("Females displaying Conspecific Care")
print(tab %>% filter(atypical_behavior == "Conspecific Care") %>% 
        group_by(brd) %>% count(), n=25)

cat("\n% of One-Off Instances (observed only once)\n")
tab %>% filter(atypical_behavior == "Conspecific Care") %>%
  summarise(
    n_seen_once   = sum(days_adopted < 2, na.rm = TRUE),
    n_total  = n(),
    percent_seen_once = (n_seen_once / n_total) * 100
  )

cat("\n% of Total Seen >1 day\n")
tab %>% filter(atypical_behavior == "Conspecific Care") %>%
  summarise(
    n_seen_more_than_once   = sum(days_adopted > 1, na.rm = TRUE),
    n_total  = n(),
    percent_seen_once = (n_seen_more_than_once / n_total) * 100
  )

cat("\nSummary Statistics: days_adopted (subset of data >1 day)\n")
cat("Range:", min(tab$days_adopted[tab$days_adopted > 1], na.rm = TRUE), 
    max(tab$days_adopted[tab$days_adopted > 1], na.rm = TRUE), "\n")
cat("Mean:", mean(tab$days_adopted[tab$days_adopted > 1], na.rm = TRUE), "\n")


cat("\n\n=======4.2|MISDIRECTED CARE=======\n\n")

cat("\n-- Misdirected Care --\n")
print(tab %>% filter(atypical_behavior == "Misdirected Care") %>% count())

cat("\nCount of Misdirected Care Behaviors by Female\n")
print(tab %>% filter(atypical_behavior == "Misdirected Care") %>% group_by(brd) %>% count())


cat("\n\n=======4.3|CARRYING DECEASED YOUNG=======\n\n")

cat("\nCount of Instances of Females Carrying Dead Pups\n")
print(tab %>% filter(atypical_behavior == "Carrying Dead Pup") %>% count())

cat("\nInstances of Females Carrying Dead Pups by Female\n")
print(tab %>% filter(atypical_behavior == "Carrying Dead Pup") %>% group_by(brd) %>% 
        count(), n = Inf)
cat("\nFemales Carrying Dead Pups More Than Once\n")
print(tab %>% filter(atypical_behavior == "Carrying Dead Pup") %>% group_by(brd) %>% 
        count() %>% filter(n>1), n = Inf)

cat("\nSummary Statistics: mom_age (Carrying Dead Pup only)\n")
cat("Standard deviation:", sd(tab$mom_age[tab$atypical_behavior == "Carrying Dead Pup"], 
                              na.rm = TRUE), "\n")
cat("Range:", min(tab$mom_age[tab$atypical_behavior == "Carrying Dead Pup"], 
                  na.rm = TRUE),
    max(tab$mom_age[tab$atypical_behavior == "Carrying Dead Pup"], 
        na.rm = TRUE), "\n")
cat("Mean:", mean(tab$mom_age[tab$atypical_behavior == "Carrying Dead Pup"], 
                  na.rm = TRUE), "\n")

cat("\nSummary Statistics: days_carcass_carried (Carrying Dead Pup only)\n")
cat("Standard deviation:", sd(tab$days_carcass_carried[tab$atypical_behavior == "Carrying Dead Pup"], 
                              na.rm = TRUE), "\n")
cat("Range:", min(tab$days_carcass_carried[tab$atypical_behavior == "Carrying Dead Pup"], 
                  na.rm = TRUE),
    max(tab$days_carcass_carried[tab$atypical_behavior == "Carrying Dead Pup"], 
        na.rm = TRUE), "\n")
cat("Mean:", mean(tab$days_carcass_carried[tab$atypical_behavior == "Carrying Dead Pup"], 
                  na.rm = TRUE), "\n")
cat("Females seen carrying dead pup that also engaged in Conspecific Care:",  
    length(unique(tab$brd[tab$atypical_behavior == "Conspecific Care" & 
                            tab$brd %in% unique(tab$brd[tab$atypical_behavior 
                                                        == "Carrying Dead Pup"])])), "\n")
cat("Females seen carrying dead pup that also engaged in Misdirected Care:", 
    length(unique(tab$brd[tab$atypical_behavior == "Misdirected Care" & 
                            tab$brd %in% unique(tab$brd[tab$atypical_behavior 
                                                        == "Carrying Dead Pup"])])), "\n")

cat("\n\n=======4.4|REPRODUCTIVE TIMING=======\n\n")
cat("Occurrences with enough reproductive info:", 
    sum(tab$atypical_behavior %in% c("Conspecific Care", "Misdirected Care") & 
          !is.na(tab$Standardized_Gestation_Day)), "\n")

cat("Count of Females enough reproductive info:", 
    length(unique(tab$brd[tab$atypical_behavior %in% c("Conspecific Care", "Misdirected Care") & 
                            !is.na(tab$Standardized_Gestation_Day)])), "\n")

cat("Occurrences within 90 days of weaning/loss:", 
    sum(tab$atypical_behavior %in% c("Conspecific Care", "Misdirected Care") & 
          !is.na(tab$Standardized_Gestation_Day) & tab$Standardized_Gestation_Day <= 90), "\n")

cat("Percent within 90 days:", 
    round(100 * sum(tab$atypical_behavior %in% c("Conspecific Care", "Misdirected Care") & 
                      !is.na(tab$Standardized_Gestation_Day) & tab$Standardized_Gestation_Day <= 90) /
            sum(tab$atypical_behavior %in% c("Conspecific Care", "Misdirected Care") & 
                  !is.na(tab$Standardized_Gestation_Day)), 1), "\n")

cat("Occurences within 30 days of next birth):", 
    sum(tab$atypical_behavior %in% c("Conspecific Care", "Misdirected Care") & 
          !is.na(tab$Standardized_Gestation_Day) & tab$Standardized_Gestation_Day > 90 & 
          tab$days_before_birth <= 30, na.rm = TRUE), "\n")

cat("\nSummary Statistics: Standardized gestation period\n")
cat("Standard deviation:", sd(tab$Standardized_Gestation_Day, na.rm = TRUE), "\n")
cat("Range:", min(tab$Standardized_Gestation_Day, na.rm = TRUE), max(tab$Standardized_Gestation_Day, na.rm = TRUE), "\n")
cat("Mean:", mean(tab$Standardized_Gestation_Day, na.rm = TRUE), "\n")

sink() #sink ends

cat("Done. Full output saved to:", file.path(outdir, "summary_statistics_output.txt"), "\n")
