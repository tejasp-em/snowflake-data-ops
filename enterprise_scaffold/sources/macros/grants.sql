{% macro grant_schema_read(db, schema, role, role_type) %}
{% if role_type == 'database' %}
    GRANT USAGE ON SCHEMA {{db}}.{{schema}} TO DATABASE ROLE {{db}}.{{role}};
    GRANT SELECT ON ALL TABLES IN SCHEMA {{db}}.{{schema}} TO DATABASE ROLE {{db}}.{{role}};
    GRANT SELECT ON ALL VIEWS IN SCHEMA {{db}}.{{schema}} TO DATABASE ROLE {{db}}.{{role}};
    GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA {{db}}.{{schema}} TO DATABASE ROLE {{db}}.{{role}};
{% else %}
    GRANT USAGE ON SCHEMA {{db}}.{{schema}} TO ROLE {{role}};
    GRANT SELECT ON ALL TABLES IN SCHEMA {{db}}.{{schema}} TO ROLE {{role}};
    GRANT SELECT ON ALL VIEWS IN SCHEMA {{db}}.{{schema}} TO ROLE {{role}};
    GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA {{db}}.{{schema}} TO ROLE {{role}};
{% endif %}
{% endmacro %}

{% macro grant_schema_write(db, schema, role) %}
    GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {{db}}.{{schema}} TO DATABASE ROLE {{db}}.{{role}};
{% endmacro %}

{% macro grant_schema_ddl(db, schema, role) %}
    GRANT CREATE TABLE, CREATE VIEW, CREATE DYNAMIC TABLE ON SCHEMA {{db}}.{{schema}} TO DATABASE ROLE {{db}}.{{role}};
{% endmacro %}

{% macro create_team_schema(db, team_name) %}
    DEFINE SCHEMA {{db}}.{{team_name}}
        WITH MANAGED ACCESS
        COMMENT = 'Team workspace for {{team_name}}';
{% endmacro %}
