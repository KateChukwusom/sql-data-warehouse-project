/* 
-------------------------------------------------------------------------------------
Stored Procedure: Load silver layer( BRONZE -> SILVER)
-------------------------------------------------------------------------------------
Script purpose:
	This stored procedure performs the ETL(Extract, Transform, Load) process to populate the 'silver'
	tables from the 'bronze' schema.
	Action Performed:
	- Truncates Silver tables
	- Inserts transformed and cleased data from bronze into silver tables.

	Usage examples: 
		EXEC silver.load_silver

-------------------------------------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME;
		BEGIN TRY
			PRINT '======================================';
			PRINT 'lOADING SILVER LAYER';
			PRINT '======================================';

			PRINT '-------------------';
			PRINT 'LOADING CRM TABLES';
			PRINT '-------------------';

	SET @start_time = GETDATE()
	PRINT '..Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>> Inserting data info into silver.crm_cust_info'
	INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

	SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		ELSE 'n/a'
	END cst_marital_status, -- normalize marital status vlues to readable format

	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END cst_gndr, -- normalize gender values to readable format

	cst_create_date
	FROM (
	SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	) t
		WHERE flag_last =1 --Select the most recent record per customer
	SET @end_time = GETDATE()
	PRINT '.. LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'


	PRINT '------------------------------------------------------------------------------------------'

	SET @start_time = GETDATE()
	PRINT '..Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> Inserting data info into silver.crm_prd_info'
	INSERT INTO silver.crm_prd_info(
		prd_id,
		prd_key,
		cat_id,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt)

		SELECT 
		prd_id,
		prd_key,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,

		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Main Line'
			WHEN 'R' THEN 'Regular'
			WHEN 'S' THEN 'Special Edition'
			WHEN 'T' THEN 'Technology'
			ELSE 'N/A'
		END AS prd_line,
		CAST(prd_start_dt AS DATE ) AS prd_start_dt,
		CAST(DATEADD(DAY, -1,
			   LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
		  ) AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info
	SET @end_time = GETDATE();
	PRINT 'LOAD DURATION:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';



	PRINT'--------------------------------------------------------------------------------------'

	SET @start_time = GETDATE();
	PRINT '..Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT '>> Inserting data info into silver.crm_sales_details'
	INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)

	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0  OR LEN(sls_order_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt, 

	CASE WHEN sls_ship_dt = 0  OR LEN(sls_ship_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,

	CASE WHEN sls_due_dt = 0  OR LEN(sls_due_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS (sls_price)
			 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / sls_quantity
		ELSE sls_price
	END AS sls_price
	FROM bronze.crm_sales_details
	SET @end_time = GETDATE();
	PRINT 'LOAD DURATION:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';

	PRINT '----------------------------------------------------------------------------------'
	PRINT '>>> LOADING ERP SILVER TABLES>>>>>>>'

	SET @start_time = GETDATE()
	PRINT '..Truncating Table: silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;
	PRINT '>> Inserting data info into silver.erp_cust_az12'
	INSERT INTO silver.erp_cust_az12(
	cid, 
	bdate,
	gen
	)

	SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
		ELSE cid
	END AS cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE CAST(bdate AS DATE)
	  END AS valid_bdate,

	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'N/A'
	END AS gen
	FROM 
	bronze.erp_cust_az12
	SET @end_time = GETDATE();
	PRINT 'LOAD DURATION:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';

	PRINT '---------------------------------------------------------------------------------------------------'

	SET @start_time = GETDATE();
	PRINT '..Truncating Table: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	PRINT '>> Inserting data info into silver.erp_loc_a101'
	INSERT INTO silver.erp_loc_a101(
	cid,
	cntry
	)

	SELECT 
	REPLACE(cid, '-', '') AS cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
		 WHEN TRIM(cntry) = ' ' OR cntry IS NULL THEN 'N/A'
		 ELSE TRIM(cntry)
	END AS cntry
	FROM bronze.erp_loc_a101;
	SET @end_time = GETDATE();
	PRINT 'LOAD DURATION:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';

	PRINT '-------------------------------------------------------------------------------'

	SET @start_time = GETDATE()
	PRINT '..Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	PRINT '>> Inserting data info into silver.erp_px_cat_g1v2'
	INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance)

	SELECT 
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_px_cat_g1v2
	SET @end_time = GETDATE();
	PRINT 'LOAD DURATION:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
	END TRY
BEGIN CATCH
    PRINT '*** ERROR OCCURRED ***';
    PRINT ERROR_MESSAGE();
END CATCH;
	
END
