USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT 
    first_name
    ,last_name
FROM actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the 
column Actor Name. */

SELECT 
    upper(concat(first_name,' ', last_name)) `Actor Name` 
FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name
, "Joe." What is one query would you use to obtain this information? */

SELECT
    actor_id 
    ,first_name
    ,last_name
FROM actor
WHERE
    first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT
    first_name
    ,last_name
FROM actor
WHERE
    last_name like '%gen%';

/* 2c. Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order: */

SELECT
    first_name
    ,last_name
FROM actor
WHERE
    last_name like '%li%'
ORDER BY last_name, first_name;

/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan
, Bangladesh, and China: */

SELECT
    country_id
    ,country
FROM country
WHERE
    country in ('Afghanistan', 'Bangladesh', 'China');
    
/* 3a. You want to keep a description of each actor. You don't think you will be performing queries 
on a description, so create a column in the table actor named description and use the data type 
BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). */

ALTER TABLE `actor`
	ADD COLUMN `description` BLOB NULL AFTER `last_update`;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete 
the description column. */

ALTER TABLE `actor`
	DROP COLUMN `description`;

/* 4a. List the last names of actors, as well as how many actors have that last name. */

SELECT
    last_name
    ,count(1) qtt
FROM actor
GROUP BY
    last_name;
    
/* 4b. List last names of actors and the number of actors who have that last name, but only for 
names that are shared by at least two actors */

SELECT
    last_name
    ,count(1) qtt
FROM actor
GROUP BY
    last_name
HAVING count(1) > 1
ORDER BY count(1) desc;

/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
 Write a query to fix the record. */
 
 UPDATE actor
 SET first_name = 'Harpo'
 WHERE first_name = 'Groucho' and last_name = 'Williams';
 
/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was 
the correct name after all! In a single query, if the first name of the actor is currently HARPO
, change it to GROUCHO. */

 UPDATE actor
 SET first_name = 'Groucho'
 WHERE first_name = 'Harpo' and last_name = 'Williams';
 
/* 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? */
 
 SHOW CREATE TABLE address;
 
/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
Use the tables staff and address: */

SELECT 
    CONCAT(first_name, ' ' ,last_name) staff_member
    ,b.address
FROM staff a
JOIN address b ON a.address_id = b.address_id;

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
 Use tables staff and payment. */
 
SELECT 
    CONCAT(first_name, ' ' ,last_name) staff_member
    ,SUM(b.amount) pay
FROM staff a
JOIN payment b ON a.staff_id = b.staff_id
WHERE
    b.payment_date >= '2005-08-01' AND b.payment_date < '2005-09-01'
GROUP BY
    staff_member;
    
/* 6c. List each film and the number of actors who are listed for that film. Use tables film_actor 
and film. Use inner join. */

SELECT 
    title
    ,COUNT(b.actor_id) Total_Actors
FROM film a
JOIN film_actor b ON a.film_id = b.film_id
GROUP BY
    title;
    
/* 6d. How many copies of the film Hunchback Impossible exist in the inventory system? */

SELECT 
    title
    ,a.film_id
    ,COUNT(b.film_id) Total
FROM film a
JOIN inventory b ON a.film_id = b.film_id
WHERE 
    a.title = 'Hunchback Impossible'
GROUP BY
    title, a.film_id;
    
/* 6e. Using the tables payment and customer and the JOIN command, list the total 
paid by each customer. List the customers alphabetically by last name: */

SELECT 
    first_name
	 ,last_name
    ,SUM(amount) paid
FROM customer a
JOIN payment b ON a.customer_id = b.customer_id
GROUP BY
    first_name
	 ,last_name
ORDER BY 
    last_name;
    
/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence
, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
of movies starting with the letters K and Q whose language is English. */

SELECT
    *
FROM	(
		SELECT 
		    title
		FROM film
		WHERE 
		language_id = (SELECT language_id FROM `language` WHERE `name` = 'english')
		) A
WHERE (title LIKE 'Q%') OR (title LIKE 'K%');

/* 7b. Use subqueries to display all actors who appear in the film Alone Trip. */

SELECT 
    first_name
    ,last_name
FROM actor 
WHERE 
actor_id IN ( 
					SELECT
					    actor_id
					FROM 
					    film_actor
					WHERE 
					    film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip'));
					    
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email 
addresses of all Canadian customers. Use joins to retrieve this information. */

SELECT 
    first_name
    ,last_name
    ,email
FROM customer
WHERE 
    address_id IN (SELECT 
					     address_id 
				       FROM
				        address
					    WHERE 
					     city_id IN (		    
											SELECT 
											    city_id
											FROM city 
											    WHERE country_id = (SELECT country_id FROM country WHERE country = 'canada')));


/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
 Identify all movies categorized as family films. */
 
SELECT
    title
FROM film
WHERE 
    film_id IN (    
						SELECT
						film_id
						FROM film_category a 
						WHERE 
						a.category_id = (SELECT category_id FROM category WHERE NAME = 'family'));
						
/* 7e. Display the most frequently rented movies in descending order. */
SELECT
    title
    ,rentals
FROM film, 
			  (SELECT
				    film_id
				    ,rentals
				FROM inventory a
				JOIN (
						SELECT
						    inventory_id
						    ,COUNT(1) rentals
						FROM rental
						GROUP BY
						    inventory_id
						ORDER BY rentals DESC) b
				ON a.inventory_id = b.inventory_id) b
WHERE film.film_id = b.film_id;

/* 7f. Write a query to display how much business, in dollars, each store brought in. */

SELECT
    store_id
    ,SUM(total)
FROM inventory a, 
				  (SELECT 
					    inventory_id
						 ,sum(b.amount) total
					FROM rental a,
							  (SELECT 
								    rental_id
								    ,amount
								FROM payment) b 
					WHERE
					    a.rental_id = b.rental_id
					GROUP BY inventory_id
					) b
WHERE a.inventory_id = b.inventory_id
GROUP BY store_id;

/* 7g. Write a query to display for each store its store ID, city, and country. */

SELECT
    store_id 
    ,b.address
    ,c.city
    ,d.country
FROM
    store a 
	     ,(SELECT * FROM address) b
			  ,(SELECT * FROM city ) c
				 ,(SELECT * FROM country ) d  
WHERE
    a.address_id = b.address_id AND b.city_id = c.city_id AND c.country_id = d.country_id;
    
/* 7h. List the top five genres in gross revenue in descending order.
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */

SELECT 
    c.name Genre
	 ,SUM(p.amount) Gross 
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 
   c.name 
ORDER BY Gross  DESC
LIMIT 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five 
genres by gross revenue. Use the solution from the problem above to create a view. If you haven't 
solved 7h, you can substitute another query to create a view. */

CREATE VIEW genre_revenue AS
		SELECT 
		    c.name Genre
			 ,SUM(p.amount) Gross 
		FROM category c
		JOIN film_category fc ON c.category_id = fc.category_id
		JOIN inventory i ON fc.film_id = i.film_id
		JOIN rental r ON i.inventory_id = r.inventory_id
		JOIN payment p ON r.rental_id = p.rental_id
		GROUP BY 
		   c.name 
		ORDER BY Gross  DESC
		LIMIT 5;
    
/* 8b. How would you display the view that you created in 8a? */

SELECT * FROM genre_revenue; 

/* 8c. You find that you no longer need the view top_five_genres. Write a query to delete it. */

DROP VIEW genre_revenue;
					    
