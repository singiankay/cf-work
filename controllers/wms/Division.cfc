component displayname="WMS Division" extends="app.controllers.Controller"
{
	function config()
	{
		provides("html, json");
	}

	function index()
	{
		renderWith(SESSION.wms.allowed_divisions);
	}

	function show()
	{
		renderWith(SESSION.wms.active_division);
	}

	function create()
	{
		SESSION.wms.active_division = params.division;
		renderWith(true);
	}

	function update()
	{
		
	}

	function delete()
	{

	}

	function setDivision() 
	{
		SESSION.wms.active_division = params.key;
		redirectTo(back=true);
	}
}