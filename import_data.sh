#!/bin/bash

# PostgreSQL container name
CONTAINER_NAME="postgres-dbt"
DB_NAME="dbt-db"
DB_USER="dbt-user"

# Folder containing CSV files
CSV_DIR="./data"

# Check if the folder exists
if [ ! -d "$CSV_DIR" ]; then
    echo "Error: Directory $CSV_DIR does not exist."
    exit 1
fi

echo "📂 Copying CSV files to PostgreSQL container..."
docker cp "$CSV_DIR/products.csv" $CONTAINER_NAME:/products.csv
docker cp "$CSV_DIR/customers.csv" $CONTAINER_NAME:/customers.csv
docker cp "$CSV_DIR/orders.csv" $CONTAINER_NAME:/orders.csv
docker cp "$CSV_DIR/order_items.csv" $CONTAINER_NAME:/order_items.csv

echo "🚀 Running data import in PostgreSQL..."
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME <<EOF

-- Load data into tables
\copy products(name, price, category) FROM '/products.csv' DELIMITER ',' CSV HEADER;
\copy customers(name, email) FROM '/customers.csv' DELIMITER ',' CSV HEADER;
\copy orders(customer_id, order_date) FROM '/orders.csv' DELIMITER ',' CSV HEADER;
\copy order_items(order_id, product_id, quantity, price) FROM '/order_items.csv' DELIMITER ',' CSV HEADER;

EOF

echo "✅ Data import completed successfully!"
