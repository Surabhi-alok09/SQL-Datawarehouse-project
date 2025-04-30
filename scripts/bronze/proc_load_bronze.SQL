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

CREATE PROCEDURE bronze.load_bronze as
BEGIN
	PRINT '==========================';
	PRINT 'LOADING BRONZE LAYER';
	PRINT '==========================';

	PRINT '--------------------------';
	PRINT 'LOADING CRM TABLES';
	PRINT '--------------------------';

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

	PRINT '>> Truncating table: bronze.crm_prod_info';

	TRUNCATE TABLE bronze.crm_prod_info;

	PRINT '>> Inserting data into : bronze.crm_prod_info';

	BULK INSERT bronze.crm_prod_info
	FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	PRINT '>> Truncating table: bronze.crm_sales_detail';

	TRUNCATE TABLE bronze.crm_sales_detail;

	PRINT '>> Inserting data into : bronze.crm_sales_detail';

	BULK INSERT bronze.crm_sales_detail
	FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	PRINT '--------------------------';
	PRINT 'LOADING ERP TABLES';
	PRINT '--------------------------';

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

	PRINT '>> Truncating table: bronze.erp_cust_loc_a101';

	TRUNCATE TABLE bronze.erp_cust_loc_a101;

	PRINT '>> Inserting data into : bronze.erp_cust_loc_a101';

	BULK INSERT bronze.erp_cust_loc_a101
	FROM 'C:\Users\alokz\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	WITH(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

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
END
