{% macro coalesce_null(column_name, default_value="'UNKNOWN'") %}
    coalesce({{ column_name }}, {{ default_value }})
{% endmacro %}
