{% macro current_timestamp_utc() %}
    {%- if target.type == 'snowflake' -%}
        convert_timezone('UTC', current_timestamp())::timestamp_ntz
    {%- elif target.type == 'bigquery' -%}
        current_timestamp()
    {%- elif target.type == 'redshift' -%}
        getdate()
    {%- elif target.type == 'postgres' -%}
        (now() at time zone 'utc')
    {%- elif target.type == 'databricks' -%}
        current_timestamp()
    {%- else -%}
        current_timestamp
    {%- endif -%}
{% endmacro %}
