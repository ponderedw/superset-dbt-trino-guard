select
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    join_date
from {{ source('public', 'customers') }} 
WHERE DATE_TRUNC('month', join_date) = '2023-01-01'