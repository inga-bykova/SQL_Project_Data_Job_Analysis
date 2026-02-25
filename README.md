# Introduction

This project is a data analysis of job postings in 2023. The analysis is based on a dataset of 787,686 job postings from various companies across the world. The dataset includes information about the job title, company, location, salary, and other relevant details.

Focusing on data analyst roles, this project explores top-paying jobs, in-demand skills, and where high demand meets high salary in data analytics.

Check SQL queries in the [project_sql](project_sql) folder.

# Background

The job market has been experiencing significant changes in recent years, with the rise of remote work, the gig economy, and the increasing demand for tech skills. This project from Luke Barousse was born out of his desire to pinpoint top-paid and in-demand skills, streamlining work to find optimal career paths in data analytics.

Data hails from Luke Barousse's [SQL Course](https://www.lukebarousse.com/sql).

### Main questions of the project:

1. What are the top-paying data analyst jobs?
2. What skills are required for these jobs?
3. What skills are most in-demand for data analysts?
4. Which skills are assotiated with higher salaries?
5. What are the most optimal skills to learn?

# Tools I Used

For my deep dive into the data analyst job market, I used several key tools:

- **SQL**: the foundation of my analysis, used to query the dataset and uncover meaningful insights.
- **PostgreSQL**: the database management system I used to store and work with job posting data efficiently.
- **Antigravity**: the AI coding assistant that helped me write and debug my SQL queries.
- **Git/GitHub**: the version control system I used to track my changes and share my work with others.
- **ChatGPT**: used to help create bar charts and support visualization of insights from the resulting CSV files.

# The Analysis

Queries for the project aimed at answering the specific questions of the data analyst job market.

### 1. What are the top-paying data analyst jobs?

At the first part of the project, the analysis identifies the highest-paying remote Data Analyst jobs. 

The query filters for Data Analyst positions with a specified annual salary, keeps only roles listed as “Anywhere” (remote), joins company details, and returns the top 10 jobs by salary. 

This provides a quick snapshot of the best-paid remote opportunities in the dataset.

```sql
SELECT 
    job_id,
    job_title,
    name AS company_name,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM 
    job_postings_fact
LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_location = 'Anywhere'
ORDER BY 
    salary_year_avg DESC
LIMIT 10;
```
Here is the main insight from this query:
- **Salary Range:** Top 10 highest paying remote data analyst roles span from $184,000 to $650,000.
- **Employers:** Companies vary from tech giants like Meta and Google to healthcare like UCLA Health.
- **Job Titles:** Large variety of job titles, from Data Analyst to Director of Data Analytics.

![Top Paying Jobs](assets/1_top_paying_roles.png)
*Bar graph showing top 10 highest paying remote data analyst roles; ChatGPT generated using SQL query results*

### 2. What skills are required for these jobs?

To understand which skills are required for the highest-paying remote Data Analyst roles, a `CTE` (Common Table Expression) was used to first isolate the top 10 jobs by salary after applying filters. Then, a `LEFT JOIN` added company names, and `INNER JOIN`s linked each job to its required skills.


```sql
WITH top_paying_jobs AS 
    (
        SELECT 
            job_id,
            job_title,
            name AS company_name,
            salary_year_avg
    FROM 
        job_postings_fact
    LEFT JOIN company_dim
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE 
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_location = 'Anywhere'
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
    )

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim
    ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```
Among the top 10 highest-paying Data Analyst jobs in 2023, `SQL` was the most frequently requested skill (8 mentions), followed by `Python` (7) and `Tableau` (6). Other skills - including `R`, `Snowflake`, `Pandas`, and `Excel` - also appeared, but with lower demand.

![Skills Required](assets/2_top_paying_skills.png)
*Bar graph showing the most frequent skills across the top 10 highest-paying remote Data Analyst jobs in 2023; ChatGPT generated using SQL query results.*

### 3. What skills are most in-demand for data analysts?

This section identifies the top 5 most in-demand skills for remote Data Analyst roles by counting how often each skill appears across job postings. 

The query joins the job postings table with the skill mapping and skill lookup tables, filters for remote Data Analyst positions, and then ranks skills by demand. 

```sql
SELECT 
    skills,
    COUNT(skills_job_dim.skill_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_work_from_home = TRUE
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```
The results highlight which tools and technologies employers request most frequently in remote data analyst jobs.

| Skills   | Demand Count |
|----------|-------------:|
| sql      |         7291 |
| excel    |         4611 |
| python   |         4330 |
| tableau  |         3745 |
| power bi |         2609 |
*Table of the most in-demand skills for data analysts*

- `SQL` and `Excel` continue to be core requirements for remote Data Analyst positions, showing that employers still rely heavily on solid data extraction, analysis, and spreadsheet skills. 
- `Python` and `BI/visualization` tools like `Tableau` and `Power BI` are widely requested, underscoring the increasing value of technical capabilities for communicating insights and supporting business decisions.

### 4. Which skills are assotiated with higher salaries?

This part of the project identifies which skills are linked to higher salaries for remote Data Analyst roles.

The query joins job postings with skill tables, filters only Data Analyst jobs with a specified annual salary, calculates the average salary for each skill, and returns the top 25 highest-paying skills. This helps highlight which technical skills are most valuable in the market.

