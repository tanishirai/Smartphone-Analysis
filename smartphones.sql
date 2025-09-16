-- Price & Ratings
-- 1. What is the average price of smartphones by processor brand?
select * from smartphones_cleaned_dataset;
SELECT 
    brand_name, AVG(price)
FROM
    smartphones_cleaned_dataset
GROUP BY brand_name , processor_brand;

-- 2. Which brands offer smartphones under ₹15,000 with 5G support?
SELECT 
    brand_name, price, has_5g
FROM
    smartphones_cleaned_dataset
WHERE
    price < 15000 AND has_5g = 'True';

-- 3. Which smartphones have the top 10 highest user ratings?
SELECT 
    model, rating
FROM
    smartphones_cleaned_dataset
ORDER BY rating DESC
LIMIT 10;

-- 4. How does average price vary by RAM size (e.g., 4GB, 6GB, 8GB)?
SELECT 
    ram_capacity, AVG(price)
FROM
    smartphones_cleaned_dataset
GROUP BY ram_capacity
ORDER BY ram_capacity;

-- 5. What is the average user rating per screen refresh rate (e.g., 60Hz, 90Hz, 120Hz)?
SELECT 
    refresh_rate, AVG(rating)
FROM
    smartphones_cleaned_dataset
GROUP BY refresh_rate;



-- 6. Get min, max, and average price grouped by internal storage.
SELECT 
    internal_memory, 
    MIN(price), MAX(price), AVG(price)
FROM
    smartphones_cleaned_dataset
GROUP BY internal_memory;


-- Feature-Specific Analysis
-- 7. How many smartphones support 5G, NFC, and IR Blaster separately or together?
SELECT
    -- Individual Features
    SUM(has_5g = "True") "5G_phones",
    SUM(has_nfc = "True") "NFC_phones",
    SUM(has_ir_blaster = "True") "IR_Blaster_phones",

    -- Pairwise Combinations
    SUM(has_5g = "True" AND has_nfc = "True")  "5G+NFC_phones",
    SUM(has_5g = "True" AND has_ir_blaster = "True") "5G+IR_phones",
    SUM(has_nfc = "True" AND has_ir_blaster = "True") "NFC+IR_phones",

    -- All Three Together
    SUM(has_5g = "True" AND has_nfc = "True" AND has_ir_blaster = "True") "5G+NFC+IR_phones"
FROM smartphones_cleaned_dataset;

-- 8. List smartphones that support both 5G and fast charging.
SELECT 
    model, has_5g, fast_charging_available
FROM
    smartphones_cleaned_dataset
WHERE
    has_5g = 'True'
        AND fast_charging_available = 1;

-- 9. What is the distribution of processor core count across smartphone models?
SELECT 
    processor_brand, num_cores, COUNT(model) 'number_of_phones'
FROM
    smartphones_cleaned_dataset
GROUP BY num_cores , processor_brand;

-- 10. What is the most common processor brand in phones priced below ₹20,000?
SELECT 
    processor_brand, COUNT(brand_name) AS number_of_phones
FROM
    smartphones_cleaned_dataset
WHERE
    price < 20000
GROUP BY processor_brand
ORDER BY number_of_phones DESC
LIMIT 5;


-- Battery, Charging, and Performance
-- 11. Which smartphones have the highest battery capacity in each price segment (e.g., < ₹10k, 10k-20k, >₹20k)?
WITH ranked_phones AS (
  SELECT 
    model,
    battery_capacity,
    price,
    CASE
      WHEN price < 10000 THEN 'Budget (< ₹10K)'
      WHEN price BETWEEN 10000 AND 20000 THEN 'Mid-Range (₹10K-20K)'
      ELSE 'Premium (> ₹20K)'
    END AS price_segment,
    RANK() OVER (
      PARTITION BY 
        CASE
          WHEN price < 10000 THEN 'Budget (< ₹10K)'
          WHEN price BETWEEN 10000 AND 20000 THEN 'Mid-Range (₹10K-20K)'
          ELSE 'Premium (> ₹20K)'
        END 
      ORDER BY battery_capacity DESC, price ASC  -- Tie-breaker: cheaper first
    ) AS battery_rank
  FROM smartphones_cleaned_dataset
)
SELECT * FROM ranked_phones WHERE battery_rank = 1;


