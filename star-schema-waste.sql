
/* Create star schema with trips as main fact in company process
 and  info about period, station and truck as dimension for this fact*/

CREATE TABLE "DimDate"
(
    dateid integer NOT NULL Primary KEY,
    date DATE,
    Year integer, 
    Quarter integer,
    QuarterName character(50),
    Month integer,
    Monthname character(50),
    Day integer,
    Weekday integer,
    WeekdayName character(50)   
);

CREATE TABLE "DimStation"
(
    stationid integer NOT NULL PRIMARY KEY,
    city varchar(40)
);

CREATE TABLE "DimTruck"
(
    truckid integer NOT NULL PRIMARY KEY,
    trucktype varchar(40) NOT NULL
);

CREATE TABLE "MyFactTrips"
(
    tripid integer NOT NULL PRIMARY KEY,
    dateid integer NOT NULL,
    stationid integer NOT NULL,
    truckid integer NOT NULL,
    wastecollected Decimal,
    FOREIGN KEY(dateid) REFERENCES "DimDate" (dateid),
    FOREIGN KEY(stationid) REFERENCES "DimStation" (stationid),
    FOREIGN KEY(truckid) REFERENCES "DimTruck" (truckid)
);



/* Total total amount of waste collected by station and by trucks */

select stationid, truckid, sum(wastecollected)
from "MyFactTrips"
group by 
grouping sets(stationid, truckid, wastecollected);



/* Total total amount of waste collected by year, by city and by station
 with subtotal by year */
select
	d.year,
	s.city,
	t.stationid,
	sum(wastecollected) as totalwastecollected
FROM "MyFactTrips" t
LEFT JOIN "DimDate" d ON t.dateid = d.dateid
LEFT JOIN "DimStation" s ON  t.stationid = s.stationid
GROUP BY
ROLLUP (year, city, t.stationid)
ORDER BY (year, city, t.stationid)



/* Total total amount of waste collected by year, by city and by station
 with subtotal by year, bycity, by stationid (deeper granularity) */

 select
	d.year,
	s.city,
	t.stationid,
	AVG(wastecollected) as average_wastecollected
FROM "MyFactTrips" t
LEFT JOIN "DimDate" d ON t.dateid = d.dateid
LEFT JOIN "DimStation" s ON  t.stationid = s.stationid
GROUP BY
CUBE (year, city, t.stationid)
ORDER BY (year, city, t.stationid)

/* Store in a view for further query the maximum wasted collected by city,
statioid and truck type */

CREATE MATERIALIZED VIEW max_waste_stats 
(city, stationid, trucktype, max_wastecollected) AS
(select
	s.city,
	t.stationid,
 	k.trucktype,
    MAX(wastecollected) as max_wastecollected
FROM "MyFactTrips" t
LEFT JOIN "DimTruck" k ON t.truckid = k.truckid
LEFT JOIN "DimStation" s ON  t.stationid = s.stationid
GROUP BY city, t.stationid, k.trucktype)


/* Store in a view for further query the maw wasted collected by city,
statioid and truck type */

REFRESH MATERIALIZED VIEW max_waste_stats; -- making sure to populate the MQT max_waste_stats with fresh data --
select * from max_waste_stats; -- query the MQT max_waste_stats --






