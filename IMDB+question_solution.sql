USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT count(*) AS num_of_rows_in_movie FROM movie;
-- RESULT = 7997

SELECT count(*) AS num_of_rows_in_director_mapping FROM director_mapping;
-- RESULT = 3867

SELECT count(*) AS num_of_rows_in_genre FROM genre;
-- RESULT = 14662

SELECT count(*) AS num_of_rows_in_names FROM names;
-- RESULT = 25735

SELECT count(*) AS num_of_rows_in_ratings FROM ratings;
-- RESULT = 7997

SELECT count(*) AS num_of_rows_in_role_mapping FROM role_mapping;
-- RESULT = 15615

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT	SUM(
			CASE 
				WHEN id is null THEN 1 
                ELSE 0 
			END
			) as NullCount_id,
		SUM(
			CASE 
				WHEN title is null THEN 1 
                ELSE 0 
			END
			) as NullCount_title,
		SUM(
			CASE 
				WHEN year is null THEN 1 
                ELSE 0 
			END
			) as NullCount_year,
		SUM(
			CASE 
				WHEN date_published is null THEN 1 
                ELSE 0 
			END
			) as NullCount_date_published,
		SUM(
			CASE 
				WHEN duration is null THEN 1 
                ELSE 0 
			END
			) as NullCount_duration,
		SUM(
			CASE 
				WHEN country is null THEN 1 
                ELSE 0 
			END
			) as NullCount_country,
		SUM(
			CASE 
				WHEN worlwide_gross_income is null THEN 1 
                ELSE 0 
			END
			) as NullCount_worlwide_gross_income,
		SUM(
			CASE 
				WHEN languages is null THEN 1 
                ELSE 0 
			END
			) as NullCount_languages,
		SUM(
			CASE 
				WHEN production_company is null THEN 1 
                ELSE 0 
			END
			) as NullCount_production_company
FROM movie;
-- RESULT = country, worlwide_gross_income, languages, production_company(total 4 columns have null values).


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Year wise trend. 
SELECT	year,
		count(title) AS number_of_movies
FROM	movie
GROUP BY year;

-- Month wise trend.
SELECT	month(date_published) AS month_num,
		count(title) AS number_of_movies
FROM	movie
GROUP BY month_num
ORDER BY month_num;



/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT	count(title) AS number_of_movies,
		year
FROM	movie
WHERE	(country like '%India%' OR country like '%USA%') AND year = 2019;
-- RESULT = 1059 movies produced in the USA or India in the year 2019.



/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT	Distinct genre
FROM	genre;




/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT	genre,
		Count(title) as number_of_movies
FROM	movie m 
		INNER JOIN
        genre g
        ON m.id = g.movie_id
GROUP BY genre
ORDER BY number_of_movies DESC;
-- RESULT = 'Drama' genre has highest number of movies produced overall.


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH	movies_with_singleGenre AS
	(
		SELECT	movie_id
		FROM	genre
		GROUP BY movie_id
		HAVING	Count(movie_id)=1
	)
SELECT	Count(*) AS 'Movies with single genre'
FROM	movies_with_singleGenre;


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT	g.genre,
		Round(avg(m.duration),2) AS avg_duration
FROM	movie m
		INNER JOIN
        genre g
		ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY avg_duration DESC;
-- RESULT = 'Action' genre has highest avg duration of 112.88 mins followed by 'Romance','Crime' and 'Drama'.


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH	genre_ranking AS
	(
		SELECT	genre,
				Count(movie_id) AS movie_count,
				RANK() OVER( ORDER BY Count(movie_id) DESC ) AS genre_rank
		FROM	genre
		GROUP BY genre
	)
SELECT	*
FROM	genre_ranking
WHERE	genre = 'Thriller';



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT	Min(avg_rating) AS min_avg_rating,
		Max(avg_rating) AS max_avg_rating,
        Min(total_votes) AS min_total_votes,
        Max(total_votes) AS max_total_votes,
        Min(median_rating) AS min_median_rating,
        Max(median_rating) AS max_median_rating
