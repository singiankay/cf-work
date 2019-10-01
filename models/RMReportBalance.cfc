component extends="Model"
{
	function config() {
		table(false);
		validatesFormatOf(properties="docentry, id_record", regEx="[0-9]", allowBlank=true);
	}

	boolean function getTotal()
	{
		if(!this.valid()) {
			this.total = QueryNew("");
			return false;
		}

		var groups = model("materialgroupings").findAll(select="id, code, division, type", where="division = #SESSION.rmreport.division# AND type NOT IN ('Finished Goods', 'All')");
		var productionArea = getProductionArea(SESSION.rmreport.division, this.area);

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource("sapdb");
			sqlQuery.setSQL("
				SELECT COALESCE(SUM((COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)))), 0) qty_balance 
				  FROM [@FN_ORCV] rcv 
				  LEFT JOIN (
				     SELECT U_BaseRef, 
				        SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
				        SUM(CASE WHEN U_LocationTo = 4 THEN U_Quantity END) [p_IQC-Q], 
				        SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
				        SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
				        SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
				        SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
				        SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
				        SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
				        SUM(CASE WHEN U_LocationFrom = 4 THEN U_Quantity END) [m_IQC-Q], 
				        SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
				        SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
				        SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
				        SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
				        SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S], 
				        SUM(CASE WHEN U_LocationFrom = 15 THEN U_Quantity END) [m_IQC-S] 
				       FROM [@FN_OITF] 
				      WHERE Canceled = 'N'
				      GROUP BY U_BaseRef 
				     ) itf
				         ON itf.U_BaseRef = rcv.Docentry 
				  LEFT JOIN (
				     SELECT U_BaseRef,
				        SUM(CASE WHEN U_Location = 'IQC-G' THEN U_Quantity END) [IQC-G], 
				        SUM(CASE WHEN U_Location = 'IQC-Q' THEN U_Quantity END) [IQC-Q], 
				        SUM(CASE WHEN U_Location = 'PCK-G' THEN U_Quantity END) [PCK-G], 
				        SUM(CASE WHEN U_Location = 'WHS-G' THEN U_Quantity END) [WHS-G], 
				        SUM(CASE WHEN U_Location = 'WHS-Q' THEN U_Quantity END) [WHS-Q], 
				        SUM(CASE WHEN U_Location = 'WHS-R' THEN U_Quantity END) [WHS-R], 
				        SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S] 
				       FROM [@FN_OISS] 
				      WHERE Canceled = 'N' 
				        AND U_Release = 1 
				      GROUP BY U_BaseRef 
				     ) iss_m
				         ON iss_m.U_BaseRef = rcv.DocEntry 
				 INNER JOIN dbo.OITM itm 
				         ON itm.Itemcode = rcv.U_ItemCode 
				 WHERE rcv.Canceled = 'N'  
				   AND rcv.Status = 'O' 
				   AND (:docentry = 0 OR rcv.Docentry = :docentry)
				   AND (:id_record = 0 OR rcv.U_IDRecord = :id_record)
				   AND itm.ItmsgrpCod IN (:groups) 
				   AND (:area_code = -1 OR itm.U_ProductionLine IN (:area))
				   AND (:mat_no IS NULL OR itm.ItemCode LIKE :mat_no)
				   AND (:mat_name IS NULL OR itm.ItemName LIKE :mat_name)
				   AND (:supplier_lot IS NULL OR rcv.U_LotCode = :supplier_lot)
				   AND (:npi_lot IS NULL OR rcv.U_LotCode2 = :npi_lot)
				   AND (:supplementary_lot IS NULL OR rcv.U_LotCode3 = :supplementary_lot)
				   AND (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) <> 0 
				OPTION (RECOMPILE)
			");
			sqlQuery.addParam(name="groups", value=(ListLen(valueList(groups.code)) > 0 ? valueList(groups.code) : 0), CFSQLTYPE="CF_SQL_INTEGER", list="true");
			sqlQuery.addParam(name="area", value=productionArea, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="area_code", value=this.area, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="mat_no", value="%"&trim(this.mat_no)&"%", CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.mat_no));
			sqlQuery.addParam(name="mat_name", value="%"&trim(this.mat_name)&"%", CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.mat_name));
			sqlQuery.addParam(name="supplier_lot", value=trim(this.supplier_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.supplier_lot));
			sqlQuery.addParam(name="npi_lot", value=trim(this.npi_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.npi_lot));
			sqlQuery.addParam(name="supplementary_lot", value=trim(this.supplementary_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.supplementary_lot));
			sqlQuery.addParam(name="docentry", value=(isNumeric(this.docentry) && round(this.docentry) == this.docentry ? this.docentry : 0), CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="id_record", value=(isNumeric(this.id_record) && round(this.id_record) == this.id_record ? this.id_record : 0), CFSQLTYPE="CF_SQL_INTEGER");
			this.total = sqlQuery.execute().getResult();
			return true;
		}
		catch(any e) {
			return false;
		}
	}

	boolean function getFull()
	{
		if(!this.valid()) {
			this.full = QueryNew("");
			return false;
		}

		var groups = model("materialgroupings").findAll(select="id, code, division, type", where="division = #SESSION.rmreport.division# AND type NOT IN ('Finished Goods', 'All')");
		var productionArea = getProductionArea(SESSION.rmreport.division, this.area);

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource("sapdb");
			sqlQuery.setSQL(" 
				SELECT rcv.U_ProductLine AS division, itm.U_ProductionLine AS area, rcv.DocEntry AS docentry, rcv.U_IDRecord AS id, U_ItemType AS item_type, itm.ItmsGrpCod AS subgroup_code, itb.ItmsGrpNam classification, isgn.Name AS material_type, rcv.U_ItemCode AS material_no, rcv.U_ItemDescription AS material_name, rcv.U_Reference AS form_number, rcv.U_Fifo AS receive_date, rcv.U_ExpiryDate AS expiration_date, rcv.U_InvNo AS invoice_no, rcv.U_PONo AS po_no, rcv.U_QRcode AS qr_code, rcv.U_LotCode AS supplier_lot, rcv.U_LotCode2 AS npi_lot, rcv.U_LotCode3 AS supplementary_lot, 
				       COALESCE(rcv.U_Quantity, 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0)) iqc_g, 
				       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) iqc_q, 
				       COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) pck_g, 
				       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) whs_g, 
				       COALESCE(itf.[p_WHS-Q], 0) - (COALESCE(itf.[m_WHS-Q], 0) + COALESCE(iss_m.[WHS-Q], 0)) whs_q, 
				       COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) whs_r, 
				       COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) whs_s, 
				       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) iqc_s,
				       COALESCE(rcv.U_Quantity, 0) qty_in,
				       COALESCE(CASE WHEN rcv.u_isinspected = 0 THEN rcv.U_Quantity END, 0) qty_for_iqc,
				       (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) qty_balance,
				       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) qty_ncp,
				       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) qty_on_hold, 
				       COALESCE(itf.[p_reinspect], 0) - (COALESCE(itf.[m_reinspect], 0) + COALESCE(iss_m.[reinspect], 0)) qty_reinspect,
				       COALESCE(iss_m.issued_qty, 0) qty_issued, 
				       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) 
				     + COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) 
				     + COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) 
				     + COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) qty_unissued
				  FROM [@FN_ORCV] rcv 
				  LEFT JOIN (
				     SELECT U_BaseRef, 
				        SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
				        SUM(CASE WHEN U_LocationTo = 4 THEN U_Quantity END) [p_IQC-Q], 
				        SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
				        SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
				        SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
				        SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
				        SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
				        SUM(CASE WHEN U_LocationTo = 15 THEN U_Quantity END) [p_IQC-S],
				        SUM(CASE WHEN U_LocationFrom IN (6,10,13,14) AND U_LocationTo = 4 THEN U_Quantity END) [p_reinspect], 
				        SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
				        SUM(CASE WHEN U_LocationFrom = 4 THEN U_Quantity END) [m_IQC-Q], 
				        SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
				        SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
				        SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
				        SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
				        SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S], 
				        SUM(CASE WHEN U_LocationFrom = 15 THEN U_Quantity END) [m_IQC-S],
				        SUM(CASE WHEN U_LocationFrom = 4 AND RIGHT(U_Reference, 2) = 're' THEN U_Quantity END) [m_reinspect]
				       FROM [@FN_OITF] 
				      WHERE Canceled = 'N'
				      GROUP BY U_BaseRef 
				     ) itf
				         ON itf.U_BaseRef = rcv.Docentry 
				  LEFT JOIN (
				     SELECT U_BaseRef,
				        SUM(CASE WHEN U_Location = 'IQC-G' THEN U_Quantity END) [IQC-G], 
				        SUM(CASE WHEN U_Location = 'IQC-Q' THEN U_Quantity END) [IQC-Q], 
				        SUM(CASE WHEN U_Location = 'PCK-G' THEN U_Quantity END) [PCK-G], 
				        SUM(CASE WHEN U_Location = 'WHS-G' THEN U_Quantity END) [WHS-G], 
				        SUM(CASE WHEN U_Location = 'WHS-Q' THEN U_Quantity END) [WHS-Q], 
				        SUM(CASE WHEN U_Location = 'WHS-R' THEN U_Quantity END) [WHS-R], 
				        SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S], 
				        SUM(CASE WHEN U_Location = 'IQC-S' THEN U_Quantity END) [IQC-S], 
				        SUM(CASE WHEN RIGHT(U_Reference, 2) = 're' THEN U_quantity END) [reinspect], 
				        SUM(U_Quantity) issued_qty
				       FROM [@FN_OISS] 
				      WHERE Canceled = 'N' 
				        AND U_Release = 1 
				      GROUP BY U_BaseRef 
				     ) iss_m
				         ON iss_m.U_BaseRef = rcv.DocEntry 
				 INNER JOIN dbo.OITM itm 
				         ON itm.Itemcode = rcv.U_ItemCode 
				 INNER JOIN dbo.[@ITEMSUBGROUPNAME] isgn 
				         ON isgn.Code = itm.U_ItemSubGroup 
				 INNER JOIN dbo.OITB itb 
				         ON itb.ItmsGrpCod = itm.ItmsGrpCod 
				 WHERE rcv.Canceled = 'N'  
				   AND rcv.Status = 'O' 
				   AND (:docentry = 0 OR rcv.Docentry = :docentry)
				   AND (:id_record = 0 OR rcv.U_IDRecord = :id_record)
				   AND itm.ItmsgrpCod IN (:groups) 
				   AND (:area_code = -1 OR itm.U_ProductionLine IN (:area))
				   AND (:mat_no IS NULL OR itm.ItemCode LIKE :mat_no)
				   AND (:mat_name IS NULL OR itm.ItemName LIKE :mat_name)
				   AND (:supplier_lot IS NULL OR rcv.U_LotCode = :supplier_lot)
				   AND (:npi_lot IS NULL OR rcv.U_LotCode2 = :npi_lot)
				   AND (:supplementary_lot IS NULL OR rcv.U_LotCode3 = :supplementary_lot)
				   AND (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) <> 0 
				 ORDER BY rcv.U_ExpiryDate ASC, rcv.U_FIFO ASC, rcv.U_ItemCode, rcv.DocEntry DESC 
				OPTION (RECOMPILE)
			");
			sqlQuery.addParam(name="groups", value=(ListLen(valueList(groups.code)) > 0 ? valueList(groups.code) : 0), CFSQLTYPE="CF_SQL_INTEGER", list="true");
			sqlQuery.addParam(name="area", value=productionArea, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="area_code", value=this.area, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="mat_no", value="%"&trim(this.mat_no)&"%", CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.mat_no));
			sqlQuery.addParam(name="mat_name", value="%"&trim(this.mat_name)&"%", CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.mat_name));
			sqlQuery.addParam(name="supplier_lot", value=trim(this.supplier_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.supplier_lot));
			sqlQuery.addParam(name="npi_lot", value=trim(this.npi_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.npi_lot));
			sqlQuery.addParam(name="supplementary_lot", value=trim(this.supplementary_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.supplementary_lot));
			sqlQuery.addParam(name="docentry", value=(isNumeric(this.docentry) && round(this.docentry) == this.docentry ? this.docentry : 0), CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="id_record", value=(isNumeric(this.id_record) && round(this.id_record) == this.id_record ? this.id_record : 0), CFSQLTYPE="CF_SQL_INTEGER");
			this.full = sqlQuery.execute().getResult();
			return true;
		}
		catch(any e) {
			return false;
		}
	}

	private function getProductionArea(division, area)
	{
		if(arguments.division == 1) {
			if(arguments.area == 0) {
				return "UT-CT1,UT-CT2,UT-CT3,UT-CT4,UT-OT,UT-PZT,UT-PNT,UT-TRADED,UT-COMMON";
			}
			else if(arguments.area == 1) {
				return "UT-CT1";
			}
			else if(arguments.area == 2) {
				return "UT-CT2";
			}
			else if(arguments.area == 3) {
				return "UT-CT3";
			}
			else if(arguments.area == 4) {
				return "UT-CT4";
			}
			else if(arguments.area == 5) {
				return "UT-OT";
			}
			else if(arguments.area == 6) {
				return "UT-PZT";
			}
			else if(arguments.area == 7) {
				return "UT-PNT";
			}
			else if(arguments.area == 8) {
				return "UT-COMMON";
			}
			else if(arguments.area == 9) {
				return "UT-TRADED";
			}
			else {
				return "";
			}
		}
		else {
			return "";
		}
	}

	boolean function getPartial()
	{
		if(!this.valid()) {
			this.partial = QueryNew("");
			return false;
		}

		var groups = model("materialgroupings").findAll(select="id, code, division, type", where="division = #SESSION.rmreport.division# AND type NOT IN ('Finished Goods', 'All')");
		var productionArea = getProductionArea(SESSION.rmreport.division, this.area);		

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource("sapdb");
			sqlQuery.setSQL("
				SELECT TOP 100 rcv.U_ProductLine AS division, itm.U_ProductionLine AS area, rcv.DocEntry AS docentry, rcv.U_IDRecord AS id, U_ItemType AS item_type, itm.ItmsGrpCod AS subgroup_code, rcv.U_ItemCode AS material_no, rcv.U_ItemDescription AS material_name, rcv.U_Reference AS form_number, rcv.U_Fifo AS receive_date, rcv.U_ExpiryDate AS expiration_date, rcv.U_InvNo AS invoice_no, rcv.U_PONo AS po_no, rcv.U_QRcode AS qr_code, rcv.U_LotCode AS supplier_lot, rcv.U_LotCode2 AS npi_lot, rcv.U_LotCode3 AS supplementary_lot, 
				       COALESCE(rcv.U_Quantity, 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0)) iqc_g, 
				       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) iqc_q, 
				       COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) pck_g, 
				       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) whs_g, 
				       COALESCE(itf.[p_WHS-Q], 0) - (COALESCE(itf.[m_WHS-Q], 0) + COALESCE(iss_m.[WHS-Q], 0)) whs_q, 
				       COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) whs_r, 
				       COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) whs_s, 
				       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) iqc_s,
				       COALESCE(rcv.U_Quantity, 0) qty_in,
				       COALESCE(CASE WHEN rcv.u_isinspected = 0 THEN rcv.U_Quantity END, 0) qty_for_iqc,
				       (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) qty_balance,
				       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) qty_ncp,
				       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) qty_on_hold, 
				       COALESCE(itf.[p_reinspect], 0) - (COALESCE(itf.[m_reinspect], 0) + COALESCE(iss_m.[reinspect], 0)) qty_reinspect, 
				       COALESCE(iss_m.issued_qty, 0) qty_issued, 
				       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) 
				     + COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) 
				     + COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) 
				     + COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) qty_unissued
				  FROM [@FN_ORCV] rcv 
				  LEFT JOIN (
				     SELECT U_BaseRef, 
				        SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
				        SUM(CASE WHEN U_LocationTo = 4 THEN U_Quantity END) [p_IQC-Q], 
				        SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
				        SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
				        SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
				        SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
				        SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
				        SUM(CASE WHEN U_LocationTo = 15 THEN U_Quantity END) [p_IQC-S],
				        SUM(CASE WHEN U_LocationFrom IN (6,10,13,14) AND U_LocationTo = 4 THEN U_Quantity END) [p_reinspect], 
				        SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
				        SUM(CASE WHEN U_LocationFrom = 4 THEN U_Quantity END) [m_IQC-Q], 
				        SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
				        SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
				        SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
				        SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
				        SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S], 
				        SUM(CASE WHEN U_LocationFrom = 15 THEN U_Quantity END) [m_IQC-S],
				        SUM(CASE WHEN U_LocationFrom = 4 AND RIGHT(U_Reference, 2) = 're' THEN U_Quantity END) [m_reinspect] 
				       FROM [@FN_OITF] 
				      WHERE Canceled = 'N'
				      GROUP BY U_BaseRef 
				     ) itf
				         ON itf.U_BaseRef = rcv.Docentry 
				  LEFT JOIN (
				     SELECT U_BaseRef,
				        SUM(CASE WHEN U_Location = 'IQC-G' THEN U_Quantity END) [IQC-G], 
				        SUM(CASE WHEN U_Location = 'IQC-Q' THEN U_Quantity END) [IQC-Q], 
				        SUM(CASE WHEN U_Location = 'PCK-G' THEN U_Quantity END) [PCK-G], 
				        SUM(CASE WHEN U_Location = 'WHS-G' THEN U_Quantity END) [WHS-G], 
				        SUM(CASE WHEN U_Location = 'WHS-Q' THEN U_Quantity END) [WHS-Q], 
				        SUM(CASE WHEN U_Location = 'WHS-R' THEN U_Quantity END) [WHS-R], 
				        SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S], 
				        SUM(CASE WHEN U_Location = 'IQC-S' THEN U_Quantity END) [IQC-S], 
				        SUM(CASE WHEN RIGHT(U_Reference, 2) = 're' THEN U_quantity END) [reinspect], 
				        SUM(U_Quantity) issued_qty
				       FROM [@FN_OISS] 
				      WHERE Canceled = 'N' 
				        AND U_Release = 1 
				      GROUP BY U_BaseRef 
				     ) iss_m
				         ON iss_m.U_BaseRef = rcv.DocEntry 
				 INNER JOIN dbo.OITM itm 
				         ON itm.Itemcode = rcv.U_ItemCode
				 WHERE rcv.Canceled = 'N'  
				   AND rcv.Status = 'O' 
				   AND (:docentry = 0 OR rcv.Docentry = :docentry)
				   AND (:id_record = 0 OR rcv.U_IDRecord = :id_record)
				   AND itm.ItmsgrpCod IN (:groups) 
				   AND (:area_code = -1 OR itm.U_ProductionLine IN (:area))
				   AND (:mat_no IS NULL OR itm.ItemCode LIKE :mat_no)
				   AND (:mat_name IS NULL OR itm.ItemName LIKE :mat_name)
				   AND (:supplier_lot IS NULL OR rcv.U_LotCode = :supplier_lot)
				   AND (:npi_lot IS NULL OR rcv.U_LotCode2 = :npi_lot)
				   AND (:supplementary_lot IS NULL OR rcv.U_LotCode3 = :supplementary_lot)
				   AND (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) <> 0 
				 ORDER BY rcv.U_ExpiryDate ASC, rcv.U_FIFO ASC, rcv.U_ItemCode, rcv.DocEntry DESC 
				OPTION (RECOMPILE)
			");
			sqlQuery.addParam(name="groups", value=(ListLen(valueList(groups.code)) ? valueList(groups.code) : 0), CFSQLTYPE="CF_SQL_INTEGER", list="true");
			sqlQuery.addParam(name="area", value=productionArea, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="area_code", value=this.area, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="mat_no", value="%"&trim(this.mat_no)&"%", CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.mat_no));
			sqlQuery.addParam(name="mat_name", value="%"&trim(this.mat_name)&"%", CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.mat_name));
			sqlQuery.addParam(name="supplier_lot", value=trim(this.supplier_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.supplier_lot));
			sqlQuery.addParam(name="npi_lot", value=trim(this.npi_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.npi_lot));
			sqlQuery.addParam(name="supplementary_lot", value=trim(this.supplementary_lot), CFSQLTYPE="CF_SQL_VARCHAR", null=isCharacterNullable(this.supplementary_lot));
			sqlQuery.addParam(name="docentry", value=(isNumeric(this.docentry) && round(this.docentry) == this.docentry ? this.docentry : 0), CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="id_record", value=(isNumeric(this.id_record) && round(this.id_record) == this.id_record ? this.id_record : 0), CFSQLTYPE="CF_SQL_INTEGER");
			this.partial = sqlQuery.execute().getResult();
			return true;
		}
		catch(any e) {
			return false;
		}
	}

	private function removeSpecialChars(value)
	{
		return replace(arguments.value, ',', '', 'all');
	}

	private function isCharacterNullable(value)
	{
		if(len(trim(arguments.value)) == 0) {
			return true;
		}
		else {
			return false;
		}
	}

}