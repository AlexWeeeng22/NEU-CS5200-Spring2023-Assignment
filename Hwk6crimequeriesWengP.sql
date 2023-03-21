USE  crime_db2022wengp;

-- 4.	(5 points)
-- For each calendar day in the database, generate the number of crime incidents that occurred on that day.
--  The result should contain the calendar day and the count of the crimes.
--  Rename the count of the crimes to num_crimes. Return the results ordered by the incident date in ascending order.
use crime_db2022wengp;
SELECT date(Occurred_on_Date) AS incident_day, count(incident_number) AS incident_number FROM incident GROUP BY incident_day
ORDER BY incident_day DESC;


-- 5.	(5 points)
-- Which street had the most number of crime incidents? Return the street name and the number of incidents. 
SELECT Street As street_name, count(incident_number) AS incident_number 
FROM incident Group BY street_name
HAVING incident_number = (SELECT max(incident_number) FROM (SELECT Street,count(incident_number) AS incident_number FROM incident GROUP BY Street) a);
-- ORDER BY street_name DESC;


-- 6.	(5 points)
-- what is the maximum number of crimes that could have occurred in the North End 
-- during the specific time period? Return the number  

-- SELECT count(incident_number), district_code FROM incident 
-- WHERE district_code=(SELECT district_code from neighborhood where neighborhood_name='North End')
-- GROUP BY district_code;

SELECT count(incident_number) FROM incident 
WHERE district_code=(SELECT district_code from neighborhood where neighborhood_name='North End');

-- 7.	(5 points)
-- How many crimes occurred in Hyde Park? Return the number. 

-- SELECT count(district_code) FROM incident
-- WHERE district_code = ('E18');

-- select sum(num) as Hyde_Park_number from (
-- (select Street,count(incident_number) as num
-- from incident
-- where Street like '%HYDE PARK%'
-- group by Street))a;

select sum(num) as Hyde_Park_number from (
(select district_code,count(incident_number) as num
from incident
where district_code=(select district_code from neighborhood where neighborhood_name like '%HYDE PARK%')
group by district_code))a;

-- 8.	(5 points)
-- Report on all rapes that occurred during the time period. 
-- Return the crime code, the incident date and the district. 
-- Order the results by date, then by district.  

-- SELECT crime_code,Occurred_on_Date,district_name 
-- FROM
--     (SELECT crime_code,Occurred_on_Date,offense_name,district_name 
--      FROM (offense RIGHT JOIN incident ON crime_code=offense_code) 
--      LEFT JOIN district ON district.district_code=incident.district_code 
--      WHERE offense_name LIKE '%RAPE%') c
-- ORDER BY Occurred_on_Date DESC, district_name DESC;

-- SELECT crime_code, Occurred_on_Date, offense_name, district_name 
--      FROM (offense RIGHT JOIN incident ON crime_code=offense_code
--      LEFT JOIN district ON district.district_code=incident.district_code)
--      WHERE offense_name LIKE '%RAPE%';
--  
-- SELECT crime_code, offense_name FROM offense
-- WHERE offense_name LIKE '%RAPE%'; 

-- SELECT crime_code, offense_name FROM (offense LEFT JOIN incident ON crime_code = offense_code)
-- WHERE offense_name LIKE '%RAPE%';

-- SELECT crime_code, Occurred_on_Date, offense_name, district_name FROM (offense LEFT JOIN incident ON crime_code = offense_code
-- LEFT JOIN district ON district.district_code=incident.district_code)
-- WHERE offense_name LIKE '%RAPE%';

select crime_code,Occurred_on_Date,district_name from
(select crime_code,Occurred_on_Date,offense_name,district_name 
from (offense right join incident  on crime_code=offense_code) left join district on district.district_code=incident.district_code 
where offense_name like '%rape%') c
order by Occurred_on_Date desc, district_name desc;

-- 9.	 (5 points)
-- Determine the number of times each crime code occurred during the time period. 
-- Rename the count num_occurrences. 
-- The results should contain the crime code, the crime description and the count num_occurrences. 
-- Order the results in descending order using num_occurences.  
-- Each crime code must appear in the result. 
-- If a crime code did not occur, then its num_occurrences should be 0. 

