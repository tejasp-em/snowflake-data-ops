-- =============================================================================
-- SERVE: Consumption views for BI tools, dashboards, and downstream consumers
-- =============================================================================

-- ---------------------------------------------------------------------------
-- REVENUE DASHBOARD: Daily revenue metrics for executive dashboards
-- ---------------------------------------------------------------------------
DEFINE VIEW {{project_db}}{{env_suffix}}.SERVE.V_REVENUE_DASHBOARD
AS
SELECT
    SALE_DATE,
    CHANNEL,
    CUSTOMER_REGION,
    PRODUCT_CATEGORY,
    ORDER_COUNT,
    UNIQUE_CUSTOMERS,
    TOTAL_UNITS_SOLD,
    GROSS_REVENUE,
    TOTAL_DISCOUNTS,
    NET_REVENUE,
    ROUND(NET_REVENUE / NULLIF(ORDER_COUNT, 0), 2) AS AVG_ORDER_VALUE,
    ROUND(NET_REVENUE / NULLIF(UNIQUE_CUSTOMERS, 0), 2) AS REVENUE_PER_CUSTOMER
FROM {{project_db}}{{env_suffix}}.CURATED.DT_DAILY_SALES;

-- ---------------------------------------------------------------------------
-- CUSTOMER SEGMENTS: Customer segmentation view for marketing teams
-- ---------------------------------------------------------------------------
DEFINE VIEW {{project_db}}{{env_suffix}}.SERVE.V_CUSTOMER_SEGMENTS
AS
SELECT
    CUSTOMER_ID,
    CUSTOMER_KEY,
    FULL_NAME,
    REGION,
    CUSTOMER_SEGMENT,
    IS_ACTIVE,
    LIFETIME_ORDER_COUNT,
    LIFETIME_REVENUE,
    AVG_ORDER_VALUE,
    FIRST_ORDER_DATE,
    LAST_ORDER_DATE,
    DAYS_SINCE_LAST_ORDER,
    CUSTOMER_SINCE,
    CASE
        WHEN LIFETIME_ORDER_COUNT = 0 THEN 'PROSPECT'
        WHEN LIFETIME_ORDER_COUNT = 1 THEN 'NEW'
        WHEN DAYS_SINCE_LAST_ORDER <= 30 THEN 'ACTIVE'
        WHEN DAYS_SINCE_LAST_ORDER <= 90 THEN 'AT_RISK'
        WHEN DAYS_SINCE_LAST_ORDER <= 180 THEN 'LAPSED'
        ELSE 'CHURNED'
    END AS LIFECYCLE_STAGE,
    CASE
        WHEN LIFETIME_REVENUE >= 10000 THEN 'PLATINUM'
        WHEN LIFETIME_REVENUE >= 5000 THEN 'GOLD'
        WHEN LIFETIME_REVENUE >= 1000 THEN 'SILVER'
        ELSE 'BRONZE'
    END AS VALUE_TIER
FROM {{project_db}}{{env_suffix}}.CURATED.DT_CUSTOMER_360;

-- ---------------------------------------------------------------------------
-- PRODUCT CATALOG: Active product catalog with performance metrics
-- ---------------------------------------------------------------------------
DEFINE VIEW {{project_db}}{{env_suffix}}.SERVE.V_PRODUCT_CATALOG
AS
SELECT
    PRODUCT_ID,
    PRODUCT_SKU,
    PRODUCT_NAME,
    CATEGORY,
    SUBCATEGORY,
    CURRENT_PRICE,
    TOTAL_ORDERS,
    TOTAL_UNITS_SOLD,
    TOTAL_REVENUE,
    AVG_SELLING_PRICE,
    AVG_DISCOUNT_PERCENT,
    GROSS_MARGIN_PERCENT,
    IS_ACTIVE
FROM {{project_db}}{{env_suffix}}.CURATED.DT_PRODUCT_PERFORMANCE
WHERE IS_ACTIVE = TRUE;

-- ---------------------------------------------------------------------------
-- ORDER DETAIL: Full order detail view for operational reporting
-- ---------------------------------------------------------------------------
DEFINE VIEW {{project_db}}{{env_suffix}}.SERVE.V_ORDER_DETAIL
AS
SELECT
    ORDER_ID,
    ORDER_KEY,
    ORDER_DATE,
    STATUS,
    CHANNEL,
    PAYMENT_METHOD,
    CUSTOMER_KEY,
    CUSTOMER_NAME,
    CUSTOMER_REGION,
    CUSTOMER_SEGMENT,
    PRODUCT_SKU,
    PRODUCT_NAME,
    PRODUCT_CATEGORY,
    PRODUCT_SUBCATEGORY,
    QUANTITY,
    UNIT_PRICE,
    DISCOUNT_PERCENT,
    LINE_TOTAL,
    ORDER_TOTAL,
    ORDER_DISCOUNT,
    TAX_AMOUNT,
    SHIPPING_AMOUNT,
    CURRENCY_CODE
FROM {{project_db}}{{env_suffix}}.CURATED.DT_ORDER_ENRICHED;
