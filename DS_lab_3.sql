




--lab 3 revison---------
--===========================================

CREATE TYPE riv3_address_t AS OBJECT(
 streetno INTEGER,
 streetname VARCHAR(10),
 suburb VARCHAR(10),
 state VARCHAR(10),
 pin CHAR(4)
);
/

CREATE TYPE exchange_array AS VARRAY(3) OF VARCHAR2(10);
/


CREATE TYPE riv3_stock_t AS OBJECT(
 company VARCHAR(10),
 curr_price FLOAT,
 exchanges EXCHANGE_ARRAY,
 last_dividend FLOAT,
 EPS FLOAT
)

CREATE TYPE riv3_investment_t AS OBJECT(
 company REF riv3_stock_t,
 purchase_price FLOAT,
 invested_date DATE,
 qty NUMBER
)

CREATE TYPE riv3_investments AS TABLE OF riv3_investment_t;
/

CREATE TYPE riv3_client_t AS OBJECT(
 firstname VARCHAR(10),
 lastname VARCHAR(10),
 address RIV3_ADDRESS_T,
 investments RIV3_INVESTMENTS
)


CREATE TABLE riv3_stocks OF riv3_stock_t(
 company PRIMARY KEY
);
/


CREATE TABLE riv3_clients OF riv3_client_t(
 PRIMARY KEY(firstname, lastname)
) NESTED TABLE investments STORE AS investments_table;
/

select * from riv3_stocks



--insert data into `stocks` table
INSERT INTO riv3_stocks VALUES (riv3_stock_t('BHP', 10.50, exchange_array('Sydney', 'New York'), 1.50, 3.20));
INSERT INTO riv3_stocks VALUES (riv3_stock_t('IBM', 70.00, exchange_array('London', 'New York', 'Tokyo'), 4.25, 10.00));
INSERT INTO riv3_stocks VALUES (riv3_stock_t('INTEL', 76.50, exchange_array('London', 'New York'), 5.00, 12.40));
INSERT INTO riv3_stocks VALUES (riv3_stock_t('FORD', 40.00, exchange_array('New York'), 2.00, 8.50));
INSERT INTO riv3_stocks VALUES (riv3_stock_t('GM', 60.00, exchange_array('New York'), 2.50, 9.20));
INSERT INTO riv3_stocks VALUES (riv3_stock_t('INFOSYS', 45.00, exchange_array('New York'), 3.00, 7.80));


INSERT INTO riv3_clients values(
 riv3_client_t('Yasitha', 'Ransilu',riv3_address_t(3,'East Av','Bentley','WA','6102'),riv3_investments(
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'BHP'), 12,TO_DATE('2001-10-02','YYYY-MM-DD'), 1000),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'BHP'), 10.5,TO_DATE('2002-06-08','YYYY-MM-DD'), 2000),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'IBM'), 58,TO_DATE('2000-02-12','YYYY-MM-DD'), 500),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'IBM'), 65,TO_DATE('2001-04-10','YYYY-MM-DD'), 1200),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'INFOSYS'), 64,TO_DATE('2001-08-11','YYYY-MM-DD'), 1000)
 )
 )
);
/


INSERT INTO riv3_clients values(
 riv3_client_t('Chamath', 'Yashohara',riv3_address_t(42,'Bent St','Perth','WA','6001'),riv3_investments(
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'INTEL'), 35,TO_DATE('2000-01-30','YYYY-MM-DD'), 300),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'INTEL'), 54,TO_DATE('2001-01-30','YYYY-MM-DD'), 400),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'INTEL'), 60,TO_DATE('2001-10-02','YYYY-MM-DD'), 200),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'FORD'), 40,TO_DATE('1999-10-05','YYYY-MM-DD'), 300),
  riv3_investment_t((SELECT REF(S) FROM riv3_stocks S WHERE S.COMPANY = 'GM'), 55.5,TO_DATE('2000-12-12','YYYY-MM-DD'), 500)
 )
 )
);
/


select * from riv3_clients;
select * from riv3_stocks;

select c.firstname, c.lastname, i.company.company COMPANY_NAME
from riv3_clients c, table(c.investments) i;
/


--a
select DISTINCT c.firstname, c.lastname, i.company.company COMPANY_NAME, i.company.curr_price CURRENT_PRICE, i.company.last_dividend LAST_DIVIDEND, i.company.EPS EARNINGS_PER_SHARE
from riv3_clients c, table(c.investments) i;
/


--b
select c.firstname, c.lastname, i.company STOCK_NAME, SUM(i.qty) TOTAL_SHARES, ROUND(SUM(i.purchase_price*i.qty)/SUM(i.qty),2) AVG_PURCHASE_PRICE
from riv3_clients c, table(c.investments) i
group by c.firstname, c.lastname, i.company;
/

--c
select i.company.company STOCK_NAME, c.firstname, c.lastname, SUM(i.qty) NUM_OF_SHARES, i.company.curr_price*SUM(i.qty) CURRENT_VALUE
from riv3_clients c, table(c.investments) i, table(i.company.exchanges) e
where e.COLUMN_VALUE = 'New York'
group by i.company.company, c.firstname, c.lastname,i.company.curr_price;
/

--d
select c.firstname, c.lastname, SUM(i.purchase_price*i.qty) TOTAL_PURCHASE_PRICE
from riv3_clients c, TABLE(c.investments) i
group by c.firstname, c.lastname;
/



--e
select c.firstname, c.lastname, SUM(i.company.curr_price*i.qty - i.purchase_price*i.qty) BOOK_PROFIT
from riv3_clients c, table(c.investments) i
group by c.firstname, c.lastname;
/


--4.


--inserting chamath's GM stocks to ransilu
INSERT INTO TABLE(
  SELECT c.investments
  FROM riv3_clients c
  WHERE c.lastname = 'Ransilu'
)
SELECT i.company,
       i.purchase_price,
       i.invested_date,
       i.qty
FROM riv3_clients c,
     TABLE(c.investments) i
WHERE c.firstname = 'Chamath'
  AND DEREF(i.company).company = 'GM';

--deleting GM stocks from chamath
DELETE FROM TABLE(
 SELECT c.investments
 FROM riv3_clients c
 WHERE c.firstname = 'Chamath'
)
WHERE DEREF(company).company = 'GM';
/


--inserting infosys to chamath
INSERT INTO TABLE(
 SELECT c.investments
 FROM riv3_clients c
 WHERE c.firstname = 'Chamath'
)
SELECT i.company,
       i.purchase_price,
       i.invested_date,
       i.qty
FROM riv3_clients c, table(c.investments) i
WHERE DEREF(company).company = 'INFOSYS';
/

DELETE FROM TABLE(
 SELECT c.investments
 FROM riv3_clients c
 WHERE c.firstname = 'Yasitha'
)
WHERE DEREF(company).company = 'INFOSYS';
/



