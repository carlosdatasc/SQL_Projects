CREATE DATABASE practice_sql;

USE practice_sql;

CREATE TABLE customers(
	customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE products(
	product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE sales(
	sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


INSERT INTO customers VALUES
(1,'Ana','CDMX'),
(2,'Luis','Monterrey'),
(3,'Carla','Guadalajara'),
(4,'Pedro','CDMX'),
(5,'Sofía','Merida');

INSERT INTO products VALUES
(101,'Laptop','Tecnología',180000),
(102,'Mouse','Tecnología',350),
(103,'Libro','Educación',250),
(104,'Escritorio','Muebles',3000),
(105,'Silla','Muebles',1800);

INSERT INTO sales VALUES
(1,1,101,1,'2024-03-01'),
(2,1,103,2,'2024-03-02'),
(3,2,104,1,'2024-03-05'),
(4,3,105,2,'2024-03-05'),
(5,3,102,1,'2024-03-06'),
(6,4,101,1,'2024-03-08');

#Ejercicio 1
# Muestra el nombre del cliente , el producto y el monto total de la venta
SELECT
	c.name,
    p.product_name,
    (p.price * s.quantity) AS Sale
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN products p ON s.product_id = p.product_id;

#Ejercicio 2
#Muestra todos los clientes junto con el total gastado si compraron algo
#Si no tienen compra, mostrar total como 0

SELECT
	c.name,
    #Coalesce devuelve el primer valor que no sea nulo
    COALESCE(SUM(p.price * s.quantity),0) AS total
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id 
LEFT JOIN products p ON s.product_id = p.product_id
GROUP BY c.name ;

#Ejercicio 3
#Encuentra las categorías de productos cuyo promedio de ingresos por venta supero los $5000

SELECT
	p.category,
    AVG(p.price*s.quantity) AS mean_cat
FROM products p
INNER JOIN sales s ON s.product_id = p.product_id
GROUP BY p.category
HAVING mean_cat > 5000;