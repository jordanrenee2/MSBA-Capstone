# Experiential Learning and Career Success: An Outcomes-Based Evaluation


## Project Overview

This project evaluates whether participation in experiential learning activities during college is associated with improved early career outcomes among alumni.

Specifically, the analysis compares:

- **Salaries** of graduates who participated in experiential learning versus those who did not  
- **Salaries** of graduates who report that experiential learning helped them versus those who report it did not  
- **Job satisfaction levels** of graduates who participated in experiential learning versus those who did not  

Experiential learning participation is measured using survey responses indicating involvement in internships, volunteering, fellowships, research, and other applied learning experiences.

Career outcomes are measured using:

- Employment status  
- Annual salary  
- Self-reported employment quality and satisfaction indicators  

The findings aim to support data-informed decision-making related to experiential learning programming and institutional resource allocation.

---

## Research Questions

This project addresses the following testable research questions:

### Salary Comparison (Participation-Based)
Do graduates who participated in experiential learning earn higher annual salaries than those who did not?

### Salary Comparison (Perceived Helpfulness-Based)
Do graduates who report that experiential learning helped them earn higher salaries than those who report it did not help?

### Job Satisfaction Comparison
Do graduates who participated in experiential learning report higher job satisfaction than those who did not?

### Optional Extension
Does the number of experiential learning activities completed predict higher salary or job satisfaction?

---

## Technologies Used

- **R**: Data cleaning, feature engineering, statistical modeling, and visualization  
- **Libraries**: `tidyverse`, `readr`, `janitor`, `stringr`, `MASS`, `purrr`, `ggplot2`, `broom`, `scales`, `dplyr`, `tidyr`


---

## Data Source

The dataset consists of **post-graduation survey responses** (First Destination Survey / UM Graduation Survey) from university alumni.  

**Included variables:**

- **Demographics**: gender, ethnicity
- **Academic information**: major, college, graduation date  
- **Experiential learning participation**: select-all-that-apply survey items  
- **Perceived helpfulness of experiential learning**  
- **Employment outcomes**: employment status, employer, job function, employment type  
- **Salary and compensation**: annual salary, bonus, other compensation  
- **Job satisfaction**: alignment of current position with expectations  

> All data were **de-identified** prior to analysis.


---


## Feature Engineering & Model Development

### Key Derived Variables

| Variable | Description |
|----------|-------------|
| `el_participation_binary` | 1 if respondent participated in ≥1 EL activity, 0 if none |
| `el_count` | Count of EL activities selected |
| `el_helpfulness_binary` | 1 if respondent reported EL helped, 0 otherwise |
| `log_salary` | Natural log of `annual_salary` (for linear modeling) |
| `job_alignment_num` | Numeric recoding of job satisfaction (1 = low, 3 = high) |

### Dataset Filters

- Only **submitted responses**  
- Outcome = `"Working". "Military", "Still Looking", "Not Seeking", "Volunteering"` (exclude continuing education)  
- Non-missing salary values for salary models  

### Control Variables

- Major or College  
- Gender  



---

## Statistical Models Implemented

### Salary Models

1. **Independent samples t-tests**: compare salaries by EL participation  
2. **Linear regression**:  
   - `log_salary ~ el_participation_binary + controls`  
   - `log_salary ~ el_helpfulness_binary + controls`  
3. **Optional extension**: Dose-response analysis  
   - `log_salary ~ el_count + controls`  

### Job Satisfaction Models

1. **Mean comparison tests**: by EL participation  
2. **Linear regression / ordinal logistic regression**:  
   - `job_alignment_num ~ el_participation_binary + controls`  

### College-Level Analysis

- College-specific t-tests and regressions  
- Predicted salary and job satisfaction accounting for college-specific EL effects  

---

## Visualizations

- **Boxplots**: salary and job satisfaction by EL participation and helpfulness  
- **Scatterplots**: salary and job satisfaction vs number of EL activities  
- **College-level summaries**: mean salary and job satisfaction by EL participation  
     
---

## How to Run the Project

1. **Clone the repository**  

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   
2. **Install required R packages (if not already installed)**
   
   ```bash
   install.packages(c("tidyverse","readr","janitor","stringr","MASS","purrr","ggplot2","broom","scales","dplyr","tidyr"))


4. **Run data preprocessing script**

   ```bash
   source("data_preprocessing.R")  # generates fds_2023_processed.csv


4. **Run analysis and visualization script**

   ```bash
   source("analysis_visualization.R")  # generates plots, t-tests, and regression results

5. Inspect outputs

Processed data: fds_2023_processed.csv

Plots: salary, job satisfaction, EL dose-response

Regression and t-test summaries printed in console

-- 

## Project Structure

```bash
   ├─ README.md
   ├─ fds_2023.csv                  # raw alumni survey data
   ├─ fds_2023_processed.csv        # cleaned and feature-engineered data
   ├─ data_preprocessing.R          # preprocessing and feature engineering script
   ├─ analysis_visualization.R      # statistical modeling and visualization script
   └─ plots/                        # optional: saved visualizations

