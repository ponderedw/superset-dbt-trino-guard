{% set prod_schema = 'dbt' %}
with 
superset_sources as (
    SELECT
        *
    FROM
        TABLE(
            superset.system.query('
            with base as (
            select ds.dashboard_id, t.sql, t."schema", t.table_name, t.database_id
            from 
                public.slices s, 
                public.dashboard_slices ds,
                public."tables" t
            where s.id = ds.slice_id 
            and s.datasource_id  = t.id ),
            --select * from base where sql is null or sql = ''''
            --union all
            sql_queries_parsing as (
            select distinct dashboard_id, "sql", regexp_matches(
                        "sql", 
                        ''(?i)(?:from|join)\s+([a-zA-Z0-9._]+)'', 
                        ''g''
                    ) table_name from base where sql is not null and sql <> ''''),
            unnest_sql_queries_parsing as (
            select distinct dashboard_id, unnest(table_name) as table_name from sql_queries_parsing       )

            select distinct dashboard_id,
            split_part(table_name, ''.'', array_length(string_to_array(table_name, ''.''), 1) - 1) AS schema_name,
                split_part(table_name, ''.'', array_length(string_to_array(table_name, ''.''), 1)) AS table_name
            from unnest_sql_queries_parsing
            where table_name LIKE ''%.%''
            union 
            select dashboard_id, "schema", table_name from base where sql is null or sql = ''''
            '))
)
select *
from superset_sources ss
where 
    case when cast(ss.schema_name as varchar) like '{{ prod_schema }}_%' then
        '{{ env_var('DBT_SCHEMA', target.schema) }}'
            || 
            substr(
                cast(ss.schema_name as varchar),
                strpos(cast(ss.schema_name as varchar), '{{ prod_schema }}') + length('{{ prod_schema }}'),
                length(cast(ss.schema_name as varchar))
                )
        when cast(ss.schema_name as varchar) = '{{ prod_schema }}' then '{{ env_var('DBT_SCHEMA', target.schema) }}'
        else cast(ss.schema_name as varchar)
    end || '.' || cast(ss.table_name as varchar) not in (
	select
		distinct schema_name || '.' || alias
	from
		{{ source('db_metadata', 'metadata') }} dnd
	where
		resource_type in ('model', 'snapshot', 'seed')
)