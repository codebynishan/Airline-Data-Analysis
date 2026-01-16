use flightdb;

select * from flight_data;
SELECT COUNT(*) FROM flight_data;
set sql_safe_updates=0;

-- . Find all rows where price or duration is NULL.
select  *
from flight_data 
where price or duration is null;

-- . Delete rows where source_city or destination_city is missing.
delete from flight_data
where source_city is null
or destination_city is null;

-- . Identify duplicate flights with the same flight and departure_time.
select flight,departure_time,count(*) as duplicate_count
from flight_data
group by flight,departure_time
having count(*)>1;

-- . Replace negative days_left values with 0.
update flight_data
set days_left=0
where days_left<0;

-- . Standardize class values by converting all text to uppercase.
update flight_data
set class =upper(class);

-- . Create a new column full_route as source_city → destination_city.
alter table flight_data
add column full_route varchar(100);
update flight_data
set full_route=concat(source_city,'-',destination_city);


-- . Convert duration from HH:MM format to total minutes.
update flight_data
set duration=(substring_index(duration,'.',1)*60)+
		     (substring_index(duration,'.',-1)*60);

-- . Find the average price of flights per airline.
select airline,
avg(price) as avg_price
from flight_data
group by airline;

-- .Find the distinct airlines
select distinct airline as airlines
from flight_data;

-- . Count flights departing from each source_city.
select source_city,
count(*) as total_flight
from flight_data
group by source_city;

-- . Find the flight(s) with the longest duration.
select *
from flight_data
where duration = (select max(duration)  from flight_data);

-- . List the top 5 cheapest flights for each destination_city.
select *
from (select *,row_number()
over(partition by destination_city 
order by price asc ) 
as rn
from flight_data)x
where rn<=5;

-- . Calculate the total revenue (price sum) for all flights in Economy class.
select flight,sum(price) as total_revenue
from flight_data
where class='ECONOMY'
group by flight;

-- . Find the airline with the highest total revenue.
select airline,
sum(price) as total_revenue
from flight_data
group by airline
order by total_revenue desc;


-- . Identify flights where price is above the average price for that route.
select flight,
price,
full_route
from (select flight,
price,
full_route,avg(price) over(partition by full_route) as avg_price
from flight_data)f
where price > avg_price;

-- . Find flights with shortest duration but highest price.
select flight,duration,price
from flight_data
where duration=(select min(duration) from flight_data)
and price=(select max(price)
from flight_data
where duration=(select min(duration) from flight_data));

-- . Group by airline and class to get average price and total flights.
select airline,class,
avg(price) as avg_price,count(flight) as total_flight
from flight_data
group by class,airline;


