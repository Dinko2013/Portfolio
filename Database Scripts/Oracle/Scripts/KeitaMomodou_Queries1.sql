--Question1
select track.name as Track_Name,
count(invoiceline.trackid) as Purchase_Count
from track
left join INVOICELINE on INVOICELINE.TRACKID =track.TRACKID
group by track.name
order by count(invoiceline.trackid) asc;

--Question 2
select track.TRACKID as Track_ID,
track.name as Track_Name
from track
left join INVOICELINE on INVOICELINE.TRACKID =track.TRACKID
group by track.name,track.TRACKID
HAVING count(invoiceline.trackid) = 0
order by count(invoiceline.trackid) asc;

--Question 3
Select b_author.lname as "Last Name",
 b_author.fname as "First Name"
 from  b_author
 left join  b_bookauthor on b_author.authorid = b_bookauthor.authorid
 left join b_books on b_bookauthor.isbn = b_books.isbn
 where b_books.isbn is null;
 
 --Question 4
 select b_books.title as Title
 from B_BOOKS
 left join B_ORDERITEMS on B_BOOKS.ISBN = B_ORDERITEMS.ISBN
 where B_ORDERITEMS.ISBN is null;
 
--Question 5
 select b_publisher.name as Publisher_Name
 from b_publisher
 left join  B_Books  on b_books.pubid = b_publisher.PUBID
 left join B_ORDERITEMS on B_BOOKS.ISBN = B_ORDERITEMS.ISBN
 where B_ORDERITEMS.ISBN is null;
 
 --Question 6
 select b_customers.customer# as  Customer#,
 b_customers.lastname as Last_name,
  b_customers.firstname as first_name
 from B_CUSTOMERS
 left join  b_orders  on b_orders.CUSTOMER# = B_CUSTOMERS.CUSTOMER#
 left join B_ORDERITEMS on B_ORDERITEMS.ORDER# = b_orders.ORDER#
 where b_orders.CUSTOMER# is null;
 
-- Question 7
Select *
FROM NUMBERS_TWOS
inner join numbers_threes on NUMBERS_TWOS.MULTIPLE_OF_2 = numbers_threes.MULTIPLE_OF_3;

--Question 8
Select *
FROM NUMBERS_TWOS
left outer join numbers_threes on NUMBERS_TWOS.MULTIPLE_OF_2 = numbers_threes.MULTIPLE_OF_3;

--Question 9
Select *
FROM NUMBERS_TWOS
right outer join numbers_threes on NUMBERS_TWOS.MULTIPLE_OF_2 = numbers_threes.MULTIPLE_OF_3;

--Question 10
Select *
FROM NUMBERS_TWOS
full outer  join numbers_threes on NUMBERS_TWOS.MULTIPLE_OF_2 = numbers_threes.MULTIPLE_OF_3;

--Question 11
Select NUMBERS_TWOS.MULTIPLE_OF_2 ,
numbers_threes.MULTIPLE_OF_3,
nvl(NUMBERS_TWOS.MULTIPLE_OF_2 ,numbers_threes.MULTIPLE_OF_3) as Sort_Order
FROM NUMBERS_TWOS
full outer  join numbers_threes on NUMBERS_TWOS.MULTIPLE_OF_2 = numbers_threes.MULTIPLE_OF_3
order by Sort_Order;

--Question 12(Bonus)
Select NUMBERS_TWOS.MULTIPLE_OF_2 ,
numbers_threes.MULTIPLE_OF_3,
numbers_fives.multiple_of_5,
NVL(NUMBERS_TWOS.MULTIPLE_OF_2 ,NVl(numbers_threes.MULTIPLE_OF_3,numbers_fives.MULTIPLE_OF_5)) as Sort_Order
FROM NUMBERS_TWOS
full outer  join numbers_threes on NUMBERS_TWOS.MULTIPLE_OF_2 = numbers_threes.MULTIPLE_OF_3
full outer join numbers_fives on numbers_threes.MULTIPLE_OF_3 = numbers_fives.MULTIPLE_OF_5
--where numbers_threes.MULTIPLE_OF_3 is not null or numbers_fives.MULTIPLE_OF_5 is not null
order by Sort_Order;
