component displayname="JO Approval" extends="app.controllers.Controller"
{
	title = "JO - Approval";

	function config()
	{
		filters("restrictAccess");
		provides("html, json");
		usesLayout(template="/jo/layout");
	}

	function index()
	{
		controllerJS = "jo/approval/index";

		if(!structKeyExists(params, "q")) {
			var params.q = "";
		}
		if(!structKeyExists(params, "page")) {
			var params.page = 1;
		}

		jo = model("jorevision").findAll(
			select="tbl_erpx_jo_revision.jo_id, MAX(tbl_erpx_jo_revision.revision_no) AS revision_no, tbl_erpx_jo.jo_number",
			where="(tbl_erpx_jo.jo_number LIKE '%#params.q#%' OR tbl_erpx_jo_revision.model_no LIKE '%#params.q#%' OR tbl_erpx_jo_revision.model_name LIKE '%#params.q#%') AND tbl_erpx_jo_revision.is_active = 1 AND tbl_erpx_jo.division = #SESSION.jo.active_division# AND tbl_erpx_jo.is_active = 1 AND tbl_erpx_jo_revision.status = 'Pending'", 
			group="jo_id",
			include="jo",
			page=params.page,
			perPage=100,
			order="tbl_erpx_jo.jo_number DESC"
		);

		if(jo.recordCount > 0) {
			jorevision = model("jorevision").findAll(where="jo_id IN (#valueList(jo.jo_id)#)");
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

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "jo")) {
			flashInsert(error="You are not logged in");
			redirectTo(route="joLogin");
		}
	}
}