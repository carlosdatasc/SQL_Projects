USE practice_sql;

CREATE TABLE data_sales (
	CompraID INT PRIMARY KEY,
	CustomerID VARCHAR(20),
    InvoiceID VARCHAR(20),
    InvoiceDate DATE,
    Amount INT
);

INSERT INTO data_sales (CompraID,CustomerID, InvoiceID, InvoiceDate, Amount) VALUES
(1,"C001",	"INV001",	"2024-01-10",	120),
(2,"C002",	"INV002",	"2024-01-11",	250),
(3,"C001",	"INV003",	"2024-02-10",	80),
(4,"C003",	"INV004",	"2024-02-12",	300),
(5,"C002",	"INV005",	"2024-03-01",	200),
(6,"C001",	"INV006",	"2024-03-15",	50),
(7,"C004",	"INV007",	"2024-03-22",	400),
(8,"C002",	"INV008",	"2024-04-05",	150),
(9,"C003",	"INV009",	"2024-04-10",	100),
(10,"C004",	"INV010",	"2024-04-20",	350);

# Ejercicio 1
# Agrupa los registros por CustomerID y calcula:
# el número de facturas (COUNT(InvoiceID)),
# la suma total (SUM(TotalAmount)).

SELECT
	CustomerID,
	COUNT(InvoiceID) AS facturas,
    SUM(Amount) AS suma_total
FROM data_sales
GROUP BY CustomerID;

# Ejercicio 2
# Supón que hoy es '2024-05-01'.
# Calcula, por cada cliente, cuántos días han pasado desde su última compra.

SELECT
	CustomerId,
	MAX(InvoiceDate) AS last_purchase,
    DATEDIFF('2024-05-01', MAX(InvoiceDate)) AS RecencyDays
FROM data_sales
GROUP BY CustomerId;


#Ejercicio 3
#Crea una consulta que devuelva para cada cliente:
# Número total de compras (F),
# Monto total gastado (M),
# Promedio por compra (extra).

SELECT 
	CustomerID,
    COUNT(DISTINCT InvoiceID) AS Frequency,
    SUM(Amount) AS Monetary,
    AVG(Amount) AS AvgPurchase
FROM data_Sales
GROUP BY CustomerID;


# Ejercicio 4
#Usa un CTE o subconsulta para unir las tres métricas (Recency, Frequency, Monetary).
#Ordena a los clientes de mejor a peor según:
#Recency ascendente (menor = mejor),
#Frequency descendente,
#Monetary descendente.

WITH RFM AS(
	SELECT
		CustomerID,
        DATEDIFF('2024-05-01',MAX(InvoiceDate)) AS Recency,
        COUNT(DISTINCT InvoiceID) AS Frequency,
        SUM(Amount) AS Monetary
	FROM data_sales
    GROUP BY CustomerID
)
SELECT
	*
FROM RFM
ORDER BY Recency ASC, Frequency DESC, Monetary desc;

# Ejercicio 5
# Usa condiciones lógicas (CASE WHEN) para clasificar clientes según sus métricas RFM:

WITH RFM AS(
	SELECT
		CustomerID,
        DATEDIFF('2024-05-01',MAX(InvoiceDate)) AS Recency,
        COUNT(DISTINCT InvoiceID) AS Frequency,
        SUM(Amount) AS Monetary
	FROM data_sales
    GROUP BY CustomerID
)
SELECT
	*,
    CASE
		WHEN Recency <= 30 AND Frequency >= AND Monetary >=300 THEN 'VIP'
        WHEN Recency <=60 AND Frequency BETWEEN 1 AND 2 THEN 'New Customer'
        WHEN Recency > 60 AND Frequency <=1 THEN 'Lost'
        ELSE 'Regular'
	END AS Segment
FROM RFM;