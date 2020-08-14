/* What is the average life of a file before it is deleted? */
SELECT sum(deleted::DATE-created::DATE)/count(*) as avg_age_deleted
FROM postclick
WHERE deleted IS NOT NULL


/* How many files have been deleted since Aug 1st 2019? */
SELECT count(*)
FROM postclick
WHERE deleted is not null


/* How many files are deleted in the same day they are created? */
SELECT count(*)
FROM postclick
WHERE created = deleted


/* Of the files deleted, what is the percentage where files were deleted on the same day they were created? */
SELECT ROUND(((count(*) *100)::numeric / (SELECT (count(*))::numeric FROM postclick where deleted is not null)),2)
FROM postclick
WHERE created = deleted


/* How many files created every week? */ 
SELECT date_trunc('week', created)::DATE as week, count(*) as Total_Files_Created
FROM postclick
GROUP BY 1
ORDER BY 1

/* What is the average number of files created per day? */
/* Option 1 */
SELECT count(*)::numeric/ count(DISTINCT created)::numeric
FROM postclick

/* Option 2 */
SELECT avg(a.f_count) as avg_files_per_day 
FROM (SELECT count(*) as f_count
	  FROM postclick
	  GROUP BY created) a
	  

/* What is the average number of files deleted per day? */
SELECT avg(a.d_count) as avg_del_per_day 
FROM (SELECT count(*) as d_count
	  FROM postclick
	  GROUP BY deleted) a


/* What is the average number of files created per user? */
SELECT count(*)::numeric/count(DISTINCT user_id)::numeric
FROM postclick


/* What are the top 10 oldest files deleted? */
SELECT file_id, created, deleted, deleted-created AS age_of_file
FROM postclick
WHERE deleted is not null
order by 4 DESC
LIMIT 10


/* How many distinct users creating a new file each month? */
SELECT date_trunc('month', created), count(DISTINCT user_id)
FROM postclick
GROUP BY 1


/* Top 10 users with the most total updates */
SELECT user_id, sum(version) AS total_updates
FROM postclick
WHERE version >1
GROUP BY user_id
ORDER BY 2 DESC
LIMIT 10


/*Top users with most deleted files */
SELECT user_id, count(*)
FROM postclick
WHERE deleted is not null
GROUP BY user_id
ORDER BY COUNT(*) DESC
LIMIT 10


/* Write a query to show user_id, file_id, number of updates made for each file, and total updates made by the user*/
SELECT user_id,
       file_id,
	   version AS num_updates,
       SUM(version) OVER
         (PARTITION BY user_id) AS total_updates_by_user
FROM postclick
ORDER BY total_updates_by_user DESC


/* Last updates made each month where file was not deleted? 
   This shows the count of when a file was last updated per month which excludes files that are deleted because when a file is deleted it is considered an update.
*/
SELECT date_trunc('month', updated)::DATE AS Month, count(*) AS num_updates
FROM postclick
WHERE version >1 and deleted is null
GROUP BY 1
ORDER BY 1


/* 
Users with the most files? 
user 3282991 has 6038 files 
*/
SELECT user_id, count(*)
FROM postclick
GROUP BY user_id
ORDER BY count(*) DESC


/* 
Lets take a closer look at user 3282991 
How many files were created each month OR week OR day by user 3282991?
Looks like they created 6038 files between 8/12/19 - 8/14/19
*/
SELECT date_trunc('day', created)::DATE, count(*)
FROM Postclick
WHERE user_id = '3282991'
GROUP BY 1
ORDER BY 1


/* 
Did user 3282991 delete any of the 6038 files created?
12 were deleted on the same day it was created
*/
select file_id, created,updated,deleted
from postclick
where user_id = '3282991' AND deleted is not null


/* 
Did user 3282991 make any updates to the 6038 files created?
There are 0 files with version greater than 1. Files were created with no updates.
*/
SELECT count(*)
FROM postclick
WHERE user_id = '3282991' AND version>1


/* Find files created in August where updates are still being made past November */
SELECT file_id, updated, version
FROM postclick
WHERE date_trunc('month', created) = '2019-08-01' AND updated > '2019-11-30' AND deleted is NULL


/* Number of files created in August where updates are still being made past November */
SELECT count(*)
FROM postclick
WHERE date_trunc('month', created) = '2019-08-01' AND updated > '2019-11-30' AND deleted is NULL


/* How many distinct users who created a file in August are still making updates past November (exclude files that were deleted)? */
SELECT count(DISTINCT user_id)
FROM postclick
WHERE date_trunc('month', created) = '2019-08-01' AND updated > '2019-11-30' AND deleted is NULL


/* How many files were updated more than once on the day that it was created? 
(Exclude files that were deleted because when a file is deleted that counts as an update)
*/
SELECT date_trunc('month', created)::DATE as Month, count(*) AS num_updates_on_day_created
FROM postclick
WHERE created = updated AND version > 1 AND deleted is null
GROUP BY 1



