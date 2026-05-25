-- =============================================================================
-- ANALYTICS: Dynamic tables for the curated/transformation layer
-- =============================================================================

-- ---------------------------------------------------------------------------
-- CURATED CUSTOMER 360: Unified customer profile
-- ---------------------------------------------------------------------------
DEFINE DYNAMIC TABLE {{project_db}}{{env_suffix}}.CURATED.DT_CUSTOMER_360
WAREHOUSE = '{{project_db}}_ANALYTICS_WH{{env_suffix}}'
TARGET_LAG = '{{dt_target_lag}}'
INITIALIZE = 'ON_CREATE'
AS
SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_KEY,
    c.FULL_NAME,
    c.EMAIL,
    c.REGION,
    c.CUSTOMER_SEGMENT,
    c.IS_ACTIVE,
    COUNT(DISTINCT o.ORDER_ID) AS LIFETIME_ORDER_COUNT,
    COALESCE(SUM(o.TOTAL_AMOUNT), 0) AS LIFETIME_REVENUE,
    COALESCE(AVG(o.TOTAL_AMOUNT), 0) AS AVG_ORDER_VALUE,
    MIN(o.ORDER_DATE) AS FIRST_ORDER_DATE,
    MAX(o.ORDER_DATE) AS LAST_ORDER_DATE,
    DATEDIFF('day', MAX(o.ORDER_DATE), CURRENT_DATE()) AS DAYS_SINCE_LAST_ORDER,
    c.CREATED_AT AS CUSTOMER_SINCE,
    c.SOURCE_SYSTEM
FROM {{project_db}}{{env_suffix}}.RAW.CUSTOMERS c
LEFT JOIN {{project_db}}{{env_suffix}}.RAW.ORDERS o
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
    AND o.STATUS != 'CANCELLED'
GROUP BY
    c.CUSTOMER_ID, c.CUSTOMER_KEY, c.FULL_NAME, c.EMAIL,
    c.REGION, c.CUSTOMER_SEGMENT, c.IS_ACTIVE,
    c.CREATED_AT, c.SOURCE_SYSTEM;

-- ---------------------------------------------------------------------------
-- CURATED ORDER ENRICHED: Orders joined with customer and product details
-- ---------------------------------------------------------------------------
DEFINE DYNAMIC TABLE {{project_db}}{{env_suffix}}.CURATED.DT_ORDER_ENRICHED
WAREHOUSE = '{{project_db}}_ANALYTICS_WH{{env_suffix}}'
TARGET_LAG = '{{dt_target_lag}}'
INITIALIZE = 'ON_CREATE'
AS
SELECT
    o.ORDER_ID,
    o.ORDER_KEY,
    o.ORDER_DATE,
    o.ORDER_TIMESTAMP,
    o.STATUS,
    o.CHANNEL,
    o.PAYMENT_METHOD,
    c.CUSTOMER_KEY,
    c.FULL_NAME AS CUSTOMER_NAME,
    c.REGION AS CUSTOMER_REGION,
    c.CUSTOMER_SEGMENT,
    oi.PRODUCT_ID,
    p.PRODUCT_SKU,
    p.PRODUCT_NAME,
    p.CATEGORY AS PRODUCT_CATEGORY,
    p.SUBCATEGORY AS PRODUCT_SUBCATEGORY,
    oi.QUANTITY,
    oi.UNIT_PRICE,
    oi.DISCOUNT_PERCENT,
    oi.LINE_TOTAL,
    o.TOTAL_AMOUNT AS ORDER_TOTAL,
    o.DISCOUNT_AMOUNT AS ORDER_DISCOUNT,
    o.TAX_AMOUNT,
    o.SHIPPING_AMOUNT,
    o.CURRENCY_CODE
FROM {{project_db}}{{env_suffix}}.RAW.ORDERS o
INNER JOIN {{project_db}}{{env_suffix}}.RAW.ORDER_ITEMS oi
    ON o.ORDER_ID = oi.ORDER_ID
INNER JOIN {{project_db}}{{env_suffix}}.RAW.CUSTOMERS c
    ON o.CUSTOMER_ID = c.CUSTOMER_ID
INNER JOIN {{project_db}}{{env_suffix}}.RAW.PRODUCTS p
    ON oi.PRODUCT_ID = p.PRODUCT_ID;

