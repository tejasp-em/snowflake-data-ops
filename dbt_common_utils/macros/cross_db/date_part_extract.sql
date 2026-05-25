{% macro date_part_extract(date_part, date_column) %}
    {%- if target.type == 'snowflake' -%}
        date_part({{ date_part }}, {{ date_column }})
    {%- elif target.type == 'bigquery' -%}
        extract({{ date_part }} from {{ date_column }})
    {%- elif target.type in ('redshift', 'postgres') -%}
        date_part('{{ date_part }}', {{ date_column }})
    {%- elif target.type == 'databricks' -%}
        extract({{ date_part }} from {{ date_column }})
    {%- else -%}
        extract({{ date_part }} from {{ date_column }})
    {%- endif -%}
{% endmacro %}
