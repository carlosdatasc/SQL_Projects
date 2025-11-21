USE practice_sql;

CREATE TABLE customers_f(
	customer_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(20),
    city VARCHAR(20),
    signup_date DATE,
    acquisition_chanel VARCHAR (20)
);

INSERT INTO customers_f (customer_id,name,city,signup_date,acquisition_chanel) VALUES
("C001","Ana López","Mexico City","2024-12-10","Ads"),
("C002","Carlos Ruiz","Guadalajara","2025-01-05","Organic"),
("C003","María Pérez","Monterrey","2025-01-12","Referral"),
("C004","Juan García","Querétaro","2025-01-20","Ads"),
("C005","Luisa Torres","León","2025-02-02","Organic"),
("C006","Pedro Díaz","Puebla","2025-02-15","Referral"),
("C007","Sofía Ramírez","Toluca","2025-02-18","Ads"),
("C008","Diego Hernández","CDMX","2025-03-03","Organic");

CREATE TABLE product_f(
	product_id VARCHAR(5) PRIMARY KEY,
    product_name VARCHAR(20),
    category VARCHAR(20),
    list_price DECIMAL(4,2)
);

INSERT INTO product_f (product_id, product_name,category, list_price) VALUES
("P001","Plan Básico","Subscription",9.99),
("P002","Plan Pro","Subscription",19.99),
("P003","Plan Empresa","Subscription",49.00),
("P004","Soporte Premium","Service",15.00),
("P005","Onboarding Express","Service",29.00),
("P006","Add-on Analítica","AddOn",9.00);

CREATE TABLE orders(
	order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_date DATE,
    order_chanel VARCHAR(20)
);

INSERT INTO orders (order_id, customer_id,order_date,order_chanel) VALUES
("O001","C001","2025-01-10","Web"),
("O002","C002","2025-01-15","Web"),
("O003","C003","2025-01-20","App"),
("O004","C001","2025-01-28","Web"),
("O005","C004","2025-02-02","Store"),
("O006","C005","2025-02-05","Web"),
("O007","C002","2025-02-09","App"),
("O008","C003","2025-02-12","Web"),
("O009","C006","2025-02-18","Web"),
("O010","C007","2025-02-25","App"),
("O011","C001","2025-03-01","Web"),
("O012","C005","2025-03-05","Store"),
("O013","C006","2025-03-10","Web"),
("O014","C008","2025-03-12","Web"),
("O015","C002","2025-03-20","App"),
("O016","C003","2025-03-28","Web");

CREATE TABLE order_items_f (
	order_id VARCHAR(5),
    product_id VARCHAR(5),
    quantity INT,
	unit_price DECIMAL(4,2)
);	

INSERT INTO order_items_f(order_id,product_id,quantity,unit_price) VALUES
("O001","P001",1,9.99),
("O002","P002",1,19.99),
("O003","P002",1,19.99),
("O004","P004",1,15.00),
("O004","P006",1,9.00),
("O005","P003",1,49.00),
("O006","P001",1,9.99),
("O007","P006",2,9.00),
("O008","P002",1,19.99),
("O009","P001",1,9.99),
("O009","P006",1,9.00),
("O010","P005",1,29.00),
("O011","P002",1,19.99),
("O011","P006",1,9.00),
("O012","P004",2,15.00),
("O013","P003",1,49.00),
("O014","P001",1,9.99),
("O014","P006",2,9.00),
("O015","P002",1,19.99),
("O016","P003",1,49.00);

# Ejercicio 1
#Crea un CTE recent_orders que tome pedidos entre 2025-03-02 y 2025-03-31.
#Une recent_orders → order_items → products.
#Calcula ingreso (quantity*unit_price) y agrega por order_channel y category.
#Ordena de mayor a menor ingreso.

WITH recent_orders AS(
	SELECT
		o.order_id,
        o.customer_id,
        o.order_date,
        o.order_chanel
	FROM orders o
    WHERE o.order_date BETWEEN DATE("2025-03-02") AND DATE("2025-03-11")
),
order_lines AS(
	SELECT
		ro.order_id,
        ro.order_chanel,
        p.category,
        (oi.quantity * oi.unit_price) AS line_revenue
	FROM recent_orders ro
    JOIN order_items_f oi ON ro.order_id = oi.order_id 
    JOIN product_f p ON	p.product_id = oi.product_id
)
SELECT
	order_chanel,
    category,
    ROUND(SUM(line_revenue),2) AS revenue_30d
FROM order_lines
GROUP BY order_chanel,category
ORDER BY revenue_30d DESC;

# Ejercicio 2
#Deriva el mes (YYYY-MM) desde order_date.
#Suma el total por cliente y mes.
#Aplica RANK() OVER(PARTITION BY mes ORDER BY total DESC) para obtener el ranking.
#Con ventanas, calcula cumulativo y % respecto al total del mes (cumulativo/total_mes).

