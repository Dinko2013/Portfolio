Drop table #Raw
select Year,
paygroup as Paygroup,
January,
February,
March,
April,
May,
June,
July,
August,
September,
October,
November,
Decemeber
Into #RAW
from
(
Select
year(pyh_payperiod) as [Year],
datename(month,(pyh_payperiod)) as mm,
asgn_id,
pd.pyt_itemcode,
pt.pyt_description,
case when pt.pyt_itemcode ='TSM' then 'Line Haul' when pt.pyt_itemcode ='WITFLA' then 'Accessorials' else lbl.name end paygroup,
pyd_amount 
from paydetail pd
join paytype pt on pd.pyt_itemcode =pt.pyt_itemcode
join labelfile lbl on pt.pyt_group = lbl.abbr and lbl.labeldefinition ='PayGroup'
where  pyh_payperiod >=Cast('2018-04-01' as date) and asgn_id='300-46' and pyd_status in('PND','COL','REL','XFR')
 ) d
pivot
    (
        SUM(d.pyd_amount) 
        for d.[mm] in (January,February,March,April,May,June,July,August,September,October,November,Decemeber)
) as Pivot1
 
select Year,
paygroup,
ISNULL(SUM(January),0) as January,
ISNULL(SUM(February),0) as February,
ISNULL(SUM(March),0) as March,
ISNULL(SUM(April),0) as April,
ISNULL(SUM(May),0) as May,
ISNULL(SUM(June),0) as June,
ISNULL(SUM(July),0) as July,
ISNULL(SUM(August),0) as August,
ISNULL(SUM(September),0) as September,
ISNULL(SUM(October),0) as October,
ISNULL(SUM(November),0) as November,
ISNULL(SUM(Decemeber),0) as Decemeber
from #Raw
Group by [Year],[paygroup]
order by Year,paygroup