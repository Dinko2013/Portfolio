
 
CREATE TABLE #FuelData(
		BatchID varchar (50)
		,DocType varchar (3)
		,TransNumber nvarchar(100)
		,TransDate date
		,PostDate date
		,VendorID varchar (12)
		,VendorName varchar(50)
		,InvoiceNo varchar (24)
		,Descrip varchar (120)
		,DEBIT_ACCT  varchar (50)
		,DEBIT_AMT numeric (15,4)
		,CREDIT_ACCT  varchar (50)
		,CREDIT_AMT numeric (15,4)
		,UNITNUMBER  varchar (24)
		,UNITTYPE nvarchar(10)
		,MDAGroup varchar (50)
		,UnitDivision  varchar (12)
		,UnitEntity varchar (12)
		,DistType varchar (12) 
		,Quantity float
		,Amt float
		,LineType varchar(50)
		,MDA_Flag int
		)

declare @cap1  numeric (15,4) = 0.01 -- cap amount of 0.01

SELECT UnitType, UnitID, SnapshotDate, Division, NULL as LicenseType
INTO #Fleet1
FROM FleetList.dbo.vw_FleetList_Snapshot_Fuel

SELECT Division, TMW_abbr
INTO #Fleet2
FROM FleetList.dbo.Division_TBL

-- INSERT INTO TEMP TABLE  
INSERT INTO #FuelData ([BatchID],DocType, TransNumber, TransDate,PostDate,VendorID,VendorName,InvoiceNo,Descrip
						,DEBIT_ACCT, DEBIT_AMT, CREDIT_ACCT, CREDIT_AMT, UNITNUMBER, UNITTYPE, MDAGroup
						,UnitDivision,UnitEntity,DistType,Quantity, Amt, LineType, MDA_Flag)
--Transaction totals for tractor fuel > NOT FLEET ONE
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,(CASE WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'BROKERS' THEN
			-- Broker and NO Cap
		(CASE WHEN ISNULL(E.COL_DATA, 0.0) <= 0.0  OR (ISNULL(E.COL_DATA, 0.0) > 0.0 AND F.cfb_tractorfuelcode IN ('DEFD', 'AUTO')) THEN
				F.cfb_totaldue
		 ELSE -- Broker With Cap -- added **@cap
				(ROUND(CAST((( (E.COL_DATA + @cap1) * F.cfb_trcgallons) * (ISNULL(TR.tax_rate, 0) / 100)) + (((E.COL_DATA + @cap1) * F.cfb_trcgallons) * (ISNULL(TR2.tax_rate, 0) / 100)) + ((E.COL_DATA + @cap1) * F.cfb_trcgallons) AS float), 2))
		 END)
	   WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'EMPLOYEE FUEL' THEN
		        CASE WHEN F.cfb_tractorfuelcode IN ('DEFD', 'AUTO') THEN
					F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax2, 0) + ISNULL(F.cfb_tax1, 0))
				ELSE
					F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax2, 0) + ISNULL(F.cfb_tax1, 0))
				END
	   ELSE
				F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))
	   END) - ISNULL(cfb_advanceamt, 0) 
	   ---(CASE WHEN t.division = 'G3'  AND cac_description NOT LIKE '%Suncor%' and t.unittype = 'BRK' THEN f.cfb_trcgallons * 0.01 else 0 end) 
	   AS Amt
	  ,'TotalUnitFuel' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) AND F.cfb_transferred_to_GP = 'N' 
AND CASE WHEN F.cfb_tractorfuelcode IN ('DEFD', 'AUTO', 'OIL') 
AND ISNULL(T.UnitType, 'Other') IN ('BRK', 'OTHER') THEN 'FUEL' ELSE F.cfb_tractorfuelcode END NOT IN ('DEFD', 'AUTO', 'OIL', 'WS') 
AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'
and cfb_accountid <> '611439'  -- NOT Fleet One >   select * from cdacctcode where cac_id = '611439'

UNION ALL