FROM	ratings;
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH	rating_rankings AS
	(
		SELECT	m.title,
				r.avg_rating,
				DENSE_RANK() OVER( ORDER BY r.avg_rating DESC ) as movie_rank
		FROM	movie m
				INNER JOIN
				ratings r
				ON m.id = r.movie_id
	)
SELECT	*
FROM	rating_rankings
WHERE	movie_rank <= 10;


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT	median_rating,
		Count(movie_id) AS movie_count
FROM	ratings
GROUP BY median_rating
ORDER BY Count(movie_id) DESC;


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH	production_company_rankings AS
	(
		SELECT	m.production_company,
				count(m.id) AS movie_count,
				DENSE_RANK() OVER( ORDER BY Count(m.id) DESC ) AS prod_company_rank
		FROM	movie m
				INNER JOIN 
				ratings r
				ON m.id = r.movie_id
		WHERE	r.avg_rating > 8 AND m.production_company IS NOT NULL
		GROUP BY m.production_company
	)
SELECT	*
FROM	production_company_rankings
WHERE	prod_company_rank = 1;


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT	g.genre,
		Count(m.title) AS movie_count
FROM	movie m
		INNER JOIN 
			genre g
				ON m.id = g.movie_id
        INNER JOIN
			ratings r
				ON m.id = r.movie_id
WHERE	m.country like '%USA%' AND r.total_votes > 1000 and m.year=2017 AND Month(m.date_published) = 3
GROUP BY g.genre
ORDER BY Count(m.title) DESC;




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT	m.title,
		r.avg_rating,
        g.genre
FROM	movie m
		INNER JOIN 
			genre g
				ON m.id = g.movie_id
        INNER JOIN
			ratings r
				ON m.id = r.movie_id
WHERE	m.title like 'THE%' AND r.avg_rating > 8
GROUP BY m.title
ORDER BY avg_rating DESC;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT	count(*) as num_of_movies
FROM	movie AS m
		INNER JOIN 
			ratings AS r
				ON r.movie_id = m.id
WHERE	r.median_rating = 8	AND m.date_published BETWEEN '2018-04-01' AND '2019-04-01';
-- RESULT = 361 movies.

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- Based on language of movie:
SELECT	languages,
		Sum(total_votes) AS total_votes
FROM	movie AS M
		INNER JOIN ratings AS R
			ON R.movie_id = M.id
WHERE	languages LIKE '%Italian%'
UNION
SELECT	languages,
		Sum(total_votes) AS total_votes
FROM	movie AS M
		INNER JOIN ratings AS R
			ON R.movie_id = M.id
WHERE	languages LIKE '%GERMAN%'
ORDER BY total_votes DESC;

-- Based on country:
SELECT	country, sum(total_votes) as total_votes
FROM	movie AS m
		INNER JOIN ratings as r 
			ON m.id=r.movie_id
WHERE	country = 'Germany' or country = 'Italy'
GROUP BY country; 

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT	Sum(
			CASE
				WHEN NAME IS NULL THEN 1
				ELSE 0
			END) AS name_nulls,
		Sum(
			CASE
				WHEN height IS NULL THEN 1
				ELSE 0
			END) AS height_nulls,
		Sum(
			CASE
				WHEN date_of_birth IS NULL THEN 1
				ELSE 0
			END) AS date_of_birth_nulls,
		Sum(
			CASE
				WHEN known_for_movies IS NULL THEN 1
				ELSE 0
			END) AS known_for_movies_nulls
FROM	names;
-- Column height, date_of_birth and known_for_movies have null values.

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH top_genre_3 AS
(
	SELECT	g.genre,
			Count(g.movie_id) AS movie_count
	FROM	genre g
				INNER JOIN ratings r
					ON g.movie_id = r.movie_id
	WHERE	avg_rating>8
	GROUP BY genre
	ORDER BY movie_count DESC 
    LIMIT	 3 
)
SELECT	n.name AS director_name, 
		count(m.id) AS movie_count 
