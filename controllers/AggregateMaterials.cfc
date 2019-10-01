component displayname="Aggregate Planning Materials" extends="app.controllers.Controller"
{	

	function config() 
	{
		provides("html,json");
	}

	function index()
	{
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));

		var inventory = model("monthlyinventory").findAll(where="division = '#params.division#' AND monthyear >= '#firstDay#' AND monthyear <= '#lastDay#' AND location IN ('Production','WH/IQC','InTransit')");
		renderWith(inventory);
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

	function getOpenPO()
	{
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 7, firstDay ));
		var inventory = model("monthlyinventory").findAll(where="division = '#params.division#' AND monthyear >= '#firstDay#' AND monthyear <= '#lastDay#' AND location = 'OpenPO'");
		renderWith(inventory);
	}

}