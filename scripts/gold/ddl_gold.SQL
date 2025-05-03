/*
==================================================================================
DDL script : Create Gold Views.
=================================================================================
Script Purpose:
  This script creates views for gold layer.
  The gold layer represent the final dimension and fact tables (star schema)

  Each view transform and combine data from the silver layer
  to produce clean, enrich and business ready dataset.

Usage:
  These views can be queried directly for analytics and reporting.

======================================================================================
*/

--====================================================================================
  --Create Dimension: gold.dim_customers
--====================================================================================

    IF OBJECT_ID ('gold.dim_customers', 'V') IS NOT NULL
	    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
	ELSE COALESCE(ca.gen, 'N/A')
END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_cust_loc_a101 la
ON		ci.cst_key = la.cid;

--====================================================================================
  --Create Dimension: gold.dim_product
--====================================================================================

    IF OBJECT_ID ('gold.dim_product', 'V') IS NOT NULL
	    DROP VIEW gold.dim_product;
GO

    IF OBJECT_ID ('gold.dim_product', 'V') IS NOT NULL
	    DROP VIEW gold.dim_product;
GO
CREATE VIEW gold.dim_product AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS catergory,
	pc.subcat AS subcategory,
	pc. maintanence,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date,
	pn.prd_end_dt AS end_date
 FROM silver.crm_prod_info AS pn
 LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id =pc.id
 WHERE pn.prd_end_dt IS NULL; 

--====================================================================================
  --Create Fact: gold.fact_sales
--====================================================================================

    IF OBJECT_ID ('gold.fact_sales', 'V') IS NOT NULL
	    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_detail sd
LEFT JOIN gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;

