/* 
---------------------------------------------------------------------------------------------------------------
Stored procedure: load bronze layer (source => bronze)

--------------------------------------------------------------------------------------------------------------

Script Purpose:
This stored procedure loads data into the bronze schema from external csv files, it performs the following actions;
- Truncates the bronze tables before loading the data
- Uses the 'BULK INSERT' command to load data from csv files to bronze tables

Parameters:
   None.
   This stored procedure does not accept any parameters or return any values

   Usage example:
   EXEC bronze.load_bronze;

------------------------------------------------------------------------------------------------------------------
*/



	CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
	BEGIN
		DECLARE @start_time DATETIME, @end_time DATETIME;
		BEGIN TRY
			PRINT '======================================';
			PRINT 'lOADING BRONZE LAYER';
			PRINT '======================================';

			PRINT '-------------------';
			PRINT 'LOADING CRM TABLES';
			PRINT '-------------------';

			SET @start_time = GETDATE();
			TRUNCATE TABLE bronze.crm_cust_info; -- this is used to delete all the rows in the table
			BULK INSERT bronze.crm_cust_info
			FROM 'C:\Users\Admin\Downloads\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 

			);
			SET @end_time = GETDATE();
			PRINT '.. LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'

			SET @start_time = GETDATE();
			TRUNCATE TABLE bronze.crm_prd_info;
			 BULK INSERT bronze.crm_prd_info
			FROM 'C:\Users\Admin\Downloads\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 

			);
			SET @end_time = GETDATE();
			PRINT '.. LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'


			SET @start_time = GETDATE();
			TRUNCATE TABLE bronze.crm_sales_details;
			BULK INSERT bronze.crm_sales_details
			FROM 'C:\Users\Admin\Downloads\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 

			);
			SET @end_time = GETDATE()
			PRINT '... LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'

			PRINT '-------------------';
			PRINT 'LOADING ERP TABLES';
			PRINT '-------------------';

			SET @start_time = GETDATE()
			TRUNCATE TABLE bronze.erp_cust_az12;
			BULK INSERT bronze.erp_cust_az12
			FROM 'C:\Users\Admin\Downloads\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 

			);
			SET @end_time = GETDATE()
			PRINT '... LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'


			SET @start_time = GETDATE()
			TRUNCATE TABLE bronze.erp_loc_a101;
			BULK INSERT bronze.erp_loc_a101
			FROM 'C:\Users\Admin\Downloads\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 

			);
			SET @end_time = GETDATE()
			PRINT '... LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'


			SET @start_time = GETDATE()
			TRUNCATE TABLE bronze.erp_px_cat_g1v2;
			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'C:\Users\Admin\Downloads\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK 

			);
			SET @end_time = GETDATE()
			PRINT '... LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '...........................'


		END TRY
		BEGIN CATCH
			PRINT '.................'
			PRINT 'ERROR OCCURED DURING LOADING THE BRONZE LAYER'
			PRINT '.................................' 
		END CATCH
	END 
