-- =============================================================================
-- INFRASTRUCTURE: Databases, Schemas, Warehouses, Stages, File Formats
-- =============================================================================

-- ---------------------------------------------------------------------------
-- DATABASE
-- ---------------------------------------------------------------------------
DEFINE DATABASE {{project_db}}{{env_suffix}}
    COMMENT = 'Enterprise data platform - {{env_suffix}} environment';

-- ---------------------------------------------------------------------------
-- SCHEMAS (medallion architecture: RAW -> CURATED -> SERVE)
-- ---------------------------------------------------------------------------
DEFINE SCHEMA {{project_db}}{{env_suffix}}.RAW
    COMMENT = 'Landing zone for raw ingested data'
    DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_raw}};

DEFINE SCHEMA {{project_db}}{{env_suffix}}.CURATED
    WITH MANAGED ACCESS
    COMMENT = 'Cleansed and transformed data'
    DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_curated}};

DEFINE SCHEMA {{project_db}}{{env_suffix}}.SERVE
    WITH MANAGED ACCESS
    COMMENT = 'Business-ready data for consumption'
    DATA_RETENTION_TIME_IN_DAYS = {{data_retention_days_serve}};

DEFINE SCHEMA {{project_db}}{{env_suffix}}.STAGING
    COMMENT = 'Temporary staging area for data ingestion';

DEFINE SCHEMA {{project_db}}{{env_suffix}}.PIPELINE
    COMMENT = 'Schema for tasks and orchestration objects';

{% if enable_sandbox %}
DEFINE SCHEMA {{project_db}}{{env_suffix}}.SANDBOX
    COMMENT = 'Sandbox for ad-hoc exploration and prototyping'
    DATA_RETENTION_TIME_IN_DAYS = 1;
{% endif %}

{% for team in teams %}
{{ create_team_schema(project_db ~ env_suffix, team.name) }}
{% endfor %}

-- ---------------------------------------------------------------------------
-- WAREHOUSES
-- ---------------------------------------------------------------------------
DEFINE WAREHOUSE {{project_db}}_ETL_WH{{env_suffix}}
WITH
    WAREHOUSE_SIZE = '{{etl_wh_size}}'
    AUTO_SUSPEND = {{auto_suspend_seconds}}
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'ETL and data ingestion workloads';

DEFINE WAREHOUSE {{project_db}}_ANALYTICS_WH{{env_suffix}}
WITH
    WAREHOUSE_SIZE = '{{analytics_wh_size}}'
    AUTO_SUSPEND = {{auto_suspend_seconds}}
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Analytics and BI query workloads';

{% for team in teams %}
DEFINE WAREHOUSE {{team.name}}_WH{{env_suffix}}
WITH
    WAREHOUSE_SIZE = '{{team.wh_size}}'
    AUTO_SUSPEND = {{auto_suspend_seconds}}
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Dedicated warehouse for {{team.name}} team';

{% endfor %}

-- ---------------------------------------------------------------------------
-- FILE FORMATS
-- ---------------------------------------------------------------------------
DEFINE FILE FORMAT {{project_db}}{{env_suffix}}.STAGING.CSV_FORMAT
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    NULL_IF = ('', 'NULL', 'N/A', 'null')
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Standard CSV ingest format';

DEFINE FILE FORMAT {{project_db}}{{env_suffix}}.STAGING.JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    STRIP_NULL_VALUES = FALSE
    COMMENT = 'Standard JSON ingest format';

DEFINE FILE FORMAT {{project_db}}{{env_suffix}}.STAGING.PARQUET_FORMAT
    TYPE = 'PARQUET'
    COMPRESSION = 'SNAPPY'
    BINARY_AS_TEXT = FALSE
    COMMENT = 'Standard Parquet ingest format';

-- ---------------------------------------------------------------------------
-- INTERNAL STAGES
-- ---------------------------------------------------------------------------
DEFINE STAGE {{project_db}}{{env_suffix}}.STAGING.CSV_LANDING
    DIRECTORY = (ENABLE = TRUE)
    FILE_FORMAT = (FORMAT_NAME = '{{project_db}}{{env_suffix}}.STAGING.CSV_FORMAT')
    COMMENT = 'Landing stage for CSV file uploads';

DEFINE STAGE {{project_db}}{{env_suffix}}.STAGING.JSON_LANDING
    DIRECTORY = (ENABLE = TRUE)
    FILE_FORMAT = (FORMAT_NAME = '{{project_db}}{{env_suffix}}.STAGING.JSON_FORMAT')
    COMMENT = 'Landing stage for JSON file uploads';

DEFINE STAGE {{project_db}}{{env_suffix}}.STAGING.PARQUET_LANDING
    DIRECTORY = (ENABLE = TRUE)
    FILE_FORMAT = (FORMAT_NAME = '{{project_db}}{{env_suffix}}.STAGING.PARQUET_FORMAT')
    COMMENT = 'Landing stage for Parquet file uploads';
