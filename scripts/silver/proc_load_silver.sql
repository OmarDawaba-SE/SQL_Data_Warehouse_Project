CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	-- ==================================================================================================================
	-- cleaning and inserting into silver.crm_cust_info
	-- ==================================================================================================================

	TRUNCATE TABLE silver.crm_cust_info
	INSERT INTO silver.crm_cust_info (cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
	SELECT
		cst_id
		,cst_key
		,cst_firstname
		,cst_lastname
		,cst_marital_status
		,cst_gndr
		,cst_create_date
	FROM(
		SELECT
			cst_id
			,cst_key
			,TRIM(cst_firstname) AS cst_firstname
			,TRIM(cst_lastname) AS cst_lastname
			,CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'Unknown'
			END cst_marital_status
			,CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'Unknown'
			END cst_gndr
			,cst_create_date
			,ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) Flaf_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL)t
	WHERE Flaf_last = 1;

	-- ==================================================================================================================
	-- cleaning and inserting into silver.crm_prd_info
	-- ==================================================================================================================

	TRUNCATE TABLE silver.crm_prd_info
	INSERT INTO silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
	SELECT 
		prd_id
		,REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id
		,SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key
		,prd_nm
		,ISNULL(prd_cost,0) AS prd_cost
		,CASE UPPER(TRIM(prd_line))
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			WHEN 'M' THEN 'Mountain'
			ELSE 'Unknown'
		END prd_cost
		,CAST(prd_start_dt AS DATE) AS prd_start_dt
		,CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
	FROM bronze.crm_prd_info;

	-- ==================================================================================================================
	-- cleaning and inserting into silver.crm_sales_details
	-- ==================================================================================================================

	TRUNCATE TABLE silver.crm_sales_details
	INSERT INTO silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
		SELECT 
			sls_ord_num
			,sls_prd_key
			,sls_cust_id
			,CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			END AS sls_order_dt 
			,CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) AS sls_ship_dt
			,CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) AS sls_due_dt
			,CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
			END AS sls_sales
			,sls_quantity
			,CASE WHEN sls_price IS NULL OR sls_price <= 0 
			THEN sls_sales / NULLIF(sls_price,0)
			ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;

	-- ==================================================================================================================
	-- cleaning and inserting into silver.erp_cust_az12
	-- ==================================================================================================================

	TRUNCATE TABLE silver.erp_cust_az12
	INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
		SELECT 
			CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
			ELSE CID END AS cid
			,CASE WHEN BDATE > GETDATE() THEN NULL
			ELSE BDATE END AS bdate
			,CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'MALE'
			ELSE NULL END AS gen
		FROM bronze.erp_cust_az12;

	-- ==================================================================================================================
	-- cleaning and inserting into silver.erp_loc_a101
	-- ==================================================================================================================

	TRUNCATE TABLE silver.erp_loc_a101
	INSERT INTO silver.erp_loc_a101 (cid,cntry)
		SELECT 
			REPLACE(CID,'-','') cid
			,CASE WHEN CNTRY = '' THEN NULL
			WHEN UPPER(TRIM(CNTRY)) IN ('US','USA','UNITED STATES') THEN 'United States'
			WHEN UPPER(TRIM(CNTRY)) IN ('DE','GERMANY') THEN 'Germany'
			ELSE TRIM(CNTRY) END AS cntry
		FROM bronze.erp_loc_a101;

	-- ==================================================================================================================
	-- cleaning and inserting into silver.erp_px_cat_g1v2
	-- ==================================================================================================================

	TRUNCATE TABLE silver.erp_px_cat_g1v2
	INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
		SELECT 
			ID
			,CAT
			,SUBCAT
			,MAINTENANCE
		FROM bronze.erp_px_cat_g1v2;
END

EXEC silver.load_silver
