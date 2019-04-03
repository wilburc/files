-- NOTES
	-- • use outer joins when appropriate!
	-- • account for null values when counting, summing


CREATE TABLE Employees
	(`EmployeeID` int, `DepartmentID` int, `BossID` int, `Name` varchar(7), `Salary` int)
;
	
INSERT INTO Employees
	(`EmployeeID`, `DepartmentID`, `BossID`, `Name`, `Salary`)
VALUES
	(1, 1, 3, 'Alex', 30000),
	(2, 2, 4, 'Bob', 40000),
	(3, 1, 5, 'Chris', 60000),
    (4, 2, NULL, 'Dylan', 80000),
    (5, 3, NULL, 'Ed', 50000),
    (6, 2, 1, 'Fred', 25000),
    (7, 5, NULL, 'George', 20000)
;

CREATE TABLE Departments
  (`DepartmentID` int, `Name` varchar(7))
;

INSERT INTO Departments
    (`DepartmentID`, `Name`)
VALUES
    (1, 'Eng'),
    (2, 'Design'),
    (3, 'HR'),
    (4, 'Execs'),
    (5, 'Sales')
;



CASE SYNTAX

SELECT player_name,
       weight,
       CASE WHEN weight > 250 THEN 'over 250'
            WHEN weight > 200 THEN '201-250'
            WHEN weight > 175 THEN '176-200'
            ELSE '175 or under' END AS weight_group
  FROM benn.college_football_players



1. Employees (names) who have bigger salary than their boss

USING SELF-JOIN

SELECT
  emp.Name
FROM
  Employees emp
INNER JOIN 
  Employees boss
ON
  emp.BossID = boss.EmployeeID
WHERE
  emp.Salary > boss.Salary
;



SELECT
  emp.Name
FROM
  Employees emp
  ,Employees boss
WHERE
  emp.Salary > boss.Salary
AND
  emp.BossID = boss.EmployeeID
;


2. Employees who have the biggest salary in their departments

USING SUBQUERY

SELECT
  Name
FROM
  Employees emp
INNER JOIN
(
  SELECT
    emp.DepartmentID
    ,max(emp.Salary) as highest_salary
  FROM
    Employees emp
  GROUP BY
    emp.DepartmentID
) emp2
WHERE
  emp.DepartmentID = emp2.DepartmentID
AND
  emp.Salary = emp2.highest_salary
;

USING RANK


SELECT
  e.Name 
FROM
  (
    SELECT 
     RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS Rank
     ,Name
     FROM 
       Employees
   ) e
WHERE
  e.Rank = 1
;


3. Departments that have less than 3 people in them

-- MUST SPECIFY e.EmployeeId (or e.Name) IN COUNT. 

SELECT 
  d.Name
FROM
  Departments d
INNER JOIN(
SELECT
  e.DepartmentID
FROM
  Employees e
GROUP BY
  1
HAVING
  COUNT(e.Name) < 3
) s 
WHERE 
  d.DepartmentID = s.DepartmentID






SELECT
  d.Name
FROM 
  Departments d
LEFT JOIN
  Employees e
ON
  (e.DepartmentId = d.DepartmentId)
GROUP BY 
  d.Name
HAVING
  count(e.EmployeeId) < 3 
;

SELECT
  d.Name
FROM
  Departments d
  ,Employees e
WHERE
  e.DepartmentID = d.DepartmentID
GROUP BY 
  d.Name
HAVING
  count(e.EmployeeId) < 3 
UNION ALL
SELECT
  DISTINCT(d.Name)
FROM 
  Departments d
 ,Employees e
WHERE NOT EXISTS 
  (
  SELECT 
    * 
  FROM 
    Employees e
  WHERE 
    d.DepartmentID = e.DepartmentID
  )
GROUP BY
  d.Name
;



4. Departments along with the number of people there 

SELECT
  d.Name
  ,count(e.EmployeeId) as headcount
FROM 
  Departments d
LEFT JOIN
  Employees e
ON
  (e.DepartmentId = d.DepartmentId)
GROUP BY 
  d.Name
;

5. Employees that don’t have a boss in the same department

SELECT
  emp.Name
FROM
  Employees emp
  , Employees boss
WHERE
  emp.BossID = boss.EmployeeID
AND
  emp.DepartmentID <> boss.DepartmentID
;

6. All departments and total salary there

SELECT
  d.Name as Department
  ,SUM(COALESCE(e.Salary, 0)) as Total_salary
FROM
  Employees e
RIGHT OUTER JOIN
  Departments d
ON 
  e.DepartmentID = d.DepartmentID
GROUP BY 
  d.Name
;

7. Employees from departments where max salary is 40k

SELECT
  e.Name
FROM 
  Employees e
INNER JOIN
(
  SELECT
    d.Name
   ,d.DepartmentID
  FROM
    Employees e
  INNER JOIN
    Departments d
  ON
    e.DepartmentID = d.DepartmentID
  GROUP BY 
    d.Name
  HAVING
    MAX(e.Salary) <= 40000
) dept
WHERE
  e.DepartmentID = dept.DepartmentID
;

9. Select employee with second highest salary 

SELECT
  e2.Name
