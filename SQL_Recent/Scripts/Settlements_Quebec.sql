
select asgn_id, asgn_type, January, February, March, April, May,June,July,August,September,October,November,December
from
(
  SELECT asgn_type,asgn_id,DATENAME(month, pyh_payperiod) AS 'Month',sum(pyd_amount) as TotalPay FROM zvw_PayDetails_v4_1
WHERE pyh_payperiod 
BETWEEN cast('2018-01-01' as date)
AND cast('2018-12-31' as date)
AND Ord_Div in ('03')
group by DATENAME(month, pyh_payperiod),asgn_type,asgn_id
) d
pivot
(
  max(TotalPay)
  for [Month] in (January, February, March, April, May,June,July,August,September,October,November,December)
) piv;

select asgn_id, asgn_type, January, February, March, April, May,June,July,August,September,October,November,December
from
(
  SELECT asgn_type,asgn_id,DATENAME(month, pyh_payperiod) AS 'Month',sum(pyd_amount) as TotalPay FROM zvw_PayDetails_v4_1
WHERE pyh_payperiod 
BETWEEN cast('2018-01-01' as date)
AND cast('2018-12-31' as date)
AND Ord_Div in ('76')
group by DATENAME(month, pyh_payperiod),asgn_type,asgn_id
) d
pivot
(
  max(TotalPay)
  for [Month] in (January, February, March, April, May,June,July,August,September,October,November,December)
) piv;


select asgn_id, asgn_type, January, February, March, April, May,June,July,August,September,October,November,December
from
(
  SELECT asgn_type,asgn_id,DATENAME(month, pyh_payperiod) AS 'Month',sum(pyd_amount) as TotalPay FROM TMW.dbo.zvw_PayDetails_v4_1
WHERE pyh_payperiod 
BETWEEN cast('2018-01-01' as date)
AND cast('2018-12-31' as date)
AND Ord_Div in ('G3')
group by DATENAME(month, pyh_payperiod),asgn_type,asgn_id
) d
pivot
(
  max(TotalPay)
  for [Month] in (January, February, March, April, May,June,July,August,September,October,November,December)
) piv;