SELECT offense_code AS crime_code, count(offense_code) AS num_occurences FROM incident GROUP BY crime_code
ORDER BY num_occurences DESC;

SELECT  a.crime_code,b.offense_name,a.num_occurrences from(
SELECT  crime_code,count(incident_number) AS num_occurrences
FROM incident RIGHT JOIN  offense ON incident.offense_code= offense.crime_code
GROUP BY crime_code)a LEFT JOIN offense b
ON a.crime_code=b.crime_code;


-- 10.	(5 points)
-- Determine the number of crimes that occurred in the database. 
-- The result should contain the district code, the district name, and the number of crimes for the district. 
-- Rename the number of crimes num_crimes. Orders the results in descending order using num_crimes. 
select b.district_code, b.district_name,a.num_crimes 
from (select count(incident_number) as num_crimes ,district_code from incident group by district_code) a 
right join district b
on b.district_code=a.district_code
order by num_crimes desc;


-- 11.	(5 points)
-- For each crime code, determine the number of districts it occurred in. 
-- If the crime did not occur, then the number of districts should be reported as 0.  

select crime_code, count(distinct district_code) from incident right join offense 
on incident.offense_code=offense.crime_code
group by crime_code;

-- 12.	(5 points)
-- Generate a list of crimes that occurred between  Christmas and December 28th, inclusively.  
-- Include the incident number, the name of the district, the description of the crime offense and the date of the crime.  
-- Order the results in ascending order by date of the crime 

select incident_number,district_name,offense_name,Occurred_on_Date from
( incident left join district on district.district_code=incident.district_code)
left join offense on incident.offense_code=offense.crime_code
where date(Occurred_on_Date) between '2022-12-25' and '2022-12-28'
order by Occurred_on_Date asc;



-- 13.	(5 points)
-- Generate the top crime for each district. 
-- The result should contain the name of the district, 
-- the description of the crime offense and the number of incidents. 
select  district_name,offense_name,max_crime from (
select district_name,offense_name,max_crime ,ROW_NUMBER() over(Partition by district_name  order by max_crime desc) as c 
from((select district_code,offense_code,count(incident_number)as max_crime 
from incident group by district_code,offense_code)a 
left join offense on a.offense_code=offense.crime_code)
left join district on a.district_code=district.district_code)b
where c=1;


-- 14.	(5 points)
-- For each crime code committed, 
-- create an aggregated list of district names where the crime was committed as well as 
-- the number of times the crime occurred. The result consists of the crime description, 
-- the aggregated field of the district names and the count of the number of times the crime code occurred. 
-- Rename the aggregated district names to districts and rename the count of crime instances to num_crimes. 
-- Order the results in descending order using the num_crimes field. 
select a.offense_code,districts,num_crimes from
(select offense_code,count(incident_number)as num_crimes from incident group by offense_code)a
left join (select offense_code,group_concat(district_name)as districts from (select offense_code,district_name from incident left join district on district.district_code=incident.district_code) d
group by offense_code)b
on a.offense_code=b.offense_code;



-- 15.	(5 points)
-- What is the number of crimes that occur per calendar day? 
-- The results should contain the calendar day  and the average number of crimes for that calendar day. 
-- Order the results in ascending order by the crime date.
select date(Occurred_on_Date) ,count(incident_number) from incident 
group by date(Occurred_on_Date)
order by date(Occurred_on_Date) asc;



-- 16.	(5 points)
-- What is the number of crimes that occur per day of the week? 
-- The results should contain the day of the week and the number of crimes for that day. 
-- Order the results by the days of the week starting with Monday and ending with Sunday.

select Day_of_week ,count(incident_number) from incident 
group by Day_of_week
order by Day_of_week asc;


-- 17.	(5 points)
-- What is the number of crimes that occur per calendar day? 
-- The results should contain an average number. 
select avg(num) from 
(select date(Occurred_on_Date) ,count(incident_number) as num from incident
group by date(Occurred_on_Date)) a;

-- 18.	 (5 points)
-- Which crimes were never committed during the database’s time period? 
-- The results should contain the crime code and the crime description. 
select crime_code,offense_name from offense 
where crime_code not in(select offense_code from incident);