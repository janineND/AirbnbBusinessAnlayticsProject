# price difference in different areas in NYC
SELECT neighbourhood_group, AVG(price) AS avg_price, MIN(price) as min_price, MAX(price) AS max_price
FROM NYCAirBNB
WHERE availability_365 > 0
AND minimum_nights > 0
AND number_of_reviews > 0
AND number_of_reviews*minimum_nights < 365
GROUP BY neighbourhood_group;


SELECT neighbourhood_group, room_type, AVG(price) AS avg_price, MIN(price) as min_price, MAX(price) AS max_price
FROM NYCAirBNB
WHERE availability_365 > 0
AND minimum_nights > 0
AND number_of_reviews > 0
AND number_of_reviews*minimum_nights < 365
GROUP BY neighbourhood_group, room_type
ORDER BY neighbourhood_group, room_type;

# does room type affect the listing price
SELECT room_type, AVG(price) AS avg_price, MIN(price) as min_price, MAX(price) AS max_price
FROM NYCAirBNB
WHERE availability_365 > 0
AND minimum_nights > 0
AND number_of_reviews > 0
GROUP BY room_type;

# how's the room reservation situation in different area?

-- SELECT neighbourhood_group, AVG(number_of_reviews*minimum_nights) AS avg_reservation_per_listing, 
-- 	    MIN(number_of_reviews*minimum_nights) as min_reservation_per_listing, 
--         MAX(number_of_reviews*minimum_nights) AS max_reservation_per_listing
-- FROM NYCAirBNB
-- GROUP BY neighbourhood_group;

SELECT neighbourhood_group, AVG(number_of_reviews*minimum_nights) AS avg_reservation_per_listing, 
	    MIN(number_of_reviews*minimum_nights) as min_reservation_per_listing, 
        MAX(number_of_reviews*minimum_nights) AS max_reservation_per_listing
FROM NYCAirBNB
WHERE availability_365 > 0
AND minimum_nights > 0
AND number_of_reviews > 0
GROUP BY neighbourhood_group;

# how's renter's income by area?
SELECT neighbourhood_group, AVG(number_of_reviews*minimum_nights*price) AS avg_income_per_listing, 
	    MIN(number_of_reviews*minimum_nights*minimum_nights*price) as min_income_per_listing, 
        MAX(number_of_reviews*minimum_nights*minimum_nights*price) AS max_income_per_listing
FROM NYCAirBNB
WHERE availability_365 > 0
AND minimum_nights > 0
AND number_of_reviews > 0
GROUP BY neighbourhood_group;

# which area have more potential in the next year?
DROP VIEW IF EXISTS neighbourhood_growth;
CREATE VIEW neighbourhood_growth AS
(SELECT A.neighbourhood_group, 
	   COUNT(airbnbid) AS total_airbnb,
       COUNT(DISTINCT host_id) AS total_hosts,
       COUNT(airbnbid)/COUNT(DISTINCT host_id) AS airbnb_per_host,
	   AVG(number_of_reviews*minimum_nights) AS avg_reservation_per_listing, 
	   MIN(number_of_reviews*minimum_nights) as min_reservation_per_listing, 
       MAX(number_of_reviews*minimum_nights) AS max_reservation_per_listing,
	   AVG(number_of_reviews*minimum_nights*price) AS avg_income_per_listing,
	   MAX(number_of_reviews*minimum_nights*price) AS max_income_per_listing,
       MIN(number_of_reviews*minimum_nights*price) AS min_income_per_listing,
       (Y2020-Y2010)/CAST(Y2010 AS REAL)/10 AS annual_increased_rate
FROM NYCAirBNB A left join NYCPopulation B
ON A.neighbourhood_group = B.Neighbourhood
WHERE availability_365 > 0
AND minimum_nights > 0
AND number_of_reviews > 0
GROUP BY A.neighbourhood_group);

SELECT * FROM neighbourhood_growth;

# estimate the income potential
SELECT neighbourhood_group, 
		annual_increased_rate*airbnb_per_host*avg_income_per_listing AS avg_increased_annual_income
FROM neighbourhood_growth;