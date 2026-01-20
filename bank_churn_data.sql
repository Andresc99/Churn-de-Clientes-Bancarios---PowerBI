ALTER TABLE bank_churn_data 
ADD Surname VARCHAR(45),
ADD CreditScore INT,
ADD Geography VARCHAR (45),
ADD Gender VARCHAR(10),
ADD Age INT,
ADD Tenure INT,
ADD Balance FLOAT,
ADD NumOfProducts INT,
ADD HasCrCard INT,
ADD IsActiveMember INT,
ADD EstimatedSalary FLOAT,
ADD Exited INT;

---

LOAD DATA LOCAL INFILE 'C:/Users/ACER-PC/Downloads/Bank+Customer+Churn/Bank_Churn.csv'
INTO TABLE bank_churn_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

---

-- Perfil Demografico --


SELECT Exited, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_comportamiento_abandono
FROM bank_churn_data
GROUP BY Exited;
/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

SELECT Exited, Geography, ROUND(COUNT(Geography) * 100.0 / SUM(COUNT(Geography)) OVER(PARTITION BY Geography), 2)  AS tasa_abandono_pais
FROM bank_churn_data
GROUP BY Exited, Geography
ORDER BY Exited, tasa_abandono_pais DESC;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

WITH Segmentacion_de_Clientes_Año AS (
SELECT Exited,
CASE
	WHEN Age BETWEEN 18 AND 25 THEN 'Joven Entre 18-25 Años'
    WHEN Age BETWEEN 26 AND 45 THEN 'Adulto Joven'
    WHEN Age > 45 THEN 'Adulto Mayor'
    END AS Seg_Age
FROM bank_churn_data)

SELECT Exited, Seg_Age, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM Segmentacion_de_Clientes_Año
GROUP BY Exited, Seg_Age;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

SELECT Exited, Gender, COUNT(Gender) *100.0 / SUM(COUNT(Gender)) OVER(PARTITION BY Gender) AS pct
FROM bank_churn_data
GROUP BY Exited, Gender
ORDER BY Exited, Gender DESC;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Perfil Creditcio Usuario -- 
WITH Segmentacion_atributos AS (
SELECT Geography, Exited, IsActiveMember, HasCrCard, Gender, Balance, EstimatedSalary, CreditScore,
CASE
	WHEN Tenure BETWEEN 0 AND 3 THEN 'Cliente Nuevo'
    WHEN Tenure BETWEEN 4 AND 5 THEN 'Cliente Antiguo'
    WHEN Tenure > 5 THEN 'Cliente Muy Antiguo'
    END AS Seg_Tenure,
CASE
	WHEN NumOfProducts = 1 THEN '1 Producto'
    WHEN NumOfProducts > 1 AND NumOfProducts < 3 THEN '2 Productos'
    WHEN NumOfProducts >= 3 THEN 'Mas de 3 Productos'
    END AS NumProducts,
CASE
	WHEN Age BETWEEN 18 AND 25 THEN 'Joven Entre 18-25 Años'
    WHEN Age BETWEEN 26 AND 45 THEN 'Adulto Joven'
    WHEN Age > 45 THEN 'Adulto Mayor'
    END AS Seg_Age
FROM bank_churn_data)

SELECT 
	NumProducts,
	CEIL(AVG(CreditScore)) AS Promedio_ScorCrediticio,
	ROUND(AVG(Balance), 2) AS Promedio_balance, 
    ROUND(AVG(EstimatedSalary),2) AS Promedio_salario
    
FROM Segmentacion_atributos
GROUP BY NumProducts
ORDER BY NumProducts;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

WITH Segmentacion_de_Clientes_Permanencia AS (
SELECT Exited,
CASE
	WHEN Tenure BETWEEN 0 AND 3 THEN 'Cliente Nuevo'
    WHEN Tenure BETWEEN 4 AND 5 THEN 'Cliente Antiguo'
    WHEN Tenure > 5 THEN 'Cliente Muy Antiguo'
    END AS Seg_Tenure
FROM bank_churn_data)

SELECT Exited, Seg_Tenure, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM Segmentacion_de_Clientes_Permanencia
GROUP BY Exited, Seg_tenure
ORDER BY Exited;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

WITH Segmentacion_de_Clientes_Producto AS (
SELECT Exited,
CASE
	WHEN NumOfProducts = 1 THEN '1 Producto'
    WHEN NumOfProducts > 1 AND NumOfProducts < 3 THEN '2 Productos'
    WHEN NumOfProducts >= 3 THEN 'Mas de 3 Productos'
    END AS NumProducts
FROM bank_churn_data)

SELECT NumProducts, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM Segmentacion_de_Clientes_Producto
GROUP BY NumProducts;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

SELECT Exited, IsActiveMember, COUNT(IsActiveMember) AS cnt,
ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Exited), 2) as pct
FROM bank_churn_data
GROUP BY Exited, IsActiveMember
ORDER BY cnt DESC;

SELECT Exited, ROUND(AVG(Estimatedsalary), 2) AS Promedio_salario
FROM bank_churn_data
GROUP BY Exited;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/

CALL bank; -- (1) SI; (0) NO


