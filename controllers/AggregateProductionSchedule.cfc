component displayname="Aggregate Planning Production Schedule" extends="app.controllers.Controller"
{	

	function config() 
	{
		provides("html,json");
	}

	function index()
	{
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 7, firstDay ));

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(erpdb_fg);
			if(params.area == 0) {
				sqlQuery.setSQL("
					SELECT a.id, a.date, a.qty, a.remarks, 
					       b.id AS so_line_id, b.area, b.model_id, b.qty AS so_line_qty, 
					       c.id AS so_id, c.so_no 
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
					SELECT a.id, a.date, a.qty, a.remarks, 
					       b.id AS so_line_id, b.area, b.model_id, b.qty AS so_line_qty, 
					       c.id AS so_id, c.so_no 
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
				var result = [];
				var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#ListRemoveDuplicates(quotedValueList(resultset.model_id))#)");
				for(x in resultset) {
					arrayAppend(result, {
						area: x.area,
						so_id: x.so_id,
						so_no: x.so_no,
						so_line_id: x.so_line_id,
						so_line_qty: x.so_line_qty,
						production_id: x.id,
						model_no: x.model_id,
						model_name: getModelName(modelNames, x.model_id),
						qty: x.qty,
						date: x.date,
						remarks: x.remarks
					});
				}
				renderWith(result);
			}
			else {
				renderWith([]);
			}
		}
		catch(customExcp e) {
	   	renderWith(e);
		}
	}

	function show()
	{

	}

	function create()
	{

	}

	function update()
	{

	}

	function delete()
	{

	}

	function getModelName(models, name)
	{
		for(m in models) {
			if(m.ItemCode == arguments.name) {
				return m.ItemName;
			}
		}
		return false;
	}

}