--Transaction totals for tractor fuel > FLEET ONE
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,(CASE WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'BROKERS' THEN
			-- Broker and NO Cap
		(CASE WHEN ISNULL(E.COL_DATA, 0.0) <= 0.0  OR (ISNULL(E.COL_DATA, 0.0) > 0.0 AND F.cfb_tractorfuelcode IN ('DEFD', 'AUTO')) THEN
				F.cfb_totaldue
		 ELSE -- Broker with Cap  -- added **@cap
				(ROUND(CAST(ROUND((ROUND(((E.COL_DATA + @cap1) * F.cfb_trcgallons), 2) * ROUND((ISNULL(TR.tax_rate, 0) / 100), 2)), 2) + ROUND((ROUND(((E.COL_DATA + @cap1) * F.cfb_trcgallons), 2) * ROUND((ISNULL(TR2.tax_rate, 0) / 100), 2)), 2) + ROUND(((E.COL_DATA + @cap1) * F.cfb_trcgallons), 2) AS float), 2)
				)
		 END) 
	   WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'EMPLOYEE FUEL' THEN
		        CASE WHEN F.cfb_tractorfuelcode IN ('DEFD', 'AUTO') THEN
					F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax2, 0) + ISNULL(F.cfb_tax1, 0))
				ELSE
					F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax2, 0) + ISNULL(F.cfb_tax1, 0))
				END
	   ELSE
				F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))
	   END)  AS Amt
	  ,'TotalUnitFuel' AS LineType
	  , 0 AS MDA_Flag
FROM SEASQL.TMW_STD.dbo.FleetoneFleetonecdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) AND F.cfb_transferred_to_GP = 'N' 
AND CASE WHEN F.cfb_tractorfuelcode IN ('DEFD', 'AUTO', 'OIL') 
AND ISNULL(T.UnitType, 'Other') IN ('BRK', 'OTHER') THEN 'FUEL' ELSE F.cfb_tractorfuelcode END NOT IN ('DEFD', 'AUTO', 'OIL', 'WS', 'FEE', 'CASH') 
AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'
and cfb_accountid = '611439' -- Fleet One 

UNION ALL

--Broker Fuel Recovery Account - Capped Brokers ('FuelExpense')
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
																			-- what accounts - 											
	  ,CASE WHEN cfb_tractorfuelcode IN ('DEFD', 'MISC') AND cfb_accountid IN ('8852','7089621973', '7089406276', '9116')  THEN F.cfb_trcgallons * .08  ELSE F.cfb_trcgallons * @cap1 END AS Amt
	  ,'FuelExpense' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
LEFT JOIN dbo.truckstops AS TS ON F.cfb_truckstopcode = TS.ts_code
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN FleetList.dbo.vw_FleetList_Snapshot_Fuel  AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN FleetList.dbo.Division_TBL AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.manpowerprofile AS M ON F.cfb_unitnumber = M.mpp_id
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.labelfile AS L2 ON M.mpp_division = L2.abbr AND L2.labeldefinition = 'Division'
WHERE  T.UnitType = 'BRK' 
--and cfb_accountid IN ('5590604748', '494166', '8852','7089621973', '894635','7089406276', '7081715880', '7082102591', '7084988450', '78057866', '78065547', '78090917', '558', '511', '9116')  
and F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'
/*CAP*/--AND (/*E.table_key is null OR*/ cfb_tractorfuelcode = 'DEFD')


UNION ALL

--Transaction totals for reefer fuel
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,'HWY REEFER'
	  ,ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') AS UNITTYPE
	  ,'EMPLOYEE FUEL' AS MDAGroup
	  ,'09'
	  ,'09' AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_reefergallons AS Quantity
	  ,F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0)) AS Amt
	  ,'TotalReeferFuel' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
WHERE F.cfb_reefergallons > 0 AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

-- TotalUnitFee
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,cfb_totaldue AS Amt
	  ,'TotalUnitFee' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN FleetList.dbo.vw_FleetList_Snapshot_Fuel AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN FleetList.dbo.Division_TBL AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE  F.cfb_transferred_to_GP = 'N'  AND A.cac_Vendor_Code + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)' and cfb_tractorfuelcode = 'FEE'
UNION ALL

