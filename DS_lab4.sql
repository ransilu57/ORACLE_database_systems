--===================================================
--lab4
ALTER TYPE riv3_stock_t
ADD MEMBER FUNCTION calc_yield RETURN NUMBER CASCADE;
/

DESC riv3_stock_t;
/

CREATE TYPE BODY riv3_stock_t AS
 MEMBER FUNCTION calc_yield
  RETURN NUMBER IS
   BEGIN
    IF curr_price = 0 THEN
     RETURN NULL;
    ELSE
     RETURN(SELF.last_dividend/SELF.curr_price)*100;
    END IF; ---closes the IF block
   END calc_yield; --closes the FUNCTION definition
  END; --closes the TYPE BODY
/



SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'RIV3_STOCK_T';

drop type body riv3_stock_t

select * from riv3_stocks;

SELECT s.company as STOCK_NAME, ROUND(s.calc_yield(),2) AS YIELD
FROM riv3_stocks s;



--1) b
ALTER TYPE riv3_stock_t
ADD MEMBER FUNCTION convert_to_USD(ex_rate IN NUMBER) RETURN NUMBER CASCADE;
/


CREATE OR REPLACE TYPE BODY riv3_stock_t AS

    MEMBER FUNCTION calc_yield RETURN NUMBER IS
    BEGIN
        IF curr_price = 0 THEN
            RETURN NULL;
        ELSE
            RETURN (SELF.last_dividend / SELF.curr_price) * 100;
        END IF;
    END calc_yield;

    MEMBER FUNCTION convert_to_USD(ex_rate IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN SELF.curr_price * ex_rate;
    END convert_to_USD;

END;
/


--c
desc riv3_stock_t

ALTER TYPE riv3_stock_t
ADD MEMBER FUNCTION num_of_exchanges RETURN NUMBER CASCADE;
/

CREATE OR REPLACE TYPE BODY riv3_stock_t AS
    --func1
    MEMBER FUNCTION calc_yield RETURN NUMBER IS
    BEGIN
        IF curr_price = 0 THEN
            RETURN NULL;
        ELSE
            RETURN (SELF.last_dividend / SELF.curr_price) * 100;
        END IF;
    END calc_yield;

    --func2
    MEMBER FUNCTION convert_to_USD(ex_rate IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN SELF.curr_price * ex_rate;
    END convert_to_USD;

    --func3
    MEMBER FUNCTION num_of_exchanges RETURN NUMBER IS
    BEGIN
        RETURN exchanges.COUNT;  -- VARRAY or nested table has COUNT method
    END num_of_exchanges;

END;
/

select s.company, s.num_of_exchanges()
from riv3_stocks s


--d
--adding a member function to client type
ALTER TYPE riv3_client_t
ADD MEMBER FUNCTION calc_purchase_val RETURN NUMBER CASCADE;

desc riv3_client_t

--defining the body of the member function
CREATE OR REPLACE TYPE BODY riv3_client_t AS
 MEMBER FUNCTION calc_purchase_val RETURN NUMBER IS
  total NUMBER := 0;
 BEGIN
  IF investments IS NOT NULL THEN
   FOR i IN 1..investments.COUNT LOOP --this loops through each investments
    total := total + (investments(i).purchase_price * investments(i).qty);
   END LOOP;
  END IF;
  RETURN total;
 END calc_purchase_val;
END;
/
 
 
select c.firstname, c.calc_purchase_val() PURCHASE_VALUE
from riv3_clients c;
/

--e method to compute total profit on all shares of a client
ALTER TYPE riv3_client_t
ADD MEMBER FUNCTION total_profit RETURN NUMBER CASCADE;
/

CREATE OR REPLACE TYPE BODY riv3_client_t AS
MEMBER FUNCTION calc_purchase_val RETURN NUMBER IS
  purchase_value NUMBER := 0;
 BEGIN
   SELECT SUM(i.purchase_price * i.qty)INTO purchase_value
   FROM TABLE(investments) i;
  RETURN purchase_value;
 END;

 MEMBER FUNCTION total_profit RETURN NUMBER IS
  total_profit NUMBER := 0;
  BEGIN
   SELECT SUM((i.company.curr_price - i.purchase_price)*i.qty)INTO total_profit
   FROM TABLE(investments) i;
   RETURN total_profit;
  END;
END;
/


SELECT c.firstname, c.total_profit() as TOTAL_PROFIT, c.calc_purchase_val() as PURCHASE_VALUE
from riv3_clients c;

--============================================================================================
--QUESTION 2

--a
SELECT s.company as stock_name,e.COLUMN_VALUE AS EXCHANGES, ROUND(s.calc_yield(),2) as YIELD_OF_STOCK, s.convert_to_USD(0.74) as PRICE_IN_USD
from riv3_stocks s, TABLE(s.exchanges) e;


--b
SELECT s.company AS company_name, s.curr_price AS current_price, s.num_of_exchanges() AS number_of_exchanges
FROM riv3_stocks s
WHERE s.num_of_exchanges() > 1;
/
--c
SELECT DISTINCT c.firstname,
       i.company.company AS stock_name,
       ROUND(i.company.calc_yield(),2) AS YIELD,
       i.company.curr_price AS current_price,
       i.company.EPS AS earnings_per_share
FROM riv3_clients c, TABLE(c.investments) i;
/





--d
SELECT c.firstname, c.calc_purchase_val() AS total_purchase_value
FROM riv3_clients c;
/


--e
SELECT c.firstname, c.lastname, c.total_profit() AS book_profit
FROM riv3_clients c;
