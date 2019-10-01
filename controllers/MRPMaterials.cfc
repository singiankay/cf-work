component extends="Controller"
{

	function config()
	{
		provides("html, json");
	}

	function index()
	{	
		var groups = model("materialgroupings").findAll(select="code", where="division='#params.division#' AND type IN ('Materials', 'Chemicals', 'Packaging Materials')");
		if(params.area == 0) {
			var materials = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="Canceled = 'N' AND ItmsGrpCod IN (#ValueList(groups.code)#)");
		}
		else {
			var productionLine = super.getProductionLine(params.area);
			var materials = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="Canceled = 'N' AND ItmsGrpCod IN (#ValueList(groups.code)#) AND U_ProductionLine = '#productionLine#'");
		}
		renderWith(materials);
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

	function getInventory()
	{
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		var inventory = model("monthlyinventory").findAll(where="division = '#params.division#' AND monthyear >= '#firstDay#' AND monthyear <= '#lastDay#'");
		renderWith(inventory);
	}

}