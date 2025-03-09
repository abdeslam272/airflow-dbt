-- Créer le schéma "raw" s'il n'existe pas
CREATE SCHEMA IF NOT EXISTS raw;

-- Supprimer les tables si elles existent
DROP TABLE IF EXISTS raw.order_items CASCADE;
DROP TABLE IF EXISTS raw.orders CASCADE;
DROP TABLE IF EXISTS raw.products CASCADE;
DROP TABLE IF EXISTS raw.customers CASCADE;

-- Créer les tables dans le schéma "raw"
CREATE TABLE raw.products (
    id INT PRIMARY KEY,
    name TEXT,
    category TEXT,
    price INT
);

CREATE TABLE raw.customers (
    id INT PRIMARY KEY,
    name TEXT,
    email TEXT,
    country TEXT
);

CREATE TABLE raw.orders (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount INT,
    status TEXT,
    FOREIGN KEY (customer_id) REFERENCES raw.customers(id) ON DELETE CASCADE
);

CREATE TABLE raw.order_items (
    id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price INT, 
    FOREIGN KEY (order_id) REFERENCES raw.orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES raw.products(id) ON DELETE CASCADE
);
