component displayname="WMS Login" extends="app.controllers.Controller"
{
	title = "WMS - Login";
	
	function config()
	{
		filters("restrictAccess");
		usesLayout(template="/wms/layout");
		provides("html, json");
	}

	function index()
	{
		controllerJS = 'wms/main/index';
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "wms")) {
			flashInsert(error="You are not logged in");
			redirectTo(route="wmsLogin");
		}
	}
}