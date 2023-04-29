#SQL basics (selection and aggregation) 
USE bank;

/*Assume that any _id columns are incremental, meaning that higher ids always occur 
after lower ids. For example, a client with a higher client_id joined the bank after
a client with a lower client_id.*/

# 1. Get the id values of the first 5 clients from district_id with a value equals to 1.
SELECT client_id 
FROM client
WHERE district_id = 1
LIMIT 5;

/*2. In the client table, get an id value of the last client where the district_id 
equals to 72.*/
SELECT client_id 
FROM client
WHERE district_id = 72
ORDER BY client_id DESC
LIMIT 1;

# 3. Get the 3 lowest amounts in the loan table.
SELECT amount 
FROM loan
ORDER BY amount
LIMIT 3;

/*4. What are the possible values for status, ordered alphabetically in ascending 
order in the loan table?*/
SELECT DISTINCT(status)
FROM loan
ORDER BY status;

# 5. What is the loan_id of the highest payment received in the loan table?
SELECT loan_id
FROM loan
WHERE payments = (SELECT MAX(payments) FROM loan); 

SELECT loan_id, payments
FROM loan
ORDER BY payments DESC;
/*Está mal la respuesta en el readme.md del repositorio de Ironhack,ya que el 
pago que corresponde al loan_id = 6312, es de 304, y el pago más alto registrado
corresponde a un valor de 9910*/

/* 6. What is the loan amount of the lowest 5 account_ids in the loan table? 
Show the account_id and the corresponding amount*/
SELECT account_id, amount
FROM loan
ORDER BY account_id
LIMIT 5;

/* 7. What are the account_ids with the lowest loan amount that have a loan
duration of 60 in the loan table?*/
SELECT account_id
FROM loan
WHERE duration = 60
ORDER BY amount
LIMIT 5;

# 8. What are the unique values of k_symbol in the order table?
SELECT DISTINCT(k_symbol)
FROM `order`
ORDER BY k_symbol;

# 9. In the order table, what are the order_ids of the client with the account_id 34?
SELECT order_id
FROM `order`
WHERE account_id = 34;

/* 10. In the order table, which account_ids were responsible for orders between
order_id 29540 and order_id 29560 (inclusive)?*/
SELECT DISTINCT(account_id)
FROM `order`
WHERE order_id BETWEEN 29540 AND 29560;

/* 11. In the order table, what are the individual amounts that were sent to 
(account_to) id 30067122?*/
SELECT amount
FROM `order`
WHERE account_to = 30067122;

/* 12. In the trans table, show the trans_id, date, type and amount of the 
10 first transactions from account_id 793 in chronological order, from newest to oldest.*/
SELECT trans_id, `date`, `type`, amount
FROM trans
WHERE account_id = 793
ORDER BY `date` DESC;

/* 13. In the client table, of all districts with a district_id lower than 10, how many clients 
are from each district_id? Show the results sorted by the district_id in ascending order.*/
SELECT district_id, COUNT(client_id)
FROM `client`
WHERE district_id < 10
GROUP BY district_id
ORDER BY district_id;

/* 14. In the card table, how many cards exist for each type? 
Rank the result starting with the most frequent type*/
SELECT `type`, COUNT(card_id)
FROM card
GROUP BY `type`
ORDER BY COUNT(card_id) DESC;

/* 15. Using the loan table, print the top 10 account_ids based 
on the sum of all of their loan amounts.*/
SELECT account_id, SUM(amount) AS total_loan_amount
FROM loan
GROUP BY account_id
ORDER BY total_loan_amount DESC
LIMIT 10;