--Transaction totals for DEF NOT Fleet One
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'BROKERS' THEN
		-- Broker NOT Capped
		(CASE WHEN ISNULL(E.COL_DATA, 0.0) <= 0.0  OR (ISNULL(E.COL_DATA, 0.0) > 0.0 AND F.cfb_tractorfuelcode = 'DEFD') THEN
				F.cfb_totaldue
		 ELSE -- Broker is Capped
				ROUND(CAST(((E.COL_DATA * F.cfb_trcgallons) * (ISNULL(TR.tax_rate, 0) / 100)) +((E.COL_DATA * F.cfb_trcgallons) *(ISNULL(TR2.tax_rate, 0) / 100)) + (E.COL_DATA * F.cfb_trcgallons) AS float), 2)
		 END)
	   ELSE
				ISNULL(F.cfb_ProductAmt1, F.cfb_totaldue) - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))
	   END AS Amt
	  ,'TotalUnitDEF' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (((F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) AND F.cfb_transferred_to_GP = 'N' AND F.cfb_tractorfuelcode = 'DEFD') OR (F.cfb_productcode1 = 'DEFD')) 
AND ISNULL(T.UnitType, 'Other') NOT IN ('BRK', 'OTHER') 
AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'
and cfb_accountid <> '611439'
UNION ALL

--Transaction totals for DEF for Fleet One
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,cfb_trccost AS Amt
	  ,'TotalUnitDEF' AS LineType
	  , 0 AS MDA_Flag
FROM SEASQL.TMW_STD.dbo.FleetoneFleetonecdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (((F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) AND F.cfb_transferred_to_GP = 'N')) AND ISNULL(T.UnitType, 'Other') NOT IN ('BRK', 'OTHER') AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'
and cfb_accountid = '611439' and cfb_tractorfuelcode = 'DEFD'

UNION ALL

--Transaction totals for other Automotive Products
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'BROKERS' THEN
				F.cfb_totaldue
	   ELSE
				F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))
	   END AS Amt
	  ,'TotalUnitAUTO' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) 
AND F.cfb_transferred_to_GP = 'N' 
AND F.cfb_tractorfuelcode IN ('AUTO', 'OIL')  
AND ISNULL(T.UnitType, 'Other') NOT IN ('BRK', 'OTHER') 
AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

--Transaction totals for other Automotive Products
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN (CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END) = 'BROKERS' THEN
				F.cfb_totaldue
	   ELSE
				F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))
	   END AS Amt
	  ,'TotalUnitScale' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) 
AND F.cfb_transferred_to_GP = 'N' AND F.cfb_tractorfuelcode IN ('WS') 
AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

--HST Totals
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax2, 0) AS Amt
	  ,'HST' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
WHERE (F.cfb_reefercost IS NULL OR F.cfb_reefercost = '') AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

-- HST for HWY REEFER
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,'HWY REEFER'
	  ,ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') AS UNITTYPE
	  ,'EMPLOYEE FUEL' AS MDAGroup
	  ,'09'
	  ,'09' AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax2, 0) AS Amt
	  ,'HST' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
WHERE F.cfb_reefercost IS NOT NULL AND F.cfb_reefercost <> '' AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

--QST Totals Not DEF
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,F.cfb_tax1 AS Amt
	  ,'QST' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
WHERE (F.cfb_reefercost IS NULL OR F.cfb_reefercost = '') AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)' 
AND CASE WHEN CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END = 'EMPLOYEE FUEL ' 
AND F.cfb_tractorfuelcode = 'DEFD' THEN 0 ELSE 1 END = 1 --AND CASE WHEN T.UnitType = ('BRK') THEN --'BROKERS' --WHEN T.UnitType IN ('CO', 'CO-L') THEN --'FUEL PURCHASES' --ELSE --'EMPLOYEE FUEL'--END <> 'EMPLOYEE FUEL'
-- db 5/14/2018
UNION ALL
--QST Totals for DEF
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,'HWY REEFER'
	  ,ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') AS UNITTYPE
	  ,'EMPLOYEE FUEL' AS MDAGroup
	  ,'09'
	  ,'09' AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,F.cfb_tax1 AS Amt
	  ,'QST' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
WHERE (F.cfb_reefercost IS NOT NULL AND F.cfb_reefercost <> '') AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

--Fuel Premium Totals Only for Broker with a Cap..
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,D.TMW_abbr -- unitdivision
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,ROUND((F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))) - ( (E.COL_DATA + @cap1) * F.cfb_trcgallons), 2) AS Amt
	  ,'FuelPremium' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31 and isnull(E.COL_DATA, 0.0) > 0.0  -- Added 05/17/2018 db to ensure no FuelPremium when cap is = 0.0
WHERE E.COL_DATA IS NOT NULL AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)' AND F.cfb_tractorfuelcode NOT IN ('DEFD', 'AUTO')

UNION ALL

