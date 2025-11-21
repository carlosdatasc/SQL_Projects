USE practice_sql;

CREATE TABLE wednesday1(
	id_venta INT PRIMARY KEY,
    id_cliente VARCHAR(5),
    ciudad VARCHAR(20),
    genero VARCHAR(10),
    monto INT,
    fecha_venta DATE
);

CREATE TABLE wednesday2(
	id_cliente VARCHAR(5),
    edad INT,
    ingresos INT
);

INSERT INTO wednesday1 (id_venta,id_cliente,ciudad,genero,monto,fecha_venta) VALUES
(1,	"101",	"CDMX",	"Hombre",	500,	"2024-01-05"),
(2,	"102",	"Monterrey",	"Mujer",	700,	"2024-01-10"),
(3,	"103",	"CDMX",	"Mujer",	300,	"2024-02-03"),
(4,	"104",	"Guadalajara",	"Hombre",	900,	"2024-02-15"),
(5,	"105",	"Monterrey",	"Hombre",	200,	"2024-03-01"),
(6,	"101",	"CDMX",	"Hombre",	800,	"2024-03-20");

INSERT INTO wednesday2 (id_cliente,edad,ingresos) VALUES
("101",	34,	20000),
("102",	29,	15000),
("103",	42,	25000),
("104",	37,	18000),
("105",	23,	12000);

# Ejercicio 1
# Normaliza la columna monto de la tabla ventas_clientes entre 0 y 1

SELECT
	id_venta,
    monto,
    ROUND(
		(monto-MIN(monto) OVER()) /
        (MAX(monto) OVER()-MIN(monto) OVER()),2
	) AS monto_normalizado
FROM wednesday1;

# Ejercicio 2
# Crea variables dummies para la columna genero, de modo que obtengas dos nuevas columnas: is_Hombre y is_Mujer.

SELECT
	id_venta,
    genero,
	CASE WHEN genero = 'Hombre' THEN 1 ELSE 0 END AS is_hombre,
    CASE WHEN genero = 'Mujer' THEN 1 ELSE 0 END AS is_mujer
FROM wednesday1;

# Ejercicio 3
# Une las tablas ventas_clientes y clientes para incorporar la edad e ingresos mensuales de cada cliente.

SELECT
	v.id_cliente,
    v.id_venta,
    v.ciudad,
    v.monto,
    c.edad,
    c.ingresos
FROM wednesday1 v
JOIN wednesday2 c ON c.id_cliente = v.id_cliente;

# Ejercicio 4
# Crea una nueva columna mes_venta que extraiga el mes de la fecha de venta
# Otra ventas_por_cliente que calcule cuántas compras ha hecho cada cliente.

SELECT
	id_cliente,
    EXTRACT(MONTH FROM fecha_venta) AS mes_venta,
    COUNT(id_venta) OVER (PARTITION BY id_cliente) AS ventas_cliente
FROM wednesday1;

# Ejercicio 5
# Crea una vista llamada ventas_enriquecidas que combine:
# monto normalizado
# variables dummies de género
# datos de clientes (edad, ingresos)
# número total de ventas por cliente

CREATE VIEW  ventas_enriquecidas AS
SELECT
	v.id_venta,
    v.id_cliente,
    v.ciudad,
    ROUND(
		(monto-MIN(monto) OVER()) /
		(MAX(monto) OVER()-MIN(monto) OVER()),2
    ) AS monto_normalizado,
    CASE WHEN genero = 'Hombre' THEN 1 ELSE 0 END AS is_hombre,
    CASE WHEN genero = 'Mujer' THEN 1 ELSE 0 END AS is_mujer,
    c.edad,
    c.ingresos,
    COUNT(v.id_venta) OVER(PARTITION BY v.id_cliente) AS ventas_cliente
FROM wednesday1 v
JOIN wednesday2 c ON v.id_cliente = c.id_cliente;
