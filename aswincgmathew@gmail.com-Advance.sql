--SQL Advance Case Study
use db_SQLCaseStudies


--1. list all the states in which we have customers who have bought cellphones from 2005 till today.
--Q1--BEGIN

SELECT DISTINCT(State) FROM FACT_TRANSACTIONS INNER JOIN DIM_LOCATION ON FACT_TRANSACTIONS.IDLocation = DIM_LOCATION.IDLocation
WHERE YEAR([Date]) > 2004


--Q1--END


--Q2.What state in the US is buying more 'Samsung' Cell phones?
--Q2--BEGIN


SELECT top 1 STATE , COUNT(DATE)[count] FROM FACT_TRANSACTIONS INNER JOIN DIM_LOCATION ON FACT_TRANSACTIONS.IDLocation = DIM_LOCATION.IDLocation 
INNER JOIN DIM_MODEL ON FACT_TRANSACTIONS.IDModel= DIM_MODEL.IDModel 
INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer =	DIM_MANUFACTURER.IDManufacturer
where Manufacturer_Name = 'Samsung' and Country = 'US'
GROUP BY STATE
order by [count] desc

--Q2--END


--Q3.Show the number of transactions for each model per zip code per state.
--Q3--BEGIN      

select t1.[ZipCode], t1.[State], t2.[Model_Name], count(t3.[IDCustomer]) [ttl_ tran] from [dbo].[DIM_LOCATION] as t1, [dbo].[DIM_MODEL] as t2, [dbo].[FACT_TRANSACTIONS] as t3
where t1.[IDLocation] = t3.[IDLocation] and t2.[IDModel] = t3.[IDModel]
group by t1.[ZipCode],  t1.[State], t2.[Model_Name]



--Q3--END


--Q4.show the cheapest cellphone
--Q4--BEGIN

select top 1 Model_Name, Manufacturer_Name, Unit_price from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel 
INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer =	DIM_MANUFACTURER.IDManufacturer
order by Unit_price 




--Q4--END


--Q5.Find out the average price for each model in the top 5 manufacturers in terms of sales quantity and order by average price.
--Q5--BEGIN



select Model_Name, avg(TotalPrice/Quantity)[Avg_Price] from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel 
INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer =	DIM_MANUFACTURER.IDManufacturer
where Manufacturer_Name in (
select top 5 Manufacturer_Name from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel 
INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer =	DIM_MANUFACTURER.IDManufacturer
group by Manufacturer_Name
order by sum(Quantity) desc)
group by Model_Name
order by [Avg_Price]








--Q5--END


--Q6-List the names of the customers and the average amount spent in 2009,where the average is higher than 500.
--Q6--BEGIN

select Customer_Name, avg(TotalPrice)[avg_spent] from FACT_TRANSACTIONS inner join DIM_CUSTOMER on FACT_TRANSACTIONS.IDCustomer = DIM_CUSTOMER.IDCustomer
where YEAR([Date]) = 2009
group by Customer_Name
having avg(TotalPrice)> 500
order by [avg_spent] desc




--Q6--END


--Q7.List if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008,2009 and 2010. 	
--Q7--BEGIN  
	
	
Select T1.Model_Name  from (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
  inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
  where YEAR(F.[Date])=2008 
  group by Mo.Model_Name,Mo.IDmodel
  order by TotQty desc) as T1 inner join
   (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
  inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
  where YEAR(F.[Date])=2009
  group by Mo.Model_Name,Mo.IDmodel
  order by TotQty desc) as T2 on T1.Model_Name=T2.Model_Name inner join
   (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
  inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
  where YEAR(F.[Date])=2010
  group by Mo.Model_Name,Mo.IDmodel
  order by TotQty desc) as T3 on T3.Model_Name=T2.Model_Name;






--Q7--END	

--Q8.show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010
--Q8--BEGIN

select * from( select row_number() over(order by sum(F.TotalPrice) desc) as R, M.Manufacturer_Name ,sum(F.TotalPrice) as Tot_Amt,
  YEAR(F.[Date]) as [Year]
  from FACT_TRANSACTIONS as F 
  inner join DIM_MODEL As Mo on Mo.IDModel=F.IDModel
  inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
  where YEAR(F.[Date])=2009 
  group by  M.Manufacturer_Name,YEAR(F.[Date]))as T1
  where R=2 union all
  select * from (select row_number() over(order by sum(F.TotalPrice) desc) as R, M.Manufacturer_Name ,sum(F.TotalPrice) as Tot_Amt,
  YEAR(F.[Date]) as [Year]
  from FACT_TRANSACTIONS as F 
  inner join DIM_MODEL As Mo on Mo.IDModel=F.IDModel
  inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
  where YEAR(F.[Date])=2010 
  group by  M.Manufacturer_Name,YEAR(F.[Date])) as T2
  where R=2; 






--Q8--END



--Q9.show the manufacturers that sold cellphone in 2010 but didn't in 2009.
--Q9--BEGIN
	
selecT distinct(Manufacturer_Name) from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel 
INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer =	DIM_MANUFACTURER.IDManufacturer
where YEAR([Date])  in (2010) and Manufacturer_Name not in ( selecT distinct(Manufacturer_Name) from FACT_TRANSACTIONS 
inner join DIM_MODEL on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel 
INNER JOIN DIM_MANUFACTURER ON DIM_MODEL.IDManufacturer =	DIM_MANUFACTURER.IDManufacturer
where YEAR([Date])  in (2009))


--Q9--END




--Q10.Find top 10 customers and their average spend,average quantity by each year.Also find the percentage of change in their spend.
--Q10--BEGIN
	

select TBL1.IDCustomer,TBL1.Customer_Name , TBL1.[Year],TBL1.Avg_Spend,TBL1.Avg_Qty,case when TBL2.[Year] is not null then
((TBL1.Avg_Spend-TBL2.Avg_Spend)/TBL2.Avg_Spend )* 100 
else NULL
end as 'YOY in Average Spend' from
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL1 
left join 
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL2 
on TBL1.IDCustomer=TBL2.IDCustomer and TBL2.[Year]=TBL1.[Year]-1;




--Q10--END	