/* 
=========================================================================
DDL Script: Create gold views
==========================================================================

Script Purpose:
	This script creates views for the gold layer in the data warehouse
	This gold represents the final dimension and fact tables (star schema)

	Each view performs transformations and comnines data from the silver layer
	to produce a clean, enriched and business-ready dataset.

	Created for analytics and reporting */

----------------------------------------------------------------------------------
-- CREATE dimension: gold.dim_customers
---------------------------------------------------------------------------------

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cp.cntry AS country,
	ci.cst_marital_status AS  marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
	ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
    ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 cp
ON ci.cst_key = cp.cid

GO


-------------------------------------------------------------------------------
-- CREATE dimension: gold.dim_product1
-------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_product1', 'V') IS NOT NULL
	DROP VIEW gold.dim_product1;
GO
CREATE VIEW gold.dim_product1 AS

SELECT
	ROW_NUMBER() OVER (ORDER BY pd.prd_start_dt, pd.product_key1) AS product_key,
	pd.prd_id AS product_id,
	pd.prd_key AS product_number,
	pd.product_key1 AS product_key17,
	pd.prd_nm AS product_name,
	pd.cat_id AS category_id,
	px.cat AS category,
	px.subcat AS subcategory,
	px.maintenance,
	pd.prd_cost AS cost,
	pd.prd_line AS product_line,
	pd.prd_start_dt AS start_date
FROM silver.crm_prd_info pd
	LEFT JOIN silver.erp_px_cat_g1v2 px
ON pd.cat_id = px.id
WHERE pd.prd_end_dt IS NULL
 GO 

 IF OBJECT_ID('gold.fact_sales1', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales1;
GO

-----------------------------------------------------------------------------------------------------
-- CREATE fact: gold.fact_sales1
------------------------------------------------------------------------------------------------------

CREATE VIEW gold.fact_sales1 AS

SELECT
	sd.sls_ord_num AS order_number,
	po.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_product1 po
ON sd.sls_prd_key = po.product_key17
	LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

GO
