USE practice_sql;

CREATE TABLE ventas_supermercado (
    id_venta INT,
    cliente VARCHAR(50),
    sucursal VARCHAR(50),
    fecha DATE,
    producto VARCHAR(50),
    cantidad INT,
    total DECIMAL(10,2)
);

DROP TABLE ventas_supermercado;

# Ejercicio 1
# Muestra todas las ventas de clientes que han comprado el producto 'Leche'.
SELECT
	*
FROM ventas_sup
WHERE cliente IN(
	SELECT distinct cliente
    FROM ventas_sup
    WHERE producto = 'Leche');
    
# Ejercicio 2
# Obtén los nombres de los clientes que tienen al menos una compra en la sucursal “Norte”.
SELECT distinct v1.cliente
FROM ventas_sup v1
WHERE EXISTS(
	SELECT 1
    FROM ventas_sup v2
	WHERE v2.cliente =v1.cliente
		AND v2.sucursal = 'Norte'
);


# Ejercicio 3
#Encuentra las ventas cuyo total sea mayor que el total de alguna venta hecha por “Luis” (ANY).

SELECT
	id_venta,
    cliente,
    total
FROM ventas_sup
WHERE total> ANY(
	SELECT total
    FROM ventas_sup
    WHERE cliente= 'Luis'
);

# Luego encuentra las ventas cuyo total sea mayor que el total de todas las ventas de “Luis” (ALL).
SELECT id_venta,cliente,total
FROM ventas_sup
WHERE total> ALL(
	SELECT total
    FROM ventas_sup
    WHERE cliente = 'Luis'
);

#Ejercicio 4
#Crea una CTE que calcule el total gastado por cada cliente.
# Luego selecciona solo los clientes con un gasto total mayor a 150.

WITH gasto_cliente AS(
	SELECT cliente, SUM(total) AS total_cliente
    FROM ventas_sup
    GROUP BY cliente
)
SELECT 
	*
FROM gasto_cliente
WHERE total_cliente>150;

# Ejercicio 5
#Imagina que la sucursal “Norte” supervisa a “Centro” y esta a “Sur”.
#Crea una CTE recursiva que muestre las sucursales en orden jerárquico: Norte → Centro → Sur.

WITH RECURSIVE jerarquia AS (
  SELECT 'Centro' AS sucursal, 0 AS nivel
  UNION ALL
  SELECT CASE WHEN sucursal = 'Centro' THEN 'Sur'
              WHEN sucursal = 'Sur'    THEN 'Sur'
              ELSE 'Norte' END,
         nivel + 1
  FROM jerarquia
  WHERE sucursal <> 'Sur'
)
SELECT * FROM jerarquia;
