# ================================
# Alumni Experiential Learning Analysis
# Visualization & Statistics
# ================================

library(tidyverse)
library(ggplot2)
library(scales)
library(broom)
library(dplyr)
library(tidyr)

# -------------------------------
# Load processed data
# -------------------------------
data <- read_csv("fds_2023_processed.csv", show_col_types = FALSE)

# -------------------------------
# Define factors for plotting
# -------------------------------
data <- data %>%
  mutate(
    el_participation_factor = factor(el_participation_binary, levels = c(0,1), labels = c("No EL","EL")),
    el_helpfulness_factor = factor(el_helpfulness_binary, levels = c(0,1), labels = c("Not Helpful","Helpful"))
  )

# -------------------------------
# Overall Salary Comparison by EL Participation
# -------------------------------
ggplot(data, aes(x = el_participation_factor, y = annual_salary)) +
  geom_boxplot(fill = "skyblue") +
  labs(x = "EL Participation", y = "Annual Salary", title = "Salary by EL Participation") +
  theme_minimal()

salary_participation_test <- t.test(
  annual_salary ~ el_participation_binary,
  data = data,
  na.action = na.omit
)
print(salary_participation_test)

# -------------------------------
# Salary Comparison by Helpfulness (Binary)
# -------------------------------
helpful_data <- data %>% filter(!is.na(annual_salary) & !is.na(el_helpfulness_binary))

ggplot(helpful_data, aes(x = el_helpfulness_factor, y = annual_salary)) +
  geom_boxplot(fill = "lightgreen") +
  labs(x = "EL Helpfulness", y = "Annual Salary", title = "Salary by EL Helpfulness") +
  theme_minimal()

salary_helpfulness_test <- t.test(
  annual_salary ~ el_helpfulness_binary,
  data = helpful_data,
  na.action = na.omit
)
print(salary_helpfulness_test)

# -------------------------------
# Job Satisfaction Comparison by EL Participation
# -------------------------------
ggplot(data, aes(x = el_participation_factor, y = job_alignment_num)) +
  geom_boxplot(fill = "orange") +
  labs(x = "EL Participation", y = "Job Satisfaction (1-3)", title = "Job Satisfaction by EL Participation") +
  theme_minimal()

job_satisfaction_test <- t.test(
  job_alignment_num ~ el_participation_binary,
  data = data,
  na.action = na.omit
)
print(job_satisfaction_test)

# -------------------------------
# Optional Extension: Number of EL Activities
# -------------------------------
el_count_salary_cor <- cor.test(data$el_count, data$annual_salary, use = "complete.obs")
el_count_satisfaction_cor <- cor.test(data$el_count, data$job_alignment_num, use = "complete.obs")