```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = TRUE
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```
Key takeaways from the top-paying skills for Data Analysts:

- **Big data and advanced analytics skills lead the salary ranking.**
`PySpark` stands out as the top-paying skill, while tools and platforms such as `Couchbase`, `Watson`, `DataRobot`, and `Jupyter` also appear near the top. This suggests strong market value for analysts who can work with large-scale data, AI/ML-enabled tools, and advanced analytics workflows.

- **Python ecosystem skills remain highly valuable.**
`Pandas` and `NumPy` are both among the top-paying skills, reinforcing the importance of Python-based data analysis, transformation, and numerical processing in well-paid analyst roles.

- **Engineering and development-adjacent skills are associated with higher pay.**
Skills like `GitLab`, `Bitbucket`, and `Golang` indicate that analysts who can collaborate in engineering environments (version control, pipelines, coding-heavy workflows) may have an earning advantage.

- **Broader technical versatility appears to increase earning potential.**
The presence of skills such as `Elasticsearch` and `Swift` shows that higher-paying roles may favor analysts with cross-functional technical exposure beyond traditional reporting, especially in modern product and data-driven teams.

| Skills        |Average Salary ($) |
|---------------|-----------:|
| pyspark       | 208172     |
| bitbucket     | 189155     |
| couchbase     | 160515     |
| watson        | 160515     |
| datarobot     | 155486     |
| gitlab        | 154500     |
| swift         | 153750     |
| jupyter       | 152777     |
| pandas        | 151821     |
| elasticsearch | 145000     |
| golang        | 145000     |
| numpy         | 143513     |

*Table of the average salary for the top paying skills for data analysts*

### 5. What are the most optimal skills to learn?

This final part of the project identifies the most optimal skills to learn for remote Data Analyst roles by balancing salary potential and market demand. 

The query calculates how often each skill appears in job postings and its average salary, filters to skills with meaningful demand (more than 10 postings), and returns the top 25 skills ranked by highest average salary and then demand. This helps prioritize skills that are both well-paid and frequently requested.

```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.skill_id) AS demand_count,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = TRUE
GROUP BY
    skills_dim.skill_id
HAVING
     COUNT(skills_job_dim.skill_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```
The result highlights the most optimal skills to learn for remote Data Analyst roles by combining demand and salary. 

Skills like `Go`, `Hadoop`, `Snowflake`, `Azure`, `BigQuery`, and `AWS` show strong salary potential, while `Python`, `Tableau`, and `R` stand out for very high demand in job postings. Overall, the best strategy is to combine core analytics tools (`Python`, `Tableau`, `SQL-related skills`) with cloud/data engineering skills (`Snowflake`, `Azure`, `AWS`, `BigQuery`) to maximize both employability and salary potential.

| Skill ID | Skills      | Demand Count | Average Salary ($) |
|---------:|-------------|-------------:|-----------:|
| 8        | go          | 27           | 115320     |
| 234      | confluence  | 11           | 114210     |
| 97       | hadoop      | 22           | 113193     |
| 80       | snowflake   | 37           | 112948     |
| 74       | azure       | 34           | 111225     |
| 77       | bigquery    | 13           | 109654     |
| 76       | aws         | 32           | 108317     |
| 4        | java        | 17           | 106906     |
| 194      | ssis        | 12           | 106683     |
| 233      | jira        | 20           | 104918     |

*Table of the most optimal skills for data analyst sorted by salary*

# What I Learned

This project strengthened practical SQL skills through a real-world dataset and business-focused questions.

## SQL skills practiced

- Filtering with `WHERE` (role, remote jobs, non-null salaries)
- Joining tables with `LEFT JOIN` and `INNER JOIN`
- Aggregation with `COUNT()`, `AVG()`, `ROUND()`, and `GROUP BY`
- Ranking results using `ORDER BY` and `LIMIT`
- CTEs (WITH) to structure multi-step queries
- Post-aggregation filtering with `HAVING`

## Analytical skills developed

- turning business questions into query logic,
- selecting the right metrics (demand vs salary),
- comparing trade-offs between popularity and pay,
- presenting findings clearly.

This project also reinforced that SQL is not only about syntax, but about solving practical analytical problems.

# Conclusion

The 2023 job-posting analysis shows several clear patterns in the remote Data Analyst market.

- Top-paying roles exist, but are limited and often more senior/specialized.
- Core skills remain essential: `SQL`, `Excel`, `Python`, `Tableau`, and `Power BI` appear most often.
- Higher salaries are often linked to advanced tools (for example, `PySpark`, `cloud/data platforms`, and `engineering-adjacent skills`).
- The strongest skill strategy is a mix of core analytics + modern data platform skills (such as `Snowflake`, `Azure`, `AWS`, `BigQuery`).
- Demand and salary should be evaluated together, since the highest-paying skills are not always the most common.

Overall, the market favors analysts who combine strong analytical foundations with broader technical versatility.

## Closing Thoughts

This project provided solid hands-on practice in SQL and helped connect technical querying with business insight.

As a portfolio project, it demonstrates both SQL fundamentals and the ability to turn raw data into useful, structured conclusions.