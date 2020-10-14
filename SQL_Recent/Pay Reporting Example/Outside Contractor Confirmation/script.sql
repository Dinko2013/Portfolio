USE [TMW]
GO

/****** Object:  StoredProcedure [dbo].[SeabordLogistics_LoadRateConfirmation]    Script Date: 2020-10-07 4:25:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Momodou Keita>
-- Create date: <2020-09-14>
-- Description:	<Send load and pay confirmation paper work for brokered loads>
-- =============================================
CREATE PROCEDURE [dbo].[SeabordLogistics_LoadRateConfirmation](@orderno varchar(max))
AS
BEGIN
--Select o.ord_hdrnumber 'Order #',
--l.lgh_carrier 'Carrier Id',
--c.car_name 'Carrier Name',
--c.car_address1 'Carrier Address',
--c.car_zip 'Carrier ZipCode',
--ctyc.cty_nmstct 'Carrier City',
--c.car_country 'Carrier Country',
--c.car_phone1 'Carrier Main Phone',
--c.car_phone2 'Carrier Secondary Phone',
--c.car_phone3 'Carrier Fax',
--isnull(c.car_contact,'N/A') 'Carrier Contact',
--s.cmp_id 'Stop Company Id',
--cmp.cmp_name 'Stop Company Name',
--cty.cty_name 'Stop city Name',
--cty.cty_state 'Stop City State',
--cmp.cmp_zip 'Stop Zipcode',
--s.stp_event 'Stop Event',
--s.stp_arrivaldate 'Stop Arrival Time'
--,f.cmd_code 'Commodity Code',
--cast(f.fgt_weight as varchar) 'Feight Weight',
--f.fgt_weightunit 'Freight Weight Unit',
--f.fgt_count 'Freight Count',
--f.fgt_countunit 'Frieght Count unit',
--o.ord_remark 'Order Instructions',
--pyd_description 'Pay Item Description',
--pyd_quantity 'Pay Quantity',
--pyd_rate 'Pay Rate',
--lbl1.name 'Pay Rate Unit',
--pyd_amount 'Pay Amount',
--pyd_sequence
--from orderheader o
--INNER JOIN (select value from STRING_SPLIT(@orderno,',') a where a.value is not null) a on a.value = o.ord_hdrnumber
--join legheader l on o.ord_hdrnumber = l .ord_hdrnumber
--join stops s on o.ord_hdrnumber = s.ord_hdrnumber
--join freightdetail f on s.stp_number = f.stp_number
--join carrier c on l.lgh_carrier = c.car_id 
--join company cmp on s.cmp_id = cmp.cmp_id
--join city cty on cmp.cmp_city = cty.cty_code
--join city ctyc on c.cty_code = ctyc.cty_code
--join paydetail p on o.ord_hdrnumber=p.ord_hdrnumber
--join labelfile lbl1 on p.pyd_rateunit =lbl1.abbr and lbl1.labeldefinition ='RateBy' 



Select o.ord_hdrnumber,
cmp.cmp_name 'Origin_Company_Name',
cty.cty_name 'Origin_City_Name',
cmp.cmp_address1 'Origin_City_Address',
cty.cty_state 'Origin_City_State',
cmp.cmp_zip 'Origin_Zipcode',
cmp.cmp_primaryphone 'Orgin_Primary_Phone',
cmp.cmp_secondaryphone 'Origin_Secondary_Phone',
s.stp_arrivaldate 'Origin_Arrival_Date',
o.ord_remark,
f.cmd_code 'Commodity Code',
cast(f.fgt_weight as varchar) 'Feight_Weight',
f.fgt_weightunit 'Freight_Weight_Unit',
f.fgt_count 'Freight_Count',
f.fgt_countunit 'Frieght_Count_unit'
Into #loadingStopInfo
from stops s
join company cmp on s.cmp_id = cmp.cmp_id
join city cty on cmp.cmp_city = cty.cty_code
join orderheader o  on s. mov_number = o.mov_number 
join freightdetail f on s.stp_number = f.stp_number
INNER JOIN (select value from STRING_SPLIT(@orderno,',') a where a.value is not null) a on a.value = o.ord_hdrnumber
where stp_event  in('LLD','HPL')


Select o.ord_hdrnumber,
cmp.cmp_name 'Destination_Company_Name',
cty.cty_name 'Destination_City_Name',
cmp.cmp_address1 'Destination_City_Address',
cty.cty_state 'Destination_City_State',
cmp.cmp_zip 'Destination_Zipcode',
cmp.cmp_primaryphone 'Destination_Primary_Phone',
cmp.cmp_secondaryphone 'Destination_Secondary_Phone',
s.stp_arrivaldate 'Destination_Arrival_Date'
Into #UnloadingStopInfo
from stops s
join company cmp on s.cmp_id = cmp.cmp_id
join city cty on cmp.cmp_city = cty.cty_code
join orderheader o  on s. mov_number = o.mov_number 
join freightdetail f on s.stp_number = f.stp_number
INNER JOIN (select value from STRING_SPLIT(@orderno,',') a where a.value is not null) a on a.value = o.ord_hdrnumber
where stp_event ='LUL'


Select o.ord_hdrnumber 'Order #',
l.lgh_carrier 'Carrier Id',
c.car_name 'Carrier Name',
c.car_address1 'Carrier Address',
c.car_zip 'Carrier ZipCode',
ctyc.cty_nmstct 'Carrier City',
c.car_country 'Carrier Country',
c.car_phone1 'Carrier Main Phone',
c.car_phone2 'Carrier Secondary Phone',
c.car_phone3 'Carrier Fax',
isnull(c.car_contact,'N/A') 'Carrier Contact',
lld.Origin_Company_Name,
lld.Origin_City_Name,
lld.Origin_City_Address,
lld.Origin_City_State,
lld.Origin_Zipcode,
lld.Orgin_Primary_Phone,
lld.Origin_Secondary_Phone,
lld.Origin_Arrival_Date,
lul.Destination_Company_Name,
lul.Destination_City_Name,
lul.Destination_City_Address,
lul.Destination_City_State,
lul.Destination_Zipcode,
lul.Destination_Primary_Phone,
lul.Destination_Secondary_Phone,
lul.Destination_Arrival_Date,
lld.[Commodity Code] 'Commodity',
lld.Feight_Weight,
lld.Freight_Weight_Unit,
lld.Freight_Count,
lld.Frieght_Count_unit,
o.ord_remark,
pyd_description 'Pay Item Description',
pyd_quantity 'Pay Quantity',
pyd_rate 'Pay Rate',
lbl1.name 'Pay Rate Unit',
pyd_amount 'Pay Amount',
pyd_sequence
from orderheader o
join #loadingStopInfo lld on o.ord_hdrnumber = lld.ord_hdrnumber
join #UnloadingStopInfo lul on o.ord_hdrnumber = lul.ord_hdrnumber
INNER JOIN (select value from STRING_SPLIT(@orderno,',') a where a.value is not null) a on a.value = o.ord_hdrnumber
join legheader l on o.ord_hdrnumber = l .ord_hdrnumber
join carrier c on l.lgh_carrier = c.car_id 
join city ctyc on c.cty_code = ctyc.cty_code
join paydetail p on o.ord_hdrnumber=p.ord_hdrnumber
join labelfile lbl1 on p.pyd_rateunit =lbl1.abbr and lbl1.labeldefinition ='RateBy' 

Drop table #loadingStopInfo
Drop table #UnloadingStopInfo

END
GO


