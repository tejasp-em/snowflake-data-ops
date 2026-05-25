-- =============================================================================
-- DATA QUALITY: Expectations using built-in Data Metric Functions
-- =============================================================================

{% set db = project_db ~ env_suffix %}

-- ---------------------------------------------------------------------------
-- CUSTOMERS: Ensure key fields are populated
-- ---------------------------------------------------------------------------
ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.CUSTOMERS
    ON (CUSTOMER_ID)
    EXPECTATION CUSTOMER_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.CUSTOMERS
    ON (CUSTOMER_KEY)
    EXPECTATION CUSTOMER_KEY_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.CUSTOMERS
    ON (EMAIL)
    EXPECTATION CUSTOMER_EMAIL_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    TO TABLE {{db}}.RAW.CUSTOMERS
    ON (CUSTOMER_KEY)
    EXPECTATION CUSTOMER_KEY_UNIQUE (value = 0);

-- ---------------------------------------------------------------------------
-- PRODUCTS: Ensure product data integrity
-- ---------------------------------------------------------------------------
ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.PRODUCTS
    ON (PRODUCT_ID)
    EXPECTATION PRODUCT_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.PRODUCTS
    ON (PRODUCT_SKU)
    EXPECTATION PRODUCT_SKU_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    TO TABLE {{db}}.RAW.PRODUCTS
    ON (PRODUCT_SKU)
    EXPECTATION PRODUCT_SKU_UNIQUE (value = 0);

-- ---------------------------------------------------------------------------
-- ORDERS: Ensure order data integrity
-- ---------------------------------------------------------------------------
ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.ORDERS
    ON (ORDER_ID)
    EXPECTATION ORDER_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.ORDERS
    ON (CUSTOMER_ID)
    EXPECTATION ORDER_CUSTOMER_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.ORDERS
    ON (ORDER_DATE)
    EXPECTATION ORDER_DATE_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    TO TABLE {{db}}.RAW.ORDERS
    ON (ORDER_ID)
    EXPECTATION ORDER_ID_UNIQUE (value = 0);

-- ---------------------------------------------------------------------------
-- ORDER_ITEMS: Ensure line-item data integrity
-- ---------------------------------------------------------------------------
ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.ORDER_ITEMS
    ON (ORDER_ITEM_ID)
    EXPECTATION ORDER_ITEM_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.ORDER_ITEMS
    ON (ORDER_ID)
    EXPECTATION ORDER_ITEM_ORDER_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.ORDER_ITEMS
    ON (PRODUCT_ID)
    EXPECTATION ORDER_ITEM_PRODUCT_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    TO TABLE {{db}}.RAW.ORDER_ITEMS
    ON (ORDER_ITEM_ID)
    EXPECTATION ORDER_ITEM_ID_UNIQUE (value = 0);

-- ---------------------------------------------------------------------------
-- EVENTS: Ensure event stream integrity
-- ---------------------------------------------------------------------------
ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.EVENTS
    ON (EVENT_ID)
    EXPECTATION EVENT_ID_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE {{db}}.RAW.EVENTS
    ON (EVENT_TIMESTAMP)
    EXPECTATION EVENT_TIMESTAMP_NOT_NULL (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    TO TABLE {{db}}.RAW.EVENTS
    ON (EVENT_ID)
    EXPECTATION EVENT_ID_UNIQUE (value = 0);
