/*
============================================================================================
Stored Procedure: Load silver layer (bronze -> Silver)
==============================================================================================
Script Purpose:
	This Stored Procedure performs the ETL (Extract, Transform, load) process to populate
	tables in Silver Schema from Bronze Schema.
Action Performed:
	-Truncate Silver Table.
	-Insert transformed and Cleansed data from Bronze to Silver Schema

Parameters:
	None

Usage Example:
 EXEC silver.load_silver;
==============================================================================================
*/

CREATE PROCEDURE silver.load_silver AS
BEGIN
	PRINT '====================================================';
	PRINT 'Loading CRM Tables';
	PRINT '====================================================';

	PRINT '>> Truncating Table silver.crm_cust_info';
	TRUNCATE TABLE  silver.crm_cust_info;
	PRINT '>> Inserting data into silver.crm_cust_info';

	INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM (cst_marital_status)) = 'S' THEN 'SINGLE'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
			ELSE 'N/A'
		END cst_marital_status,
		CASE WHEN UPPER(TRIM (cst_gndr)) = 'F' THEN 'FEMALE'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
			ELSE 'N/A'
		END cst_gndr,
		cst_create_date
	FROM
	(SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date desc) as flag
	FROM bronze.crm_cust_info) t
	WHERE flag =1;

	PRINT '>> Truncating Table silver.crm_prod_info';
	TRUNCATE TABLE  silver.crm_prod_info;
	PRINT '>> Inserting data into silver.crm_prod_info';

	INSERT INTO silver.crm_prod_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5), '-', '_') AS cat_id,
		SUBSTRING (prd_key,7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL (prd_cost,0) AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'N/A'
	END AS prd_line,
		prd_start_dt,
		DATEADD(DAY,-1,LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_date
	FROM bronze.crm_prod_info;


	PRINT '>> Truncating Table silver.crm_sales_detail';
	TRUNCATE TABLE  silver.crm_sales_detail;
	PRINT '>> Inserting data into silver.crm_sales_detail';

	INSERT INTO silver.crm_sales_detail(
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
		CASE WHEN sls_order_dt<=0 or len(sls_order_dt)!=8  THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt<=0 or len(sls_ship_dt)!=8  THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt<=0 or len(sls_due_dt)!=8  THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales <=0 OR sls_sales IS NULL OR sls_sales != sls_quantity *ABS(sls_price) 
			THEN sls_quantity *ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price<=0 
			THEN sls_sales / NULLIF(sls_quantity,0)
			ELSE sls_price
	END AS sls_price
	from bronze.crm_sales_detail;

	PRINT '====================================================';
	PRINT 'Loading ERP Tables';
	PRINT '====================================================';

	PRINT '>> Truncating table silver.erp_cust_az12';
	TRUNCATE TABLE  silver.erp_cust_az12;
	PRINT '>> Inserting data into silver.erp_cust_az12';

	INSERT INTO silver.erp_cust_az12(
		cid,
		bdate,
		gen
	)
	SELECT
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING (cid,4, LEN(cid))
			ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen)) ='F' THEN 'Female'
			 WHEN UPPER(TRIM(gen)) ='M' THEN 'Male'
			 ELSE 'N/A'
		END AS gen
	FROM bronze.erp_cust_az12;

	PRINT '>> Truncating Table silver.erp_cust_loc_a101';
	TRUNCATE TABLE  silver.erp_cust_loc_a101;
	PRINT '>> Inserting data into silver.erp_cust_loc_a101';

	INSERT INTO silver.erp_cust_loc_a101(
		cid,
		cntry
	)
	SELECT
		REPLACE (cid, '-','') cid,
		CASE WHEN TRIM(ccntry) = 'DE' THEN 'Germany'
			WHEN TRIM(ccntry)IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(ccntry) IS NULL OR TRIM(ccntry)= '' THEN 'N/A'
			ELSE TRIM (ccntry)
		END AS cntry
	FROM bronze.erp_cust_loc_a101;

	PRINT '>> Truncating Table silver.erp_px_cat_g1v2';
	TRUNCATE TABLE  silver.erp_px_cat_g1v2;
	PRINT '>> Inserting data into silver.erp_px_cat_g1v2';

	INSERT INTO silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintanence
	)
	SELECT 
		id,
		cat,
		subcat, 
		maintanence
	FROM bronze.erp_px_cat_g1v2;
END;
