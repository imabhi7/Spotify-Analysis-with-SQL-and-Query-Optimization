-- Advanced SQL Project

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

-- Exploratory Data Analysis (EDA)
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT * FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

-- --------------------
-- Basic Data Analysis
-- --------------------

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists.

SELECT DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true';

-- 4. Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist.

SELECT 
	artist, COUNT (*) as totat_number_of_tracks
FROM spotify
GROUP BY artist;

-- ----------------------
-- Moderate Data Analysis
-- ----------------------

-- 6. Calculate the average danceability of tracks in each album.

SELECT 
	album, 
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;

-- 7. Find the top 5 tracks with the highest energy values.

SELECT 
	track,
	MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- 8. List all tracks along with their views and likes where official_video = TRUE.

SELECT
	track,
	SUM(views) as total_view,
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track
ORDER BY total_view DESC;

-- 9. For each album, calculate the total views of all associated tracks.

SELECT 
	album,
	track,
	SUM(views) as total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.

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

-- ----------------------
-- Detailed Data Analysis
-- ----------------------

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

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

-- 12. Write a query to find tracks where the liveness score is above the average.

SELECT 
	track, 
	liveness 
FROM spotify 
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

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


-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
	track,
	(energy/liveness) AS energy_to_liveness_ratio 
FROM spotify 
WHERE (energy/liveness) > 1.2
ORDER BY 2;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM 
    spotify;

-- Query Optimization

EXPLAIN ANALYZE -- et 6.077ms & pt 0.119ms
SELECT 
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Playboi Carti'
AND most_played_on = 'Spotify'
ORDER BY stream DESC LIMIT 5;

CREATE INDEX artist_index ON spotify(artist);
