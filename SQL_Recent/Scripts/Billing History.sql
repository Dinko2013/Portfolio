SELECT IH.ivh_invoicenumber
	--, IH.ivh_mbnumber
	--, IH.mov_number
	, IH.ivh_billdate
	, IH.ivh_deliverydate
	, IH.ord_hdrnumber
	, IH.ivh_billto
	, CB.cmp_name
	, ISNULL(ID.ivd_refnum, dbo.zfn_Get_BOLs(IH.ord_hdrnumber)) as Cust_Bol
	, C1.cty_name +  ', '+ c1.cty_state as [Origin_City]
	, IH.ivh_shipdate
	, IH.ivh_consignee
	--, CC.cmp_altid
	, CC.cmp_name as [Consignee]
	, C2.cty_name+  ', '+ c2.cty_state as [Dest_City]
	, ISNULL(T1.mpp_initlast,(SELECT LEFT(MPP.mpp_firstname,1) + MPP.mpp_lastname FROM orderheader O JOIN manpowerprofile MPP ON O.ord_driver1 = MPP.mpp_id WHERE O.ord_hdrnumber = IH.ord_hdrnumber)) as [Driver ID]
	, ISNULL(T1.lgh_tractor,(SELECT O.ord_tractor FROM orderheader O WHERE O.ord_hdrnumber = IH.ord_hdrnumber)) as [Truck ID]
	, ISNULL(T1.lgh_primary_trailer,(SELECT O.ord_trailer FROM orderheader O WHERE O.ord_hdrnumber = IH.ord_hdrnumber)) as [Trailer ID]
	, ISNULL(NULLIF(ID.cmd_code,'UNKNOWN'),'') as [Commodity ID]
	, ISNULL(NULLIF(CMD.cmd_name,'UNKNOWN'),'') as [Commodity]
	, ISNULL(NULLIF(ID.ivd_volume,0),1) as [Quantity]
	, ID.ivd_volunit as [UofM]
	, ISNULL(NULLIF(ID.ivd_description,'UNKNOWN'),CT.cht_description) as ivd_desc
	, ID.ivd_rate
	, ivd_quantity
	, ID.ivd_charge
	, dbo.zfn_Get_TaxRate_New(IH.ivh_billto, IH.ivh_originstate, IH.ivh_deststate, IH.ivh_deliverydate) as Tax_Rate
	, ISNULL(ROUND(dbo.zfn_Get_Secondary_Charges(IH.ivh_invoicenumber,'FSC',ID.ivd_number),2),0) as FSC
	, ISNULL(ROUND(dbo.zfn_Get_Secondary_Charges(IH.ivh_invoicenumber,'ACC',ID.ivd_number),2),0) as Access
	, ISNULL(ROUND(dbo.zfn_Get_Secondary_Charges(IH.ivh_invoicenumber,'QST',ID.ivd_number),2),0) as QST
    ,id.cht_itemcode
	, CT.cht_typeofcharge
	, ID.ivd_sequence
	, IH.ivh_invoicestatus
	, IH.ivh_mbstatus
	, CASE WHEN IH.ivh_mbstatus <> 'NTP' AND IH.ivh_invoicestatus <> 'HLA' THEN
		ISNULL(IH.ivh_mbstatus, 'NA')
	ELSE
		ISNULL(IH.ivh_invoicestatus,'NA')
	END as ivh_invoicestatus2
FROM invoiceheader IH
JOIN invoicedetail ID
	ON IH.ivh_hdrnumber = ID.ivh_hdrnumber
JOIN company CB
	ON IH.ivh_billto = CB.cmp_id
JOIN company CC
	ON IH.ivh_consignee = CC.cmp_id
JOIN city C1
	ON IH.ivh_origincity = C1.cty_code
JOIN city C2
	ON IH.ivh_destcity = C2.cty_code
LEFT JOIN commodity CMD
	ON ID.cmd_code = CMD.cmd_code
LEFT JOIN (SELECT S.stp_number, LEFT(M.mpp_firstname,1) + M.mpp_lastname as mpp_initlast, L.lgh_tractor, L.lgh_primary_trailer, L.trc_type2 FROM stops S JOIN legheader L ON S.lgh_number = L.lgh_number JOIN manpowerprofile M ON L.lgh_driver1 = M.mpp_id) T1
	ON ID.stp_number = T1.stp_number
JOIN chargetype CT
	ON ID.cht_itemcode = CT.cht_itemcode
WHERE ID.cht_itemcode NOT IN ('GST', 'HST', 'PST', 'TAX3','FSC','ACC','FUEREC')
and Cast(ivh_billdate as date) BETWEEN cast('2018-04-01' as date) and cast('2019-03-31' as date) and ivh_billto ='SUPCAL'
AND ID.ivd_charge <> 0
