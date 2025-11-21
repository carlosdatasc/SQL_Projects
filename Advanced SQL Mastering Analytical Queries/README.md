SQL Advanced Practice — Weekly Exercises

This repository contains a complete set of SQL advanced practice exercises, designed to reinforce analytical thinking and the most important concepts for real-world data analysis.


🎯 Learning Objectives

This practice focuses on:

Advanced SELECT

INNER, LEFT, RIGHT JOIN

Aggregations with GROUP BY + HAVING

Subqueries with IN, EXISTS, ANY, ALL

CTEs (WITH) for reusable queries

Window functions:
ROW_NUMBER(), RANK(), LAG(), LEAD(),
OVER (PARTITION BY ... ORDER BY ...)

SQL + ML workflow: creating analytical views for export into Python

📦 Dataset Used

A synthetic database named ventas_globales with 4 tables:

clientes

productos

ventas

empleados

The dataset was designed to allow the practice of joins, aggregations, time analysis, and analytical transformations.

All tables and inserts are included in the file:

01_create_tables.sql

02_insert_data.sql

🧠 Exercises Included
1. JOIN + GROUP BY + HAVING

Analyze total sales by country and product category using multiple joins and group filters.

2. Subqueries with ANY / ALL / EXISTS

Identify customers whose purchases exceed the average product price in their country.

3. CTE + Window Functions

Calculate monthly sales, growth vs. previous month, and ranking per country using:
LAG, RANK, OVER (PARTITION BY ...).

4. EXISTS for Hierarchical Logic

Return employees who have customers in their country surpassing a defined sales threshold.

5. SQL + Machine Learning Integration

Create an analytical VIEW with Recency–Frequency–Monetary (RFM) features for export into Python.