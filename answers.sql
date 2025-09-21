-- ecommerce_db_schema.sql
-- Database schema for a simple e-commerce store (MySQL)

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- CUSTOMERS / USERS
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ADDRESSES (One customer -> many addresses)
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- CATEGORIES (Products grouping)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

-- PRODUCTS
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ORDERS (One customer -> many orders)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending','paid','shipped','completed','cancelled') NOT NULL DEFAULT 'pending',
    shipping_address_id INT,
    billing_address_id INT,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ORDER_ITEMS (Many-to-many between orders and products with extra attributes)
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- PAYMENTS (one-to-one / one-to-many depending on business rules)
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    paid_amount DECIMAL(12,2) NOT NULL CHECK (paid_amount >= 0),
    paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('card','paypal','bank_transfer','cash') NOT NULL,
    transaction_reference VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- INDEXES to speed common queries
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orderitems_product ON order_items(product_id);

-- SAMPLE SEED DATA (small)
INSERT INTO categories (name, description) VALUES
('Laptops','Portable computers'),
('Accessories','Computer accessories and peripherals');

INSERT INTO products (category_id, name, sku, description, price, stock) VALUES
(1, 'Ultrabook Pro 14', 'UBP14-001', '14-inch ultrabook, 16GB RAM, 512GB SSD', 1299.00, 10),
(1, 'Gaming Laptop 17', 'GL17-002', '17-inch gaming laptop, RTX GPU', 1999.99, 5),
(2, 'Wireless Mouse', 'WM-100', 'Comfort wireless mouse', 29.99, 100),
(2, 'Mechanical Keyboard', 'MK-200', 'Tactile mechanical keyboard', 89.99, 50);

INSERT INTO customers (first_name, last_name, email, phone) VALUES
('John','Doe','john.doe@example.com','+2348010000001'),
('Jane','Smith','jane.smith@example.com','+2348010000002');

INSERT INTO addresses (customer_id, address_line1, city, state, postal_code, country) VALUES
(1, '12 Market St', 'Lagos', 'Lagos', '100001', 'Nigeria'),
(2, '45 High Rd', 'Abuja', 'FCT', '900001', 'Nigeria');

-- Insert an example order
INSERT INTO orders (customer_id, shipping_address_id, billing_address_id, total_amount, status)
VALUES (1, 1, 1, 1328.99, 'paid');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1299.00),
(1, 3, 1, 29.99);

INSERT INTO payments (order_id, paid_amount, payment_method, transaction_reference) VALUES
(1, 1328.99, 'card', 'TXN123456789');

-- End of schema

