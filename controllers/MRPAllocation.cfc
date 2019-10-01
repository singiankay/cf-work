component displayname="MRP Allocation" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(erpdb_fg);
			if(params.area == 0) {
				sqlQuery.setSQL("
					SELECT DISTINCT b.model_id AS model_no
					  FROM tbl_erpx_production_schedule a
					 INNER JOIN tbl_erpx_sales_order_lines b 
					         ON b.id = a.so_line_id 
					 INNER JOIN tbl_erpx_sales_orders c 
					         ON c.id = b.so_id
					 WHERE a.date >= :firstDay 
					   AND a.date <= :lastDay 
					   AND c.division = :division
					   AND b.is_active = 1 
					   AND c.is_active = 1 
					 ORDER BY a.date ASC
				");
			}
			else {
				sqlQuery.setSQL("
					SELECT DISTINCT b.model_id AS model_no 
					  FROM tbl_erpx_production_schedule a
					 INNER JOIN tbl_erpx_sales_order_lines b 
					         ON b.id = a.so_line_id 
					 INNER JOIN tbl_erpx_sales_orders c 
					         ON c.id = b.so_id
					 WHERE a.date >= :firstDay 
					   AND a.date <= :lastDay 
					   AND c.division = :division
					   AND b.is_active = 1 
					   AND c.is_active = 1 
					   AND b.area = :area
					 ORDER BY a.date ASC 
				");
			}
			sqlQuery.addParam(name="division", value=params.division, CFSQLTYPE="CF_SQL_INTEGER");
			if(params.area != 0) {
				sqlQuery.addParam(name="area", value=super.getArea(params.area), CFSQLTYPE="CF_SQL_INTEGER");
			}
			sqlQuery.addParam(name="firstDay", value=firstDay, CFSQLTYPE="CF_SQL_DATE");
			sqlQuery.addParam(name="lastDay", value=lastDay, CFSQLTYPE="CF_SQL_DATE");
			
			var resultset = sqlQuery.execute().getResult();
			if(resultset.recordCount) {
				renderWith(getIposModels(valueList(resultset.model_no), params.division));
			}
			else {
				renderWith(resultset);
			}
		}
		catch(customExcp e) {
	   	renderWith(e);
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

	function getProcessName(processes, r) {
		for(p in arguments.processes) {
			if(p.Code == arguments.r) {
				return p.U_ProcessName;
			}
		}
		return false;
	}

	function getMaterialName(materials, r) {
		for(m in arguments.materials) {
			if(m.ItemCode == arguments.r) {
				return m.ItemName;
			}
		}
		return false;
	}

	function getMaterialCode(materials, r) {
		for(m in arguments.materials) {
			if(m.ItemCode == arguments.r) {
				return m.ItmsGrpCod;
			}
		}
		return false;
	}

	function show() {

	}

	function create() {

	}

	function update() {

	}

	function delete() {

	}

	function saveFG() {

		

	}

	function getShipments() {

		var salesOrderLines = model("salesorderline").findAll(where="tbl_erpx_sales_orders.division = '#params.division#' AND tbl_erpx_sales_order_lines.area = '#super.getArea(params.area)#' AND 
			DATE_FORMAT(tbl_erpx_sales_order_lines.production_date, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND tbl_erpx_sales_orders.is_active = 1 AND tbl_erpx_sales_order_lines.is_active = 1 AND tbl_erpx_sales_orders.document_status = 'Posted'", order="tbl_erpx_sales_order_lines.model_id, tbl_erpx_sales_order_lines.production_date ASC", include="salesorder");
		if(salesOrderLines.recordcount) {
			var modelIds = ListQualify(valueList(salesOrderLines.model_id),"'");
			var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelIds#)");
			var result = [];

			for(soRows in salesOrderLines) {
				arrayAppend(result, {
					id: soRows.id,
					so_id: soRows.so_id,
					so_no: soRows.so_no,
					model_id: soRows.model_id,
					model_name: getModelName(modelNames, soRows.model_id),
					requested_delivery_date: soRows.requested_delivery_date,
					confirmed_date: soRows.confirmed_date,
					production_date: soRows.production_date,
					qty: soRows.qty
				});
			}

			renderWith(result);
		}
		else {
			renderWith([]);
		}

	}

	function getFiveMonthShipments() {

		var salesOrderLines = model("salesorderline").findAll(where="tbl_erpx_sales_orders.division = '#params.division#' AND tbl_erpx_sales_order_lines.area = '#super.getArea(params.area)#' AND tbl_erpx_sales_order_lines.production_date > date_add(date_add(LAST_DAY('#DateFormat(params.monthyear, 'yyyy-mm-dd')#'),interval 1 DAY),interval -1 MONTH) AND tbl_erpx_sales_order_lines.production_date < date_add(LAST_DAY('#DateFormat(params.monthyear, 'yyyy-mm-dd')#'), interval 4 MONTH) AND tbl_erpx_sales_orders.is_active = 1 AND tbl_erpx_sales_order_lines.is_active = 1 AND tbl_erpx_sales_orders.document_status = 'Posted'", order="tbl_erpx_sales_order_lines.model_id, tbl_erpx_sales_order_lines.production_date ASC", include="salesorder");
		if(salesOrderLines.recordcount) {
			var modelIds = ListQualify(valueList(salesOrderLines.model_id),"'");
			var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelIds#)");
			var result = [];

			for(soRows in salesOrderLines) {
				arrayAppend(result, {
					id: soRows.id,
					so_id: soRows.so_id,
					so_no: soRows.so_no,
					model_id: soRows.model_id,
					model_name: getModelName(modelNames, soRows.model_id),
					requested_delivery_date: soRows.requested_delivery_date,
					confirmed_date: soRows.confirmed_date,
					production_date: soRows.production_date,
					qty: soRows.qty
				});
			}

			renderWith(result);
		}
		else {
			renderWith([]);
		}

	}


	function getModelName(modelNames, id) {

		for(names in arguments.modelNames) {
			if(names.ItemCode == arguments.id) {
				return names.ItemName;
			}
		}
		return false;

	}

	

}