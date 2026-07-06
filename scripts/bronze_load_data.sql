--loading data from csv into tables 
--NOTE: replace YourDataPath in FROM caluse with your csv path
BULK INSERT bronze.crm_cust_info
FROM 'YourDataPath\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH(
	FIRSTROW = 2 --cause first row is header
	,FIELDTERMINATOR = ',' --the seperator between data in rows
	,TABLOCK --so it locks the csv file while loading data
);

BULK INSERT bronze.crm_prd_info
FROM 'YourDataPath\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH(
	FIRSTROW = 2 --cause first row is header
	,FIELDTERMINATOR = ',' --the seperator between data in rows
	,TABLOCK --so it locks the csv file while loading data
);

BULK INSERT bronze.crm_sales_details
FROM 'YourDataPath\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH(
	FIRSTROW = 2 --cause first row is header
	,FIELDTERMINATOR = ',' --the seperator between data in rows
	,TABLOCK --so it locks the csv file while loading data
);

BULK INSERT bronze.erp_cust_az12
FROM 'YourDataPath\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH(
	FIRSTROW = 2 --cause first row is header
	,FIELDTERMINATOR = ',' --the seperator between data in rows
	,TABLOCK --so it locks the csv file while loading data
);

BULK INSERT bronze.erp_loc_a101
FROM 'YourDataPath\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
WITH(
	FIRSTROW = 2 --cause first row is header
	,FIELDTERMINATOR = ',' --the seperator between data in rows
	,TABLOCK --so it locks the csv file while loading data
);

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'YourDataPath\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH(
	FIRSTROW = 2 --cause first row is header
	,FIELDTERMINATOR = ',' --the seperator between data in rows
	,TABLOCK --so it locks the csv file while loading data
);

--Check the quality of inserted data

SELECT TOP(10) * FROM bronze.crm_cust_info;

SELECT TOP(10) * FROM bronze.crm_prd_info;

SELECT TOP(10) * FROM bronze.crm_sales_details;

SELECT TOP(10) * FROM bronze.erp_cust_az12;

SELECT TOP(10) * FROM bronze.erp_loc_a101;

SELECT TOP(10) * FROM bronze.erp_px_cat_g1v2;
