USE practice_sql;

CREATE TABLE customers_orders(
	customer_id INT PRIMARY KEY,
	nombre VARCHAR(50),
	city VARCHAR(20),
	order_date DATE,
	amount DECIMAL(10,2),
	bonus INT,
	phone_number VARCHAR(25)
);

INSERT INTO customers_orders (customer_id,nombre,city,order_date,amount,bonus,phone_number) VALUES
(1,	"Ana García",	"Mexico City","2023-07-01",	120.50,	10,	"(555) 123-4567"),
(2,	"Luis Pérez",	"mexico city",	"2023-07-02",	NULL,	NULL,	"555 765 4321"),
(3, "María López",	"Guadalajara",	"2023/07/03",	340.00,	15,	"(33) 111-2222"),
(4,	"José Torres",	"GUADALAJARA",	"2023-07-04",	510.00,	NULL,	"33-111-2222"),
(5,	"Laura Ruiz",	"Monterrey",	"2023-07-05",	NULL,	5,	"(81) 222-3333");


# Ejercicio 1
#Muestra el customer_id, amount, bonus y una nueva columna llamada bonus_fixed que reemplace los valores nulos de bonus por 0.

SELECT
	customer_id,
    amount,
    bonus,
    COALESCE(bonus, 0) AS bonus_fixed
FROM customers_orders;

# Ejercicio 2
# Muestra customer_id, city original y una nueva columna city_cleaned donde todos los valores estén en mayúsculas y sin espacios al inicio o final.

SELECT
	customer_id,
    city,
	TRIM(UPPER(city))AS city_cleaned
FROM customers_orders;

# Ejercicio  3
# Algunos valores en order_date están como texto (usa / o -). Convierte order_date a tipo DATE en una nueva columna order_date_clean.

SELECT
	CAST(order_date AS DATE) AS clean_date
FROM customers_orders;

# Ejercicio 4
# Clasifica a los clientes según su gasto (amount) en una nueva columna spending_category

SELECT
	CASE
		WHEN amount < 200 THEN "Low"
        WHEN amount BETWEEN 200 AND 500 THEN "Medium"
        WHEN amount > 500 THEN "High"
	END AS spending_category
FROM customers_orders;

# Ejercicio 5
# Crea una nueva columna clean_phone eliminando paréntesis, guiones y espacios de phone_number.

SELECT
	customer_id,
    phone_number AS original_phone,
    REPLACE(
		REPLACE(
			REPLACE(
				REPLACE(TRIM(phone_number), '(',''),
			')',''),
		'-',''),
	' ','') AS clean_phone
FROM customers_orders;