--Fuel Cap HST Totals for only Brokers
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,D.TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN ISNULL(E.COL_DATA, 0.0) <= 0.0  OR E.COL_DATA = '' OR (ISNULL(E.COL_DATA, 0.0) > 0.0 AND F.cfb_tractorfuelcode IN ('DEFD', 'AUTO')) THEN
			f.cfb_tax3
	   ELSE
		
			--(ROUND((cfb_trccost), 2) * ROUND((ISNULL(TR.tax_rate, 0)) / 100, 2)) + (ROUND((cfb_trccost), 2) * ROUND(ISNULL(TR2.tax_rate, 0) / 100, 2))
			ROUND(  ( (  ( (E.COL_DATA + @cap1) * F.cfb_trcgallons)* (ISNULL(TR.tax_rate, 0) / 100) ) ) + (((E.COL_DATA + @cap1) * F.cfb_trcgallons) * (ISNULL(TR2.tax_rate, 0) / 100) ) , 2)
	   END AS Amt
	  ,'FuelCap HST' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'HST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END = 'BROKERS' 
AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)' 

UNION ALL

--Fuel Cap QST Totals
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,D.TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN ISNULL(E.COL_DATA, 0.0) <= 0.0  OR E.COL_DATA = '' OR (ISNULL(E.COL_DATA, 0.0) > 0.0 AND F.cfb_tractorfuelcode = 'DEFD') THEN
			f.cfb_tax1
	   ELSE -- if Broker with Cap
			ROUND(((E.COL_DATA + @cap1) * F.cfb_trcgallons) * (dbo.zfn_Get_TaxRate(F.cfb_truckstopstate, F.cfb_transdate) / 100), 2)
	   END AS Amt
	  ,'FuelCap QST' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
WHERE cfb_truckstopstate = 'QC' AND F.cfb_transferred_to_GP = 'N' 
AND CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END = 'BROKERS' 
AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

--Employee Fuel Amount
SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,'OTHER' AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,E.ee_occupation
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,F.cfb_totaldue + ISNULL(F.cfb_tax1, 0) AS Amt
	  ,'EmployeeFuel' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EMPLOYEEPROFILE AS E ON F.cfb_unitnumber = E.ee_ID
WHERE  CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END = 'EMPLOYEE FUEL' 
AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN T.UnitType = ('BRK') THEN -- Broker
				
				 F.cfb_trcgallons * (cfb_trccostpergallon 
				 - CASE WHEN cfb_tractorfuelcode IN ('DEFD', 'MISC') and F.cfb_accountid IN ('8852','7089621973')  THEN ( .08) ELSE ( @cap1) END  ) 
				 + ( ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0) + ISNULL(F.cfb_tax3, 0))
		ELSE
					F.cfb_totaldue 
		END	AS Amt
	  ,'TotalCredit' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.taxrate AS TR ON F.cfb_truckstopstate = TR.tax_state AND TR.tax_description <> 'GST' AND F.cfb_transdate BETWEEN TR.tax_effectivedate AND TR.tax_expirationdate