FROM 
(
  SELECT
    e.Name
   ,e.Salary
  FROM
    Employees e
  ORDER BY 
    e.Salary DESC
  LIMIT 2
) e2
ORDER BY 
  e2.Salary
LIMIT 1
;

10. Select employee with N highest salary

SELECT
  e.Name
FROM
  Employees e
WHERE
  (
    SELECT 
      COUNT(DISTINCT(e2.Salary)) 
    FROM 
      Employees e2
    WHERE
      e2.Salary > e.Salary
  ) = 3
;

11. Select departments and the highest salary in that department


SELECT
  d.Name
  ,IFNULL(MAX(e.Salary),0) as "highest salary"
FROM
  Employees e
RIGHT OUTER JOIN
  Departments d
ON
  e.DepartmentID = d.DepartmentID
GROUP BY
  d.Name
;



12. joining two tables without caring if NULL
SELECT
    p.FirstName
    ,p.LastName
    ,a.City
    ,a.State
FROM
    Person p
LEFT OUTER JOIN
    Address a
ON 
    a.PersonId = p.PersonId
;


13. Second highest salary, null if none

SELECT
    MAX(e.Salary) AS SecondHighestSalary
FROM
    Employee e
WHERE
   	e.Salary < 
    (
    SELECT
        MAX(e2.Salary)
    FROM
        Employee e2
    )

-- alt

SELECT
	(
	SELECT
		DISTINCT(Salary)
	FROM 
		Employee 
	ORDER BY
		Salary DESC 
	LIMIT
		1
	OFFSET
		1
	)
AS SecondHighestSalary

14. Rankings without rank() 

-- >= is important. dont do > 
SELECT 
	Score
	,(
	SELECT 
		COUNT(DISTINCT(SCORE)) 
	FROM 
		Scores 
	WHERE 
		Score >= s.Score
	) as Rank
FROM
	Scores s
ORDER BY 
	Score DESC

15. Customers who never order (their id does not show up in the orders table)

# Write your MySQL query statement below

SELECT
    c.Name as Customers
FROM
    Customers c
WHERE
    c.Id NOT IN (
                SELECT
                    o.CustomerId
                FROM
                    Orders o
                )


16. Employees who have the highest salaries in their departments
SELECT
    d.Name as Department
    ,e.Name as Employee
    ,e.Salary as Salary
FROM 
    Employee e
    ,Department d
INNER JOIN
    (
    SELECT
        e.DepartmentId
        ,MAX(e.Salary) as highest_salary
    FROM
        Employee e
    GROUP BY
        e.DepartmentId
    ) h
WHERE
    e.DepartmentId = h.DepartmentId
AND
    e.Salary = h.highest_salary
AND
    e.DepartmentId = d.Id

SELECT 
	d.Name as Department
	,e.Name as Employee
	,e.Salary as Salary
FROM 
	Employee e
	,Department d
WHERE
	e.DepartmentId = d.Id
AND
	e.Salary = (
				SELECT
					MAX(Salary)
				FROM
					Employee e2
				WHERE 
					e2.DepartmentId = d.Id	
				);

17. Department and their top 3 salaries

-- DO NOT FORGET TO COMPARE DEPARTMENTS TOO IN SUBQUERY
SELECT
    d.Name as Department
    , e.Name as Employee
    , e.Salary
FROM
    Employee e
    ,Department d
WHERE
    e.DepartmentId = d.Id
AND
    2 >= (
    SELECT
        COUNT(DISTINCT(e2.Salary))
    FROM
        Employee e2
    WHERE 
        e2.Salary > e.Salary
    AND
        e2.DepartmentId = e.DepartmentId
    ) 
ORDER BY
    Salary DESC
    , Department
;

18. Select all duplicates

SELECT
    DISTINCT(p.Email)
FROM
    Person p
    ,Person p2
WHERE
    p.Id <> p2.Id
AND
    p.Email = p2.Email
;

SELECT
    Email
FROM
    Person
GROUP BY
    Email
HAVING 
    COUNT(*) > 1
;
    
19. Days where the weather went up the next Days
# Write your MySQL query statement below

SELECT
    w.Id 
FROM
    Weather w
    ,Weather w_prev
WHERE
    TO_DAYS(w.Date) = TO_DAYS(w_prev.Date) + 1
AND
    w.Temperature > w_prev.Temperature
;

20. Crazy trips and users query

-- yOU NEED “OR NULL” SO IT DOESNT GET COUNTED
SELECT
    t.Request_at as Day
    ,round(count(t.Status != 'Completed' OR NULL) / count(*), 2) as "Cancellation Rate"
FROM
    Trips t
INNER JOIN
    Users u
ON
    (u.Users_Id = t.Client_Id)
WHERE
    u.Banned = 'No'
AND
    u.Role = 'Client'
AND
    t.Request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY
    t.Request_at
ORDER BY    
    Day
;

21. Numbers that appear at least 3 times in a row

SELECT
    DISTINCT(l1.Num) as ConsecutiveNums
FROM
    Logs l1
    ,Logs l2
    ,Logs l3
WHERE
    l1.Num = l2.Num
AND
    l1.Num = l3.Num
AND
    l1.Id = (l2.Id - 1)
AND
    l1.Id = (l3.Id - 2)
;




