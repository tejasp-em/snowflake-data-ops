{% macro audit_compare_relations(a_relation, b_relation, primary_key_columns, columns_to_compare=none) %}

    {%- if columns_to_compare is none -%}
        {%- set a_cols = adapter.get_columns_in_relation(a_relation) -%}
        {%- set col_names = a_cols | map(attribute='name') | list -%}
    {%- else -%}
        {%- set col_names = columns_to_compare -%}
    {%- endif -%}

    {%- set pk_csv = primary_key_columns | join(', ') -%}

    with a_data as (
        select * from {{ a_relation }}
    ),

    b_data as (
        select * from {{ b_relation }}
    ),

    a_only as (
        select {{ pk_csv }}, 'in_a_only' as _audit_status
        from a_data
        {{ dbt.except() }}
        select {{ pk_csv }}, 'in_a_only' as _audit_status
        from b_data
    ),

    b_only as (
        select {{ pk_csv }}, 'in_b_only' as _audit_status
        from b_data
        {{ dbt.except() }}
        select {{ pk_csv }}, 'in_b_only' as _audit_status
        from a_data
    ),

    row_count_summary as (
        select
            (select count(*) from a_data) as a_row_count,
            (select count(*) from b_data) as b_row_count,
            (select count(*) from a_only) as a_only_count,
            (select count(*) from b_only) as b_only_count
    ),

    column_diffs as (
        {%- for col in col_names %}
        {%- if col not in primary_key_columns %}
        select
            '{{ col }}' as column_name,
            count(*) as mismatch_count
        from a_data
        inner join b_data
            on {% for pk in primary_key_columns %}a_data.{{ pk }} = b_data.{{ pk }}{% if not loop.last %} and {% endif %}{% endfor %}
        where a_data.{{ col }} != b_data.{{ col }}
            or (a_data.{{ col }} is null and b_data.{{ col }} is not null)
            or (a_data.{{ col }} is not null and b_data.{{ col }} is null)
        {% if not loop.last %}union all{% endif %}
        {%- endif -%}
        {%- endfor %}
    )

    select 'row_counts' as audit_type, null as column_name, null as mismatch_count, a_row_count, b_row_count, a_only_count, b_only_count
    from row_count_summary
    union all
    select 'column_diffs' as audit_type, column_name, mismatch_count, null, null, null, null
    from column_diffs
    where mismatch_count > 0

{% endmacro %}
