component displayname="RM Report Division" extends="app.controllers.Controller"
{
	function config()
	{
		provides("html, json");
	}

	function index()
	{
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

	function setDivision() 
	{
		SESSION.rmreport.division = params.key;
		redirectTo(back=true);
	}
}