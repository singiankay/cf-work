component displayname="Master" extends="app.controllers.Controller"
{

	PageTitle = "Admin";
	applications = ["Master","Job Order","Issuance","Material Requirements Planning","WMS"];
	options = {
		"JobOrder" = ["Supervisor","Planner","Assistant Planner"],
		"Issuance" = [],
		"Material Requirements Planning" = [],
		"WMS" = ["Supervisor","Staff"]
	};
	role = [];

	function config() {

		// super.config(includeForgeryProtection=false);
		provides("html,json");

	}


	/**
	 * Get Admin Access for ERP Expansion
	 * param limit
	 * param page
	 * param orderby
	 * param ascending
	 * param byColumn
	 * @return {[JSON Object]} [description]
	 */
	function index() {

		if(structKeyExists(params, "orderBy")) {
			switch(params.orderBy) {
				case "NAME":
					params.orderBy = "CONCAT(a.EMP3,' ',a.EMP2)";	
				break;
				case "POSITION":
					params.orderBy = "a.emp5";
				break;
				case "APPLICATIONS":
					params.orderBy = "b.applications";
				break;
				case "DESCRIPTION":
					params.orderBy = "b.description";
				break;
				case "STATUS":
					params.orderBy = "b.is_active";
				break;
				default: 
					params.orderBy = "b.id";
			}
		}
		else {
			var params.orderBy = "b.id";
		}
		params.ascending = super.getOrderBy(params.ascending);
		var sqlOrderBy = "ORDER BY #preserveSingleQuotes(params.orderBy)# #preserveSingleQuotes(params.ascending)#";

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(employee_db);
			sqlQuery.setSQL("
				SELECT (
						 	SELECT COUNT(d.id) 
							  FROM #hris#.m_employee c 
							 INNER JOIN #erpdb_fg#.tbl_erpx_admin d 
						  			 ON d.fk_user_id = c.EMP33 
				  			 WHERE CONCAT(EMP3,' ',EMP2) LIKE :query
				   		    OR c.EMP5 LIKE :query 
				   	 	    OR d.id LIKE :query 
				   	 	    OR d.created_by LIKE :query 
				   	 	    OR d.updated_by LIKE :query
				   	 	    OR d.description LIKE :query
						 ) AS total,
						 a.EMP3 AS firstname, a.EMP2 AS lastname, a.EMP5 AS position, 
						 b.id AS id, b.fk_user_id AS fk_id, b.applications, b.description, b.is_active AS status, b.created_by, b.updated_by  
				  FROM #hris#.m_employee a
				 INNER JOIN #erpdb_fg#.tbl_erpx_admin b 
				       ON b.fk_user_id = a.EMP33 
	       	 WHERE CONCAT(a.EMP3,' ',a.EMP2) LIKE :query
	   		    OR a.EMP5 LIKE :query 
	   	 	    OR b.id LIKE :query 
	   	 	    OR b.created_by LIKE :query 
	   	 	    OR b.updated_by LIKE :query
	   	 	    OR b.description LIKE :query
				 		 #sqlOrderBy#
				 LIMIT :qlimit 
				OFFSET :qoffset
			");
			sqlQuery.addParam(name="qlimit", value=params.limit, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="qoffset", value=(params.page-1)*params.limit, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="query", value="%"&params.query&"%", CFSQLTYPE="CF_SQL_VARCHAR");
			var resultset = sqlQuery.execute().getResult();
		}
		catch (customExcp e) {
		    renderWith(e);
		}

		renderWith(resultset);

	}


	function getApplications() {

		renderWith(applications);

	}


	private function getDivision() {

		var divisions = model("division").findall(
			select="code",
			where="id < 8 AND is_active = 1", 
			order="code ASC",
			returnAs="objects"
		);
		return divisions;

	}


	/**
	 * [Employee Search in Admin]
	 * @param name="q"
	 * @return {[query object]} [employees]
	 */
	function getEmployees() {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(employee_db);
			sqlQuery.setSQL("
				SELECT a.EMP3 as firstname, a.EMP2 as lastname, a.EMP33 as id, a.EMP5 AS position 
				  FROM #hris#.m_employee a
				  LEFT JOIN #erpdb_fg#.tbl_erpx_admin b 
				       ON b.fk_user_id = a.EMP33
				 WHERE a.EMP27 = 1 
				   AND CONCAT(EMP3,' ',EMP2) LIKE :query
				   AND b.fk_user_id IS NULL 
			");
			sqlQuery.addParam(name="query", value="%"&params.q&"%", CFSQLTYPE="CF_SQL_VARCHAR");
			var resultset = sqlQuery.execute().getResult();
			
		}
		catch (customExcp e) {
		    renderWith(e);
		}
		renderWith(data=resultset);

	}


	function getAdminByID() {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(employee_db);
			sqlQuery.setSQL("
				SELECT a.EMP3 AS firstname, a.EMP2 AS lastname, a.EMP5 AS position, 
						 b.id AS id, b.fk_user_id AS fk_id, b.applications, b.description, b.is_active AS status, b.created_by, b.updated_by  
				  FROM m_employee a
				 INNER JOIN #erpdb_fg#.tbl_erpx_admin b 
				       ON b.fk_user_id = a.EMP33 
				 WHERE a.EMP27 = 1 
				   AND b.id = :id
			");
			sqlQuery.addParam(name="id", value=params.id, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			
		}
		catch (customExcp e) {
		    renderWith(e);
		}
		renderWith(resultset);

	}


	function getERPAdminByID() {

		var ERPAdmin =model("admin").findOne(where="fk_user_id = #params.id#");
		renderWith(ERPAdmin);

	}



	function createAdmin() {

		var app = deserializeJSON(params.applications);
		var hasID = model("admin").findOne(select="id", where="fk_user_id = '"&params.id&"'");

		if((super.isStringEmpty(params.id) == true) || (super.isArrayEmpty(app) == true)) {
			if(super.isStringEmpty(params.id) == true) {
				renderWith(super.setStatus("error","Error in identifying employee. Please refresh the browser and try again."));
			} else if(super.isArrayEmpty(app) == true) {
				renderWith(super.setStatus("error","Application is required to be selected"));
			}
		}
		else if(IsObject(hasID)) {
			renderWith(super.setStatus("error","Account already exists"));
		}
		else {
			var admin = model("admin").new();
			admin.fk_user_id = params.id;
			admin.applications = params.applications;
			admin.description = params.description;
			admin.save();
			if(admin.hasErrors()) {
				renderWith(admin);
			}
			else {  
				renderWith(super.setStatus("success","Record Saved"));
			}
		}

	}

	function create() {
		if(!structKeyExists(params.FORM, "description")) {
			params.form.description = "";
		}

		var admin = model("admin").new();
		admin.fk_user_id = params.fk_id;
		admin.applications = serializeJSON(params.form.applications);
		admin.description = params.form.description;
		admin.is_active = super.getBooleanNumber(params.form.active);
		admin.created_by = params.created_by;
		admin.save();

		if(admin.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(admin.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully created #params.form.name#.'] });
		}

	}


	function update() {

		var admin = model("admin").findOne(where="fk_user_id = #params.fk_id#");
		var update = admin.update(applications=serializeJSON(params.form.applications), description=params.form.description, is_active= super.getBooleanNumber(params.form.active), updated_by= params.updated_by);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated #params.form.name#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(admin.allErrors()) });
		}
		
	}

	function delete() {

		var admin = model("admin").findOne(where="fk_user_id = #params.key#");
		var delete = admin.delete();

		if(delete) {
			renderWith({status:'success', message: ['Successfully deleted #params.name#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(admin.allErrors()) });
		}

	}
}