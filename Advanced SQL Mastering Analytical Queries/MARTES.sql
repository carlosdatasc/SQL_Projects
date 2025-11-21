USE practice_sql;


CREATE TABLE ventas_supermercado (
  id_venta INT PRIMARY KEY,
  fecha DATE,
  tienda VARCHAR(10),
  producto VARCHAR(50),
  cliente VARCHAR(50),
  ventas DECIMAL(10,2)
);

INSERT INTO ventas_supermercado (id_venta, fecha, tienda, producto, cliente, ventas) VALUES
(1, '2024-01-01', 'A', 'Café', 'Ana', 10.5),
(2, '2024-01-02', 'A', 'Azúcar', 'Ana', 8.2),
(3, '2024-01-03', 'A', 'Pan', 'Luis', 5.0),
(4, '2024-01-01', 'B', 'Café', 'Ana', 11.0),
(5, '2024-01-02', 'B', 'Azúcar', 'Juan', 6.5),
(6, '2024-01-03', 'B', 'Pan', 'Juan', 5.2),
(7, '2024-01-04', 'B', 'Café', 'Ana', 12.0),
(8, '2024-01-04', 'A', 'Pan', 'Luis', 7.5);

#Ejercicio 1
#Compra más reciente de cada cliente
SELECT	
	*
FROM
	(SELECT
		cliente,
		producto,
		fecha,
		ventas,
		ROW_NUMBER() OVER (PARTITION BY cliente ORDER BY fecha DESC) AS rn
	FROM ventas_supermercado) AS sub
WHERE rn=1;

#Ejercicio 2
# Clasificar productos dentro de cada tienda según ventas totales

SELECT
	*
FROM(
	SELECT
		tienda,
        producto,
        SUM(ventas) AS total_ventas,
        RANK() OVER(PARTITION BY tienda ORDER BY SUM(ventas) DESC) AS posicion
	FROM ventas_supermercado
    GROUP BY tienda,producto
) AS ranking
WHERE posicion <=3;

#Ejercicio 3
# Analizar la evolución temporal fila a fila
SELECT
	tienda,
    fecha,
    SUM(ventas) AS ventas_dia,
    LAG(SUM(ventas)) OVER (PARTITION BY tienda ORDER BY fecha) AS anterior,
    (SUM(ventas)-LAG(SUM(ventas)) OVER (PARTITION BY tienda ORDER BY fecha)) AS diferencia
FROM ventas_supermercado
GROUP BY tienda, fecha
ORDER BY tienda, fecha;

# Ejercicio 4
# Ver cuando será la compra de cada cliente
SELECT
	cliente,
    fecha AS fecha_actual,
    LEAD(fecha) OVER (PARTITION BY cliente ORDER BY fecha) AS next,
    DATEDIFF(LEAD(fecha) OVER (PARTITION BY cliente ORDER BY fecha),fecha) AS Dif_dias
FROM ventas_supermercado
ORDER BY cliente,fecha;

# Ejercicio 5
# Mostrar cómo evolucionan las ventas en el tiempo dentro de cada tienda.

SELECT
	tienda,
    fecha,
    SUM(ventas) AS ventas_dia,
    SUM(SUM(ventas)) OVER(PARTITION BY tienda ORDER BY fecha) AS acumulado
FROM ventas_supermercado
GROUP BY tienda, fecha
ORDER BY tienda, fecha;

# Ejercicio 6
# Identificar los días dónde las ventas se duplican respecto al día anterior

WITH variaciones AS(
	SELECT
		tienda,
        fecha,
        SUM(ventas) AS ventas_dia,
        LAG(SUM(ventas)) OVER (PARTITION BY tienda ORDER BY fecha) AS ventas_previas
	FROM ventas_supermercado
    GROUP BY tienda, fecha
)
SELECT
	tienda,
    fecha,
    ventas_dia,
    ventas_previas,
    ROUND((ventas_dia-ventas_previas)/ ventas_previas*100,2) AS variacion_pct,
    RANK() OVER(PARTITION BY tienda ORDER BY (ventas_dia-ventas_previas)DESC) AS importancia
FROM variaciones
WHERE ventas_previas IS NOT NULL
	AND ventas_dia>= ventas_previas*2
ORDER BY tienda, fecha;