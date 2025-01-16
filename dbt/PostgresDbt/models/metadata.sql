{{
  config(
    materialized = 'table',
    on_schema_change='sync_all_columns',
    post_hook = after_commit('{{ insert_metadata() }}')
  )
}}

with empty_table as (
    select
        cast(null as varchar(600)) as unique_id,
        cast(null as varchar(600)) as package_name,
        cast(null as varchar(600)) as database_name,
        cast(null as varchar(600)) as schema_name,
        cast(null as varchar(600)) as name,
        cast(null as varchar(600)) as alias,
        cast(null as varchar(600)) as resource_type,
        cast(null as varchar(600)) as group,
        cast(null as varchar(600)) as original_file_path
)

select 
        unique_id,
        package_name,
        database_name,
        schema_name,
        name,
        alias,
        resource_type,
        "group",
        original_file_path
from empty_table
-- This is a filter so we will never actually insert these values
where 1 = 0