--Question1
select customer.firstname,
customer.lastname,
employee.firstname as "support Rep First Name",
employee.lastname as "support Rep Last Name"
from customer
inner join EMPLOYEE on customer.SUPPORTREPID= EMPLOYEE.EMPLOYEEID;

--Question 2
select track.name as "Track",
genre.name as "Genre",
mediatype.name as " Media Type"
from track 
inner join GENRE on GENRE.GENREID = track.GENREID
inner join MEDIATYPE on MEDIATYPE.MEDIATYPEID = track.MEDIATYPEID;

--Question 3
select customer.firstname as "First Name",
customer.lastname as "Last Name",
track.name as "Track name",
INVOICE.INVOICEDATE as "Date Purchased"
from CUSTOMER
inner join INVOICE on INVOICE.CUSTOMERID = CUSTOMER.CUSTOMERID
inner join INVOICELINE on INVOICELINE.INVOICEID = INVOICE.INVOICEID
inner join track on track.TRACKID = INVOICELINE.TRACKID
ORDER by CUSTOMER.LASTNAME asc,CUSTOMER.FIRSTNAME asc, track.NAME asc;

--Question 4
select e.firstname as "Employee First Name",
e.lastname as "Employee Last Name",
m.firstname as "Manager First Name" ,
m.lastname as "Manager Last Name"
from EMPLOYEE e
inner join EMPLOYEE m on E.Reportsto= M.Employeeid;

--Question 5
select artist.name as "Artist Name",
count(album.albumid) as "# of Album Avaiable" 
from album
inner join artist on artist.ARTISTID = album.ARTISTID
GROUP BY artist.NAME;

--Question 6
select track.name as "Track Name",
album.title as "Album Title",
artist.name as "Performed by"
from track 
inner join ALBUM on track.ALBUMID = ALBUM.ALBUMID
inner join ARTIST on ALBUM.ARTISTID = ARTIST.ARTISTID
order by track.NAME asc;

--Question 7
select  distinct customer.firstname as "First Name",
customer.lastname as "Last Name",
mediatype.name as "Media Type Bought"
from customer
inner JOIN INVOICE on INVOICE.CUSTOMERID = customer.CUSTOMERID
inner join INVOICELINE on INVOICELINE.INVOICEID = INVOICE.INVOICEID
inner join track on track.TRACKID = INVOICELINE.TRACKID
inner join MEDIATYPE on track.MEDIATYPEID = MEDIATYPE.MEDIATYPEID;

--Question 8
select invoice.invoiceid as "Invoice Number",
invoice.INVOICEDATE as "Invoice Date",
sum(invoiceline.quantity) as "Total Item Quantity",
customer.firstname as "First Name",
customer.lastname as "Last Name"
from invoice
inner join customer on invoice.customerid = customer.customerid
inner join invoiceline on invoice.invoiceid = invoiceline.invoiceid
group by invoice.invoiceid,invoice.INVOICEDATE,customer.firstname,customer.lastname
order by invoice.invoiceid asc;

--Question 9[This Solution won't work if record happen to be more than 1]
select First_Name,last_name,Video_Tracks_Purchase from
(
select customer.FIRSTNAME as First_Name,
customer.lastname as Last_Name,
count(track.MEDIATYPEID) as Video_Tracks_Purchase
from invoice
inner JOIN customer on  invoice.CUSTOMERID= customer.CUSTOMERID
inner join invoiceline on invoiceline.INVOICEID = invoice.INVOICEID
inner join track on invoiceline.TRACKID = track.TRACKID
inner join MEDIATYPE on track.MEDIATYPEID = MEDIATYPE.MEDIATYPEID
where MEDIATYPE.MEDIATYPEID = 3
GROUP BY customer.FIRSTNAME, customer.lastname
order by Video_Tracks_Purchase desc)
where ROWNUM =1;

--Question 10 [This Solution won't work if record happen to be more than 1]
select Artist_Name, Num_of_tracks_sold FROM
(select artist.name as Artist_Name,
count(quantity) as Num_of_tracks_sold
from artist
inner join album on album.artistid = artist.ARTISTID
inner join track on album.albumid = track.ALBUMID
inner join invoiceline on track.TRACKID = invoiceline.TRACKID
group by artist.name
order by Num_of_tracks_sold desc)
where rownum=1;