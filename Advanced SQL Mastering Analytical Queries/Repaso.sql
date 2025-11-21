CREATE DATABASE globales;

USE globales;

#Crear Tabla Clientes
CREATE TABLE clientes(
	id_cliente INT PRIMARY KEY,
    nombre VARCHAR(50),
    pais VARCHAR(30),
    edad INT,
    fecha_registro DATE
);

#Crear Tabla Productos
CREATE TABLE productos(
	id_producto INT PRIMARY KEY,
    categoria VARCHAR(30),
    precio DECIMAL(10,2),
    costo DECIMAL(10,2)
);

#Crear Tabla ventas
CREATE TABLE ventas(
	id_venta INT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    fecha_venta DATE,
    cantidad INT,
    canal_venta VARCHAR(20),
    descuento DECIMAL(4,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

#Crear tabla de empleados
CREATE TABLE empleados(
	id_empleado VARCHAR(5) PRIMARY KEY,
    nombre_empleado VARCHAR(50),
    pais VARCHAR(30),
    cargo VARCHAR(40),
    fecha_ingreos DATE
);

INSERT INTO clientes VALUES
(1, 'Ana Torres', 'México', 28, '2021-06-15'),
(2, 'Juan Pérez', 'México', 35, '2022-02-20'),
(3, 'Laura Gómez', 'España', 42, '2020-11-03'),
(4, 'Pedro Ruiz', 'Chile', 31, '2021-04-10'),
(5, 'Marta López', 'México', 39, '2023-01-25'),
(6, 'Sofía Vega', 'Chile', 26, '2022-09-18'),
(7, 'Carlos Díaz', 'España', 33, '2023-03-10');

INSERT INTO productos VALUES
(101, 'Electrónica', 500, 300),
(102, 'Ropa', 80, 40),
(103, 'Hogar', 150, 90),
(104, 'Juguetes', 40, 15),
(105, 'Electrónica', 800, 600);

INSERT INTO ventas VALUES
(1001, 1, 101, '2023-01-15', 2, 'Online', 0.05),
(1002, 2, 103, '2023-02-10', 1, 'Tienda', 0.10),
(1003, 3, 105, '2023-03-22', 3, 'Online', 0.00),
(1004, 1, 102, '2023-04-05', 5, 'Online', 0.15),
(1005, 4, 104, '2023-05-18', 4, 'Tienda', 0.10),
(1006, 2, 101, '2023-07-25', 1, 'Online', 0.00),
(1007, 5, 103, '2023-09-10', 2, 'Tienda', 0.05),
(1008, 6, 105, '2023-10-12', 1, 'Online', 0.00),
(1009, 7, 101, '2023-11-02', 1, 'Tienda', 0.20),
(1010, 3, 102, '2023-11-20', 3, 'Online', 0.05);

INSERT INTO empleados VALUES
('E01', 'Luis Ramírez', 'México', 'Ejecutivo ventas', '2020-08-15'),
('E02', 'María Santos', 'Chile', 'Gerente regional', '2019-10-10'),
('E03', 'Pablo Ortega', 'España', 'Ejecutivo ventas', '2021-02-01');

#Ejercicio 1
# Muestra el país y la categoría de producto donde las ventas totales superen los 1000 USD, considerando solo ventas después de 2023-01-01.
# Ordena los resultados de mayor a menor total y muestra solo las categorías con más de 3 clientes distintos.

SELECT
  c.pais,
  p.categoria,
  ROUND(SUM(p.precio*v.cantidad*(1 - v.descuento)),2) AS ventas_totales,
  COUNT(DISTINCT v.id_cliente) AS clientes_un
FROM ventas v
JOIN productos p ON v.id_producto = p.id_producto
JOIN clientes c  ON c.id_cliente = v.id_cliente
WHERE v.fecha_venta > '2023-01-01'
GROUP BY c.pais, p.categoria
HAVING ventas_totales > 1000
   AND clientes_un >= 2
ORDER BY ventas_totales DESC;


#Ejercicio 2
#Muestra los clientes que han realizado compras mayores al precio promedio de todos los productos de su país.
#Considera solo clientes con más de 5 compras totales.

SELECT 
	c.nombre,
    c.pais,
    COUNT(v.id_venta) AS total_compras,
    MAX(p.precio) AS precio_max
FROM ventas v
JOIN clientes c ON c.id_cliente = v.id_cliente
JOIN productos p ON p.id_producto = v.id_producto
GROUP BY c.id_cliente, c.nombre, c.pais
HAVING MAX(p.precio) > ALL (
    SELECT AVG(p2.precio)
    FROM ventas v2
    JOIN clientes c2 ON v2.id_cliente = c2.id_cliente
    JOIN productos p2 ON v2.id_producto = p2.id_producto
    WHERE c2.pais = c.pais
)
AND COUNT(v.id_venta) > 1
ORDER BY precio_max DESC;

# Ejercicio 3
#Utilizando un CTE, calcula el total mensual de ventas por cliente y luego usa una función ventana para obtener:
#La diferencia de ventas respecto al mes anterior (LAG),
#El crecimiento porcentual, y
#El rango de ventas dentro de su país (RANK OVER PARTITION BY país ORDER BY ventas_totales DESC).

WITH ventas_mensuales AS (
	SELECT
		c.id_cliente,
        c.nombre,
        c.pais,
        DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
        ROUND(SUM(p.precio*v.cantidad*(1-v.descuento)),2) AS ventas_totales
	FROM ventas v
    JOIN clientes c ON c.id_cliente = v.id_cliente
    JOIN productos p ON p.id_producto = v.id_producto
    GROUP BY c.id_cliente, c.nombre, c.pais, mes
)
SELECT
	id_cliente,
    nombre,
    pais,
    mes,
    ventas_totales,
    LAG(ventas_totales) OVER (PARTITION BY id_cliente ORDER BY mes) AS ventas_previas,
    ROUND(
		(ventas_totales- LAG(ventas_totales) OVER (PARTITION BY id_cliente ORDER BY mes))
        /LAG(ventas_totales) OVER (PARTITION BY id_cliente ORDER BY mes) * 100,2
    ) AS crecimiento_pct,
    RANK() OVER (PARTITION BY pais ORDER BY ventas_totales DESC) AS ranking_pais
FROM ventas_mensuales
ORDER BY pais, id_cliente, mes;

# Ejercicio 4
#Lista los empleados que tienen al menos un cliente en su mismo país que haya comprado más de 10 000 USD en total.
#Usa EXISTS en lugar de JOIN directo para la validación.

SELECT
	e.id_empleado,
    e.nombre_empleado,
    e.pais,
    e.cargo
FROM empleados e
WHERE EXISTS(
	SELECT 1
    FROM clientes c
    JOIN ventas v ON v.id_cliente = c.id_cliente
    JOIN productos p ON p.id_producto = v.id_producto
    WHERE c.pais = e.pais
    GROUP BY c.id_cliente
    HAVING SUM(p.precio*v.cantidad * (1-v.descuento)) > 1000
);

#Ejercicio 5
#Crea una vista llamada vw_ventas_analiticas que contenga por cada cliente:
#id_cliente, país
#recencia (días desde la última compra),
#frecuencia (número de compras),
#monetario (suma total de ventas).
#Luego exporta esa vista a un DataFrame en Python para usarla en un modelo de clustering RFM.

CREATE OR REPLACE VIEW vw_ventas_analiticas AS
SELECT
	c.id_cliente,
    c.nombre,
    c.pais,
    COUNT(v.id_venta) AS frecuencia,
    ROUND(AVG(v.descuento),3) AS promedio_descuento,
    ROUND(SUM(p.precio*v.cantidad * (1-v.descuento)),2) AS monetario,
    DATEDIFF(CURDATE(),MAX(v.fecha_venta)) AS recencia_dias
FROM ventas v
JOIN clientes c ON c.id_cliente = v.id_cliente
JOIN productos p ON p.id_producto = v.id_producto
GROUP BY c.id_cliente, c.nombre, c.pais;