/* Question: What are the the most in-demand skills for Data Analyst jobs? */


WITH remote_skill_jobs AS 
(
SELECT
    skill_id,
    COUNT(*) AS skill_count
FROM 
    skills_job_dim AS skills_to_job
INNER JOIN  job_postings_fact AS jpf ON jpf.job_id = skills_to_job.job_id
WHERE
    jpf.job_work_from_home IS TRUE
    AND jpf.job_title_short = 'Data Analyst'
GROUP BY 
    skill_id
)
SELECT 
    skill.skill_id,
    skill.skills,
    remote_skill_jobs.skill_count
FROM remote_skill_jobs
INNER JOIN skills_dim AS skill ON skill.skill_id = remote_skill_jobs.skill_id
ORDER BY remote_skill_jobs.skill_count DESC
LIMIT 5;


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