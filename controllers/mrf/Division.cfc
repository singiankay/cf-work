component displayname="MRF Division" extends="app.controllers.Controller"
{
	function config()
	{
		provides("html, json");
	}

	function index()
	{
		renderWith(SESSION.mrf.allowed_divisions);
	}

	function show()
	{
		renderWith(SESSION.mrf.active_division);
	}

	function create()
	{
		SESSION.mrf.active_division = params.division;
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
		SESSION.mrf.active_division = params.key;
		redirectTo(back=true);
	}
}