{% macro is_weekend(date_column) %}
    case
        when dayofweek({{ date_column }}) in (0, 6) then true
        else false
    end
{% endmacro %}
