                
                -- MySQL Module End Project - Analyzing E-Learning Platform Purchases --

CREATE DATABASE learning_Platform;

USE learning_platform;

CREATE TABLE learners (
     learner_id INT PRIMARY KEY,
     full_name VARCHAR(30),
     country VARCHAR(30)
     );
     
CREATE TABLE courses (
     course_id INT PRIMARY KEY,
     course_name VARCHAR(30),
     category VARCHAR(30),
     unit_price DECIMAL(10,2)
     );
     
CREATE TABLE purchases (
	purchase_id INT PRIMARY KEY,
    learner_id INT,
    course_id INT,
    quantity INT,
	purchase_date DATE,
	FOREIGN KEY (learner_id) REFERENCES learners (learner_id),
	FOREIGN KEY (course_id) REFERENCES courses (course_id)
	);
    
    INSERT INTO learners
	VALUES (1, 'Akalya', 'India'),
		   (2, 'Jani', 'Nepal'),
           (3, 'Atchaya', 'Singapore'),
           (4, 'Divya', 'Malaysia'),
           (5, 'Rahana', 'India');
    
    INSERT INTO courses
	VALUES (111, 'Excel', 'Beginner', 9999),
		   (112, 'Power BI', 'Non-Technical', 14999),
           (113, 'SQL', 'Technical', 24999),
           (114, 'AI', 'Advance', 19999),
           (115, 'Python', 'Technical', 24999);
    
    INSERT INTO purchases
	VALUES (001, 4, 111, 2, '2026-06-15'),
		   (002, 5, 113, 1, '2026-06-17'),
           (003, 1, 115, 1, '2026-06-18'),
           (004, 4, 115, 3, '2026-06-19'),
           (005, 2, 114, 1, '2026-06-21'),
           (006, 3, 111, 1, '2026-06-23'),
           (007, 5, 114, 2, '2026-06-26'),
           (008, 2, 115, 1, '2026-06-28');
    
SELECT * FROM courses;
SELECT * FROM learners;
SELECT * FROM purchases;
    
                                -- Data Exploration Using Joins --
    
    SELECT full_name, course_name, category, quantity, ROUND(unit_price * quantity,2) AS total_amount, purchase_date 
    FROM learners AS l
    INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
	INNER JOIN courses AS c
    ON c.course_id = p.course_id
    ORDER BY total_amount DESC;
    
    
	SELECT full_name, course_name, category, quantity, ROUND(unit_price * quantity,2) AS total_amount, purchase_date 
    FROM learners AS l
    LEFT JOIN purchases AS p
    ON l.learner_id = p.learner_id
	LEFT JOIN courses AS c
    ON p.course_id = c.course_id
    ORDER BY total_amount DESC;
    
    
	SELECT full_name, course_name, category, quantity, ROUND(IFNULL(unit_price * quantity,0),2) AS total_amount, purchase_date 
    FROM purchases AS p
    RIGHT JOIN courses AS c
    ON p.course_id = c.course_id
	LEFT JOIN learners AS l
    ON p.learner_id = l.learner_id 
    ORDER BY total_amount DESC;
    
    
								-- Core Analytical --

-- Q.1 Display each learner's total spending with their country.

    SELECT l.learner_id, full_name, country, SUM(unit_price * quantity) AS total_spending
    FROM learners AS l
    LEFT JOIN purchases AS p
    ON l.learner_id = p.learner_id
	JOIN courses AS c
    ON p.course_id = c.course_id
    GROUP BY l.learner_id
    ORDER BY total_spending DESC;
                                
-- Q.2 Find the Top 3 most purchased courses by quantity 
                                
    SELECT p.course_id, course_name, SUM(quantity) AS toal_quantity 
    FROM purchases AS p
    JOIN courses AS c
    ON p.course_id = c.course_id
    GROUP BY p.course_id 
    ORDER BY toal_quantity DESC 
    LIMIT 3;
    
    
-- Q.3 Show each category's total revenue and number of unique learners
   
    SELECT category, SUM(unit_price * quantity) AS Total_revenue, COUNT(DISTINCT(p.learner_id)) AS Unique_learners
    FROM purchases AS p 
    INNER JOIN courses AS c 
    ON p.course_id = c.course_id
    GROUP BY category
    ORDER BY Total_revenue DESC;
    
-- Q.4 List learners who purchased from more than one category

    SELECT l.learner_id, full_name, COUNT(DISTINCT category) AS Categories_purchased
    FROM learners AS l 
    INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
    INNER JOIN courses AS c
    ON p.course_id = c.course_id
    GROUP BY l.learner_id
    HAVING Categories_purchased > 1;
    
-- Q.5 identify courses never purchased
    
    SELECT c.course_id, course_name
    FROM courses AS c
    LEFT JOIN purchases AS p
    ON c.course_id = p.course_id
    WHERE p.course_id IS NULL ;
    
    
								-- Subqueries & Correlated Subqueries -- 
                                
