component displayname="JO Division" extends="app.controllers.Controller"
{
	function config()
	{
		provides("html, json");
	}

	function index()
	{
		renderWith(SESSION.jo.allowed_divisions);
	}

	function show()
	{
		renderWith(SESSION.jo.active_division);
	}

	function create()
	{
		SESSION.jo.active_division = params.division;
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
		SESSION.jo.active_division = params.key;
		redirectTo(back=true);
	}
}