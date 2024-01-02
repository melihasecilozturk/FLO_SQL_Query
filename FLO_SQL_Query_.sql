--2. Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.
SELECT  
  COUNT(DISTINCT master_id) AS TOTAL_CUSTOMERS
FROM 
  CUSTOMERS

--3. Toplam yapılan alışveriş sayısı ve ciroyu getirecek sorguyu yazınız.

SELECT 
  SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOTAL_PURCHASE,
  SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOTAL_INCOME
FROM 
  CUSTOMERS

--4. Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.

ALTER TABLE 
  CUSTOMERS 
ADD 
  TOTAL_ORDER_NUM INT, 
  TOTAL_VALUE FLOAT

UPDATE CUSTOMERS
SET TOTAL_ORDER_NUM = order_num_total_ever_online + order_num_total_ever_offline

UPDATE CUSTOMERS
SET TOTAL_VALUE = customer_value_total_ever_offline + customer_value_total_ever_online




SELECT 
(SUM(TOTAL_VALUE)/SUM(TOTAL_ORDER_NUM)) AS AVG_INCOME
FROM 
  CUSTOMERS



--5. En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını getirecek sorguyu yazınız.

SELECT 
  LAST_ORDER_CHANNEL,
  SUM(TOTAL_VALUE) AS TOTAL_INCOME,
  SUM(TOTAL_ORDER_NUM) AS TOTAL_PURCHASE
FROM 
  CUSTOMERS
GROUP BY
  LAST_ORDER_CHANNEL


--6. Store type kırılımında elde edilen toplam ciroyu getiren sorguyu yazınız.

SELECT 
  STORE_TYPE,
  SUM(TOTAL_VALUE)
FROM
  CUSTOMERS
GROUP BY
  STORE_TYPE




—- BONUS - > Store type icerisindeki verilerin parse edilmis hali.

SELECT Value,SUM(TOPLAM_CIRO/COUNT_) FROM
(
SELECT store_type MAGAZATURU,(SELECT COUNT(VALUE) FROM  string_split(store_type,',') ) COUNT_,
       SUM(TOTAL_VALUE) TOPLAM_CIRO 
FROM CUSTOMERS 
GROUP BY store_type) T
CROSS APPLY (SELECT  VALUE  FROM  string_split(T.MAGAZATURU,',') ) D
GROUP BY Value




-- 7. Yıl kırılımında alışveriş sayılarını getirecek sorguyu yazınız (Yıl olarak müşterinin ilk alışveriş tarihi (first_order_date) yılını
-- baz alınız)

SELECT 
  YEAR(FIRST_ORDER_DATE) AS YEAR,
  SUM(TOTAL_ORDER_NUM) AS TOTAL_PURCHASE
FROM 
  CUSTOMERS
GROUP BY
  YEAR(FIRST_ORDER_DATE)


--8. En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.

SELECT 
  last_order_channel,
  (SUM(TOTAL_VALUE)/SUM(TOTAL_ORDER_NUM)) AS AVG_INCOME

FROM 
  CUSTOMERS
GROUP BY
  LAST_ORDER_CHANNEL


  --9. Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazınız.


-- hangi kategoriden kaç tane alınmış?
SELECT 
  interested_in_catagories_12,
  COUNT(*) AS TOTAL_PURCHASE
FROM 
  CUSTOMERS
GROUP BY
  interested_in_catagories_12
ORDER BY 
  2 DESC

-- en çok hangisinden alınmış 
SELECT TOP 1
  interested_in_catagories_12,
  COUNT(*) AS TOTAL_PURCHASE
FROM 
  CUSTOMERS
GROUP BY
  interested_in_catagories_12
ORDER BY 
  2 DESC


-- BONUS - > kategorilerin parse edilmis cozumu


SELECT K.VALUE,SUM(T.FREKANS_BILGISI/T.SAYI) FROM 
(SELECT 
(SELECT COUNT(VALUE) FROM string_split(interested_in_catagories_12,',')) SAYI,  
REPLACE(REPLACE(interested_in_catagories_12,']',''),'[','') KATEGORI, 
COUNT(*) FREKANS_BILGISI 
FROM CUSTOMERS
GROUP BY interested_in_catagories_12) T 

CROSS APPLY (SELECT * FROM string_split(KATEGORI,',')) K
GROUP BY K.value


--10. En çok tercih edilen store_type bilgisini getiren sorguyu yazınız.


-- hangi store typedan kaç tane var?
SELECT
  store_type,
  COUNT(*) AS TOTAL_PURCHASE
FROM 
  CUSTOMERS
GROUP BY
  store_type
ORDER BY 
  2 DESC

-- en çok hangisi tercih edilmiş 

SELECT TOP 1
  store_type,
  COUNT(*) AS TOTAL_PURCHASE
