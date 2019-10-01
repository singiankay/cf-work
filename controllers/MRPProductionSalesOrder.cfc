component displayname="MRP Production Sales Order" extends="app.controllers.Controller"
{	

	function config() {

		provides("html,json");

	}

	function index() {

		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		var area = super.getArea(params.area);

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(erpdb_fg);
			if(params.area == 0) {
				sqlQuery.setSQL("  
					SELECT a.id, a.so_no, 
					       b.id AS so_line_id, b.area, b.model_id, b.qty, b.requested_delivery_date, b.confirmed_date, 
					       c.sum_qty
					  FROM tbl_erpx_sales_orders a 
					 INNER JOIN tbl_erpx_sales_order_lines b 
					    ON b.so_id = a.id 
					  LEFT JOIN (
					  	  SELECT SUM(qty) AS sum_qty, so_line_id 
					  	    FROM tbl_erpx_production_schedule c
					  	   GROUP BY so_line_id
					  	) c 
					    ON c.so_line_id = b.id 
					 WHERE b.requested_delivery_date >= :firstDay  
					   AND b.requested_delivery_date <= :lastDay  
					   AND b.is_active = 1 
					   AND a.division = :division 
					   AND a.is_active = 1 
					   AND a.document_status = 'Posted' 
					 ORDER BY a.so_no, b.id
				");
			}
			else {
				sqlQuery.setSQL("  
					SELECT a.id, a.so_no, 
					       b.id AS so_line_id, b.area, b.model_id, b.qty, b.requested_delivery_date, b.confirmed_date, 
					       c.sum_qty
					  FROM tbl_erpx_sales_orders a 
					 INNER JOIN tbl_erpx_sales_order_lines b 
					    ON b.so_id = a.id 
					  LEFT JOIN (
					  	  SELECT SUM(qty) AS sum_qty, so_line_id 
					  	    FROM tbl_erpx_production_schedule c
					  	   GROUP BY so_line_id
					  	) c 
					    ON c.so_line_id = b.id 
					 WHERE b.area = :area 
					   AND b.requested_delivery_date >= :firstDay  
					   AND b.requested_delivery_date <= :lastDay  
					   AND b.is_active = 1 
					   AND a.division = :division 
					   AND a.is_active = 1 
					   AND a.document_status = 'Posted' 
					 ORDER BY a.so_no, b.id
				");
			}
			
			sqlQuery.addParam(name="division", value=params.division, CFSQLTYPE="CF_SQL_INTEGER");
			if(params.area != 0) {
				sqlQuery.addParam(name="area", value=area, CFSQLTYPE="CF_SQL_INTEGER");
			}
			sqlQuery.addParam(name="firstDay", value=firstDay, CFSQLTYPE="CF_SQL_DATE");
			sqlQuery.addParam(name="lastDay", value=lastDay, CFSQLTYPE="CF_SQL_DATE");
			var resultset = sqlQuery.execute().getResult();
			
			if(resultset.recordCount) {
				var names = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#listRemoveDuplicates(quotedValueList(resultset.model_id))#)");
				var result = [];
				for(r in resultset) {
					arrayAppend(result, {
						id: r.id,
						area: r.area,
						so_no: r.so_no,
						so_line_id: r.so_line_id,
						model_no: r.model_id,
						model_name: getModelName(names, r.model_id),
						qty: r.qty,
						sum_qty: r.sum_qty,
						requested_delivery_date: r.requested_delivery_date,
						confirmed_date: r.confirmed_date
					});
				}
				renderWith(result);
			}
			else {
				renderWith(resultset);
			}

		}
		catch(customExcp e) {
	   	renderWith(e);
		}

	}

	function getModelName(names, id) {
		for(name in names) {
			if(name.ItemCode == arguments.id) {
				return name.ItemName;
			}
		}
		return false;
	}


	function show() {

		var salesorderline = model("salesorderline").findByKey(key=#params.key#, include="salesorder");
		if(Len(Trim(salesorderline.production_date_by))) {
			var userName = model("hrisemployee").findOne(select="fullname", where="id = '#salesorderline.production_date_by#'");
			var name = userName.fullname;
		}
		else {
			var name = '';
		}
		
		var show = {
			so_id: salesorderline.so_id,
			so_no: salesorderline.salesorder.so_no,
			id: salesorderline.id,
			production_date:	salesorderline.production_date,
			production_remarks: salesorderline.production_remarks,
			production_date_by: salesorderline.production_date_by,
			production_date_by_name: name
		};
		renderWith(show);

	}

	function update() {

	}


	function verifyExcel() {
		
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		var area = super.getArea(params.area);
		var SOArray = [];
		var SORecordsDraft = [];
		var SORecords = [];

		for(rows in params.data) {
			arrayAppend(SOArray, rows.SOLineID);
		}
		SOLines = arrayToList(SOArray);

		if(listLen(SOLines)) {
			var verifySO = model("salesorderline").findAll(where="tbl_erpx_sales_order_lines.id IN (#SOLines#) AND tbl_erpx_sales_order_lines.requested_delivery_date >= '#firstDay#' AND tbl_erpx_sales_order_lines.requested_delivery_date <= '#lastDay#' AND tbl_erpx_sales_orders.division = '#params.division#' AND tbl_erpx_sales_order_lines.area = '#area#' AND tbl_erpx_sales_order_lines.is_active = 1 AND tbl_erpx_sales_orders.is_active = 1 AND tbl_erpx_sales_orders.document_status = 'Posted'", include="salesorder", order="so_id ASC");

			if(verifySO.recordCount) {
				var model_names = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#quotedValueList(verifySO.model_id)#)");
				
				for(rows in params.data) {
					if(isImportSOLineInSOLine(verifySO, rows.SOLineID)) {
						for(lines in verifySO) {
							if(rows.SOLineID == lines.id) {
								var name = getName(lines.model_id, model_names);
								var status = isDateValid(lines.id, params.data, "verify");
								
								arrayAppend(SORecordsDraft, {
									so_id: lines.so_id,
									so_no: lines.so_no,
									so_date: lines.so_date,
									shipment_status: lines.shipment_status,
									remarks: lines.remarks,
									id: lines.id,
									model_id: lines.model_id,
									model_name: name,
									qty: lines.qty,
									requested_delivery_date: lines.requested_delivery_date,
									confirmed_date: lines.confirmed_date,
									production_date: getProductionDate(lines.id, params.data),
									production_remarks: getProductionRemarks(lines.id, params.data),
									status: status,
									status_message: (status == true ? "" : "Invalid Date in Column _ProductionDate") 
								});
							}
						}
					}
					else {
						arrayAppend(SORecordsDraft, {
							so_id: rows.SalesOrderID,
							so_no: rows.SalesOrderNumber,
							so_date: rows.SalesOrderDate,
							shipment_status: rows.ShipmentStatus,
							remarks: rows.Remarks,
							id: rows.ID,
							model_id: rows.ModelNumber,
							model_name: rows.ModelName,
							qty: rows.Qty,
							requested_delivery_date: lsParseDateTime(rows.CustomerRequestedDeliveryDate),
							confirmed_date: lsParseDateTime(rows.ConfirmedDate),
							production_date: (Len(Trim(rows._ProductionDate))? lsParseDateTime(rows._ProductionDate) : ""),
							production_remarks: rows._ProductionRemarks,
							status: false,
							status_message: "Sales Order Line Does Not Exist"
						});
					}
				}
			}
		}
		renderWith(SORecordsDraft);
	}

	function uploadExcel() {

		transaction { 
			try { 
				for(rows in params.data) {
					var updateLines = model("salesorderline").updateByKey(key=rows.SOLineID, production_date=(Len(Trim(rows._ProductionDate)) ? lsParseDateTime(rows._ProductionDate) : ''), production_remarks=rows._ProductionRemarks, production_date_by=params.user_id);
				}
				transaction action="commit";
				renderWith({status:'success', message: ['Successfully imported data'] });
			} 
			catch(any e) { 
				transaction action="rollback"; 
				renderWith({status:'error', message: [e.message,'Error importing data. Please recheck the records']});
			} 
		}

	}

	function getName(id, modelNames) {

		for(names in arguments.modelNames) {
			if(arguments.id == names.ItemCode) {
				return names.ItemName;
			}
		}
		return false;

	}

	function getProductionDate(id, importData) {

		for(data in arguments.importData) {
			if(data.SOLineID == arguments.id) {
				if(Len(Trim(data._ProductionDate))) {
					return lsParseDateTime(data._ProductionDate);
				}
				else {
					return "";
				}
			}
		}
		return false;

	}

	function getProductionRemarks(id, importData) {

		for(data in arguments.importData) {
			if(data.SOLineID == arguments.id) {
				return data._ProductionRemarks;
			}
		}
		return false;

	}

	function isImportSOLineInSoLine(verifySO, rowID) {

		var isExist = false;
		for(lines in arguments.verifySO) {
			if(arguments.rowID == lines.id) {
				isExist = true;
			}
		}
		return isExist;

	}

	function isDateValid(id, importData, action) {

		if(arguments.action == "verify") {
			for(data in arguments.importData) {
				if(data.SOLineID == arguments.id) {
					if(Len(Trim(data._ProductionDate)) > 0) {
						if(isDate(Trim(data._ProductionDate))) {
							return true;
						}
						else {
							return false;
						}
					}
					else {
						return true;
					}
				}
			}
		}
	}
	

}