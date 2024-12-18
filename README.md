# Spotify-Analysis-with-SQL-and-Query-Optimization

![Spotify Logo](Spotify_logo.jpg)
**Click Here to get:** [Spotify Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

## Overview
This project analyzes a Spotify dataset containing various attributes about tracks, albums, and artists using **SQL**. The process includes normalizing a denormalized dataset, performing SQL queries of varying complexity, and optimizing query performance. The goal is to generate valuable insights and demonstrate efficient query handling for large datasets.

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
Understanding the dataset is the first step toward effective analysis. The dataset includes key attributes such as:
- **`Artist`**: Name of the performer or creator of the track.
- **`Track`**: Title of the song.
- **`Album`**: The collection or album to which the track belongs.
- **`Album_type`**: Specifies whether it’s a single, an album, or another type.
- Various metrics like:
  - **`Danceability`**: How suitable the track is for dancing.
  - **`Energy`**: Intensity and activity level of the track.
  - **`Loudness`**, **`Tempo`**, and more.

### 2. Querying the Data
Once the data is inserted into the database, queries are written to explore and analyze the dataset. These queries are divided into levels based on complexity:

#### **Easy Queries**
- Focus on simple data retrieval.
- Examples:
  - Filtering data based on conditions.
  - Retrieving distinct values.
  - Basic aggregations like `SUM` and `COUNT`.

#### **Medium Queries**
- Involve more complex operations:
  - Grouping data using `GROUP BY`.
  - Applying aggregation functions like `AVG`, `MAX`, and `MIN`.
  - Performing joins between tables.

#### **Advanced Queries**
- Deal with sophisticated SQL techniques:
  - Nested subqueries for layered logic.
  - **Window Functions** for calculations across a set of rows.
  - **Common Table Expressions (CTEs)** for breaking down complex queries.

### 3. Query Optimization
Analyzing large datasets efficiently requires optimizing SQL queries. Key strategies include:

#### **Indexing**
- Add indexes on frequently queried columns to reduce query execution time.

#### Using Execution Plans
- Utilize **`EXPLAIN ANALYZE`** to understand how the database processes a query.
- Review the output to identify bottlenecks and improve performance.

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

## Easy Queries
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

## Medium Queries
1. Calculate the average danceability of tracks in each album.
```sql
SELECT 
	album, 
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;
```

2. Find the top 5 tracks with the highest energy values.
```sql
SELECT 
	track,
	MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;
```

3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT
	track,
	SUM(views) as total_view,
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track
ORDER BY total_view DESC;
```

4. For each album, calculate the total views of all associated tracks.
```sql
SELECT 
	album,
	track,
	SUM(views) as total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;
```

5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
SELECT * FROM
(SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY 1
) as t1
WHERE
	streamed_on_spotify > streamed_on_youtube
	AND
	streamed_on_youtube <> 0;
```

## Advanced Queries

1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
WITH ranking_artist
AS
(SELECT 
	artist,
	track,
	SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC)
SELECT * FROM ranking_artist
WHERE rank <=3;
```

2. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT 
	track, 
	liveness 
FROM spotify 
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```

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
ORDER BY 2 DESC;
```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT 
	track,
	(energy/liveness) AS energy_to_liveness_ratio 
FROM spotify 
WHERE (energy/liveness) > 1.2
ORDER BY 2;
```

5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM 
    spotify;
```

## Query Optimization Technique

To enhance the performance of SQL queries in the Spotify dataset, we implemented the following optimization process:

### 1. Initial Query Performance Analysis Using `EXPLAIN`
- The performance of a query retrieving tracks based on the `artist` column was analyzed using the `EXPLAIN` function.  
- **Initial performance metrics**:
  - **Execution Time (E.T.):** 6.077 ms  
  - **Planning Time (P.T.):** 0.119 ms  
- Below is the result of the query analysis before optimization:  
  ![EXPLAIN Before Index](Explain_before_index.png)

### 2. Optimization via Indexing
- To improve query performance, we **created an index** on the `artist` column.  
- **Why indexing?**  
  Indexes accelerate data retrieval by creating a reference structure, making it quicker to locate rows based on indexed columns.  
- **SQL Command**:
  	```sql
  	CREATE INDEX artist_index ON spotify(artist);
	```

### 3. Performance After Index Creation
After indexing, the query was executed again, yielding significantly improved performance:

- **Execution Time (E.T.):** 0.69 ms  
- **Planning Time (P.T.):** 0.14 ms  

Below is the `EXPLAIN` result after optimization:  
![EXPLAIN After Index](Explain_after_index.png)

### 4. Graphical Comparison of Query Performance
The graph below compares the query performance before and after indexing, clearly illustrating the substantial drop in execution and planning times:

- **Performance Before Indexing:**  
  ![Performance Before Indexing](Graphical_view_before_index.png)

- **Performance After Indexing:**  
  ![Performance After Indexing](Graphical_view_after_index.png)

## Conclusion
This project highlights the power of **SQL** in analyzing large datasets and emphasizes the importance of **query optimization techniques** in improving performance. By applying SQL to analyze Spotify data, we derived valuable insights about tracks, albums, and artists. Moreover, the optimization process demonstrated how indexing can significantly enhance query performance, enabling faster data retrieval and more efficient database operations. Overall, this analysis showcases the practical application of SQL in real-world data-driven tasks and the critical role of query optimization in handling large-scale datasets.