FROM 
  CUSTOMERS
GROUP BY
  store_type
ORDER BY 
  2 DESC


-- BONUS - > rownumber kullanilarak cozulmus hali

SELECT * FROM
(
SELECT    
ROW_NUMBER() OVER(  ORDER BY COUNT(*) DESC) ROWNR,
    store_type, 
    COUNT(*) FREKANS_BILGISI 
FROM CUSTOMERS
GROUP BY store_type 
)T 
WHERE ROWNR=1


--11. En son alışveriş yapılan kanal (last_order_channel) bazında, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlık alışveriş yapıldığını getiren sorguyu yazınız.

SELECT DISTINCT last_order_channel,
(
    SELECT top 1 interested_in_catagories_12
    FROM CUSTOMERS  WHERE last_order_channel=C.last_order_channel
    group by interested_in_catagories_12
    order by 
    SUM(TOTAL_ORDER_NUM) desc 
),
(
    SELECT top 1 SUM(TOTAL_ORDER_NUM)
    FROM CUSTOMERS  WHERE last_order_channel=C.last_order_channel
    group by interested_in_catagories_12
    order by 
    SUM(TOTAL_ORDER_NUM) desc 
)
FROM CUSTOMERS C



-- BONUS - > CROSS APPLY yontemi ile yapilmis cozum



SELECT DISTINCT last_order_channel,D.interested_in_catagories_12,D.TOPLAMSIPARIS
FROM CUSTOMERS C
CROSS APPLY 
(SELECT top 1 interested_in_catagories_12,SUM(TOTAL_ORDER_NUM) TOPLAMSIPARIS
    FROM CUSTOMERS  WHERE last_order_channel=C.last_order_channel
    group by interested_in_catagories_12
    order by 
    SUM(TOTAL_ORDER_NUM) desc ) D




-- 12. En çok alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız.

SELECT
  TOP 1
  MASTER_ID,
  TOTAL_ORDER_NUM
FROM 
  CUSTOMERS
ORDER BY
  TOTAL_ORDER_NUM DESC


-- veya alttaki, same shit


SELECT TOP 1 master_id              
    FROM CUSTOMERS 
    GROUP BY master_id 
ORDER BY  SUM(TOTAL_ORDER_NUM) DESC 


-- veya alttaki, row numberla yapılan

SELECT D.master_id
FROM 
    (SELECT master_id, 
           ROW_NUMBER() OVER(ORDER BY SUM(TOTAL_ORDER_NUM) DESC) RN
    FROM CUSTOMERS 
    GROUP BY master_id) AS D
WHERE RN = 1;


--13. En çok alışveriş yapan kişinin alışveriş başına ortalama cirosunu ve alışveriş yapma gün ortalamasını (alışveriş sıklığını)
-- getiren sorguyu yazınız.


-- CAST bir ifadeyi belirli bir veri tipine dönüştürmek istendiğinde kullanılır. Burda float a çevirdik.

SELECT
  TOP 1
  MASTER_ID,
  TOTAL_ORDER_NUM,
  TOTAL_VALUE,
  DATEDIFF(DAY, FIRST_ORDER_DATE, LAST_ORDER_DATE) AS TOTAL_DAY,
  (TOTAL_VALUE/TOTAL_ORDER_NUM) AS AVERAGE_INCOME,
  ROUND(CAST(DATEDIFF(DAY, FIRST_ORDER_DATE, LAST_ORDER_DATE) AS FLOAT)/TOTAL_ORDER_NUM, 2) AS PURCHASE_FREQUENCY
FROM 
  CUSTOMERS
ORDER BY
  TOTAL_ORDER_NUM DESC


--14. En çok alışveriş yapan (ciro bazında) ilk 100 kişinin alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.

SELECT 
  TOP 100
  MASTER_ID,TOTAL_VALUE,
  ROUND(CAST(DATEDIFF(DAY, FIRST_ORDER_DATE, LAST_ORDER_DATE) AS FLOAT)/TOTAL_ORDER_NUM, 2) AS PURCHASE_FREQUENCY
FROM 
  CUSTOMERS
ORDER BY
  2 DESC


  --15. En son alışveriş yapılan kanal (last_order_channel) kırılımında en çok alışveriş yapan müşteriyi getiren sorguyu yazınız.

SELECT TOP 1
   last_order_channel,
   TOTAL_ORDER_NUM,
   master_id

FROM 
   CUSTOMERS

ORDER BY 2 DESC 

  


--16. En son alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız. (Max son tarihte birden fazla alışveriş yapan ID bulunmakta. Bunları da getiriniz.)

SELECT master_id,last_order_date FROM CUSTOMERS
WHERE last_order_date=(SELECT MAX(last_order_date) FROM CUSTOMERS)
