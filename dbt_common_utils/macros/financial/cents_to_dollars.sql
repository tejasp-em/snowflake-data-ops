{% macro cents_to_dollars(column_name, precision=2) %}
    case
        when {{ column_name }} is null then null
        when {{ column_name }} = 0 then 0.00
        else round(cast({{ column_name }} as numeric(38, 4)) / 100.0, {{ precision }})
    end
{% endmacro %}
