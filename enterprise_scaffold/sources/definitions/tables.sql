-- =============================================================================
-- RAW TABLES: Generic enterprise data landing tables with change tracking
-- =============================================================================

-- ---------------------------------------------------------------------------
-- CUSTOMERS: Core customer master data
-- ---------------------------------------------------------------------------
DEFINE TABLE {{project_db}}{{env_suffix}}.RAW.CUSTOMERS (
    CUSTOMER_ID NUMBER NOT NULL,
    CUSTOMER_KEY VARCHAR(50) NOT NULL,
    FULL_NAME VARCHAR(200),
    EMAIL VARCHAR(300),
    PHONE VARCHAR(50),
    ADDRESS_LINE_1 VARCHAR(500),
    ADDRESS_LINE_2 VARCHAR(500),
    CITY VARCHAR(100),
    STATE_PROVINCE VARCHAR(100),
    POSTAL_CODE VARCHAR(20),
    COUNTRY_CODE VARCHAR(3),
    REGION VARCHAR(50),
    CUSTOMER_SEGMENT VARCHAR(50),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(50),
    _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    test_col string
)
CHANGE_TRACKING = TRUE
COMMENT = 'Customer master data from upstream CRM systems'
DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};

-- ---------------------------------------------------------------------------
-- PRODUCTS: Product catalog
-- ---------------------------------------------------------------------------
DEFINE TABLE {{project_db}}{{env_suffix}}.RAW.PRODUCTS (
    PRODUCT_ID NUMBER NOT NULL,
    PRODUCT_SKU VARCHAR(50) NOT NULL,
    PRODUCT_NAME VARCHAR(300),
    DESCRIPTION VARCHAR(2000),
    CATEGORY VARCHAR(100),
    SUBCATEGORY VARCHAR(100),
    UNIT_PRICE NUMBER(12,2),
    COST_PRICE NUMBER(12,2),
    CURRENCY_CODE VARCHAR(3) DEFAULT 'USD',
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    LAUNCH_DATE DATE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SOURCE_SYSTEM VARCHAR(50),
    _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
CHANGE_TRACKING = TRUE
COMMENT = 'Product catalog from ERP and merchandising systems'
DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};

-- ---------------------------------------------------------------------------
-- ORDERS: Transactional order data
-- ---------------------------------------------------------------------------
DEFINE TABLE {{project_db}}{{env_suffix}}.RAW.ORDERS (
    ORDER_ID NUMBER NOT NULL,
    ORDER_KEY VARCHAR(50) NOT NULL,
    CUSTOMER_ID NUMBER NOT NULL,
    ORDER_DATE DATE NOT NULL,
    ORDER_TIMESTAMP TIMESTAMP_NTZ,
    STATUS VARCHAR(30) DEFAULT 'PENDING',
    TOTAL_AMOUNT NUMBER(15,2),
    DISCOUNT_AMOUNT NUMBER(12,2) DEFAULT 0,
    TAX_AMOUNT NUMBER(12,2) DEFAULT 0,
    SHIPPING_AMOUNT NUMBER(12,2) DEFAULT 0,
    CURRENCY_CODE VARCHAR(3) DEFAULT 'USD',
    PAYMENT_METHOD VARCHAR(50),
    CHANNEL VARCHAR(50),
    SHIPPED_AT TIMESTAMP_NTZ,
    DELIVERED_AT TIMESTAMP_NTZ,
    SOURCE_SYSTEM VARCHAR(50),
    _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
CHANGE_TRACKING = TRUE
COMMENT = 'Transactional order records from POS and e-commerce systems'
DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};

-- ---------------------------------------------------------------------------
-- ORDER_ITEMS: Line-level order details
-- ---------------------------------------------------------------------------
DEFINE TABLE {{project_db}}{{env_suffix}}.RAW.ORDER_ITEMS (
    ORDER_ITEM_ID NUMBER NOT NULL,
    ORDER_ID NUMBER NOT NULL,
    PRODUCT_ID NUMBER NOT NULL,
    QUANTITY NUMBER NOT NULL,
    UNIT_PRICE NUMBER(12,2) NOT NULL,
    DISCOUNT_PERCENT NUMBER(5,2) DEFAULT 0,
    LINE_TOTAL NUMBER(15,2),
    _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
CHANGE_TRACKING = TRUE
COMMENT = 'Order line items linked to orders and products'
DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};

-- ---------------------------------------------------------------------------
-- EVENTS: Generic event tracking (web analytics, application telemetry)
-- ---------------------------------------------------------------------------
DEFINE TABLE {{project_db}}{{env_suffix}}.RAW.EVENTS (
    EVENT_ID NUMBER NOT NULL,
    EVENT_TYPE VARCHAR(100) NOT NULL,
    EVENT_TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    USER_ID VARCHAR(100),
    SESSION_ID VARCHAR(100),
    PAGE_URL VARCHAR(2000),
    REFERRER_URL VARCHAR(2000),
    DEVICE_TYPE VARCHAR(50),
    BROWSER VARCHAR(100),
    OS VARCHAR(100),
    IP_ADDRESS VARCHAR(45),
    COUNTRY_CODE VARCHAR(3),
    PROPERTIES VARIANT,
    SOURCE_SYSTEM VARCHAR(50),
    _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
CHANGE_TRACKING = TRUE
COMMENT = 'Unified event stream from web analytics and application telemetry'
DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};

-- ---------------------------------------------------------------------------
-- AUDIT_LOG: System-level audit trail
-- ---------------------------------------------------------------------------
DEFINE TABLE {{project_db}}{{env_suffix}}.RAW.AUDIT_LOG (
    LOG_ID NUMBER NOT NULL,
    EVENT_TYPE VARCHAR(100) NOT NULL,
    EVENT_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    ACTOR VARCHAR(200),
    ACTION VARCHAR(200),
    RESOURCE_TYPE VARCHAR(100),
    RESOURCE_NAME VARCHAR(500),
    DETAILS VARIANT,
    STATUS VARCHAR(30),
    SOURCE_SYSTEM VARCHAR(50),
    _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
CHANGE_TRACKING = TRUE
COMMENT = 'Centralized audit log for compliance and governance'
DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};
