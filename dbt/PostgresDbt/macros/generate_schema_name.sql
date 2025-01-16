{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name == 'snapshots' and default_schema == 'dbt' -%}
        {{ custom_schema_name }}
    {%- else -%}
        {%- if custom_schema_name is none or custom_schema_name == 'none' -%}
            {{ default_schema }}
        {%- else -%}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}