LEFT JOIN dbo.taxrate AS TR2 ON F.cfb_truckstopstate = TR2.tax_state AND TR2.tax_description = 'GST' AND F.cfb_transdate BETWEEN TR2.tax_effectivedate AND TR2.tax_expirationdate
WHERE (F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,CASE WHEN T.UnitType = 'BRK' THEN
			CASE WHEN  F.cfb_tractorfuelcode = 'DEFD' THEN--CASE WHEN E.COL_DATA IS NULL OR (E.COL_DATA IS NOT NULL AND F.cfb_tractorfuelcode = 'DEFD') THEN
				ROUND((F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))), 2) - 	  
				ROUND(CASE WHEN T.UnitType = 'BRK' AND  (/*E.table_key is null OR*/ cfb_tractorfuelcode = 'DEFD')  THEN
				CASE WHEN 
				cfb_tractorfuelcode IN ('DEFD', 'MISC') 
				AND cfb_accountid IN ('8852','7089621973', '7089406276', '9116')  
				THEN F.cfb_trcgallons * .08  
				ELSE F.cfb_trcgallons * .01
				 END 
				 ELSE 
				 0 
				 END, 2)
			ELSE
				ROUND((F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))), 2)--CAST(ROUND((E.COL_DATA * F.cfb_trcgallons), 2) AS float)
			- 	  
				ROUND(CASE WHEN T.UnitType = 'BRK'  THEN
				CASE WHEN 
				cfb_tractorfuelcode IN ('DEFD', 'MISC') 
				AND cfb_accountid IN ('8852','7089621973', '7089406276', '9116')  
				THEN F.cfb_trcgallons * .08  
				ELSE F.cfb_trcgallons * .01
				 END 
				 ELSE 
				 0 
				 END, 2)
			END
	   ELSE
			ROUND((F.cfb_totaldue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0))), 2) 
	   END AS Amt
	  ,'InterCompany' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EXTRA_INFO_DATA AS E ON F.cfb_unitnumber = E.TABLE_KEY AND E.EXTRA_ID = 10 AND E.TAB_ID = 2 AND E.COL_ID = 31
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
LEFT JOIN dbo.labelfile AS L2 ON emp.ee_occupation = L2.abbr AND L2.labeldefinition = 'Division'
WHERE (F.cfb_reefergallons IS NULL OR F.cfb_reefergallons = 0) AND F.cfb_transferred_to_GP = 'N' AND 
ISNULL(L2.label_extrastring1, ISNULL(L.label_extrastring1, EMP.ee_licensenumber)) <> 
	CASE WHEN LEFT(A.cac_Vendor_Code, 1) IN ('S', 'W') THEN '00'
	WHEN LEFT(A.cac_Vendor_Code, 1) = 'H' THEN '02'
	WHEN LEFT(A.cac_Vendor_Code, 1) = 'F' THEN '14'
	WHEN LEFT(A.cac_Vendor_Code, 1) = 'M' THEN '16'
	WHEN LEFT(A.cac_Vendor_Code, 1) = 'R' THEN '19'
	WHEN LEFT(A.cac_Vendor_Code, 1) = 'G' THEN '72'
	END AND 
A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

UNION ALL

SELECT null  AS BatchID
	  ,1 AS DocType
	  ,F.cfb_transnumber
	  ,F.cfb_transdate
	  ,GETDATE()
	  ,A.cac_vendor_code
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS VendorName
	  ,F.cfb_referencenumber AS InvoiceNo
	  ,A.cac_description + ' [' + A.cac_vendor_code + '] ' AS Description			
      ,null AS DEBIT_ACCT
	  ,null AS DEBIT_AMT
	  ,null AS  CREDIT_ACCT 
	  ,null AS CREDIT_AMT
	  ,F.cfb_unitnumber
	  ,CASE WHEN T.UnitType IS NULL THEN 'OTHER' ELSE ISNULL(NULLIF(T.UnitType, 'CO-L'), 'CO') END AS UNITTYPE
	  ,CASE WHEN T.UnitType = ('BRK') THEN 'BROKERS' WHEN T.UnitType IN ('CO', 'CO-L') THEN 'FUEL PURCHASES' ELSE 'EMPLOYEE FUEL' END AS MDAGroup
	  ,CASE WHEN D.TMW_abbr IS NULL THEN EMP.ee_occupation ELSE D.TMW_abbr End AS TMW_abbr
	  ,L.label_extrastring1 AS UnitEntity
	  ,null AS DistType
	  ,F.cfb_trcgallons AS Quantity
	  ,F.cfb_TotalDue - (ISNULL(F.cfb_tax3, 0) + ISNULL(F.cfb_tax1, 0) + ISNULL(F.cfb_tax2, 0)) AS Amt
	  ,'InterCompanyReefer' AS LineType
	  , 0 AS MDA_Flag
