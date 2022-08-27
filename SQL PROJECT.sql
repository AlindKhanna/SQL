use orders;
show tables;

#------QUERY 1----------------------------------------------#

select PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,
CASE
   WHEN PRODUCT_CLASS_CODE=2050 THEN PRODUCT_PRICE+2000
   WHEN PRODUCT_CLASS_CODE=2051 THEN PRODUCT_PRICE+500
   WHEN PRODUCT_CLASS_CODE=2052 THEN PRODUCT_PRICE+600
   ELSE PRODUCT_PRICE
END AS PRODUCT_PRICE_INCREMENT
FROM product ORDER BY PRODUCT_CLASS_CODE DESC;

#------QUERY 2----------------------------------------------#


select PRODUCT_CLASS_CODE,PRODUCT_QUANTITY_AVAIL,PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_DESC,
CASE
   WHEN PRODUCT_CLASS_DESC='Electronics'
   THEN
   CASE
   WHEN PRODUCT_QUANTITY_AVAIL <= 10 THEN "LOW STOCK"
   WHEN PRODUCT_QUANTITY_AVAIL >= 11 AND PRODUCT_QUANTITY_AVAIL <= 30 THEN "IN STOCK"
   WHEN  PRODUCT_QUANTITY_AVAIL >= 31 THEN "ENOUGH STOCK"
   END
   WHEN PRODUCT_CLASS_DESC='Computer'
   THEN
   CASE
   WHEN PRODUCT_QUANTITY_AVAIL <= 10 THEN "LOW STOCK"
   WHEN PRODUCT_QUANTITY_AVAIL >= 11 AND PRODUCT_QUANTITY_AVAIL <= 30 THEN "IN STOCK"
   WHEN  PRODUCT_QUANTITY_AVAIL >= 31 THEN "ENOUGH STOCK"
END
WHEN PRODUCT_CLASS_DESC='Stationery'
   THEN
   CASE
   WHEN PRODUCT_QUANTITY_AVAIL <= 20 THEN "LOW STOCK"
   WHEN PRODUCT_QUANTITY_AVAIL >= 21 AND PRODUCT_QUANTITY_AVAIL <= 80 THEN "IN STOCK"
   WHEN  PRODUCT_QUANTITY_AVAIL >= 81 THEN "ENOUGH STOCK"
END
WHEN PRODUCT_CLASS_DESC='Clothes'
   THEN
   CASE
   WHEN PRODUCT_QUANTITY_AVAIL <= 20 THEN "LOW STOCK"
   WHEN PRODUCT_QUANTITY_AVAIL >= 21 AND PRODUCT_QUANTITY_AVAIL <= 80 THEN "IN STOCK"
   WHEN  PRODUCT_QUANTITY_AVAIL >= 81 THEN "ENOUGH STOCK"
END
ELSE
CASE
   WHEN PRODUCT_QUANTITY_AVAIL <= 15 THEN "LOW STOCK"
   WHEN PRODUCT_QUANTITY_AVAIL >= 16 AND PRODUCT_QUANTITY_AVAIL <= 50 THEN "IN STOCK"
   WHEN  PRODUCT_QUANTITY_AVAIL >= 51 THEN "ENOUGH STOCK"
   END
END AS 'STOCK AVAILABILITY'
FROM product
INNER JOIN PRODUCT_CLASS
USING(PRODUCT_CLASS_CODE);

#------QUERY 3----------------------------------------------#

SELECT country,COUNT(CITY) FROM address 
GROUP BY COUNTRY HAVING COUNTRY NOT IN('USA','MALAYSIA') 
AND count(CITY) > 1 
ORDER BY COUNT(CITY) DESC;

#------QUERY 4----------------------------------------------#

select customer_id,CONCAT(customer_fname,customer_lname) as cname,city,pincode,ORDER_ID, PRODUCT_CLASS_DESC, product_desc,product_quantity,product_price,product_quantity*product_price as SUBTOTAL
FROM online_customer
INNER JOIN address USING(ADDRESS_ID)
LEFT JOIN order_header USING(CUSTOMER_ID)
LEFT JOIN order_items USING(ORDER_ID)
LEFT JOIN product USING(PRODUCT_ID)
LEFT JOIN product_class USING(PRODUCT_CLASS_CODE)
WHERE PINCODE NOT LIKE '%0%'
GROUP BY customer_id
order by SUBTOTAL;

#------QUERY 5----------------------------------------------#

use orders;
select ORDER_ITEMS.PRODUCT_ID,product.PRODUCT_DESC,SUM(ORDER_ITEMS.PRODUCT_QUANTITY) AS TQTY
FROM ORDER_ITEMS
INNER JOIN product ON product.PRODUCT_ID = ORDER_ITEMS.PRODUCT_ID
where ORDER_ITEMS.ORDER_ID in
(SELECT distinct order_id from order_items
where product_id=201
)
 and
 ORDER_ITEMS.PRODUCT_ID <> 201
group by ORDER_ITEMS.PRODUCT_ID
ORDER BY tqty DESC
LIMIT 1;

#------QUERY 6----------------------------------------------#

select customer_id,CONCAT(customer_fname,customer_lname) as cname,CUSTOMER_EMAIL,ORDER_ID, product_desc,product_quantity,product_price,product_quantity*product_price as SUBTOTAL
FROM online_customer
LEFT JOIN order_header USING(CUSTOMER_ID)
LEFT JOIN order_items USING(ORDER_ID)
LEFT JOIN product USING(PRODUCT_ID);

#------QUERY 7----------------------------------------------#

select CARTON_ID,LEN*WIDTH*HEIGHT as carton_vol from carton
where(LEN*WIDTH*HEIGHT) >=
(select SUM(LEN*WIDTH*HEIGHT*PRODUCT_QUANTITY) as totalvol 
from product
INNER JOIN order_items USING(PRODUCT_ID)
where ORDER_ID= 10006
)
LIMIT 1;

#------QUERY 8----------------------------------------------#

select customer_id,CONCAT(customer_fname,customer_lname) as cname,order_id,SUM(product_quantity) AS SUMP
from online_customer
LEFT JOIN order_header USING(customer_id)
LEFT JOIN order_items USING(ORDER_ID)
WHERE 
(PAYMENT_MODE = 'Credit Card' 
OR 
PAYMENT_MODE= 'Net Banking')
AND
ORDER_STATUS = 'Shipped'
GROUP BY customer_id
HAVING SUMP >= 10;

#------QUERY 9----------------------------------------------#
select customer_id,CONCAT(customer_fname,customer_lname) as cname,order_id,SUM(product_quantity)
from online_customer
INNER JOIN order_header USING(customer_id)
INNER JOIN order_items USING(ORDER_ID)
WHERE 
CONCAT(customer_fname,customer_lname) LIKE 'A%'
AND
ORDER_STATUS = 'Shipped'
GROUP BY ORDER_ID
HAVING ORDER_ID > 10030;

#------QUERY 10----------------------------------------------#

select PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC,SUM(product_quantity) as SPQ,SUM(product_quantity*PRODUCT_PRICE) as TValue
from online_customer
INNER JOIN address USING(ADDRESS_ID)
INNER JOIN order_header USING(CUSTOMER_ID)
INNER JOIN order_items USING(ORDER_ID)
INNER JOIN product USING(PRODUCT_ID)
INNER JOIN product_class USING(PRODUCT_CLASS_CODE)
WHERE 
ORDER_STATUS = 'Shipped'
AND
COUNTRY NOT IN('INDIA','USA')
GROUP BY PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC
order by SPQ DESC 
LIMIT 1