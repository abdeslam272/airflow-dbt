SELECT status
FROM {{ ref('orders') }}
WHERE status NOT IN ('Pending', 'Completed', 'Cancelled')