/* 16. In the loan table, retrieve the number of loans issued 
for each day, before (excl) 930907, ordered by date in descending order.*/
SELECT DATE_FORMAT(DATE(`date`), "%d/%m/%Y") AS `date`, COUNT(loan_id) AS num_loans
FROM loan 
WHERE `date` < 930907
GROUP BY `date`
ORDER BY `date` DESC;
/*En esta Query no se ordenan las fechas de manera correcta, ya que el date_format convierte
la columna de fecha en una cadena de texto, por lo que la ordenación se realiza por orden 
lexicográfico. Es decir, que el error se produce porque compara cada número de la fecha como
si fuera una cadena de caracteres independientes, y no como un valor numérico en conjunto. 
Para solucionar el error, se puede ordenar la columna original de fecha,sin convertirla a una 
cadena de texto, o se puede convertir a un formato que sea compatible con el ordenamiento 
lexicográfico, como "yyyy-mm-dd".*/

#RESPUESTA CORRECTA:
SELECT DATE(`date`) AS `date`, COUNT(loan_id) AS num_loans
FROM loan 
WHERE `date` < 930907
GROUP BY `date`
ORDER BY `date` DESC;

/* 17. In the loan table, for each day in December 1997, count the number of loans
 issued for each unique loan duration, ordered by date and duration, both in ascending 
 order. You can ignore days without any loans in your output.*/
SELECT DATE(`date`) AS `date`, duration, COUNT(loan_id) AS num_loans
FROM loan
WHERE YEAR(`date`) = 1997 AND MONTH(`date`) = 12
GROUP BY `date`, duration
ORDER BY `date` ASC, duration ASC;

/* 18. In the trans table, for account_id 396, sum the amount of transactions 
for each type (VYDAJ = Outgoing, PRIJEM = Incoming). 
Your output should have the account_id, the type and the sum of amount, 
named as total_amount. Sort alphabetically by type.*/
SELECT account_id, `type`, FORMAT(SUM(amount), 2) AS total_amount 
FROM trans
WHERE account_id = 396
GROUP BY `type`
ORDER BY `type`;

/* 19. From the previous output, translate the values for type to English, 
rename the column to transaction_type, round total_amount down to an integer*/
SELECT account_id,
	CASE
		WHEN `type` = 'PRIJEM' THEN 'INCOMING'
		WHEN `type` = 'VYDAJ' THEN 'OUTGOING'
	END AS transaction_type,
	FLOOR(SUM(amount)) AS total_amount
FROM trans
WHERE account_id = 396
GROUP BY `type`
ORDER BY `type`;

/* 20. From the previous result, modify your query so that it returns only 
one row, with a column for incoming amount, outgoing amount and the difference.*/
SELECT account_id,
	FLOOR(SUM(CASE WHEN `type` = 'PRIJEM' THEN amount ELSE 0 END)) AS Incoming_amount,
	FLOOR(SUM(CASE WHEN `type` = 'VYDAJ' THEN amount ELSE 0 END)) AS Outgoing_amount,
	FLOOR(SUM(CASE WHEN `type` = 'PRIJEM' THEN amount ELSE -amount END)) AS Difference
FROM trans
WHERE account_id = 396;

/* 21. Continuing with the previous example, rank the top 10 account_ids based on their difference.*/
SELECT account_id,
	FLOOR(SUM(CASE WHEN `type` = 'PRIJEM' THEN amount ELSE 0 END)) AS Incoming_amount,
	FLOOR(SUM(CASE WHEN `type` = 'VYDAJ' THEN amount ELSE 0 END)) AS Outgoing_amount,
	FLOOR(SUM(CASE WHEN `type` = 'PRIJEM' THEN amount ELSE -amount END)) AS Difference
FROM trans
GROUP BY account_id
ORDER BY Difference DESC;

SELECT account_id,
	FORMAT(SUM(CASE WHEN `type` = 'PRIJEM' THEN amount ELSE 0 END), 2) AS Incoming_amount,
	FORMAT(SUM(CASE WHEN `type` = 'VYDAJ' THEN amount ELSE 0 END), 2) AS Outgoing_amount,
	FORMAT(SUM(CASE WHEN `type` = 'PRIJEM' THEN amount ELSE -amount END), 2) AS Difference
FROM trans
GROUP BY account_id
ORDER BY Difference DESC;