-- ---------------------------------------------------------------------------
-- CURATED DAILY SALES: Aggregated daily sales metrics
-- ---------------------------------------------------------------------------
DEFINE DYNAMIC TABLE {{project_db}}{{env_suffix}}.CURATED.DT_DAILY_SALES
WAREHOUSE = '{{project_db}}_ANALYTICS_WH{{env_suffix}}'
TARGET_LAG = '{{dt_target_lag}}'
INITIALIZE = 'ON_CREATE'
AS
SELECT
    DATE_TRUNC('DAY', o.ORDER_DATE) AS SALE_DATE,
    o.CHANNEL,
    c.REGION AS CUSTOMER_REGION,
    p.CATEGORY AS PRODUCT_CATEGORY,
    COUNT(DISTINCT o.ORDER_ID) AS ORDER_COUNT,
    COUNT(DISTINCT o.CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
    SUM(oi.QUANTITY) AS TOTAL_UNITS_SOLD,
    SUM(oi.LINE_TOTAL) AS GROSS_REVENUE,
    SUM(o.DISCOUNT_AMOUNT) AS TOTAL_DISCOUNTS,
    SUM(o.TAX_AMOUNT) AS TOTAL_TAX,
    SUM(o.TOTAL_AMOUNT) AS NET_REVENUE
FROM {{project_db}}{{env_suffix}}.RAW.ORDERS o
INNER JOIN {{project_db}}{{env_suffix}}.RAW.ORDER_ITEMS oi
    ON o.ORDER_ID = oi.ORDER_ID
INNER JOIN {{project_db}}{{env_suffix}}.RAW.CUSTOMERS c
    ON o.CUSTOMER_ID = c.CUSTOMER_ID
INNER JOIN {{project_db}}{{env_suffix}}.RAW.PRODUCTS p
    ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE o.STATUS != 'CANCELLED'
GROUP BY SALE_DATE, o.CHANNEL, c.REGION, p.CATEGORY;

-- ---------------------------------------------------------------------------
-- CURATED PRODUCT PERFORMANCE: Product-level aggregated metrics
-- ---------------------------------------------------------------------------
DEFINE DYNAMIC TABLE {{project_db}}{{env_suffix}}.CURATED.DT_PRODUCT_PERFORMANCE
WAREHOUSE = '{{project_db}}_ANALYTICS_WH{{env_suffix}}'
TARGET_LAG = 'DOWNSTREAM'
INITIALIZE = 'ON_CREATE'
AS
SELECT
    p.PRODUCT_ID,
    p.PRODUCT_SKU,
    p.PRODUCT_NAME,
    p.CATEGORY,
    p.SUBCATEGORY,
    p.UNIT_PRICE AS CURRENT_PRICE,
    p.COST_PRICE,
    COUNT(DISTINCT oi.ORDER_ID) AS TOTAL_ORDERS,
    SUM(oi.QUANTITY) AS TOTAL_UNITS_SOLD,
    SUM(oi.LINE_TOTAL) AS TOTAL_REVENUE,
    AVG(oi.UNIT_PRICE) AS AVG_SELLING_PRICE,
    AVG(oi.DISCOUNT_PERCENT) AS AVG_DISCOUNT_PERCENT,
    CASE
        WHEN p.COST_PRICE > 0
        THEN ROUND((SUM(oi.LINE_TOTAL) - (SUM(oi.QUANTITY) * p.COST_PRICE)) / NULLIF(SUM(oi.LINE_TOTAL), 0) * 100, 2)
        ELSE NULL
    END AS GROSS_MARGIN_PERCENT,
    p.IS_ACTIVE
FROM {{project_db}}{{env_suffix}}.RAW.PRODUCTS p
LEFT JOIN {{project_db}}{{env_suffix}}.RAW.ORDER_ITEMS oi
    ON p.PRODUCT_ID = oi.PRODUCT_ID
LEFT JOIN {{project_db}}{{env_suffix}}.RAW.ORDERS o
    ON oi.ORDER_ID = o.ORDER_ID
    AND o.STATUS != 'CANCELLED'
GROUP BY
    p.PRODUCT_ID, p.PRODUCT_SKU, p.PRODUCT_NAME,
    p.CATEGORY, p.SUBCATEGORY, p.UNIT_PRICE,
    p.COST_PRICE, p.IS_ACTIVE;
