-- ==================================================================================================================
-- Creating Customer dimension For Gold Layer
-- ==================================================================================================================

CREATE VIEW gold.dm_customers AS
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS Customer_key
        ,ci.cst_id AS customer_id
        ,ci.cst_key AS customer_number
        ,ci.cst_firstname AS customer_firstname
        ,ci.cst_lastname AS cusomer_lastname
        ,cl.CNTRY AS customer_country
        ,ci.cst_marital_status AS customer_marital_status
        ,CASE WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr
            WHEN ca.gen != 'Unknown' THEN COALESCE(ca.gen,'n/a')
            ELSE 'n/a' END AS gender
        ,ca.bdate AS customer_birthdate
        ,ci.cst_create_date AS customer_creation_date
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 cl
    ON ci.cst_key = cl.cid;

-- ==================================================================================================================
-- Creating Product dimension For Gold Layer
-- ==================================================================================================================

CREATE VIEW gold.dm_products AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY pri.prd_start_dt,pri.prd_key) AS product_key
        ,pri.prd_id AS product_id
        ,pri.prd_key AS product_number
        ,pri.prd_nm AS product_name
        ,pri.cat_id AS category_id
        ,pc.CAT AS category
        ,pc.SUBCAT AS subcategory
        ,pc.MAINTENANCE AS maintenance
        ,pri.prd_cost AS product_cost
        ,pri.prd_line AS product_line
        ,pri.prd_start_dt AS product_start_date
    FROM silver.crm_prd_info pri
    LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pri.cat_id = pc.id
    WHERE pri.prd_end_dt IS NULL; --filtering to get current data only

-- ==================================================================================================================
-- Creating Sales dimension For Gold Layer
-- ==================================================================================================================

CREATE VIEW gold.fact_sales AS
    SELECT 
        csd.sls_ord_num AS order_number
        ,gdp.product_key
        ,gdc.Customer_key
        ,csd.sls_order_dt AS order_date
        ,csd.sls_ship_dt AS ship_date
        ,csd.sls_due_dt AS due_date
        ,csd.sls_sales AS sales_amount
        ,csd.sls_quantity AS quantity
        ,csd.sls_price AS price
    FROM silver.crm_sales_details csd
    LEFT JOIN gold.dm_customers gdc
    ON csd.sls_cust_id = gdc.customer_id
    LEFT JOIN gold.dm_products gdp
    ON csd.sls_prd_key = gdp.product_number
