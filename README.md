# atypical_nurturant_care
This repository contains data and scripts to reproduce the summary statistics and figures for the Atypical Nurturant Care Behavior manuscript.
# Atypical Nurturant Care Behavior Analysis — README

Scripts to reproduce the summary statistics and figures for the
Atypical Nurturant Care Behavior manuscript.

## Files

| File | Purpose |
|---|---|
| `01_functions.R` | Shared functions: loads and cleans the raw data, computes `Standardized_Gestation_Day`, and defines the shared figure theme/colors. Sourced by both scripts below — not run on its own. |
| `02_summary_statistics.R` | Produces every summary statistic reported in the manuscript text. No figure, but creates "summary_statistics_output.txt" output file. |
| `03_figures.R` | Produces every figure (fig3a–b, fig4, fig5a–c, fig6). No stats. |

## Raw File Metadata

Data dictionary for the raw observations file.

| Column Name | Description |
|---|---|
| UID | Unique ID for each instance of atypical nurturant care |
| BRD | Otter BRD (tag) number |
| Rehab_Research | Whether an otter was tagged via a research study or due to rehabilitation and care (either as an orphaned pup or injured older animal). |
| Mom Age | Estimated age of mom at time of behavior |
| Date of Care | Date of first observation of atypical care behavior |
| Days Carcass Carried | Duration of carcass carrying (in days) |
| Days Adopted | Duration of adoption length (in days) |
| Days After Wean/Loss | Days after previous pup wean/loss (if known) |
| Days Before Birth | Days before next pup birth (if known) |
| Description | Detailed description of behavior observed (listed in Supplemental Figure 1) |
| Atypical Behavior | Type of behavior observed (conspecific care, misdirected care, or carrying a dead pup) |
| Repro Stage Cond | Stage of reproduction in which the behavior occurred (wean/loss, pup birth, gestation) |
| Lat | Latitude coordinates of behavior in decimal degrees |
| Long | Longitude coordinates of behavior in decimal degrees |
| Year | Year of observation |
> **Note:** this dictionary describes the full raw data collection schema. `data_konrad_2026.xlsx`

## Setup

**Folder structure** — these three scripts expect to sit in a project root alongside a `raw/` folder:

```
your_project/
├── 01_functions.R
├── 02_summary_statistics.R
├── 03_figures.R
└── raw/
    └── data_konrad_2026.xlsx
└── figures/
    └── fig3a.png
    └── fig3b.png
    └── fig3c.png
    └── fig4.png
    └── fig5a.png
    └── fig5b.png
    └── fig5c.png
    └── fig6.png
└── output/
    └── summary_statistics_output.txt
```

Open the project in RStudio (or set your working directory to `your_project/`) so that `here::here()` resolves correctly. `output/` and `figures/` folders are created automatically when you run the scripts — you don't need to make them yourself.

**Packages** — `librarian::shelf()` at the top of `01_functions.R` will auto-install anything missing the first time you run it. Required: `tidyverse`, `readxl`, `writexl`, `dplyr`, `janitor`, `ggpubr`, `scales`.

## Running

Run in a **fresh R session** (`Session > Restart R` in RStudio first) so you're not relying on leftover objects from a previous run:

```r
source("02_summary_statistics.R")
source("03_figures.R")
```

Both scripts source `01_functions.R` themselves — you don't need to run it separately.

## Output

- `02_summary_statistics.R` writes all console output to `output/summary_statistics_output.txt`, so there's a permanent record of the exact numbers behind the manuscript text (in addition to printing to console).
- `03_figures.R` writes each figure as a `.png` to `figures/` (600 dpi), plus `figures/sessionInfo.txt` recording the package versions used to generate them.

## Data notes

- Raw file expected: `raw/data_konrad_2026.xlsx`.
- `brd` (band ID) is the individual-female identifier used throughout.
- `repro_stage_cond` is the only reproductive-stage column in the raw file (categories: wean/loss, pup birth, gestation).
- `Standardized_Gestation_Day` isn't in the raw file — it's computed in `load_and_prepare_data()` from `days_after_wean_loss` and `days_before_birth` (averaged when both are valid, otherwise whichever one is available; see comments in `01_functions.R` for the exact logic).
- `geom_jitter()` plots in `03_figures.R` are seeded (`set.seed(42)`) so re-running produces identical point positions.


## If something breaks

- **"path does not exist" error on the raw file** — usually means either the file isn't in `raw/`, or you're running a stale copy of `01_functions.R` (grep it for `xlsx` to check what filename it's actually looking for). Restart R and re-source before assuming the data is missing.
- **Column not found errors** — the raw file's column names are transformed by `janitor::clean_names()` (e.g. "Mom Age" → `mom_age`). If the raw file's columns change, `01_functions.R` will need updating to match.
