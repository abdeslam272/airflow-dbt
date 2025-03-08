CREATE TABLE products (
    id INT PRIMARY KEY,
    name TEXT,
    category TEXT,
    price INT
);

CREATE TABLE customers (
    id INT PRIMARY KEY,
    name TEXT,
    email TEXT,
    country TEXT
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    order_date DATE
);

CREATE TABLE order_items (
    id INT,
    order_id INT,
    product_id INT ,
    quantity INT,
    price INT
);
