component extends="Model"
{
	function config() {
		table(false);
	}

	boolean function getSummary()
	{
		var groups = model("materialgroupings").findAll(select="id, code, division, type", where="division = #SESSION.rmreport.division# AND type NOT IN ('Finished Goods', 'All')");
		var productionArea = getProductionArea(SESSION.rmreport.division, this.area);

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource("sapdb");
			sqlQuery.setSQL("
				SELECT b.division, a.U_productionLine area, c.ItmsGrpNam classification, isgn.Name material_type, a.ItemCode material_no, a.ItemName material_name, b.qty_balance 
				  FROM dbo.OITM a 
				  LEFT JOIN (
				  	    SELECT rcv.U_ItemCode material_no, rcv.U_ProductLine division,
				  	           SUM((COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				  	         + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				  	         + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				  	         + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				  	         + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				  	         + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)))) qty_balance
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
				  	              SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S]
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
				  	     WHERE rcv.Canceled = 'N' 
				  	       AND rcv.Status = 'O' 
				  	       AND (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				            + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				            + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				            + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				            + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				            + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) <> 0 
				        GROUP BY rcv.U_ItemCode, rcv.U_ProductLine  
				  	       ) b 
				         ON b.material_no = a.ItemCode 
				 INNER JOIN dbo.OITB c 
				         ON c.ItmsGrpCod = a.ItmsGrpCod 
				 INNER JOIN dbo.[@ITEMSUBGROUPNAME] isgn 
				         ON isgn.Code = a.U_ItemSubGroup 
				 WHERE a.ItmsgrpCod IN (:groups) 
				   AND (:area_code = -1 OR a.U_ProductionLine IN (:area)) 
				 ORDER BY b.division, a.U_productionLine, a.ItemCode ASC
			");
			sqlQuery.addParam(name="groups", value=(ListLen(valueList(groups.code)) ? valueList(groups.code) : 0), CFSQLTYPE="CF_SQL_INTEGER", list="true");
			sqlQuery.addParam(name="area", value=productionArea, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="area_code", value=this.area, CFSQLTYPE="CF_SQL_INTEGER");
			this.result = sqlQuery.execute().getResult();
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