FROM	names AS n 
			INNER JOIN director_mapping AS d 
				ON n.id = d.name_id
			INNER JOIN movie AS m 
				ON d.movie_id = m.id 
			INNER JOIN ratings AS r 
				ON m.id = r.movie_id
			INNER JOIN genre AS g 
				ON g.movie_id = m.id
WHERE	g.genre IN ( SELECT genre FROM top_genre_3 )
			AND avg_rating > 8
GROUP BY name
ORDER BY movie_count DESC
LIMIT 3;
-- Top 3 directors are James Mangold/Joe Russo/Anthony Russo.

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT n.name      AS actor_name,
       Count(m.id) AS movie_count
FROM   names AS n
       INNER JOIN role_mapping AS ro
               ON n.id = ro.name_id
       INNER JOIN movie AS m
               ON ro.movie_id = m.id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE  r.median_rating >= 8
       AND ro.category = 'actor'
GROUP  BY name
ORDER  BY movie_count DESC
LIMIT  2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT     production_company ,
           Sum(total_votes) AS vote_count,
           rank() OVER w AS prod_comp_rank
FROM       movie         AS m
INNER JOIN ratings       AS r
ON         m.id=r.movie_id
GROUP BY   production_company window w AS (ORDER BY sum(total_votes) DESC)
LIMIT 3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT n.NAME 															AS actor_name,
       Sum(r.total_votes) 												AS total_votes,
       Count(DISTINCT ro.movie_id) 										AS movie_count,
       Round(Sum(r.avg_rating * r.total_votes) / Sum(r.total_votes), 2) AS actor_avg_rating,
       Rank()
         OVER (
           ORDER BY Round(Sum(r.avg_rating * r.total_votes) /
         Sum(r.total_votes), 2)
         DESC)                                                          AS actor_rank
FROM   names AS n
       INNER JOIN role_mapping AS ro
               ON n.id = ro.name_id
       INNER JOIN movie AS m
               ON ro.movie_id = m.id
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE  ro.category = 'actor'
       AND country = 'India'
GROUP  BY ro.name_id,
          n.NAME
HAVING Count(DISTINCT ro.movie_id) >= 5;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT n.name                                                           AS actress_name,
       SUM(r.total_votes)												AS total_votes,
       Count(DISTINCT ro.movie_id)                                      AS movie_count,
       Round(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actress_avg_rating,
       Rank()
         over (
           ORDER BY Round(SUM(r.avg_rating * r.total_votes) /
         SUM(r.total_votes), 2)
         DESC)                                                          AS actress_rank
FROM   names AS n
       inner join role_mapping AS ro
               ON n.id = ro.name_id
       inner join movie AS m
               ON ro.movie_id = m.id
       inner join ratings AS r
               ON r.movie_id = m.id
WHERE  ro.category = 'actress'
       AND country = 'India'
       AND languages = 'Hindi'
GROUP  BY ro.name_id,
          n.name
HAVING Count(DISTINCT ro.movie_id) >= 3
LIMIT 5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT title,
	   avg_rating,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop Movies'
       END AS avg_rating_movie_category
FROM   movie m
       INNER JOIN genre g
               ON m.id = g.movie_id
       INNER JOIN ratings r
               ON r.movie_id = m.id
WHERE  genre = 'Thriller';


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT genre,
       Round(Avg(duration), 2)                      AS avg_duration,
       SUM(Round(Avg(duration), 2))
         over(
           ORDER BY genre ROWS unbounded preceding) AS running_total_duration,
       Round(Avg(Avg(duration))
         over(
           ORDER BY genre ROWS 5 preceding), 2)         AS moving_avg_duration
FROM   movie AS m
       inner join genre AS g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY genre;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
WITH top_genres AS 
(
SELECT genre,year, COUNT(id) AS movie_count ,RANK () OVER (ORDER BY COUNT(id) DESC) AS genre_rank 
FROM genre AS g INNER JOIN movie AS m 
ON g.movie_id = m.id  
GROUP BY  genre 
ORDER BY movie_count DESC 
),
high_grossing AS
(
SELECT g.genre, year, m.title AS movie_name, worlwide_gross_income, RANK() OVER 
(PARTITION BY g.genre, year ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), 
UNSIGNED INT) DESC) AS movie_rank
FROM movie AS m 
INNER JOIN genre AS g ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_genres where genre_rank <= 3  ) )
SELECT * 
	FROM high_grossing 
		WHERE movie_rank <=5 ;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     m.production_company,
           Count(r.movie_id)   AS movie_count,
           row_number() OVER w AS prod_comp_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      position(',' IN languages)>0
