# ================================
# Alumni Experiential Learning Analysis
# Data Preprocessing 2:
# Continuing Education Subsample
# ================================

rm(list = ls())

library(tidyverse)
library(readr)
library(janitor)
library(stringr)

# -------------------------------
# Import Data
# -------------------------------

data_ce <- read_csv(
  "fds_2023.csv",
  show_col_types = FALSE
)

# -------------------------------
# Keep only submitted responses
# -------------------------------

data_ce <- data_ce %>%
  filter(response_status == "submitted")

# -------------------------------
# Keep ONLY Continuing Education outcomes
# -------------------------------

data_ce <- data_ce %>%
  filter(str_trim(outcome) == "Continuing Education")

# -------------------------------
# Basic checks
# -------------------------------

# Number of CE respondents
nrow(data_ce)

# Distribution by college
table(data_ce$recipient_primary_college)

# Distribution by education level pursued
table(data_ce$continuing_education_level)

# Distribution by field of study
table(data_ce$continuing_education_major)

# -------------------------------
# Create EL Participation Binary
# -------------------------------

count_el_items <- function(x) {
  x <- as.character(x)
  x <- str_squish(x)

  if (is.na(x) | x == "") return(NA_integer_)
  if (x == "None of the above") return(0)

  x_cleaned <- str_remove_all(x, "\\([^)]*\\)")
  str_count(x_cleaned, ",") + 1
}

count_el_items_vec <- Vectorize(count_el_items)

data_ce <- data_ce %>%
  mutate(
    el_count = count_el_items_vec(el_participation),
    el_participation_binary = if_else(el_count > 0, 1, 0)
  )

# -------------------------------
# Save Continuing Education Dataset
# -------------------------------

write_csv(data_ce, "fds_2023_continuing_education.csv")