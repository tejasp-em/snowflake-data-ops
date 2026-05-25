{% macro grant_select_on_schema(schema_name, role_name, database_name=target.database) %}

    {% set sql %}
        grant usage on schema {{ database_name }}.{{ schema_name }} to role {{ role_name }};
        grant select on all tables in schema {{ database_name }}.{{ schema_name }} to role {{ role_name }};
        grant select on all views in schema {{ database_name }}.{{ schema_name }} to role {{ role_name }};
        grant select on future tables in schema {{ database_name }}.{{ schema_name }} to role {{ role_name }};
        grant select on future views in schema {{ database_name }}.{{ schema_name }} to role {{ role_name }};
    {% endset %}

    {% do log("Granting SELECT on " ~ database_name ~ "." ~ schema_name ~ " to role " ~ role_name, info=True) %}

    {% if execute %}
        {% do run_query(sql) %}
        {{ log("Grants applied successfully.", info=True) }}
    {% endif %}

{% endmacro %}
