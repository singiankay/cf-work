component displayname="Production Schedule Import" extends="app.controllers.Controller"
{

	function config() {
		provides("html,json");
	}

	function index() {

		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));

		try {
			var result = [];
			var sqlQuery = new Query();
			sqlQuery.setDatasource(erpdb_fg);
			if(params.area == 0) {
				sqlQuery.setSQL("
					SELECT a.id, a.so_no, a.so_date, b.id AS so_line_id, 
					       b.area, b.model_id, b.qty AS qty, b.requested_delivery_date, b.confirmed_date, 
					       c.id AS schedule_id, c.date, c.qty AS schedule_qty, c.remarks
					  FROM tbl_erpx_sales_orders a
					 INNER JOIN tbl_erpx_sales_order_lines b 
					         ON b.so_id = a.id 
					  LEFT JOIN tbl_erpx_production_schedule c 
					         ON c.so_line_id = b.id
					 WHERE b.requested_delivery_date >= :firstDay
					   AND b.requested_delivery_date <= :lastDay
					   AND b.is_active = 1 
					   AND a.division = :division
					   AND a.is_active = 1 
					   AND a.document_status = 'Posted'
				");
			}
			else {
				sqlQuery.setSQL("
					SELECT a.id, a.so_no, a.so_date, 
					       b.id AS so_line_id, b.area, b.model_id, b.qty AS qty, b.requested_delivery_date, b.confirmed_date, 
					       c.id AS schedule_id, c.date AS schedule_date, c.qty AS schedule_qty, c.remarks
					  FROM tbl_erpx_sales_orders a
					 INNER JOIN tbl_erpx_sales_order_lines b 
					         ON b.so_id = a.id 
					  LEFT JOIN tbl_erpx_production_schedule c 
					         ON c.so_line_id = b.id
					 WHERE b.area = :area
					   AND b.requested_delivery_date >= :firstDay 
					   AND b.requested_delivery_date <= :lastDay
					   AND b.is_active = 1 
					   AND a.division = :division
					   AND a.is_Active = 1 
					   AND a.document_status = 'Posted'
				");
			}
			sqlQuery.addParam(name="division", value=params.division, CFSQLTYPE="CF_SQL_INTEGER");
			if(params.area != 0) {
				sqlQuery.addParam(name="area", value=super.getArea(params.area), CFSQLTYPE="CF_SQL_INTEGER");
			}
			sqlQuery.addParam(name="firstDay", value=firstDay, CFSQLTYPE="CF_SQL_DATE");
			sqlQuery.addParam(name="lastDay", value=lastDay, CFSQLTYPE="CF_SQL_DATE");
			var resultset = sqlQuery.execute().getResult();
			renderWith(resultset);
		}
		catch(customExcp e) {
	   	renderWith(e);
		}

	}

	function show() {

		

	}

	function create() {

		transaction { 
			try { 
				var status = true;
				for(rows in params.data) {
					if(Len(Trim(rows._production_id))) {
						var update = model("productionschedule").updateByKey(key=rows._production_id, date=(Len(Trim(rows._production_date)) ? lsParseDateTime(rows._production_date) : ''), qty=rows._production_qty, remarks=rows._remarks, encoded_by=params.user_id, updated_by=params.user_id, transaction=false);
						if(update == false) {
							status = false;
						}
					}
					else {
						var create = model("productionschedule").new();
						create.so_line_id = rows.so_line_id;
						create.date = rows._production_date;
						create.qty = rows._production_qty;
						create.remarks = rows._remarks;
						create.encoded_by = params.user_id;
						create.updated_by = params.user_id;
						create.save(transaction=false);
						
						if(create.hasErrors()) {
							status = false;
						}
					}
					
				}
				if(status == true) {
					transaction action="commit";
					renderWith({status:'success', message: ['Successfully imported data'] });
				}
				else {
					transaction action="rollback"; 
					renderWith({status:'error', message: [e.message,'Error importing data. Please recheck the records']});
				}
				
			} 
			catch(any e) { 
				transaction action="rollback"; 
				renderWith({status:'error', message: [e.message,'Error importing data. Please recheck the records']});
			} 
		}

	}

	function update() {

	}

	function delete() {

	}

	function verifyExcel() {

		var area = super.getArea(params.area);
		
		var soRecordsDraft = [];

		for(row in params.data) {
			arrayAppend(soRecordsDraft, {
				so_id: row.so_id,
				so_no: row.so_no,
				so_date: row.so_date,
				so_line_id: row.so_line_id,
				model_no: row.model_no,
				model_name: getModelName(row.model_no),
				qty: row.qty,
				requested_delivery_date: row.requested_delivery_date,
				confirmed_date: row.confirmed_date,
				_production_id: row._production_id,
				_production_date: row._production_date,
				_production_qty: row._production_qty,
				_remarks: row._remarks,
				action: setAction(row._production_id),
				status: verifyStatus(row),
				status_message: verifyStatusMessage(row)
			});
		}

		renderWith(soRecordsDraft);

	}

	function verifyStatus(row) {

		var so = model("salesorderline").findOne(where="tbl_erpx_sales_orders.id = '#arguments.row.so_id#' AND tbl_erpx_sales_order_lines.id = '#arguments.row.so_line_id#'", include="salesorder");
		if(isObject(so)) {
			if(setAction(arguments.row._production_id) == "Update") {
				var production_schedule = model("productionschedule").findByKey(arguments.row._production_id);
				if(isObject(production_schedule)) {
					if(isProductionDate(arguments.row._production_date)) {
						if(isProductionQty(arguments.row._production_qty)) {
							return true;
						}
						else {
							return false;
						}
					}
					else {
						return false;
					}
				}
			}
			else {
				if(isProductionDate(arguments.row._production_date)) {
					if(isProductionQty(arguments.row._production_qty)) {
						return true;
					}
					else {
						return false;
					}
				}
				else {
					return false;
				}
			}
		}
		else {
			return false;
		}

	}

	function verifyStatusMessage(row) {

		var status = [];
		var so = model("salesorderline").findOne(where="tbl_erpx_sales_orders.id = '#arguments.row.so_id#' AND tbl_erpx_sales_order_lines.id = '#arguments.row.so_line_id#'", include="salesorder");
		if(isObject(so)) {
			if(setAction(arguments.row._production_id) == "Update") {
				var production_schedule = model("productionschedule").findByKey(arguments.row._production_id);
				if(isObject(production_schedule)) {
					if(isProductionDate(arguments.row._production_date)) {
						if(!isProductionQty(arguments.row._production_qty)) {
							arrayAppend(status, 'Invalid Qty');
						}
					}
					else {
						arrayAppend(status, 'Invalid Date');
					}
				}
			}
			else {
				if(isProductionDate(arguments.row._production_date)) {
					if(!isProductionQty(arguments.row._production_qty)) {
						arrayAppend(status, 'Invalid Qty');
					}
				}
				else {
					arrayAppend(status, 'Invalid Date');
				}
			}
		}
		else {
			arrayAppend(status, 'SO / Line does not exist');
		}
		return status;
	}

	function getModelName(model_no) {
		var name = model("productname").findOne(select="ItemName", where="ItemCode = '#arguments.model_no#'");
		if(isObject(name)) {
			return name.ItemName;
		}
		else {
			return false;
		}
	}

	function setAction(id) {
		if(len(trim(arguments.id))) {
			return "Update";
		}
		return "Create";
	}

	function isProductionDate(item) {
		if(isDate(Trim(arguments.item))) {
			return true;
		}
		return false;
	}

	function isProductionQty(item) {
		if(isNumeric(Trim(arguments.item))) {
			return true;
		}
		return false;
	}


}