WITH item_lines AS(
	SELECT
		o.customer_id,
        DATE_fORMAT(o.order_date, '%Y-%m') AS month_key,
        (oi.quantity * oi.unit_price) AS line_revenue
	FROM orders o
    JOIN order_items_f	oi ON o.order_id = oi.order_id
),
customer_month AS (
	SELECT
		customer_id,
        month_key,
        ROUND(SUM(line_revenue),2) AS total
	FROM item_lines
	GROUP BY month_key,customer_id
),
Ranked AS(
	SELECT
		month_key,
        customer_id,
        total,
        RANK() OVER (PARTITION BY month_key ORDER BY total DESC) AS rank_month,
        # Acumulado descendente dentro del mes
        SUM(total) OVER (PARTITION BY month_key ORDER BY total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
        # Total del mes para %
        SUM(total) OVER (PARTITION BY month_key) AS total_month
	FROM customer_month
)
SELECT
	month_key,
    customer_id,
    total,
    rank_month,
    ROUND(cum_revenue,2) AS cum_revenue,
    ROUND(100*cum_revenue/total_month,2) AS pct_cum_month
FROM Ranked
ORDER BY 1,4,2;

#Ejercicio 3
#CTE customer_orders con last_order_date, order_count, total_spent.
#Calcula recency_days = DATEDIFF('2025-03-31', last_order_date) (usa la función equivalente en tu motor).
#Crea un score binario:
#R=1 si recency_days ≤ 30, si no 0.
#F=1 si order_count ≥ 2, si no 0.
#M=1 si total_spent ≥ 40, si no 0.
#Segmento final con CASE (ejemplos):
#Champion si R=1 AND F=1
#Loyal si R=0 AND F=1
#Promising si R=1 AND F=0
#At Risk si R=0 AND F=0

WITH order_total AS(
	SELECT 
		oi.order_id,
		SUM(oi.quantity*oi.unit_price) AS order_total
	FROM order_items_f oi
    GROUP BY oi.order_id
),
customer_orders AS (
	SELECT
		o.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(*) AS order_count,
        ROUND(SUM(ot.order_total),2) AS total_spent
	FROM orders o
    JOIN order_total ot ON ot.order_id = o.order_id
    GROUP BY o.customer_id
),
scored AS (
	SELECT
		co. *,
        DATEDIFF(DATE('2025-03-31'), co.last_order_date) AS recency_days
	FROM customer_orders co
)
SELECT
	s.customer_id,
    s.recency_days,
    s.order_count,
    s.total_spent,
    CASE 
		WHEN s.recency_days <=30 AND s.order_count >=2 THEN "Champion"
		WHEN s.recency_days > 30 AND s.order_count >=2 THEN "Loyal"
        WHEN s.recency_days <=30 AND s.order_count < 2 THEN "Promising"
        ELSE "At Risk"
	END AS segment
FROM scored s
ORDER BY s.customer_id;

#Ejercicio 4
#CTE first_purchase con first_month por cliente.
#Une con pedidos y obtén order_month.
#Para cada first_month, calcula:
#Clientes de cohorte (distintos)
#% que compran otra vez en first_month mismo o +1 (siguiente mes).

WITH order_totals AS(
	SELECT
		o.order_id,
        o.customer_id,
        o.order_date,
        DATE_FORMAT(o.order_date, '%Y.%m') AS order_month
	FROM orders o
),
first_purchase AS(
	SELECT
		customer_id,
        MIN(order_date) AS first_order_date,
        DATE_FORMAT(order_date, '%Y-%m') AS first_month
	FROM order_totals
    GROUP BY customer_id
),
joined AS(
	SELECT
		ot.customer_id,
        ot.order_month,
        fp.first_month,
        DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(fp.first_month,'-01'),'%Y-%m-%d'),INTERVAL 1 MONTH),'%Y-%m') AS plus1
	FROM order_totals ot
    JOIN first_purchase fp USING(customer_id)
),
same_month_flag AS (
	SELECT
		first_month,
        customer_id,
        SUM(order_month = first_month) AS cnt_same_month,
        MAX(order_month = plus1) AS has_plus1
	FROM joined
    GROUP BY first_month, customer_id
)
SELECT
	first_month,
    COUNT(*) AS cohorte_size,
    SUM(cnt_same_month >=2) AS repeat_in_same_month,
    SUM(has_plus1) AS repeat_in_plus1,
    ROUND(SUM(has_plus1)/COUNT(*),2) AS repeat_rate_plus1
FROM same_month_flag
GROUP BY first_month
ORDER BY first_month;

# Ejercicio 5
#Suma ingreso por product_id.
#Calcula % acumulado sobre el total (ventana ordenada DESC por ingreso).
#Etiqueta:
#A: hasta 70%
#B: 70–90%
#C: >90%


#Ejercicio 6
#A partir de customer_orders (ej. del ejercicio 3), filtra recency_days > 45.
#Añade acquisition_channel para pensar en acciones específicas (email, promo, etc.).