-- Q.6 Find learners whose total spending is above the average learner spending.
    
    SELECT l.learner_id, full_name, SUM(c.unit_price * p.quantity) AS Total_spending
    FROM learners AS l
    INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
    INNER JOIN courses AS c
    ON p.course_id = c.course_id
    GROUP BY l.learner_id
    HAVING Total_spending > (SELECT AVG(Total_spending) FROM 
    (SELECT SUM(c2.unit_price * p2.quantity) AS Total_spending 
    FROM purchases AS p2 
    INNER JOIN courses AS c2 
    ON p2.course_id = c2.course_id 
    GROUP BY p2.learner_id) AS Avgspending
    );
    
    
-- Q.7 Display Courses whose price is Higher than any course in the'Beginner'Category
    
    SELECT * FROM courses 
    WHERE unit_price > (SELECT MAX(unit_price) 
    FROM courses WHERE category = 'Beginner');
    
    
-- Q.8 Find learners who spent more than the average spending in their country
	SELECT l.*, SUM(c.unit_price * p.quantity) AS Total_spending
    FROM learners AS l 
    INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
    INNER JOIN courses AS c
    ON p.course_id = c.course_id
    GROUP BY l.learner_id
    HAVING Total_spending > (SELECT AVG(country_total)
    FROM (SELECT l2.country, l2.learner_id, SUM(c2.unit_price * p2.quantity) AS country_total
    FROM learners AS l2
    INNER JOIN purchases AS p2
    ON l2.learner_id = p2.learner_id
    INNER JOIN courses AS c2
    ON p2.course_id = c2.course_id
    WHERE l2.country = l.country
    GROUP BY l2.country, l2.learner_id ) AS CountryAvg
   ) ;
    
    
								-- CTE, CASE, VIEW and NULL Handling
    
-- Q.9 Use a CTE to Calculate total spending per learner, then; Display learners with spending above 10,000.
    
    WITH LearnerSpending AS (SELECT l.learner_id, l.full_name, SUM(c.unit_price * p.quantity) AS Total_Spending
    FROM learners AS l
    INNER JOIN purchases AS p
    ON l.learner_id = p.learner_id
    INNER JOIN courses AS c
    ON p.course_id = c.course_id
    GROUP BY l.learner_id, l.full_name)
    SELECT * FROM LearnerSpending 
    WHERE Total_Spending > 10000;
    
    
-- Q.10 CASE Expression
    
    SELECT l.learner_id, l.full_name, SUM(c.unit_price * p.quantity) AS Total_Spending,
    CASE
        WHEN SUM(c.unit_price * p.quantity) > 15000 THEN 'High Value'
        WHEN SUM(c.unit_price * p.quantity) BETWEEN 8000 AND 15000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Category
	FROM learners  AS l
	INNER JOIN purchases AS p
	ON l.learner_id = p.learner_id
	INNER JOIN courses c
	ON p.course_id = c.course_id
	GROUP BY l.learner_id;
    
    
-- Q.11 NULL Handling
    
	SELECT c.course_id, c.course_name, COALESCE(COUNT(p.purchase_id),0) AS Purchase_Count
    FROM courses c
    LEFT JOIN purchases p
    ON c.course_id = p.course_id
    GROUP BY c.course_id;
    
    
-- Q.12 View

	CREATE VIEW category_performance_view AS 
    SELECT Category, SUM(c.unit_price * p.quantity) AS Total_Revenue, 
    COUNT(p.purchase_id) AS Number_of_Purchases, ROUND(AVG(c.unit_price * p.quantity),2) AS Average_revenue_per_purchase
    FROM courses AS c
    INNER JOIN purchases AS p
    ON c.course_id = p.course_id
    GROUP BY Category;
    
    
    SELECT * FROM category_performance_view;
    
    
    /*
=====================================================================================================================================================
                                                       PROJECT SUMMARY / OBSERVATIONS
=====================================================================================================================================================

1. Created a relational database using three tables:learners, courses, and purchases with Primary Key and Foreign Key relationships.

2. Used INNER JOIN, LEFT JOIN, and RIGHT JOIN to combine learner, course, and purchase data for analysis.

3. Calculated total spending of each learner and identified the highest spending learners.

4. Analyzed the most purchased courses and category-wise revenue to understand course performance.

5. Used Subqueries and Correlated Subqueries to compare learner spending with average spending and identify above-average performers.

6. Applied CTE, CASE expression, NULL handling, and VIEW to generate meaningful business insights and improve query readability.

7. Identified courses that were never purchased, helping recognize low-performing courses that may require promotional strategies.

8. This project demonstrates how SQL can be used to analyze learner behavior, monitor sales trends, and support data-driven business decisions for an
   e-learning platform.

=====================================================================================================================================================
*/