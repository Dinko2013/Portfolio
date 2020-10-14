USE [TMW_STD]
GO

/****** Object:  StoredProcedure [dbo].[zsp_CNTIREDipProcessing]    Script Date: 2020-10-14 4:54:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[zsp_CNTIREDipProcessing]
@filename VARCHAR(500)
AS
BEGIN


-- ==================================================================================================================================
-- Author:		Mo Keita
-- Create date: 8/19/2020
-- Description:	Parses and insert Canadian Tire Files to Fuel tables
-- Changelog:   8/24/2020 - added extra checks and use tank id instead of forecast id,as it is used by inventory services. -KM
--				8/27/2020 - added more rows to check for temp and ullage:
--						    Temp rows from (27,28,29) To (27,28,29,30) 
--							and Ullage rows from(32,33,34,35) To(32,33,34,35,36) - MK
--				9/11/2020 - delete blank lines and update the rownumbers - KM
-- ===================================================================================================================================


SET NOCOUNT ON;

DECLARE  @CMD VARCHAR(4000)
DECLARE @Path as VARCHAR (100) ='\\seasql2\ddApps\Dips\CanadianTire'
DECLARE @fullpath as VARCHAR(600) = @Path +'\'+ @filename
DECLARE @fileDateTime DATETIME
DECLARE @SiteID VARCHAR(50)


DROP TABLE if EXISTS #temp
CREATE TABLE #temp (rownum INT, val VARCHAR(8000))


--Hold Processed file
DROP TABLE IF EXISTS #ztl_CNTIRE_Dips
CREATE TABLE #ztl_CNTIRE_Dips ( [SiteID] VARCHAR(10), [dipTime] DATETIME, TankID INT, Product VARCHAR(50),grossvol DECIMAL(18,2),netvol DECIMAL(18,2),diplevel DECIMAL(18,2),[temprature] DECIMAL(18,2),ullage DECIMAL(18,2))

-- Dip Site ID reference table
DROP TABLE IF EXISTS #ztl_CNTIRE_Dips_Xref
CREATE TABLE #ztl_CNTIRE_Dips_Xref(cmp_id VARCHAR(8),cmp_altid VARCHAR(8))

INSERT INTO #ztl_CNTIRE_Dips_Xref
Select cmp_id,cmp_altid from company where cmp_mastercompany ='CNTRPAR' and cmp_active ='Y' and cmp_consingee ='Y'


INSERT INTO #temp(rownum, val)
SELECT [LineNo], Line FROM Dbo.uftReadfileAsTable(@Path,@fileName)

IF NOT EXISTS (SELECT val FROM #temp WHERE val LIKE 'Error whilst Opening file%' AND rownum = 1)
BEGIN

--9/11/2020 -- delete blank lines and update rownum -KM
DELETE FROM #temp WHERE LEN(val) = 0
UPDATE x
SET x.rownum = x.New_rownum
FROM (
      SELECT rownum, ROW_NUMBER() OVER (ORDER BY [rownum]) AS New_rownum
      FROM #temp
      ) x
WHERE x.rownum <> x.New_rownum

SELECT @SiteID = SUBSTRING(val,CHARINDEX('#',val)+1,LEN(val)) FROM #temp WHERE rownum=1
SELECT @fileDateTime = ISNULL(TRY_CAST(LTRIM(RTRIM(val)) AS DATETIME),TRY_CAST(LTRIM(RTRIM(SUBSTRING(val,CHARINDEX(',',val,0)+1,99))) AS DATETIME)) 
FROM #temp WHERE rownum = 7

--search row 8 if 7 is not found
IF @fileDateTime IS NULL
BEGIN
	SELECT @fileDateTime = ISNULL(TRY_CAST(LTRIM(RTRIM(val)) AS DATETIME),TRY_CAST(LTRIM(RTRIM(SUBSTRING(val,CHARINDEX(',',val,0)+1,99))) AS DATETIME)) 
	FROM #temp WHERE rownum = 8
END

--SELECT * FROM #temp

DROP TABLE IF EXISTS #tempProd
CREATE TABLE #tempProd ( [rownum] int, [Product] varchar(500), [val] varchar(500))

INSERT INTO #tempProd(rownum, Product, val)
SELECT t1.rownum, SUBSTRING(t1.val,0,CHARINDEX(' ',t1.val)) 'Product' , t2.val
FROM #temp t1
INNER JOIN #temp t2 ON t2.rownum = t1.rownum+1
WHERE t1.val LIKE '%regular%' OR t1.val LIKE '%premium%' OR t1.val LIKE '%diesel%'
and SUBSTRING(t1.val,0,CHARINDEX(' ',t1.val)) IS NOT NULL


BEGIN TRY 
--Collect Processed Data

		INSERT INTO #ztl_CNTIRE_Dips(SiteID,dipTime,TankID,Product,grossvol,netvol,diplevel,temprature,ullage)
		SELECT  @SiteID [SiteID], @fileDateTime [diptime],ROW_NUMBER() OVER (PARTITION BY @SiteID ORDER BY @SiteID)[TankID],tp.Product
				,TRY_PARSE(gr.value AS DECIMAL(18,2) using 'en-CA') [grossVol]
				,TRY_PARSE(nt.value AS DECIMAL(18,2) using 'en-CA') [netVol]
				,TRY_PARSE(dp.value AS DECIMAL(18,2) using 'en-CA') [dipLevel]
				,TRY_PARSE(tr.value AS DECIMAL(18,2) using 'en-CA') [temprature]
				,TRY_PARSE(ul.value AS DECIMAL(18,2) using 'en-CA') [ullage]
		FROM #tempProd tp
		CROSS APPLY (
			SELECT ss.[value], ROW_NUMBER() OVER (PARTITION BY [tp].[rownum] ORDER BY [tp].[rownum]) AS RN
			FROM STRING_SPLIT([tp].[val], ' ') AS [ss] ) AS gr
		CROSS APPLY (
			SELECT ss.[value], ROW_NUMBER() OVER (PARTITION BY [tp].[rownum] ORDER BY [tp].[rownum]) AS RN
			FROM STRING_SPLIT([tp].[val], ' ') AS [ss] ) AS nt
		CROSS APPLY (
			SELECT ss.[value], ROW_NUMBER() OVER (PARTITION BY [tp].[rownum] ORDER BY [tp].[rownum]) AS RN
			FROM STRING_SPLIT([tp].[val], ' ') AS [ss] ) AS dp
		CROSS APPLY (
			SELECT ss.[value], ROW_NUMBER() OVER (PARTITION BY [tp].[rownum] ORDER BY [tp].[rownum]) AS RN
			FROM STRING_SPLIT([tp].[val], ' ') AS [ss] ) AS tr
		CROSS APPLY (
			SELECT ss.[value], ROW_NUMBER() OVER (PARTITION BY [tp].[rownum] ORDER BY [tp].[rownum]) AS RN
			FROM STRING_SPLIT([tp].[val], ' ') AS [ss] ) AS ul
		WHERE gr.RN = 10
		AND (nt.RN in (17,18) AND nt.value <> '') 
		AND (dp.RN in (24,26) AND dp.value <> '') 
		AND (tr.rn IN (27,28,29,30) AND tr.value <> '') 
		AND (ul.rn in (32,33,34,35,36) AND ul.value <> '')

--Verify is it current and aligned with tanks then insert into fuelinvamounts
INSERT INTO fuelinvamounts(cmp_id, inv_date, inv_type, inv_sequence, inv_readingdate, inv_value1, inv_value2, inv_value3, inv_value4, inv_value5, inv_value6)
SELECT cmp_id
, inv_date
, inv_type
, inv_sequence
, ReadingDate
, ISNULL(CAST([1] as numeric(18,0)),0) as inv_value1
, ISNULL(CAST([2] as numeric(18,0)),0) as inv_value2
, ISNULL(CAST([3] as numeric(18,0)),0) as inv_value3
, ISNULL(CAST([4] as numeric(18,0)),0) as inv_value4
, ISNULL(CAST([5] as numeric(18,0)),0) as inv_value5
, ISNULL(CAST([6] as numeric(18,0)),0) as inv_value6 
FROM (
	SELECT Z.SiteID as Cust_Site_ID
		, C.cmp_id
		, CAST(Z.dipTime AS DATE) AS inv_date
		, 'READ' AS inv_type
		, 1 AS inv_sequence
		, DATEADD(mi, (DATEDIFF(mi, 0, Z.dipTime)/30*30), 0) AS ReadingDate
		, tankdetail.cmp_tank_id
		, Z.netvol
	FROM #ztl_CNTIRE_Dips Z
	JOIN #ztl_CNTIRE_Dips_Xref C ON Z.SiteID = C.cmp_altid
	LEFT JOIN ztl_CNTIRE_Dips_Archive A ON Z.SiteID = A.SiteID AND Z.TankID = A.TankID AND Z.dipTime = A.dipTime
	LEFT OUTER JOIN company_tankdetail AS tankdetail ON C.cmp_id = tankdetail.cmp_id AND Z.TankID = tankdetail.cmp_tank_id
    WHERE A.SiteID IS NULL
	group by Z.SiteID, c.cmp_id, CAST(Z.dipTime AS DATE),DATEADD(mi, (DATEDIFF(mi, 0, Z.dipTime)/30*30), 0), Z.netvol,tankdetail.cmp_tank_id
	) T1
PIVOT
	(
	SUM(netvol)
	FOR cmp_tank_id IN
	([1],[2],[3],[4],[5],[6])
	) AS T2
order by ReadingDate desc

--Archive Data
INSERT INTO ztl_CNTIRE_Dips_Archive([SiteID],[dipTime],[TankID],[Product],[grossvol],[netvol],[diplevel],[temprature],[ullage],[sourcefile])
SELECT [SiteID],[dipTime],[TankID],[Product],[grossvol],[netvol],[diplevel],[temprature],[ullage],@fileName FROM #ztl_CNTIRE_Dips

--TRUNCATE table ztl_CNTIRE_Dips_Archive

--delete archive
DELETE FROM ztl_CNTIRE_Dips_Archive WHERE [dateprocessed] < GETDATE() -7

--Archive Processed File
SELECT @cmd = 'move "' + @fullPath + '"' + ' "'  + @Path + '\Archive"'
--EXEC master ..xp_cmdshell @cmd, no_output

END TRY  

BEGIN CATCH  
BEGIN
DECLARE @Message VARCHAR(2000) = @filename + ' ' + (SELECT ERROR_MESSAGE() AS ErrorMessage) 

IF LEN(@Message) > 0 AND @Message IS NOT NULL	
BEGIN
	    EXEC msdb.dbo.sp_send_dbmail
		@profile_name = N'SHSQLmail', 
		@recipients = '',
		@subject = 'CNTIRE DIP File Processing Error',
		@body = @Message,
		@body_format = 'HTML',
		@from_address = '';
END

	END
END CATCH  

END

ELSE --File not found
BEGIN
SELECT 'File not found'

END


END
GO