AND        median_rating>=8 AND production_company IS NOT NULL
GROUP BY   production_company window w AS (ORDER BY count(id) DESC) limit 2;


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT     NAME AS actress_name,
           Sum(total_votes)										AS total_votes,
           Count(r.movie_id)                                    AS movie_count,
           Round(Sum(avg_rating*total_votes)/Sum(total_votes),1)AS actress_avg_rating,
           rank() OVER w                                        AS actress_rank
FROM       names                                                AS n
INNER JOIN role_mapping                                         AS ro
ON         n.id=ro.name_id
INNER JOIN ratings AS r
ON         r.movie_id =ro.movie_id
INNER JOIN genre AS g
ON         g.movie_id=r.movie_id
WHERE      r.avg_rating> 8
AND        g.genre='Drama'
AND        ro.category='actress'
GROUP BY   n.NAME window w AS (ORDER BY count(r.movie_id) DESC) limit 3;


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH top_directors AS 
(
   SELECT
      n.id as director_id,
      n.name as director_name,
      COUNT(m.id) AS movie_count,
      RANK() OVER (
   ORDER BY
      COUNT(m.id) DESC) AS director_rank 
   FROM
      names AS n 
      INNER JOIN
         director_mapping AS d 
         ON n.id = d.name_id 
      INNER JOIN
         movie AS m 
         ON d.movie_id = m.id 
   GROUP BY
      n.id 
)
,
movie_summary AS 
(
   SELECT
      n.id as director_id,
      n.name as director_name,
      m.id AS movie_id,
      m.date_published,
      r.avg_rating,
      r.total_votes,
      m.duration,
      LEAD(date_published) OVER (PARTITION BY n.id 
   ORDER BY
      m.date_published) AS next_date_published,
      DATEDIFF(LEAD(date_published) OVER (PARTITION BY n.id 
   ORDER BY
      m.date_published), date_published) AS inter_movie_days 
   FROM
      names AS n 
      INNER JOIN
         director_mapping AS d 
         ON n.id = d.name_id 
      INNER JOIN
         movie AS m 
         ON d.movie_id = m.id 
      INNER JOIN
         ratings AS r 
         ON m.id = r.movie_id 
   WHERE
      n.id IN 
      (
         SELECT
            director_id 
         FROM
            top_directors 
         WHERE
            director_rank <= 9
      )
)
SELECT
   director_id,
   director_name,
   COUNT(DISTINCT movie_id) AS number_of_movies,
   ROUND(AVG(inter_movie_days), 0) AS avg_inter_movie_days,
   ROUND( SUM(avg_rating*total_votes) / SUM(total_votes) , 2) AS avg_rating,
   SUM(total_votes) AS total_votes,
   MIN(avg_rating) AS min_rating,
   MAX(avg_rating) AS max_rating,
   SUM(duration) AS total_duration 
FROM
   movie_summary 
GROUP BY
   director_id 
ORDER BY
   number_of_movies DESC,
   avg_rating DESC;    
-- Top director is A.L. Vijay followed by Andrew Jones and Steven Soderbergh.