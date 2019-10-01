component displayname="MRP Semi Finished Goods" extends="app.controllers.Controller"
{	

	function config()
	{
		provides("html,json");
	}

	function index()
	{
		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type='Sub-Assembly'");
		var SubGroupCodes = valueList(Subgroup.code);

		if(params.area != 0) {
			var sapModels = model("productname").findAll(select="ItemName, ItemCode, ItmsGrpCod", where="");
		}
		else {
			var sapModels = model("productname").findAll(select="ItemName, ItemCode, ItmsGrpCod", where="");
		}
	}

	function getIposModels(models, division) {
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.id_record AS model_id, a.mSap AS model_no, 
				       b.process_rev, c.bom_rev, 
				       d.mpProcess AS process_no, d.mpOrder AS process_order, d.mpYield AS process_yield, g.pSap AS process_code, 
				       e.mbItem AS bom_item, e.mbQuantity AS bom_qty, e.mbYield as bom_yield, 
				       f.maAltItem AS alt_item, f.maAltType as alt_type 
				  FROM tbl_model a 
				 INNER JOIN (
				  	  SELECT ba.mrModel, bb.process_rev 
				  	    FROM tbl_model_revision ba 
				  		INNER JOIN (
				  		 	 SELECT mrModel, MAX(mrRevision) AS process_rev
				  		 	   FROM tbl_model_revision 
				  		 	  WHERE mrType = 0 
				  		 	    AND mrActive = 1 
				  		 	    AND mrApproved = 2 
				  		 	  GROUP BY mrModel
				  		   ) bb 
				  		  ON bb.mrModel = ba.mrModel 
				  		 AND bb.process_rev = ba.mrRevision
				  	  ) b 
				    ON b.mrModel = a.id_record
				 INNER JOIN (
					  SELECT ca.mrModel, cb.bom_rev
					  	 FROM tbl_model_revision ca 
					  	INNER JOIN (
					  	 	 SELECT mrModel, MAX(mrRevision) AS bom_rev
					  	 	   FROM tbl_model_revision 
					  	 	  WHERE mrType = 1 
					  	 	    AND mrActive = 1 
					  	 	    AND mrApproved = 2 
					  	 	  GROUP BY mrModel
					  	   ) cb 
					  	  ON cb.mrModel = ca.mrModel 
					  	 AND cb.bom_rev = ca.mrRevision
				  	  ) c 
				    ON c.mrModel = a.id_record
				 INNER JOIN tbl_model_process d 
				         ON d.mpModel = b.mrModel 
				        AND d.mpRevision = b.process_rev
				  LEFT JOIN tbl_model_bom e 
				         ON e.mbModel = d.mpModel 
				        AND e.mbProcess = d.mpProcess 
				        AND e.mbRevision = c.bom_rev 
				  LEFT JOIN tbl_model_alt f 
				         ON f.maModel = e.mbModel 
				        AND f.maProcess = e.mbProcess 
				        AND f. maFatherItem = e.mbItem 
				        AND f.maRevision = e.mbRevision
				 INNER JOIN tbl_process g 
				 			ON g.id_record = d.mpProcess 
				 WHERE a.mSap IN (:models) 
				   AND a.mDivision = :division 
				   AND a.mActive = 1 
				 ORDER BY a.mSap, d.mpOrder, e.mbItem DESC, f.maAltItem DESC
			");
			sqlQuery.addParam(name="models", value=arguments.models, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="division", value=arguments.division, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			var ProcessNames = model("productprocessname").findAll(select="DocEntry, Code, U_ProcessName", where="Code IN (#listRemoveDuplicates(quotedValueList(resultset.process_code))#)");
			var materialNames = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#listRemoveDuplicates(quotedValueList(resultset.bom_item))#)");
			var alternativeNames = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#listRemoveDuplicates(quotedValueList(resultset.alt_item))#)");
			var result = [];
			for(r in resultset) {
				arrayAppend(result, {
					model_id: r.model_id,
					model_no: r.model_no,
					process_rev: r.process_rev,
					bom_rev: r.bom_rev,
					process_no: r.process_no,
					process_name: getProcessName(ProcessNames, r.process_code),
					process_order: r.process_order,
					process_yield: r.process_yield,
					bom_item: r.bom_item,
					bom_name: getMaterialName(materialNames, r.bom_item),
					bom_code: getMaterialCode(materialNames, r.bom_item),
					bom_qty: r.bom_qty,
					bom_yield: r.bom_yield,
					alt_item: r.alt_item,
					alt_name: getMaterialName(alternativeNames, r.alt_item),
					alt_code: getMaterialCode(alternativeNames, r.alt_item),
					alt_type: r.alt_type
				});
			}
			return result;
		}
		catch(customExcp e) {
		   	return e;
		}
	}

}