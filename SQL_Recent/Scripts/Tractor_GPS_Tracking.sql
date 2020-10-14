BEGIN

SET NOCOUNT ON

		DROP TABLE IF EXISTS ##FourkitesOutput
		DROP TABLE IF EXISTS ##FourkitesCols
		
		

-- Declare the variables
DECLARE @CMD VARCHAR(4000),
        @DelCMD VARCHAR(4000),
        @HEADERCMD VARCHAR(4000),
        @Combine VARCHAR(4000),
        @Path VARCHAR(4000),
        @COLUMNS VARCHAR(4000),
		@SendFTP BIT = 0


-- Set values as appropriate
		SET @COLUMNS = ''
		SET @Path = '\\seadevsql\temp\Fourkites'
		SET @SendFTP = 1 -- 0 -NO , 1 YES

		DECLARE @OutputTable AS VARCHAR(255) = '##FourkitesOutput'
		DECLARE @OutputTimeStamp AS VARCHAR(100) = convert(varchar(30), getdate(),112) + replace(convert(varchar(30), getdate(),108),':','')
		DECLARE @OutputFilePath AS VARCHAR(255) = ''
		DECLARE @OutputFile AS VARCHAR(255) = ''



DROP TABLE IF EXISTS #DowBillTos
CREATE TABLE #DowBillTos (Billto VARCHAR(8));


INSERT INTO #DowBillTos (Billto) VALUES ('DOWFRE');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWFRE01');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID06');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID05');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWCAR');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID01');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID04');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID09');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID10');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMIDIN');
INSERT INTO #DowBillTos (Billto) VALUES ('ROHCOL');
INSERT INTO #DowBillTos (Billto) VALUES ('ROHCOL01');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWLSAI');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWBAY01');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWBED');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWCHA04');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWCOL01');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWCON');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWLAP');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID03');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID07');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWMID08');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWPLA');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWSAI');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWSAR');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWTAF');
INSERT INTO #DowBillTos (Billto) VALUES ('DOWWIN01');
INSERT INTO #DowBillTos (Billto) VALUES ('ROHCOT');
INSERT INTO #DowBillTos (Billto) VALUES ('ROHCOLIN');
INSERT INTO #DowBillTos (Billto) VALUES ('ROHCRO');
INSERT INTO #DowBillTos (Billto) VALUES ('ROHWES');


DROP TABLE IF EXISTS #temp
;WITH pv AS (
SELECT ROW_NUMBER() OVER (PARTITION BY vehicle_number ORDER BY vehicle_number) [row_numcity_state], 
a.vehicle_number,
a.latitude,
a.longitude,
a.datime_gmt,
a.location,
a.city_state,
a.datime_AST,
split.value
FROM (
SELECT 
ROW_NUMBER() OVER (PARTITION BY l.vehicle_number ORDER BY l.vehicle_number) [row_num],
l.vehicle_number, 
l.latitude, 
l.longitude, 
l.datime_gmt,
l.[location],
RTRIM(LTRIM(d.[value])) [city_state],
CAST(CONVERT(datetime,datime_gmt) AT TIME ZONE 'UTC' AT TIME ZONE 'Atlantic Standard Time' AS DATETIME)  [datime_AST]
FROM peoplenet.dbo.locationhistory l
CROSS APPLY STRING_SPLIT(l.[location], ';') d
INNER JOIN (SELECT l.vehicle_number, 
				    MAX(datime) [datime] 
					from peoplenet.dbo.locationhistory l 
					GROUP BY l.vehicle_number)l1 ON l1.vehicle_number = l.vehicle_number AND l1.datime = l.datime
where latitude <>0
) a
CROSS APPLY STRING_SPLIT([city_state],',') AS split
WHERE a.row_num = '2' --City and State
)
SELECT 
    p.vehicle_number,
    p.latitude,
    p.longitude,
    p.datime_gmt,
    p.[location],
    p.datime_AST,
    p.[1] [city],
    p.[2] [state]
	into #temp
