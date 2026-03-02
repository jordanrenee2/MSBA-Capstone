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



---

## Data Source

The dataset consists of post-graduation survey (First Destination Survey or UM Graduation Survey) responses from university alumni.  

It includes:

- Demographic characteristics (gender, ethnicity, first-generation status, etc.)
- Academic information (major, college, graduation date)
- Experiential learning participation (select-all-that-apply survey items)
- Perceived helpfulness of experiential learning
- Employment outcomes (status, employer, job function)
- Salary data
- Self-reported employment satisfaction indicators

Data were de-identified prior to analysis.

---

## Feature Engineering & Model Development

### Feature Engineering

Key derived variables include:

- **EL_participated**  
  Binary indicator (1 = participated in at least one experiential learning activity, 0 = none)

- **EL_count**  
  Count of experiential learning activities selected

- **EL_helped**  
  Binary indicator (1 = respondent reported experiential learning helped, 0 = did not help)

- **log_salary**  
  Natural log transformation of annual salary (used to address right-skewed salary distribution)

- Filtered dataset restricted to respondents with:
  - Outcome = "Working"
  - Non-missing salary values (for salary models)

Control variables include:
- Major or College
- Gender
- First-generation status
- Veteran status
- Visa status
- Athlete status

---

### Model Development

The following statistical models are implemented:

1. **Salary Models**
   - Independent samples t-tests (participation vs. no participation)
   - Linear regression:
     ```
     log_salary ~ EL_participated + controls
     ```
   - Linear regression with perceived helpfulness:
     ```
     log_salary ~ EL_helped + controls
     ```

2. **Job Satisfaction Models**
   - Mean comparison tests
   - Linear or ordinal logistic regression:
     ```
     satisfaction ~ EL_participated + controls
     ```

3. **Optional Extension**
   - Dose-response analysis:
     ```
     log_salary ~ EL_count + controls
     ```
