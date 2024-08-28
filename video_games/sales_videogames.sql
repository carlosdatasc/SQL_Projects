USE ejercicios_c;

DESCRIBE vgsales;

SELECT * FROM vgsales
LIMIT 10;


SELECT 
	Year,
    SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY 1
ORDER BY 2 ASC;

-- Ventas por año Aquí yo lo ordeno mejor por la sumatoria de las ventas por año.Podría deducir que los años en los que menos se venderían 
-- Videojuegos serían en los primero registros sin embargo encuentro que los primeros dos peores años han sido recientes
-- Por lo que me pregunto ¿Qué pasó esos años? Después hago una consulta especifica sobre esos años

SELECT
	Year,
    Platform,
    SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY 2
ORDER BY 1 ASC;

-- En esta Query se obtiene la relación de ventas por año. Podría obtener a su vez la evolución de las ventas por año por consola y saber 
-- Cuál ha sido la consola con mejor evolución y o la peor evolución

-- Analisis de juegos de videojuegos
SELECT 
	Genre,
    year,
    SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Genre
ORDER BY 2 DESC;
-- Al agregar el año puedo deducir si hubo algunas causas que pudieron haber determinado las ventas de cierto tipo de Videojuegos
-- Cómo por ejemplo en el 2006 el genero que más se vendio fue deporte, puede que haya sido debido al Mundial de Futbol

-- Venta de genero por plataforma
SELECT
	Platform,
	Genre,
    SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Platform, Genre
ORDER BY Platform, Total_Sales DESC;

-- Aquí se podría hacer un conteo de las consolas que más generos han tenido y agregando el año podríamos incluso ver cómo fue evolucionado

-- Top 10 Juego más vendidos
SELECT
	Name,
    SUM(Global_Sales) AS Total_Sales,
    year
FROM vgsales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Una gráfica lineal de cómo se gasta en videojuegos 

-- Detalles de los juegos más vendidos
-- Obtener detalles completos de los 10 juegos más vendidos
SELECT *
FROM vgsales
WHERE Name IN (
    SELECT Name
    FROM (
        SELECT Name
        FROM vgsales
        GROUP BY Name
        ORDER BY SUM(Global_Sales) DESC
        LIMIT 10
    ) AS Subquery
);

-- Con base en esta query puedo determinar cual es el mercado con mayor fuerza que más consume


-- Ventas por región
SELECT
	SUM(NA_Sales) AS NA_Sales_Total,
    SUM(EU_Sales) AS EU_Sales_Total,
    SUM(JP_Sales) AS JP_Sales_Total,
    SUM(Other_Sales) AS OT_Sales_Total
FROM vgsales;
-- Me gustó más mi idea

-- Juegos más vendidos por Región
SELECT
	*
FROM vgsales
ORDER BY NA_SALES DESC
LIMIT 10;

SELECT
	*
FROM vgsales
ORDER BY EU_SALES DESC
LIMIT 10;

SELECT
	*
FROM vgsales
ORDER BY JP_SALES DESC
LIMIT 10;
SELECT
	*
FROM vgsales
ORDER BY Other_SALES DESC
LIMIT 10;

-- Podría hacer una unión de estas tablas y poner un limite de 3 para cada uno y poder comparar los juegos
-- De igual manera quitaría los demás mercados si estoy usando usa sólo dejar la columna de Usa
