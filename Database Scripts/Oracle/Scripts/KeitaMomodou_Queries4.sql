--Question 1
select title
from ALBUM
where ARTISTID = 22
order by TITLE asc;

--Question 2
select TITLE
from ALBUM
where TITLE like '%Best%';

--Question 3
Select Name
from Track
where GENREID = (select genreid from GENRE where name like '%Alternative')
order by Name asc;

--Question 4
select LASTNAME, FIRSTNAME, BIRTHDATE, HIREDATE
from employee
where HIREDATE > TO_DATE('03/30/2003', 'MM/DD/YYYY') and BIRTHDATE <TO_DATE('03/30/1965', 'MM/DD/YYYY');

--Question 5
Select Firstname, lastname
from customer
where supportrepid = (select employeeid from employee where Lastname = 'Johnson' and firstname = 'Steve')
order by LASTNAME asc;

--Question 6
select Distinct(Name)
from track
where Name like 'A%' or name like '%t'
order by name desc;


--Question 7
select MAX(count(ARTISTID)) as "Album Count" 
from album
group by ARTISTID;

--Question 8
select customerid, count(customerid) as "count(*)",sum(total) as "Sum(Total)"
from INVOICE
group by CUSTOMERID
having SUM(total)> 40
order by sum(total) desc;

--Question 9
select INVOICEID,SUM(QUANTITY) as "total Items"
from InvoiceLine
group by INVOICEID
order by SUM(QUANTITY) desc,INVOICEID asc;

--Question 10
select customerid
from INVOICE
where total > 5
;

--Question 11
select albumid,count(ALBUMID) as "Track Count"
from track 
GROUP by ALBUMID
having count(ALBUMID) >25
order by count(ALBUMID) desc;

--Question 12
select name 
from track
where TRACKID IN (select distinct(trackid) from PLAYLISTTRACK where playlistid = 17)
order by name asc;

--Question 13
select playlistid, count(trackid)
from PLAYLISTTRACK
group by PLAYLISTID
having count(trackid)>100
order by count(trackid) desc ;

--Question 14
--Question 15
select DISTINCT(playlistid) 
from PLAYLISTTRACK
where TRACKID in (select trackid from track where name = 'Stairway To Heaven');
