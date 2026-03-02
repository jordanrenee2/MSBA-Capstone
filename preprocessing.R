# ================================
# Alumni Experiential Learning Analysis
# Data Preprocessing Script
# ================================

# ================================
# Install and Load Required Libraries
# ================================

#required_packages <- c("tidyverse", "readr", "janitor", "stringr", "MASS")
#installed_packages <- rownames(installed.packages())

#for (pkg in required_packages) {
  #if (!pkg %in% installed_packages) {
    #install.packages(pkg)
  #}
#}

rm(list = ls())  # clear all objects


# Load libraries
library(tidyverse)  # data manipulation and visualization
library(readr)      # reading CSVs
library(janitor)    # clean column names
library(stringr)    # string manipulation for EL counts
library(MASS)       # ordinal regression if needed
library(purrr)



# -------------------------------
# Import Data
# -------------------------------

data <- read_csv(
  "fds_2023.csv",
  show_col_types = FALSE,
  col_types = cols(
    id = col_double(),
    recipient_primary_major = col_character(),
    recipient_secondary_majors = col_character(),
    recipient_graduation_date = col_character(),
    recipient_education_level = col_character(),
    recipient_primary_college = col_character(),
    recipient_gender = col_character(),
    recipient_ethnicity = col_character(),
    recipient_graduation_group_name = col_character(),
    response_graduation_date = col_character(),
    response_status = col_character(),
    outcome = col_character(),
    employer_name = col_character(),
    employer_industry = col_character(),
    employment_category = col_character(),
    employment_type = col_character(),
    job_function = col_character(),
    job_position = col_character(),
    employed_during_education = col_character(),
    continuing_education_school = col_character(),
    continuing_education_level = col_character(),
    continuing_education_major = col_character(),
    still_looking_option = col_character(),
    not_seeking_option = col_character(),
    annual_salary = col_double(),
    pay_schedule = col_character(),
    bonus_amount = col_double(),
    other_compensation = col_double(),
    knowledge_response = col_character(),
    knowledge_source = col_character(),
    job_alignment = col_character(),
    el_participation = col_character(),
    el_helpfulness = col_character(),
    el_most_helpful = col_character()
  )
)

# Print number of missing values
print(sum(is.na(data$annual_salary)))
print(sum(is.na(data$bonus_amount)))
print(sum(is.na(data$other_compensation)))

# Print first few rows
print(head(data))

# Print rows with missing salary
print(data %>% filter(is.na(annual_salary)))


# -------------------------------
# Keep only submitted responses
# -------------------------------
data <- data %>%
  filter(response_status == "submitted")

# Optional check
table(data$response_status)

# Exclude respondents whose outcome is Continuing education
data <- data %>%
  filter(outcome != "Continuing Education")

# -------------------------------
# Recode job_alignment (3-level ordinal)
# -------------------------------
data <- data %>%
  mutate(
    job_alignment_num = case_when(
      str_trim(job_alignment) %in% c(
        "This position significantly fails to meet my expectations",
        "This position fails to meet my expectations"
      ) ~ 1,
      str_trim(job_alignment) == "No opinion" ~ 2,
      str_trim(job_alignment) %in% c(
        "This position meets my expectations",
        "This position exceeds my expectations"
      ) ~ 3,
      TRUE ~ NA_real_
    )
  )


# -------------------------------
# Recode el_helpfulness (ordinal 1-4)
# -------------------------------
data <- data %>%
  mutate(
    el_helpfulness_num = case_when(
      str_to_title(str_trim(el_helpfulness)) == "No" ~ 1,
      str_to_title(str_trim(el_helpfulness)) == "Neutral" ~ 2,
      str_to_title(str_trim(el_helpfulness)) == "Somewhat" ~ 3,
      str_to_title(str_trim(el_helpfulness)) == "Yes" ~ 4,
      TRUE ~ NA_real_
    )
  )

# -------------------------------
# Create binary version of EL helpfulness
# -------------------------------
# 0 = Did not help (No / Neutral)
# 1 = Helped (Somewhat / Yes)
data <- data %>%
  mutate(
    el_helpfulness_binary = case_when(
      el_helpfulness_num %in% c(1, 2) ~ 0,  # No or Neutral
      el_helpfulness_num %in% c(3, 4) ~ 1,  # Somewhat or Yes
      TRUE ~ NA_real_                        # keep missing as NA
    )
  )


# -------------------------------
# Function to count EL activities ignoring commas in parentheses
# -------------------------------
count_el_items <- function(x) {
  x <- as.character(x)   # ensure input is character
  x <- str_squish(x)     # remove extra spaces
  
  if (is.na(x) | x == "") return(NA_integer_)
  if (x == "None of the above") return(0)
  
  # Remove parentheses and their contents entirely
  x_cleaned <- str_remove_all(x, "\\([^)]*\\)")
  
  # Count remaining commas and add 1
  n <- str_count(x_cleaned, ",") + 1
  
  return(n)
}

# -------------------------------
# Apply function safely to dataframe column
# -------------------------------
count_el_items_vec <- Vectorize(count_el_items)

data <- data %>%
  mutate(el_count = count_el_items_vec(el_participation))


# Create EL participation binary: 0 = none, 1 = participated in ≥1 activity
data <- data %>%
  mutate(el_participation_binary = if_else(el_count > 0, 1, 0))


# -------------------------------
# Save processed data to a new CSV
# -------------------------------
write_csv(data, "fds_2023_processed.csv")
