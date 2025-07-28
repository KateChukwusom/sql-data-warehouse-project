-- checking for silver.crm_prd_info
-- check for nulls or duplicates n primary key
-- expectation: no results-- data standardization and consistency


prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

--check for nulls or negative numbers
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL

-- check for low cardinality and standardization
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- check for invalid date orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt
  
  
  -- checking for silver.crm_cust_info
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1

-- data standardization and consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

-- data standardization and consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info


-- CHECK FOR UNWANTED SPACES
-- EXPECTATION : NO RESULTS
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT * FROM silver.crm_cust_info