-- 12. Average battery capacity grouped by processor brand or number of processor cores.
SELECT 
    processor_brand,num_cores,
    ROUND(AVG(battery_capacity), 0) AS avg_battery_capacity_mAh,
    COUNT(*) AS number_of_phones
FROM smartphones_cleaned_dataset
GROUP BY processor_brand, num_cores
ORDER BY avg_battery_capacity_mAh DESC;

-- 13. List smartphones with both fast charging and more than 5000mAh battery capacity.
SELECT 
    model, fast_charging_available, battery_capacity
FROM
    smartphones_cleaned_dataset
WHERE
    battery_capacity > 5000
        AND fast_charging_available = 1
ORDER BY battery_capacity DESC;


-- Camera Analysis
-- 14. Which front cameras offer more than 32MP resolution under ₹25,000?
SELECT 
  model,
  price,
  primary_camera_front
FROM smartphones_cleaned_dataset
WHERE price < 25000
AND primary_camera_front > 32;


-- 15. Average rear camera megapixels by price segments (low, mid, flagship).
SELECT 
    CASE
        WHEN price < 10000 THEN 'Budget (< ₹10K)'
        WHEN price BETWEEN 10000 AND 20000 THEN 'Mid-Range (₹10K-20K)'
        ELSE 'Premium (> ₹20K)'
    END AS price_segment,
    AVG(primary_camera_rear) AS avg_rear_camera_megapixels
FROM
    smartphones_cleaned_dataset
GROUP BY CASE
    WHEN price < 10000 THEN 'Budget (< ₹10K)'
    WHEN price BETWEEN 10000 AND 20000 THEN 'Mid-Range (₹10K-20K)'
    ELSE 'Premium (> ₹20K)'
END;

-- 16. What is the maximum rear camera megapixel offered by each brand?
SELECT 
    brand_name,
    MAX(primary_camera_rear) AS max_rear_camera_megapixels
FROM
    smartphones_cleaned_dataset
GROUP BY brand_name;

-- 17. List all phones where front and rear camera specs are above average.
WITH AvgCameras AS (
  SELECT 
    AVG(primary_camera_front) AS avg_front_mp,
    AVG(primary_camera_rear) AS avg_rear_mp
  FROM smartphones_cleaned_dataset
)

SELECT
  brand_name,
  model,
  primary_camera_front,
  primary_camera_rear
FROM smartphones_cleaned_dataset, AvgCameras
WHERE 
  primary_camera_front > AvgCameras.avg_front_mp
  AND primary_camera_rear > AvgCameras.avg_rear_mp;


-- Display Trends
-- 18. Distribution of screen sizes in phones launched with 5G
SELECT 
    screen_size, COUNT(*) AS phone_count
FROM
    smartphones_cleaned_dataset
WHERE
    has_5g = 'True'
GROUP BY screen_size
ORDER BY screen_size;

-- 19. Which phones support 120Hz refresh rates, and what’s their average price?
SELECT 
  model,
  price
FROM smartphones_cleaned_dataset
WHERE refresh_rate = 120;

SELECT 
    AVG(price) AS avg_price_120Hz
FROM
    smartphones_cleaned_dataset
WHERE
    refresh_rate = 120;

-- 20. Most popular screen resolution for phones under ₹15,000
SELECT 
    CONCAT(resolution_width, 'x', resolution_height) AS screen_resolution,
    COUNT(*) AS count_resolution
FROM
    smartphones_cleaned_dataset
WHERE
    price < 15000
GROUP BY resolution_width , resolution_height
ORDER BY count_resolution DESC;