FROM dbo.cdfuelbill AS F
JOIN dbo.cdacctcode AS A ON F.cfb_accountid = A.cac_id
LEFT JOIN #Fleet1 AS T ON F.cfb_unitnumber = T.UnitID AND YEAR(F.cfb_transdate) = YEAR(T.SnapshotDate) AND MONTH(F.cfb_transdate) = MONTH(T.SnapshotDate)
LEFT JOIN #Fleet2 AS D ON T.Division = D.Division
LEFT JOIN dbo.labelfile AS L ON D.TMW_abbr = L.abbr AND L.labeldefinition = 'Division'
LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.cfb_unitnumber = EMP.ee_ID
WHERE F.cfb_reefergallons > 0 AND F.cfb_transferred_to_GP = 'N' AND A.cac_Vendor_Code  + '-' + A.cac_description = 'S-10540-CST Canada Cardlock (Seaboard)'

	UPDATE F 
	SET DEBIT_ACCT = T.HSTAcct
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelTaxCodes AS T ON CASE WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
								WHEN LEFT(F.VendorID, 1) = 'H' THEN '02' 
								WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
								WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
								WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
								WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
								END = T.Entity
	WHERE LineType = 'HST'

	--Update Debit Account and Amount for QST for Company Units
	UPDATE F
	SET DEBIT_ACCT = A.QSTRcvAcct
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'QST'
	
   UPDATE F SET DEBIT_ACCT = A.RcvExpAcct, DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'TotalUnitFuel'

    --DEF Company
    UPDATE F 
	SET DEBIT_ACCT = /* db 5/14/2018 removed CASE WHEN F.UnitEntity = '72' THEN '00878-00-02'  ELSE */  
	CASE  WHEN F.UnitDivision IN ('zzzzzz') THEN '00866-00-00'  ELSE '44001-'  + 
		CASE WHEN F.UnitDivision IN ('16', 'EMP60', 'GCAL') THEN '81' ELSE F.UnitDivision END + '-' + 
		CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END
	END
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitDEF' and f.UNITTYPE <>'BRK'

   --DEF Broker
   UPDATE F SET DEBIT_ACCT = A.RcvExpAcct, DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'TotalUnitDEF' and f.UnitType ='BRK'

