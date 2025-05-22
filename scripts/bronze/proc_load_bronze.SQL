/*
===========================================================================================
Stored Procedure : Load Bronze Layer (source -> Bronze)
============================================================================================
Script Purpose:
  This Stored Procedure Loads data into 'bronze' schema feom external CVS files.
  It performs:
  - Truncates the existing bronze table before loading data.
  - Use the 'BULK INSERT' command to load data.

  Usage Ex:
     EXEC bronze.load_bronze;
=====================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		PRINT '==========================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '==========================';

		PRINT '--------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '--------------------------';

		SET @batch_start_time= GETDATE();
		SET @start_time= GETDATE();
		PRINT '>> Truncating table: bronze.crm_cust_info';

		TRUNCATE TABLE bronze.crm_cust_info;

	
		PRINT '>> Inserting data into : bronze.crm_cust_info';

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time= GETDATE();
		PRINT '>> Load Duration : ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>-------------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating table: bronze.crm_prd_info';

		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting data into : bronze.crm_prd_info';

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '>>-------------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting data into : bronze.crm_sales_details';

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '>>-------------------------------'

		PRINT '--------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '--------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table: bronze.erp_cust_az12';

		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting data into : bronze.erp_cust_az12';

		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '>>-------------------------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating table: bronze.erp_loc_a101';

		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting data into : bronze.erp_loc_a101';

		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '>>-------------------------------'

		SET @start_time = GETDATE();

		PRINT '>> Truncating table: bronze.erp_px_cat_g1v2';

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting data into : bronze.erp_px_cat_g1v2';

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : ' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' second';
		PRINT '>>-------------------------------'
		SET @batch_end_time= GETDATE();
		PRINT '>> Batch Duration : ' + CAST (DATEDIFF (second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' second';
		PRINT '>>-------------------------------'

	END TRY
	BEGIN CATCH
		PRINT '====================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT '====================================================='
	END CATCH
END
