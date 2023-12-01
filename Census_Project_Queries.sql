-- Total Number of rows in the Dataset
SELECT COUNT(*) as Total_rows 
FROM dbo.Data1;

SELECT COUNT(*) as Total_rows 
FROM dbo.Data2;

-- Data only for JHARKHAND and BIHAR

SELECT *
FROM dbo.Data1
WHERE Data1.State IN ('Jharkhand','Bihar');

SELECT *
FROM dbo.Data2
WHERE Data2.State IN ('Jharkhand','Bihar');

-- Calculating the Total Population Of INDIA

SELECT SUM(Data2.Population) As Total_Population_Of_India
FROM Dbo.Data2 ;

-- Calculating Average growth Of INDIA

SELECT AVG(Data1.Growth) * 100 As Average_Growth_of_INDIA
FROM dbo.Data1 ;

-- Calculating Average growth Of State

SELECT Data1.State , AVG(Data1.Growth) * 100 As Average_Growth
FROM dbo.Data1
GROUP BY Data1.State ;

-- Average Sex Ratio as Per State

SELECT Data1.State ,ROUND(AVG(Data1.Sex_Ratio),1)As Average_Sex_Ratio
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Sex_Ratio DESC ;

-- Average Literacy Rate more than 90

SELECT Data1.State ,ROUND(AVG(Data1.Literacy),1) As Average_Literacy_Rate
FROM dbo.Data1
GROUP BY Data1.State
HAVING ROUND(AVG(Data1.Literacy),1) > 90
ORDER BY Average_Literacy_Rate DESC ;

-- Top 3 States with Highest Growth Percentage

SELECT TOP(3) Data1.State , AVG(Data1.Growth) * 100 As Average_Growth
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Growth DESC ;

-- Top 3 States with Lowest Growth Percentage

SELECT TOP(3) Data1.State , AVG(Data1.Growth) * 100 As Average_Growth
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Growth ;

-- Top 3 States with Low Literacy Rate

SELECT TOP 3 Data1.State ,ROUND(AVG(Data1.Literacy),1) As Average_Literacy_Rate
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Literacy_Rate ;

-- Top 3 States with High Literacy Rate

SELECT TOP 3 Data1.State ,ROUND(AVG(Data1.Literacy),1) As Average_Literacy_Rate
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Literacy_Rate DESC ;

-- TOP 3 State with Highest Sex Ratio

SELECT TOP 3 Data1.State ,ROUND(AVG(Data1.Sex_Ratio),1)As Average_Sex_Ratio
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Sex_Ratio DESC ;

-- TOP 3 State with Lowest Sex Ratio

SELECT TOP 3 Data1.State ,ROUND(AVG(Data1.Sex_Ratio),1)As Average_Sex_Ratio
FROM dbo.Data1
GROUP BY Data1.State
ORDER BY Average_Sex_Ratio ;

-- Top 3 and Buttom 3 states with Growth Rate in a Single table

DROP TABLE IF EXISTS topstates
CREATE TABLE topstates
( State nvarchar(255),
  Growth_rate Float )

INSERT INTO topstates
					  SELECT Data1.State ,ROUND(AVG(Data1.Growth)*100,1) As Average_Growth 
					  FROM dbo.Data1
					  GROUP BY Data1.State;

SELECT TOP 3 State , Growth_rate 
FROM topstates
ORDER BY Growth_rate DESC;

DROP TABLE IF EXISTS buttomstates
CREATE TABLE buttomstates
( State nvarchar(255),
  Growth_rate Float )

INSERT INTO buttomstates
					  SELECT Data1.State ,ROUND(AVG(Data1.Growth)*100,1) As Average_Growth 
					  FROM dbo.Data1
					  GROUP BY Data1.State;

SELECT TOP 3 State , Growth_rate 
FROM buttomstates
ORDER BY Growth_rate;

-- USE of UNION Operator

SELECT * FROM (SELECT TOP 3 State , Growth_rate 
				FROM topstates
				ORDER BY Growth_rate DESC) As a

UNION

SELECT * FROM (SELECT TOP 3 State , Growth_rate 
				FROM buttomstates
				ORDER BY Growth_rate) AS b
				ORDER BY Growth_rate DESC;


-- Filtering The Data of States which starts with letter 'A'

SELECT Data1.District , Data1.Growth , Data1.Literacy , Data1.Sex_Ratio ,Data1.State
FROM dbo.Data1
WHERE Data1.State Like 'A%';

-- Filtering The Data of States which starts with letter 'A' and end with letter 'h'

SELECT Data1.District , Data1.Growth , Data1.Literacy , Data1.Sex_Ratio ,Data1.State
FROM dbo.Data1
WHERE Data1.State Like 'A%H';

-- Number of Males and Females in the State


WITH cte as (SELECT  a.State ,a.Sex_Ratio/1000 As Sex_Ratio ,
			 SUM(b.population) as Total_Population
			 FROM dbo.Data1 As a
			 JOIN dbo.Data2 As b on a.District = b.District
			 GROUP BY a.State , a.District , a.Sex_Ratio )

SELECT State , 
SUM(ROUND(Total_Population/(Sex_Ratio+1),0)) As Male_Population,
SUM(ROUND(Total_Population - (Total_Population/(Sex_Ratio+1)),0)) As Female_Population ,SUM(Total_Population)
FROM cte
GROUP BY State ;

-- Total Number of literate and Illitrate People as per States

SELECT C.State ,SUM(C.Literate_People) As Count_of_Literate_People ,
SUM(C.Illitrate_People) As Count_of_Illitrate_People
FROM(
	  SELECT D.District , D.State , ROUND(D.Literacy_Ratio * D.Total_Population,0) As Literate_People ,
	  ROUND((1-D.Literacy_Ratio) * D.Total_Population,0) As Illitrate_People
	  FROM (
			 SELECT a.District , a.State ,a.literacy/100 as Literacy_Ratio,b.population as Total_Population
			  FROM dbo.Data1 As a
			  JOIN dbo.Data2 As b on a.District = b.District ) As D
	) C
GROUP BY C.State ;

-- Previous Population Vs. New Population Of States

SELECT D.State , SUM(D.Previous_Population) As Previous_Population, SUM(D.Current_Population) As Current_Population
FROM
	(
	  SELECT A.District , A.State ,ROUND(Current_Population/(1+Growth_Ratio),0) As Previous_Population , A.Current_Population
	  FROM (
		     SELECT a.District , a.State ,a.Growth As Growth_Ratio ,b.population as Current_Population
		     FROM dbo.Data1 As a
		     JOIN dbo.Data2 As b on a.District = b.District ) A
	) D
GROUP BY D.State ;


-- TOP 3 Ditsrict from each State as per Literacy Rate


With MyCte As (
			    SELECT d.District , d.State , d.Literacy,
			    ROW_NUMBER() OVER (PARTITION BY d.state ORDER BY d.Literacy DESC ) as RN
			    FROM dbo.Data1 as d
			 )
SELECT District , State , Literacy 
FROM MyCte
WHERE RN <=3