--Update Debit Account and Amount for AUTO purchase totals for company units
	UPDATE F 
	SET DEBIT_ACCT = '44005-'  + 
	CASE WHEN F.UnitDivision IN ('16', 'EMP60', 'GCAL') THEN '81' ELSE F.UnitDivision END + '-' + 
	CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitAUTO'

	--Update Debit Account and Amount for Scale purchase totals for company units
	UPDATE F 
	SET DEBIT_ACCT = '44100-'  + 
	CASE WHEN F.UnitDivision IN ('16', 'EMP60', 'GCAL') THEN '81' ELSE F.UnitDivision END +'-' + 
	CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitScale' AND F.MDAGroup <> 'BROKERS'

	--Update Debit Account and Amount for Scale purchase totals for broker units
	UPDATE F 
	SET DEBIT_ACCT = '41200-' + 
	CASE WHEN F.UnitDivision IN ('16', 'EMP60', 'GCAL') THEN '81' ELSE F.UnitDivision END +'-' + 
	CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitScale' AND F.MDAGroup = 'BROKERS'

    --Update Debit Account and Amount for Broker Fuel Premium
	UPDATE F
	SET DEBIT_ACCT = A.FuelAcct
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'FuelPremium'
    UPDATE #FuelData
	SET DEBIT_ACCT = A.APAcct
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'FuelCap QST'

	--Update Credit Account and Amount for Fuel Cap HST
	UPDATE F
	SET CREDIT_ACCT = A.HSTPblAcct
	,CREDIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'FuelCap HST' 

	--Update Credit Account and Amount for Fuel Cap QST
	UPDATE F
	SET CREDIT_ACCT = A.QSTPblAcct
	,CREDIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'FuelCap QST'

	--Update Debit Account and Amount for SHANNEX
	--UPDATE F
	--SET DEBIT_ACCT = A.RcvExpAcct
	--,DEBIT_AMT = Amt
	--FROM #FuelData AS F
	--JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	--WHERE LineType = 'EmployeeFuel'

	--Update Credit Amount for Total Fuel Purchases
	UPDATE F
	SET CREDIT_ACCT = A.APAcct
	,CREDIT_AMT = F.Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE F.LineType = 'TotalCredit'

	--Update Credit Amount for Total Reefer Purchases
	UPDATE F
	SET CREDIT_ACCT = A.APAcct
	,CREDIT_AMT = F.Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON A.TMW_ID = '09' AND A.UnitType = 'REEFER'
	WHERE F.LineType = 'TotalReeferFuel' 

	--Update Credit Amount for Reefer HST
	UPDATE F
	SET CREDIT_ACCT = A.APAcct
	,CREDIT_AMT = F.Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON A.TMW_ID = '09' AND A.UnitType = 'REEFER'
	WHERE F.LineType = 'HST' AND F.UNITNUMBER LIKE '%REEFER%'

	--Update Credit Amount for Reefer QST
	UPDATE F
	SET CREDIT_ACCT = A.APAcct
	,CREDIT_AMT = F.Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON A.TMW_ID = '09' AND A.UnitType = 'REEFER'
	WHERE F.LineType = 'QST' AND F.UNITNUMBER LIKE '%REEFER%'

	--Update Debit Amount for InterCompany
	UPDATE F
	SET DEBIT_ACCT = A.DebitAcct
	,DEBIT_AMT = F.Amt
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON ISNULL(F.UnitEntity, ISNULL(L.label_extrastring1,EMP.ee_licensenumber)) = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02' 
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
	WHERE F.LineType = 'InterCompany'

	--Update Debit Amount for InterCompany
	UPDATE F
	SET CREDIT_ACCT = A.CreditAcct
	,CREDIT_AMT = F.Amt
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON ISNULL(F.UnitEntity, ISNULL(L.label_extrastring1, EMP.ee_licensenumber)) = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN	'00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'InterCompany'

    UPDATE F
	SET CREDIT_ACCT = A.APAcct
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON ISNULL(F.UnitEntity, L.label_extrastring1) = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'TotalCredit'

	UPDATE F
	SET DEBIT_ACCT = A.HSTRcv
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON  ISNULL(F.UnitEntity, ISNULL(L.label_extrastring1, EMP.ee_licensenumber)) = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19' -- ?????
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'HST'

	UPDATE F
	SET DEBIT_ACCT = A.QSTRcv
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON ISNULL(F.UnitEntity, ISNULL(L.label_extrastring1, EMP.ee_licensenumber)) = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'QST'

	UPDATE F
	SET DEBIT_ACCT = A.APAcct
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON ISNULL(F.UnitEntity, ISNULL(L.label_extrastring1, EMP.ee_licensenumber)) = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'FuelCap HST'

	UPDATE F
	SET DEBIT_ACCT = A.APAcct
	FROM #FuelData AS F
	LEFT JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate)
	LEFT JOIN dbo.EMPLOYEEPROFILE AS EMP ON F.UNITNUMBER = EMP.ee_ID
    LEFT JOIN dbo.labelfile AS L ON emp.ee_occupation = L.abbr AND L.labeldefinition = 'Division'
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON ISNULL(F.UnitEntity, ISNULL(L.label_extrastring1, EMP.ee_licensenumber)) = A.DivEntity AND 
	CASE WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
		WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
		WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
		WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
		WHEN LEFT(F.VendorID, 1) = 'R' THEN '19' -- ?????
		WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
		END = A.OwnerEntity
		WHERE F.LineType = 'FuelCap QST'

	--Update Accounts for Intercompany
	UPDATE F
	SET DEBIT_ACCT = A.RcvAccount
	FROM #FuelData AS F
	JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate) AND  
	F.UnitEntity <> 
		CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON  F.UnitEntity = A.DivEntity AND 
		CASE WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'TotalUnitFuel' AND MDAGroup = 'BROKERS'

	UPDATE F
	SET CREDIT_ACCT = A.HSTAccount
	FROM #FuelData AS F
	JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate) AND  
									F.UnitEntity <>  CASE WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
											WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
											WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
											WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
											WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
											WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
											END
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON F.UnitEntity = A.DivEntity AND 
		CASE WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'
			END = A.OwnerEntity
			WHERE F.LineType = 'FuelCap HST' AND MDAGroup = 'BROKERS'

	UPDATE F
	SET CREDIT_ACCT = A.QSTAccount
	FROM #FuelData AS F
	JOIN #Fleet1 AS FL ON F.UnitNumber = FL.UnitID AND YEAR(F.TransDate) = YEAR(FL.SnapshotDate) AND MONTH(F.TransDate) = MONTH(FL.SnapshotDate) AND
									F.UnitEntity <>  CASE WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00'
											WHEN LEFT(F.VendorID, 1) = 'H' THEN '02'
											WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
											WHEN LEFT(F.VendorID, 1) = 'M' THEN '16'
											WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
											WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'																																												   END
	JOIN dbo.ztblIntercompanyAccountCodes AS A ON F.UnitEntity = A.DivEntity AND 
	CASE	WHEN LEFT(F.VendorID, 1) IN ('S', 'W') THEN '00' 
			WHEN LEFT(F.VendorID, 1) = 'H' THEN '02' 
			WHEN LEFT(F.VendorID, 1) = 'F' THEN '14'
			WHEN LEFT(F.VendorID, 1) = 'M' THEN '16' 
			WHEN LEFT(F.VendorID, 1) = 'R' THEN '19'
			WHEN LEFT(F.VendorID, 1) = 'G' THEN '72'			
			END = A.OwnerEntity
	WHERE F.LineType = 'FuelCap QST' AND MDAGroup = 'BROKERS'


