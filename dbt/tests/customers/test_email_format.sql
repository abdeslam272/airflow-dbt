SELECT email
FROM {{ ref('customers') }}
WHERE email NOT LIKE '%@%.%'
