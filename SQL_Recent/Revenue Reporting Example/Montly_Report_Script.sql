USE [TMW]
GO

/****** Object:  StoredProcedure [dbo].[zsp_arkema_monthly_report]    Script Date: 2020-10-07 4:23:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Author:		Mo Keita
-- Create date: 2020-09-18
-- Description:	ARKEMA Bulk truck supplier service report
-- =============================================================

CREATE PROCEDURE [dbo].[zsp_arkema_monthly_report] (@fromDate as date , @toDate as date)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



--Load/order information
Select ord_hdrnumber as 'Order #',
ord_bookdate as 'Notification Date',
ref_number as 'BOL #',
origin_city as 'Orgin',
ord_originstate as 'Origin State',
ord_origin_zip as 'Origin zip',
destination_city as 'Destination',
ord_deststate as 'Destination State',
ord_dest_zip as 'Destination Zip',
isnull(LLD,HPL) as 'Actual P/U Date',
LegMiles as ord_miles,
LUL as  'Actual Delivery Date',
DATEDIFF (HOUR , isnull(LLD,HPL) , LUL )  as DeliveryTime
into #OrderArrivalDepartActual
 from
(
Select o.ord_hdrnumber,
o.ord_bookdate,
c1.cty_name as Origin_city,
r.ref_number,
ord_originstate,
ord_origin_zip,
c2.cty_name as Destination_City,
ord_deststate,
ord_dest_zip,
stp_event,
stp_arrivaldate,
(Select sum(stp_lgh_mileage) from stops where ord_hdrnumber = o.ord_hdrnumber and stp_loadstatus ='LD') as LegMiles
from orderheader o
join stops s on o.mov_number =s.mov_number and stp_event in('LUL','LLD','HPL')
join city c1 on c1.cty_code = o.ord_origincity
join city c2 on c2.cty_code = o.ord_destcity
join referencenumber r on r.ord_hdrnumber = o.ord_hdrnumber  and r.ref_type ='BL#' and ref_table ='Freightdetail'
where ord_billto in(Select cmp_id from company where cmp_name like '%Arkema%' and cmp_billto ='Y' and cmp_active ='Y') and ord_status ='CMP' and cast(ord_completiondate as date) between cast(@fromDate as date) and cast(@todate as date)
)a
Pivot
(  max(stp_arrivaldate)
   for stp_event in (LUL,LLD,HPL)
) as Pivot1


Select ord_hdrnumber,
isnull(LLD,HPL) as 'Scheduled P/U Date',
LUL as  'Scheduled Delivery Date'
into #OrderArrivalDepartSchedules
 from
(
Select o.ord_hdrnumber,
stp_event,
stp_schdtlatest
from orderheader o
join stops s on o.mov_number =s.mov_number and stp_event in('LUL','LLD','HPL')
join city c1 on c1.cty_code = o.ord_origincity
join city c2 on c2.cty_code = o.ord_destcity
join referencenumber r on r.ord_hdrnumber = o.ord_hdrnumber  and r.ref_type ='BL#' and ref_table ='Freightdetail'
where ord_billto in(Select cmp_id from company where cmp_name like '%Arkema%' and cmp_billto ='Y' and cmp_active ='Y') and ord_status ='CMP' and cast(ord_completiondate as date) between cast(@fromDate as date) and cast(@todate as date)
)a
Pivot
(  max(stp_schdtlatest)
   for stp_event in (LUL,LLD,HPL)
) as Pivot1


--Revenue information
select ord_hdrnumber as 'Order #',
ivh_currency as 'Currency',
sum(isnull([Line Haul Charges],0)) as 'Line Haul Charges',
sum(isnull([Fuel Charges],0)) as 'Fuel Charges',
sum(isnull([Loading Detention],0)) as 'Loading Detention',
sum(isnull([Loading Detention - US$],0)) as 'Loading Detention - US$',
sum(isnull([Delivery Detention],0)) as 'Delivery Detention',
sum(isnull([Delivery Detention - US$],0)) as 'Delivery Detention - US$',
sum(isnull([Accessorial Charges],0))as 'Accessorial Charges',
sum(isnull([Tanker Wash(US$) Charges],0)) as  'Tanker Wash(US$) Charges',
sum(isnull([HST],0))as 'HST',
sum(isnull([QST],0))as 'QST'
into #RevenueInfoActual
from
(
Select h.ord_hdrnumber, 
h.ivh_currency,
c.cht_description,
d.cht_itemcode,
c.cht_typeofcharge,
case when d.cht_itemcode in ('UNDEM','UDNCDM') and cht_typeofcharge ='ACC' then 'Delivery Detention'
	 when d.cht_itemcode in ('UDEMUS') and cht_typeofcharge ='ACC' then 'Delivery Detention - US$'
	  when d.cht_itemcode in ('LDMCDN') and cht_typeofcharge ='ACC' then 'Loading Detention'
	  when d.cht_itemcode in ('LDEMUS') and cht_typeofcharge ='ACC' then 'Loading Detention - US$'
	   when cht_typeofcharge ='ACC' and d.cht_itemcode not in('UNDEM','UDNCDM','UDEMUS','LDMCDN','LDEMUS') then 'Accessorial Charges'
	   when cht_typeofcharge = 'MISC' then 'Misc Charges'
	   when cht_typeofcharge = 'CHRWAS' then 'Tanker Wash(US$) Charges'
	   when cht_typeofcharge ='FSC' then 'Fuel Charges'
	   when cht_typeofcharge  ='GST' then 'HST'
	   WHEN cht_typeofcharge ='TAX3' then 'QST'
	else 'Line Haul Charges' end as typeofcharge,
d.ivd_charge
from
invoiceheader h
join invoicedetail d on h.ivh_hdrnumber = d.ivh_hdrnumber
join chargetype c on c.cht_itemcode = d.cht_itemcode
where h.ord_hdrnumber in(select [order #] from #OrderArrivalDepartActual) 
)a
pivot
(
 max(ivd_charge)
   for typeofcharge in ([Line Haul Charges],[Fuel Charges],[Loading Detention],[Loading Detention - US$],[Delivery Detention],[Delivery Detention - US$],[Accessorial Charges],[Tanker Wash(US$) Charges],[HST],[QST])
) as pv
group by ord_hdrnumber,ivh_currency


--Exceptions
Select sxn_ord_hdrnumber,
lbl.name +' -> '+ sxn_description as Exception 
into #Exceptions
from 
serviceexception s
inner join labelfile lbl on s.sxn_expcode = lbl.abbr and lbl.labeldefinition ='ReasonLate'
where sxn_ord_hdrnumber in(select [order #] from #OrderArrivalDepartActual) 



--Freight informatoin
Select s.stp_number,
ord_hdrnumber, 
cast(cast( isnull(fgt_weight,fgt_volume) as varchar) + ' ' + fgt_weightunit as varchar) as NetWeight,
case when (select cmd_hazardous from commodity where cmd_code = s.cmd_code) =1 then 'Y' else 'N' end 'hazard'
into #FreightInformation
from stops s
join freightdetail f on s.stp_number = f.stp_number and s.stp_event='LUL'
where ord_hdrnumber 
in (select [order #] from #OrderArrivalDepartActual)  

--Report Output
Select a.[Order #] 'Order#',
a.[BOL #] 'BOL',
a.[Notification Date] 'notification_datetime',
a.Orgin 'shipper_city',
a.[Origin State] 'shipper_state',
a.[Origin zip] 'shipper_zipcode',
s.[Scheduled P/U Date] 'scheduled_pickup_time',
a.[Actual P/U Date] 'actual_pickup_time',
a.Destination 'consignee_city',
a.[Destination State] 'Consignee_state',
a.[Destination Zip] 'consignee_zipcode',
s.[Scheduled Delivery Date] 'scheduled_delivery_time',
a.[Actual Delivery Date] 'actual_delivery_time',
Case when a.[Actual Delivery Date] <= s.[Scheduled Delivery Date]  then 'Y' else 'N' end 'On_Time',
isnull(e.Exception,'') as 'exception',
f.hazard 'Hazmat(Y/N)',
f.NetWeight 'Net Weight',
a.ord_miles 'Miles',
r.[Line Haul Charges] 'billed_linehaul',
r.[Fuel Charges] 'fuel_billed',
isnull(r.[Loading Detention],r.[Loading Detention - US$]) 'loading_detention_billed',
isnull(r.[Delivery Detention],r.[Delivery Detention - US$]) 'unloadin_detention_billed',
r.[Tanker Wash(US$) Charges] 'cleaning_charge_billed',
r.[Accessorial Charges] 'Other_addtional_charges',
r.HST 'HST',
r.QST 'QST',
r.Currency
from #OrderArrivalDepartActual a
join #OrderArrivalDepartSchedules s on a .[Order #] = s.ord_hdrnumber
join #RevenueInfoActual r on a.[Order #] = r.[Order #]
left join #Exceptions e on a.[Order #] =e.sxn_ord_hdrnumber
left join #FreightInformation f on a.[Order #] = f.ord_hdrnumber



DROP TABLE IF EXISTS i#OrderArrivalDepartActual
DROP TABLE IF EXISTS #OrderArrivalDepartSchedules
DROP TABLE IF EXISTS #RevenueInfoActual
DROP TABLE IF EXISTS #Exceptions
DROP TABLE IF EXISTS #Freightinformation

END
GO


