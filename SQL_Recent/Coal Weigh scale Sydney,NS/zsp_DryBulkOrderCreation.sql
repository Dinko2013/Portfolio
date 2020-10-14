USE [TMW_STD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[zsp_DryBulkOrderCreation] @frDt datetime, @toDt datetime , @mine varchar(13) , @mode int
AS
BEGIN

--GET TRANSACTION TO USE FOR ORDER CREATION EXCLUDING ANY TRANSACTIONS ALREADY PROCESSED
SELECT	ISNULL(XCD.TMWID,'UNKNOWN') AS Driver,
		 VehicleNo AS Tractor,
		  CASE WHEN (CDA.VehicleNo in('2510','2518','2522','2529')) THEN 'UNKNOWN'
			  WHEN (CDA.VehicleNo in('2501','316')) THEN 'UNKNOWN'
              ELSE
			  CDA.TrailerID 
			  End AS Trailer,
		 XCP.TMWCommodityCode AS Comm,
		 CAST ((CAST(NetWeight AS FLOAT) / 1000) AS NUMERIC(5,2)) AS Wght ,
		 CAST(transdate AS DATE) As Act_Date,
		 XMM.MasterOrder# AS Master_Order,
		 CASE WHEN (CDA.VehicleNo in('2510','2518','2522','2529')) THEN 'TOMPOR'
			  WHEN (CDA.VehicleNo in('2501','316')) THEN 'ISLSYD'
              ELSE
			  'UNKNOWN'
			  End AS Carrier,
		 DeliveryDesc AS Mine,
		 CDA.TransDate AS TransactionDate,
		 CDA.TransNo AS Trasaction#
		 INTO #TempTable1
		 FROM [TMW_STD].[dbo].[ztbl_CoalDataArchive] AS CDA
		 LEFT JOIN [TMW_STD].[dbo].[XREFCoalDrivers] AS XCD ON CDA.DriverDesc = XCD.DriverName
		 LEFT JOIN [TMW_STD].[dbo].[XREFCoalProducts] AS XCP ON CDA.ProductDesc = XCP.ProductName	
		 LEFT JOIN [TMW_STD].[dbo].[XREFMineMasters] AS XMM ON CDA.DeliveryDesc = XMM.MineName
		 LEFT JOIN [TMW_STD.[dbo].[ztbl_Tonnage_CSV_Import_Updated] AS PREV ON  PREV.transno = CDA.TransNo
		 WHERE CAST(CDA.TransDate AS DATE) between CAST(@frDt AS DATE) and CAST(@toDt as DATE) and DeliveryDesc = @mine and PREV.transno is null


UPDATE #TempTable1
SET Tractor = '2510'
Where Carrier ='TOMPOR'


UPDATE #TempTable1
SET Tractor = '2501'
Where Carrier ='ISLSYD'

--IF MODE = EXPORT 
IF @mode = 2
BEGIN
 --INSERT INTO FINAL TABLE
INSERT INTO ztbl_DryBulkOrders
		 SELECT Driver,
				Tractor,
				Trailer,
				Wght,
				Comm,
				Act_Date,
				master_order,
				Carrier,
				'0' AS orderno,
				'' AS import_dt,
				''AS message_txt,
				Trasaction#
		 FROM #TempTable1

-- DECLARE ORDER CREATION PROCEDURE PARAMETERS

DECLARE	@driver		VARCHAR(8)
	, @tractor		VARCHAR(8)
	, @trailer		VARCHAR(8)
	, @weight		FLOAT
	, @comm			VARCHAR(8)
	, @act_date		DATETIME
	, @mstr_ord		INT
	, @carrier      VARCHAR(8)
	, @RowID		INT
	, @return_value	INT
	, @message		VARCHAR(255)

SELECT @RowID = 0
SELECT @message = ''

WHILE (1 = 1) 
BEGIN 

	SELECT TOP 1 @RowID = ord_id
		, @driver = driver
		, @tractor = tractor
		, @trailer = trailer
		, @weight = cast([weight] AS FLOAT)
		, @comm = commodity
		, @act_date = act_date
		, @mstr_ord = master_order
		, @carrier = carrier
	FROM ztbl_DryBulkOrders
	WHERE orderno = 0
		AND ord_id > @RowID 
	ORDER BY ord_id

	-- Exit loop if no more records
	IF @@ROWCOUNT = 0
	BREAK;	

	EXEC @return_value = [dbo].[zsp_OrderFromMaster_Tonnage_CSV_Updated] @driver, @tractor, @trailer, @weight, @comm, @act_date, @mstr_ord,@carrier

	SELECT @message = 
	CASE 
	WHEN @return_value = 1 THEN
		'Invalid Driver ID ' + @driver
	WHEN @return_value = 2 THEN
		'Invalid Tractor ID ' + @tractor
	WHEN @return_value = 3 THEN
		'Invalid Trailer ID ' + @trailer
	WHEN @return_value = 4 THEN
		'Invalid Commodity ID ' + @comm
	WHEN @return_value = 5 THEN
		'Invalid Master Order Number ' + CAST(@mstr_ord as VARCHAR)
	WHEN @return_value = 6 THEN
		'Invalid Carrier ID ' + @carrier
	ELSE 
		''
	END 

	IF @message <> '' 
	BEGIN
		UPDATE ztbl_DryBulkOrders SET message_txt = @message WHERE ord_id = @RowID
		UPDATE ztbl_DryBulkOrders SET transno = null WHERE ord_id = @RowID
	END
	ELSE
	BEGIN
		UPDATE ztbl_DryBulkOrders SET orderno = @return_value, message_txt = CAST(getdate() as VARCHAR) WHERE ord_id = @RowID
	END

	SET @message = ''
	
 END
SELECT * FROM #tempTable1
END
SELECT * FROM #tempTable1
END
GO