{% macro standardize_column_name(column_name) %}
    {%- set result = column_name
        | lower
        | trim
        | replace(' ', '_')
        | replace('-', '_')
        | replace('.', '_')
        | replace('/', '_')
        | replace('(', '')
        | replace(')', '')
        | replace('&', 'and')
    -%}
    {%- if result[0].isdigit() -%}
        _{{ result }}
    {%- else -%}
        {{ result }}
    {%- endif -%}
{% endmacro %}

{% macro standardize_all_column_names(relation) %}
    {%- set columns = adapter.get_columns_in_relation(relation) -%}
    {%- for col in columns %}
        {{ col.quoted }} as {{ dbt_common_utils.standardize_column_name(col.name) }}
        {%- if not loop.last %},{% endif %}
    {%- endfor -%}
{% endmacro %}