# Scatterplots
ggplot(data, aes(x = el_count, y = annual_salary)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(x = "Number of EL Activities", y = "Annual Salary", title = "Annual Salary vs Number of EL Activities") +
  theme_minimal()

ggplot(data, aes(x = el_count, y = job_alignment_num)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(x = "Number of EL Activities", y = "Job Satisfaction (1-3)", title = "Job Satisfaction vs Number of EL Activities") +
  theme_minimal()

# -------------------------------
# College-Level Summary & T-Tests
# -------------------------------

# Exclude colleges with insufficient data
exclude_colleges <- c(
  NA, "Graduate School", "University of Montana", "College of Health Prof Biomed", "no college"
)

data_filtered <- data %>% filter(!recipient_primary_college %in% exclude_colleges)

# College summary for mean salary & job satisfaction
college_summary <- data_filtered %>%
  group_by(recipient_primary_college, el_participation_factor) %>%
  summarize(
    avg_salary = mean(annual_salary, na.rm = TRUE),
    avg_job_satisfaction = mean(job_alignment_num, na.rm = TRUE),
    n_salary = sum(!is.na(annual_salary)),
    n_satisfaction = sum(!is.na(job_alignment_num)),
    .groups = "drop"
  ) %>%
  arrange(recipient_primary_college)

print("College-Level Summary:")
print(college_summary)

# Initialize empty lists for t-test results
salary_tests <- list()
satisfaction_tests <- list()

colleges <- unique(data_filtered$recipient_primary_college)

for (col in colleges) {
  df_college <- data_filtered %>% filter(recipient_primary_college == col)
  
  # Salary t-test (if both groups have ≥2 obs)
  if (all(table(df_college$el_participation_binary[!is.na(df_college$annual_salary)]) >= 2)) {
    t_salary <- t.test(
      annual_salary ~ el_participation_binary,
      data = df_college,
      na.action = na.omit
    )
    
    salary_tests[[col]] <- tibble(
      college = col,
      mean_no_EL = mean(df_college$annual_salary[df_college$el_participation_binary == 0], na.rm = TRUE),
      mean_EL = mean(df_college$annual_salary[df_college$el_participation_binary == 1], na.rm = TRUE),
      t_stat = t_salary$statistic,
      df = t_salary$parameter,
      p_value = t_salary$p.value
    )
  }
  
  # Job satisfaction t-test
  if (all(table(df_college$el_participation_binary[!is.na(df_college$job_alignment_num)]) >= 2)) {
    t_satisfaction <- t.test(
      job_alignment_num ~ el_participation_binary,
      data = df_college,
      na.action = na.omit
    )
    
    satisfaction_tests[[col]] <- tibble(
      college = col,
      mean_no_EL = mean(df_college$job_alignment_num[df_college$el_participation_binary == 0], na.rm = TRUE),
      mean_EL = mean(df_college$job_alignment_num[df_college$el_participation_binary == 1], na.rm = TRUE),
      t_stat = t_satisfaction$statistic,
      df = t_satisfaction$parameter,
      p_value = t_satisfaction$p.value
    )
  }
}

# Combine t-test results
salary_tests_df <- bind_rows(salary_tests)
satisfaction_tests_df <- bind_rows(satisfaction_tests)

# -------------------------------
# Regression Models with Interaction (College-Specific EL Effects)
# -------------------------------

# Salary: EL Participation * College
salary_model <- lm(annual_salary ~ el_participation_binary * recipient_primary_college, data = data_filtered)
cat("\nRegression: Salary ~ EL Participation * College (College-Specific Effects)\n")
print(summary(salary_model))

# Job Satisfaction: EL Participation * College
satisfaction_model <- lm(job_alignment_num ~ el_participation_binary * recipient_primary_college, data = data_filtered)
cat("\nRegression: Job Satisfaction ~ EL Participation * College (College-Specific Effects)\n")
print(summary(satisfaction_model))

# Optional: Salary including more covariates
# salary_model_full <- lm(annual_salary ~ el_participation_binary + recipient_primary_college +
#                        recipient_gender + recipient_ethnicity, data = data_filtered)
# summary(salary_model_full)

# -------------------------------
# Tidy Regression Output for Interaction Models
# -------------------------------

# Function to calculate predicted means for each college
predicted_by_college <- function(model, college_var, el_var) {
  colleges <- unique(data_filtered[[college_var]])
  
  results <- lapply(colleges, function(col) {
    newdata <- data.frame(
      el_participation_binary = c(0,1),
      recipient_primary_college = col
    )
    
    preds <- predict(model, newdata = newdata, se.fit = TRUE)
    
    tibble(
      college = col,
      EL = c("No EL", "EL"),
      estimate = preds$fit,
      se = preds$se.fit
    )
  })
  
  # Combine results
  results_df <- bind_rows(results) %>%
    pivot_wider(
      names_from = EL,
      values_from = c(estimate, se)
    )
  
  # Rename columns to remove spaces
  names(results_df) <- gsub(" ", "_", names(results_df))
  
  # Compute difference and stats
  results_df <- results_df %>%
    mutate(
      difference = estimate_EL - estimate_No_EL,
      diff_se = sqrt(se_EL^2 + se_No_EL^2),
      t_value = difference / diff_se,
      p_value = 2 * pt(-abs(t_value), df = df.residual(model))
    ) %>%
    select(college, estimate_No_EL, estimate_EL, difference, t_value, p_value)
  
  return(results_df)
}

# Job Satisfaction predictions by college
job_satisfaction_by_college <- predicted_by_college(
  satisfaction_model,
  college_var = "recipient_primary_college",
  el_var = "el_participation_binary"
)

# Salary predictions by college
salary_by_college <- predicted_by_college(
  salary_model,
  college_var = "recipient_primary_college",
  el_var = "el_participation_binary"
)

# View
job_satisfaction_by_college
salary_by_college

# -------------------------------
# Structured Results Summary
# -------------------------------

cat("\n=====================\nOverall Results Summary\n=====================\n\n")

cat("1. Salary Comparison by EL Participation:\n")
print(salary_participation_test)

cat("\n2. Salary Comparison by EL Helpfulness (Binary):\n")
print(salary_helpfulness_test)

cat("\n3. Job Satisfaction Comparison by EL Participation:\n")
print(job_satisfaction_test)

cat("\n4. Correlation: Number of EL Activities vs Salary:\n")
print(el_count_salary_cor)

cat("\n5. Correlation: Number of EL Activities vs Job Satisfaction:\n")
print(el_count_satisfaction_cor)

cat("\n6. College-Level Average Salary and Job Satisfaction by EL Participation:\n")
print(college_summary)

cat("\n7. College-Level t-tests: Salary by EL Participation:\n")
print(salary_tests_df)

cat("\n8. College-Level t-tests: Job Satisfaction by EL Participation:\n")
print(satisfaction_tests_df)

cat("\n9. Predicted Salary by College (Accounting for College Size):\n")
print(salary_by_college)

cat("\n10. Predicted Job Satisfaction by College (Accounting for College Size):\n")
print(job_satisfaction_by_college)