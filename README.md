# Spotify-Analysis-with-SQL-and-Query-Optimization

![Spotify Logo](Spotify_logo.jpg)
**Click Here to get:** [Spotify Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity and optimizing query performance. The primary goal of the project is to generate valuable insights from the dataset.

```sql
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 3. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.

## Exploratory Data Analysis (EDA)
```sql
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT * FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;
```

## Basic Data Analysis
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT * FROM spotify
WHERE stream > 1000000000;
```
2. List all albums along with their respective artists.
```sql
SELECT DISTINCT album, artist
FROM spotify
ORDER BY 1;
```
3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true';
```
4. Find all tracks that belong to the album type `single`.
```sql
SELECT * FROM spotify
WHERE album_type = 'single';
```
5. Count the total number of tracks by each artist.
```sql
SELECT 
	artist, COUNT (*) as totat_number_of_tracks
FROM spotify
GROUP BY artist;
```
### Medium Level
1. Calculate the average danceability of tracks in each album.
```sql
SELECT 
	ALBUM,
	AVG(DANCEABILITY) AS AVG_DANCEABILITY
FROM SPOTIFY
GROUP BY 1
ORDER BY 2 DESC;
```
2. Find the top 5 tracks with the highest energy values.
```sql
SELECT 
	TRACK,
	MAX(ENERGY)
FROM SPOTIFY
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT
	TRACK,
SUM(VIEWS) AS TOTAL_VIEWS,
SUM (LIKES) AS TOTAL_LIKES
FROM SPOTIFY
	WHERE OFFICIAL_VIDEO= 'TRUE'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5;
```
4. For each album, calculate the total views of all associated tracks.
```sql
SELECT
	ALBUM,
	TRACK,
	SUM(VIEWS)
FROM SPOTIFY 
GROUP BY 1,2
ORDER BY 3 DESC;
```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
SELECT * FROM
	(
	SELECT
	TRACK,
	COALESCE (SUM(CASE WHEN MOST_PLAYED_ON='YOUTUBE' THEN STREAM END),0) AS STREAMED_ON_YOUTUBE,
	COALESCE (SUM(CASE WHEN MOST_PLAYED_ON='SPOTIFY' THEN STREAM END),0) AS STREAMED_ON_SPOTIFY
FROM SPOTIFY
GROUP BY 1
) AS T1
WHERE
	STREAMED_ON_SPOTIFY > STREAMED_ON_YOUTUBE
	AND
STREAMED_ON_YOUTUBE <> 0;
```

### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
2. Write a query to find tracks where the liveness score is above the average.
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```
   
5. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT
	TRACK,
	ARTIST,
	LIVENESS
FROM SPOTIFY
WHERE LIVENESS > (SELECT AVG(LIVENESS) FROM SPOTIFY)
```
6. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
WITH CTE
	AS
	(SELECT ALBUM,
MAX(ENERGY) AS HIGHEST_ENERGY,
MIN(ENERGY) AS LOWEST_ENERGY
FROM SPOTIFY
GROUP BY 1
)
SELECT ALBUM,
HIGHEST_ENERGY - LOWEST_ENERGY AS ENERGY_DIFF
FROM CTE
ORDER BY 2 DESC;
```

Here’s an updated section for your **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. You can include the specific screenshots and graphs as described.

---