SELECT distinct CODEID
	INTO #zvw_GP_MDA
	FROM OPENROWSET('SQLOLEDB', 'PWD=seaboard1;UID=views;Initial Catalog=SEHAR;SERVER=acl-sql1\gp10', [SEHAR].[dbo].[zvw_GP_MDA])

	UPDATE F
	SET MDA_Flag = 1
	FROM #FuelData F
	JOIN #zvw_GP_MDA M on F.UNITNUMBER = M.CODEID 
	WHERE M.CODEID IS NOT  NULL 

    UPDATE F
	SET MDA_Flag = 1
	FROM #FuelData F
	LEFT JOIN dbo.zvw_Fuel_Import_Employee AS E ON F.UNITNUMBER = E.ee_id  --select * from zvw_Fuel_Import_Employee 
	WHERE E.ee_ID IS NOT  NULL 

    UPDATE F  -- select * from ztblFuelAccountCodes
	SET CREDIT_ACCT = A.FuelExpAcct
	,CREDIT_AMT = Amt 
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'FuelExpense'

	   UPDATE F SET DEBIT_ACCT = A.RcvExpAcct, DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'TotalUnitDEF' and f.UnitType ='BRK'

    	UPDATE F
	SET DEBIT_ACCT = '00145-' +CASE WHEN F.UnitEntity = '00' THEN '01-' ELSE '00-' END   + CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END 
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType IN ('TotalUnitCash','TotalUnitCashFEE') and UNITTYPE LIKE 'CO%'

    UPDATE F SET DEBIT_ACCT = A.RcvExpAcct, DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType IN ('TotalUnitCash','TotalUnitCashFEE')  and f.UnitType ='BRK'

	-- Added for Fleetone > AM May 2018
	    UPDATE F
	SET DEBIT_ACCT =	CASE WHEN unittype = 'BRK' THEN '00335-'+	
							CASE WHEN F.UnitEntity = '00' THEN '01-' ELSE '00-' END   + 
							CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END 
						ELSE '50110-' + f.unitdivision + '-'  + CASE WHEN F.UnitEntity = '09' THEN '00' 
						ELSE F.UnitEntity END 
						END
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitFEE' 


    UPDATE F SET DEBIT_ACCT = A.RcvExpAcct, DEBIT_AMT = Amt
	FROM #FuelData AS F
	JOIN ztblFuelAccountCodes AS A ON F.UnitDivision = A.TMW_ID AND F.UNITTYPE = A.UnitType
	WHERE LineType = 'TotalUnitFEE'  and f.UnitType ='BRK'


-- Added for Fleetone > AM May 2018  
	UPDATE F
	SET DEBIT_ACCT = '00878-00-02'
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitCash'  and DEBIT_ACCT = '00320-00-72'

	-- Added for Fleetone G3  > AM May 2018  
	UPDATE F
	SET DEBIT_ACCT = '00878-00-02'
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitFee'  and DEBIT_ACCT = '50110-00-72'

			    UPDATE F
	SET DEBIT_ACCT = '00878-00-02'
	,DEBIT_AMT = Amt
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitCash'  and DEBIT_ACCT = '00335-00-72'

	-- Added for Fleetone G3  > AM May 2018  
	UPDATE F
	SET DEBIT_ACCT = '41000-' +CASE WHEN F.UnitDivision IN ('16', 'EMP60', 'GCAL') THEN '81' ELSE F.UnitDivision END +  '-' + CASE WHEN F.UnitEntity = '09' THEN '00' ELSE F.UnitEntity END
	,DEBIT_AMT = Amt -- * -1
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitDiscount'

	-- Added for Fleetone > AM May 2018  
	UPDATE F
	SET DEBIT_ACCT = '00878-00-02'
	,DEBIT_AMT = Amt *-1
	FROM #FuelData AS F
	WHERE LineType = 'TotalUnitDiscount'  and DEBIT_ACCT = '41000-72-72'


	Select * from  #FuelData 




GO


