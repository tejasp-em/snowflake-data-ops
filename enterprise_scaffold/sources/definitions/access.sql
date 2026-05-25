-- =============================================================================
-- ACCESS CONTROL: Three-tier role pattern with database roles
-- =============================================================================

{% set db = project_db ~ env_suffix %}

-- ---------------------------------------------------------------------------
-- DATABASE ROLES: Access Roles (granular permissions)
-- ---------------------------------------------------------------------------
DEFINE DATABASE ROLE {{db}}.DATA_READER
    COMMENT = 'Read-only access to all data in the platform';

DEFINE DATABASE ROLE {{db}}.DATA_WRITER
    COMMENT = 'Read-write access to raw and staging schemas';

DEFINE DATABASE ROLE {{db}}.DATA_ADMIN
    COMMENT = 'Full DDL and DML access across the platform';

-- ---------------------------------------------------------------------------
-- DATABASE ROLES: Functional Roles (business personas)
-- ---------------------------------------------------------------------------
DEFINE DATABASE ROLE {{db}}.ANALYST
    COMMENT = 'Business analyst: read access to curated and serve layers';

DEFINE DATABASE ROLE {{db}}.ENGINEER
    COMMENT = 'Data engineer: read-write to raw/staging, read to curated/serve';

DEFINE DATABASE ROLE {{db}}.PLATFORM_ADMIN
    COMMENT = 'Platform administrator: full control of all schemas and objects';

-- ---------------------------------------------------------------------------
-- ACCOUNT ROLES: Warehouse access (required because warehouses are account-level)
-- ---------------------------------------------------------------------------
DEFINE ROLE {{db}}_WH_USER
    COMMENT = 'Grants warehouse usage for the {{db}} platform';

-- ---------------------------------------------------------------------------
-- ROLE HIERARCHY: Access role grants
-- ---------------------------------------------------------------------------

-- DATA_READER: database + all schema usage + SELECT
GRANT USAGE ON DATABASE {{db}} TO DATABASE ROLE {{db}}.DATA_READER;

{{ grant_schema_read(db, 'RAW', 'DATA_READER', 'database') }}
{{ grant_schema_read(db, 'CURATED', 'DATA_READER', 'database') }}
{{ grant_schema_read(db, 'SERVE', 'DATA_READER', 'database') }}
{{ grant_schema_read(db, 'STAGING', 'DATA_READER', 'database') }}

-- DATA_WRITER: inherits from DATA_READER + write to RAW and STAGING
GRANT DATABASE ROLE {{db}}.DATA_READER TO DATABASE ROLE {{db}}.DATA_WRITER;

{{ grant_schema_write(db, 'RAW', 'DATA_WRITER') }}
{{ grant_schema_write(db, 'STAGING', 'DATA_WRITER') }}

-- DATA_ADMIN: inherits from DATA_WRITER + DDL on all schemas
GRANT DATABASE ROLE {{db}}.DATA_WRITER TO DATABASE ROLE {{db}}.DATA_ADMIN;

{{ grant_schema_ddl(db, 'RAW', 'DATA_ADMIN') }}
{{ grant_schema_ddl(db, 'CURATED', 'DATA_ADMIN') }}
{{ grant_schema_ddl(db, 'SERVE', 'DATA_ADMIN') }}
{{ grant_schema_ddl(db, 'STAGING', 'DATA_ADMIN') }}
{{ grant_schema_ddl(db, 'PIPELINE', 'DATA_ADMIN') }}

-- ---------------------------------------------------------------------------
-- FUNCTIONAL ROLE COMPOSITION
-- ---------------------------------------------------------------------------

-- ANALYST = DATA_READER
GRANT DATABASE ROLE {{db}}.DATA_READER TO DATABASE ROLE {{db}}.ANALYST;

-- ENGINEER = DATA_WRITER
GRANT DATABASE ROLE {{db}}.DATA_WRITER TO DATABASE ROLE {{db}}.ENGINEER;

-- PLATFORM_ADMIN = DATA_ADMIN
GRANT DATABASE ROLE {{db}}.DATA_ADMIN TO DATABASE ROLE {{db}}.PLATFORM_ADMIN;

-- ---------------------------------------------------------------------------
-- WAREHOUSE GRANTS (account role, since DB roles can't hold warehouse privs)
-- ---------------------------------------------------------------------------
GRANT USAGE ON WAREHOUSE {{project_db}}_ETL_WH{{env_suffix}} TO ROLE {{db}}_WH_USER;
GRANT USAGE ON WAREHOUSE {{project_db}}_ANALYTICS_WH{{env_suffix}} TO ROLE {{db}}_WH_USER;

{% for team in teams %}
GRANT USAGE ON WAREHOUSE {{team.name}}_WH{{env_suffix}} TO ROLE {{db}}_WH_USER;
{% endfor %}

-- ---------------------------------------------------------------------------
-- SYSADMIN ROLLUP (governance best practice)
-- ---------------------------------------------------------------------------
GRANT DATABASE ROLE {{db}}.PLATFORM_ADMIN TO ROLE SYSADMIN;
GRANT ROLE {{db}}_WH_USER TO ROLE SYSADMIN;

-- ---------------------------------------------------------------------------
-- PER-TEAM SCHEMA ACCESS
-- ---------------------------------------------------------------------------
{% for team in teams %}
DEFINE DATABASE ROLE {{db}}.{{team.name}}_MEMBER
    COMMENT = 'Member of {{team.name}} team with access to team schema';

GRANT USAGE ON DATABASE {{db}} TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;
GRANT USAGE ON SCHEMA {{db}}.{{team.name}} TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;
GRANT SELECT ON ALL TABLES IN SCHEMA {{db}}.{{team.name}} TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;
GRANT SELECT ON ALL VIEWS IN SCHEMA {{db}}.{{team.name}} TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {{db}}.{{team.name}} TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA {{db}}.{{team.name}} TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;

GRANT DATABASE ROLE {{db}}.DATA_READER TO DATABASE ROLE {{db}}.{{team.name}}_MEMBER;
GRANT DATABASE ROLE {{db}}.{{team.name}}_MEMBER TO DATABASE ROLE {{db}}.PLATFORM_ADMIN;

{% endfor %}