FROM pv
PIVOT (
    MAX([value])
    FOR [row_numcity_state] IN ([1],[2])
    ) AS p;

 WITH cte AS (
select 
		'HATI' as 'External ID'
		, isnull((Select top 1 ref_number from referencenumber where (ord_hdrnumber = O.ord_hdrnumber) AND (ref_type = 'SHEN')),o.ord_refnum)  'Identifier 1'
		, LG.lgh_tractor  'Truck Number'
		, LG.lgh_primary_trailer 'Trailer Number'
		,l.latitude 'Latitude'
		,l.longitude 'Longitude'
		,l.datime_gmt 'Located At'
		,l.[city] 'City'
		,l.[state] 'State'
		,case when lg.lgh_outstatus ='CMP' then dateadd(second,datediff(second,getutcdate(),getdate()),lg.lgh_enddate) else null end 'Delivered At'
		,'FourkitesDow' as 'Vendor'
from orderheader  O 
Left join legheader as LG on LG.ord_hdrnumber=o.ord_hdrnumber
INNER join (Select vehicle_number,
latitude,
longitude,
city as City,
rtrim(ltrim(State)) 'State',
datime_gmt,
[datime_AST]
from #temp) l on l.vehicle_number = lg.lgh_tractor and (lgh_outstatus ='STD' or (lgh_outstatus ='CMP'AND  DATEDIFF(MINUTE,lgh_enddate,GETDATE()) <= 30))
inner join #DowBillTos d on d.Billto = o.ord_billto			
)


Select distinct
[External ID]
,[Identifier 1]
,[Truck Number]
,[Trailer Number]
,latitude
,longitude
,[Located At]
,city
,state
,[Delivered At]
into ##FourkitesOutput
from CTE 
order by [External ID]


IF @SendFTP = 0 
BEGIN 
	SELECT * FROM ##FourkitesOutput 
END

IF OBJECT_ID('tempdb..##FourkitesOutput') IS NOT NULL 
BEGIN


SET @CMD = 'bcp "SELECT * from ' + @OutputTable + '" queryout "' + @Path + '\Temp_Raw_' + @OutputTimeStamp + '.csv" -S ' + @@SERVERNAME + ' -T -t, -c'
SET @HEADERCMD = 'bcp "SELECT * from ##FourkitesCols" queryout "' + @Path + '\Temp_Headers_' + @OutputTimeStamp + '.csv" -S ' + @@SERVERNAME + ' -T -t, -c'
SET @Combine = 'copy "' + @Path + '\Temp_Headers_' + @OutputTimeStamp + '.csv" + "' + @Path + '\Temp_Raw_' + @OutputTimeStamp + '.csv" "' + @Path + '\' + 'Fourkites_Dow_'+@OutputTimeStamp + '.csv" /b'
SET @DelCMD = 'del "' + @Path + '\Temp_*.csv"'

-- Generate a list of columns	
 SELECT @COLUMNS = @COLUMNS + c.name + ','
   from tempdb..syscolumns c
   join tempdb..sysobjects t
     on c.id = t.id
  where t.name like '##FourkitesOutput%'
  order by colid

  
SELECT SUBSTRING(@COLUMNS,1, LEN(@COLUMNS)-1) as Cols INTO ##FourkitesCols
  --SELECT * FROM ##FourkitesCols

-- Run the two export queries - first for the header, then for the data
--SELECT @HEADERCMD
EXEC xp_cmdshell @HEADERCMD, no_output

--SELECT @CMD
exec xp_cmdshell @CMD,no_output

-- Combine the two files into a single file
--SELECT @Combine
EXEC xp_cmdshell @Combine,no_output

-- Clean up the two temp files we created
exec xp_cmdshell @DelCMD, no_output


SET @OutputFilePath = @Path + '\' + 'Fourkites_Dow_'+ @OutputTimeStamp + '.csv' 
SET @OutputFile = 'Fourkites_Dow_'+ @OutputTimeStamp + '.csv'

IF (SELECT COUNT(*) FROM ##FourkitesOutput) = 0 BEGIN SET @OutputFilePath = '' END

END

SELECT NULLIF(@OutputFilePath,'') [OutputFileName], NULLIF(@OutputFile,'') [CSVFile]  

--FTP---
IF LEN(@OutputFilePath) > 0 AND @SendFTP = 1 --YES 
BEGIN

DECLARE @FTPServer varchar (128)
DECLARE @FTPUser varchar (128)
DECLARE @FTPPwd varchar (128)
DECLARE @SourcePath varchar (128)
DECLARE @SourceFiles varchar (128)
DECLARE @DestPath varchar (128)
DECLARE @FTPMode varchar (10)

-- FTP attributes.
SET @FTPServer = 'ftp.truck.fourkites.com'
SET @FTPUser = ''
SET @FTPPwd = ''
SET @SourcePath = ''
SET @SourceFiles = @OutputFile
SET @DestPath = '/new' -- Destination path. Blank for root directory.
SET @FTPMode = 'binary' -- ascii, binary or blank for default.

-- Get the %TEMP% environment variable.
DECLARE @tempdir varchar (128)
CREATE TABLE #tempvartable(info VARCHAR(1000 ))
INSERT #tempvartable EXEC master.. xp_cmdshell 'echo %temp%'
SET @tempdir = (SELECT top 1 info FROM #tempvartable)
IF RIGHT( @tempdir, 1 ) <> '\' SET @tempdir = @tempdir + '\'
DROP TABLE #tempvartable

DECLARE @workfile varchar (128)
DECLARE @nowstr varchar (25)

-- Generate @workfile
SET @nowstr = replace( replace(convert (varchar( 30), GETDATE(), 121 ), ' ' , '_' ), ':', '-')
SET @workfile = 'FTP_SPID' + convert (varchar( 128), @@spid) + '_' + @nowstr + '.txt'

-- Deal with special chars for echo commands.
select @FTPServer = replace( replace(replace (@FTPServer, '|', '^|'),'<' ,'^<'), '>','^>' )
select @Path = replace( replace(replace (@Path, '|', '^|'),'<' ,'^<'), '>','^>' )
select @FTPUser = replace( replace(replace (@FTPUser, '|', '^|'), '<','^<' ),'>', '^>')
select @FTPPwd = replace( replace(replace (@FTPPwd, '|', '^|'), '<','^<' ),'>', '^>')
select @DestPath = replace( replace(replace (@DestPath, '|', '^|'),'<' ,'^<'), '>','^>' )
IF RIGHT( @SourcePath, 1 ) <> '\' SET @SourcePath = @SourcePath + '\'

-- Build the FTP script file.
SELECT @cmd = 'echo ' + 'open ' + @FTPServer + ' > ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + @FTPUser + '>> ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + @FTPPwd + '>> ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + 'prompt ' + ' >> ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd, no_output

IF LEN (@FTPMode) > 0
BEGIN
       select @cmd = 'echo ' + @FTPMode + ' >> ' + @tempdir + @workfile
       EXEC master ..xp_cmdshell @cmd, no_output
END
IF LEN (@DestPath) > 0
BEGIN
       select @cmd = 'echo ' + 'cd ' + @DestPath + ' >> ' + @tempdir + @workfile
       EXEC master ..xp_cmdshell @cmd, no_output
END
--select @cmd = 'echo ' + 'put ' + @SourcePath + @SourceFiles + ' >> ' + @tempdir + @workfile
select @cmd = 'echo ' + 'put ' + @OutputFilePath + ' >> ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd , no_output
select @cmd = 'echo ' + 'quit' + ' >> ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd, no_output


-- Execute the FTP command via script file.
select @cmd = 'ftp -s:' + @tempdir + @workfile
create table #a ( id int identity(1 ,1), s varchar( 1000))
insert #a
EXEC master ..xp_cmdshell @cmd
--select id, ouputtmp = s from #a

--show error for SQL JOB
IF (SELECT COUNT(*) FROM #a WHERE s LIKE '%invalid%' OR s LIKE '%failed%') > 0
BEGIN
	;THROW 51000, 'FTP Error', 1
END
ELSE
BEGIN
	--move file to archive
	select @cmd = 'move "' + @OutputFilePath + '"' + ' "'  + @Path + '\Archive"'
	EXEC master ..xp_cmdshell @cmd, no_output
END



--Clean up.
DROP TABLE IF EXISTS #a
select @cmd = 'del ' + @tempdir + @workfile
EXEC master ..xp_cmdshell @cmd, no_output

END --FTP

END