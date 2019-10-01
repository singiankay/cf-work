component displayname="MRP FG Stock" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

		var salesOrderLines = model("salesorderline").findAll(select="id", where="tbl_erpx_sales_orders.division = '#params.division#' AND tbl_erpx_sales_order_lines.area = '#super.getArea(params.area)#' AND 
			DATE_FORMAT(tbl_erpx_sales_order_lines.production_date, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND tbl_erpx_sales_orders.is_active = 1 AND tbl_erpx_sales_order_lines.is_active = 1 AND tbl_erpx_sales_orders.document_status = 'Posted'", include="salesorder");
		if(salesOrderLines.recordcount) {
			var modelIds = valueList(salesOrderLines.id);
			var fgStocks = model("fgstock").findAll(where="so_line_id IN (#modelIDs#)");
			renderWith(fgStocks);
		}
		else {
			renderWith([]);
		}

	}

	function show() {



	}

	function create() {

		var errors = 0;
		var errorList = [];
		var modelIDList = getModelIDList(params.record);

		if(ListLen(modelIDList)) {
			var fgLines = model("fgstock").findAll(where="so_line_id IN (#modelIDList#)");
			transaction {
				try {
					for(line in params.record) {
						if(isFGStock(fgLines, line.line_id)) {
							var fgStock = model("fgstock").findOne(where="so_line_id = #line.line_id#", transaction=false);
							if(isObject(fgStock)) {
								update = fgStock.update(fg_qty=line.fg_qty, updated_by=params.user_id);
								if(update != true) {
									errors++;
									arrayAppend(errorList, fgStock.allErrors());
								}
							}
							else {
								errors++;
								arrayAppend(errorList, "No ID");
							}
						}
						else {
							var create = model("fgstock").new();
							create.so_line_id = line.line_id;
							create.fg_qty = line.fg_qty;
							create.is_active = 1;
							create.created_by = params.user_id;
							create.save(transaction=false);

							if(create.hasErrors()) {
								errors++;
								arrayAppend(errorList, create.allErrors());
							}
						}
					}
					if(errors) {
						transaction action="rollback";
						renderWith({status:'error', message: errorList});
					}
					else {
						transaction action="commit";
						renderWith({status:'success', message: ["Successfully updated FG Allocations"]});
					}
				}
				catch (customExcp e) {
					transaction action="rollback";
					renderWith({ status:'error', message: e });
				}
			}
		}

	}

	function update() {

	}

	function delete() {
		
	}


	function getMaxModelRevision(id, type) {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.mrModel, a.mrRevision, a.mrType 
				  FROM tbl_model_revision a
				 INNER JOIN (
					SELECT MAX(mrRevision) AS mrRevision, mrModel 
					  FROM tbl_model_revision 
					 WHERE mrModel = :id 
					   AND mrType = :type
					   AND mrActive = 1 
					   AND mrApproved = 2
				) b 
				ON a.mrModel = b.mrModel 
			  AND a.mrRevision = b.mrRevision  
			  AND a.mrType = :type
			  AND a.mrActive = 1 
			  AND a.mrApproved = 2
			");
			sqlQuery.addParam(name="id", value=arguments.id, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="type", value=arguments.type, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			return { status: 'success', rows: resultset };
		}
		catch (customExcp e) {
		    return { status:'error', message: e };
		}

	}

	function getDistinctProcesses(q) {

		var processArray = [];
		for(a in arguments.q) {
			if(!arrayContains(processArray, a.process_code)) {
				arrayAppend(processArray, a.process_code);
			}
		}
		return ListQualify(arrayToList(processArray),"'");
		
	}

	function getDistinctMaterials(q) {

		var materialsArray = [];
		for(a in arguments.q) {
			if(!arrayContains(materialsArray, a.material_id)) {
				arrayAppend(materialsArray, a.material_id);
			}
		}
		return ListQualify(arrayToList(materialsArray),"'");

	}

	function getModelIDList(record) {

		var modelIDArrays = [];
		for(item in arguments.record) {
			arrayAppend(modelIDArrays, item.line_id);
		}
		return arrayToList(modelIDArrays);

	}

	function isFGStock(fgLines, id) {

		for(stock in arguments.fgLines) {
			if(id == stock.so_line_id) {
				return true;
			}
		}
		return false;

	}

}