Truncate table AccumulatedPoints

Insert into AccumulatedPoints(tmwid,[Year],TCPoints)
SELECT tmwid
,startYear
,cast( isnull([Jan],0) as int)
+ Cast(isnull([Feb],0) as int)
+ Cast(isnull([Mar],0) as int)
+ Cast(isnull([Apr],0) as int)
+ Cast(isnull([May],0) as int)
+ Cast(isnull([Jun],0) as int)
+ Cast(isnull([Jul],0) as int)
+ Cast(isnull([Aug],0) as int)
+ Cast(isnull([Sep],0) as int)
+ Cast(isnull([Oct],0) as int)
+ Cast(isnull([Nov],0) as int)
+ Cast(isnull([Dec],0) as int) [TCPoints]
  FROM [DSC].[dbo].[zvw_MilestoneTrackingReport] 
  where lineType ='CareerPoints'
  order by Sequence asc

Declare @Drivername AS VARCHAR(600);
Declare @year AS int;
Declare @TCPoints as int;
Declare @AccumTCPoints as int;


DECLARE Bonus CURSOR FOR   
SELECT tmwid,[Year],[TCPoints]
FROM  AccumulatedPoints TCT

set @AccumTCPoints = 0
/*Open Cursor*/
OPEN Bonus
FETCH NEXT 
FROM Bonus INTO @Drivername,@year,@TCPoints

WHILE @@FETCH_STATUS = 0
BEGIN
Set @AccumTCPoints = (Select sum(TCPoints) from AccumulatedPoints where tmwid = @Drivername and [Year] <= @year)

update AccumulatedPoints set AccumTCPoints = @AccumTCPoints where tmwid = @Drivername and [Year] = @year

update AccumulatedPoints set [TCMiles Bonus] = case when  (@AccumTCPoints between 1100 and 2199) then 10000 when (@AccumTCPoints between 2200 and 3299) then 20000 when (@AccumTCPoints between 3300 and 4399) then 30000 when (@AccumTCPoints between 4400 and 5499) then 40000 when (@AccumTCPoints between 5500 and 6599) then 50000 when (@AccumTCPoints between 6600 and 7699) then 60000 when (@AccumTCPoints between 7700 and 8799) then 70000 when (@AccumTCPoints between 8800 and 9899) then 80000 when (@AccumTCPoints between 9900 and 10999) then 90000 when (@AccumTCPoints >= 11000) then 100000 Else 0 end where tmwid = @Drivername and [Year] = @year


FETCH NEXT 
FROM Bonus INTO @Drivername,@year,@TCPoints


END;
CLOSE Bonus  
DEALLOCATE Bonus  


SELECT TMWID
,[startYear]
,cast( isnull([Jan],0) as int)
+ Cast(isnull([Feb],0) as int)
+ Cast(isnull([Mar],0) as int)
+ Cast(isnull([Apr],0) as int)
+ Cast(isnull([May],0) as int)
+ Cast(isnull([Jun],0) as int)
+ Cast(isnull([Jul],0) as int)
+ Cast(isnull([Aug],0) as int)
+ Cast(isnull([Sep],0) as int)
+ Cast(isnull([Oct],0) as int)
+ Cast(isnull([Nov],0) as int)
+ Cast(isnull([Dec],0) as int) as 'Miles'
into #Temp
  FROM [DSC].[dbo].[zvw_MilestoneTrackingReport] 
  where lineType ='CareerMiles'
  order by Sequence asc

Declare @Drivername1 AS VARCHAR(600);
Declare @year1 AS int;
Declare @Miles as float;
Declare @AccumTCPMiles as float;


DECLARE BonusMiles CURSOR FOR   
SELECT TMWID,[startYear],[Miles]
FROM  #temp TCT

set @AccumTCPMiles = 0
/*Open Cursor*/
OPEN BonusMiles
FETCH NEXT 
FROM BonusMiles INTO @Drivername1,@year1,@Miles

WHILE @@FETCH_STATUS = 0
BEGIN

Set @AccumTCPMiles = (Select sum([Miles]) from #Temp where TMWID = @Drivername1 and [startYear] <= @year1)

update AccumulatedPoints set [AccumulatedMiles] = @AccumTCPMiles + [TCMiles Bonus] where TMWID = @Drivername1 and [Year] = @year1

FETCH NEXT 
FROM BonusMiles INTO @Drivername1,@year1,@Miles


END;
CLOSE BonusMiles  
DEALLOCATE BonusMiles  

Drop table #Temp