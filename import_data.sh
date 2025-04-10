#!/bin/bash

echo "📂 Copying CSV files to PostgreSQL container..."
docker cp data/products.csv postgres-dbt:/products.csv
docker cp data/customers.csv postgres-dbt:/customers.csv
docker cp data/orders.csv postgres-dbt:/orders.csv
docker cp data/order_items.csv postgres-dbt:/order_items.csv

echo "🚀 Running data import in PostgreSQL..."
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.products FROM '/products.csv' WITH CSV HEADER;"
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.customers FROM '/customers.csv' WITH CSV HEADER;"
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.orders FROM '/orders.csv' WITH CSV HEADER;"
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.order_items FROM '/order_items.csv' WITH CSV HEADER;"

echo "✅ Data import completed successfully!"
