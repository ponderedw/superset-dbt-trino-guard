{% macro insert_metadata_query() %}
 {%- if execute -%}
{%- set parsed_results = [] %}
  {% for node in graph.nodes.values() %}
    {% set parsed_result_dict = {
            'unique_id': node.get('unique_id'),
            'package_name': node.get('package_name'),
            'database_name': node.get('database'),
            'schema_name': node.get('schema'),
            'name': node.get('name'),
            'alias': node.get('alias'),
            'resource_type': node.get('resource_type'),
            'group': node.get('config').get('group'),
            'original_file_path': node.get('original_file_path')
            }%}
        {% do parsed_results.append(parsed_result_dict) %}
  {% endfor %}

  {{ return(parsed_results) }}

{%- endif -%}
{% endmacro %}


{% macro insert_metadata() %}
    {%- if execute -%}
        {%- set parsed_deps = insert_metadata_query() -%}
        {%- if parsed_deps | length  > 0 -%}
            {% set trunc_dbt_results_query -%}
                truncate table {{ this }}
            {%- endset -%}
            {%- do run_query(trunc_dbt_results_query) -%}
            {% set insert_dbt_results_query -%}
                insert into {{ this }}
                    (
                        unique_id,
                        package_name,
                        database_name,
                        schema_name,
                        name,
                        alias,
                        resource_type,
                        "group",
                        original_file_path
                ) values
                    {%- for parsed_dep in parsed_deps -%}
                        (
                            '{{ parsed_dep.get('unique_id') }}',
                            '{{ parsed_dep.get('package_name') }}',
                            '{{ parsed_dep.get('database_name') }}',
                            '{{ parsed_dep.get('schema_name') }}',
                            '{{ parsed_dep.get('name') }}',
                            '{{ parsed_dep.get('alias') }}',
                            '{{ parsed_dep.get('resource_type') }}',
                            '{{ parsed_dep.get('group') }}',
                            '{{ parsed_dep.get('original_file_path') }}'
                        ) {{- "," if not loop.last else "" -}}
                    {%- endfor -%}
            {%- endset -%}
            {%- do run_query(insert_dbt_results_query) -%}
        {%- endif -%}
    {%- endif -%}
    -- This macro is called from an on-run-end hook and therefore must return a query txt to run. Returning an empty string will do the trick
    {{ return ('') }}
{% endmacro %}



