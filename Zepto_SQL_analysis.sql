-- ============================================
-- ZEPTO SQL DATA ANALYSIS PROJECT
-- ============================================

-- =========================
-- DATABASE SETUP
-- =========================

CREATE DATABASE IF NOT EXISTS zepto_project;
USE zepto_project;

-- =========================
-- TABLE CREATION
-- =========================

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);

-- =========================
-- DATA EXPLORATION
-- =========================

-- Total number of records
SELECT COUNT(*) AS total_records FROM zepto;

-- Sample data preview
SELECT * FROM zepto LIMIT 10;

-- Check NULL values
SELECT * FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- Unique product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- Stock availability analysis
SELECT outOfStock, COUNT(*) AS product_count
FROM zepto
GROUP BY outOfStock;

-- Duplicate product names
SELECT name, COUNT(*) AS Number_of_SKUs
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY Number_of_SKUs DESC;

-- =========================
-- DATA CLEANING
-- =========================

-- Identify invalid price records
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Remove invalid records
DELETE FROM zepto
WHERE mrp = 0;

-- Convert paise to rupees
UPDATE zepto
SET 
    mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100;

-- Verify conversion
SELECT mrp, discountedSellingPrice FROM zepto;

-- =========================
-- DATA ANALYSIS
-- =========================

-- Q1. Top 10 products with highest discount
SELECT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2. High MRP products that are out of stock
SELECT name, mrp
FROM zepto
WHERE outOfStock = 1
  AND mrp > 300
ORDER BY mrp DESC;

-- Q3. Estimated revenue by category
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4. High MRP (>500) with low discount (<10%)
SELECT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Top 5 categories with highest average discount
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Best value products (price per gram)
SELECT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC;

-- Q7. Product segmentation by weight
SELECT name, weightInGms,
       CASE 
           WHEN weightInGms < 1000 THEN 'Low'
           WHEN weightInGms < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS weight_category
FROM zepto;

-- Q8. Total inventory weight per category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;
