component displayname="MRP" extends="app.controllers.Controller"
{

	PageTitle = "App";
	roles = structNew();
	roles.Sales = [ 'Order', 'Customer PN' ];
	roles.MRP = [ 'Production Schedule', 'RM Inventory Uploads', 'Open PO', 'WIP', 'FG Inventory', 'Allocation', 'Reports' ]; 
	roles.WH = [ 'IQC Less Materials', 'Print', 'Issuance Adjustment', 'RM Reports','MRF Approver','MRF Issuer'];
	roles.JO = ['Encode','Print','PP Approver','PP Deputy','PU Approver','PU Deputy','Notified'];


	function config() {
		provides("html,json");
	}

	function index() {

		if(structKeyExists(params, "orderBy")) {

			switch(params.orderBy) {
				case "ID":
					params.orderBy = "b.id";
				break;
				case "NAME":
					params.orderBy = "CONCAT(a.EMP3,' ',a.EMP2)";
				break;
				case "POSITION":
					params.orderBy = "a.emp5";
				break;
				case "CATEGORY":
					params.orderBy = "b.access_type";
				case "ROLE":
					params.orderBy = "b.role";
				break;
				case "DIVISION":
					params.orderBy = "b.division";
				break;
				case "STATUS":
					params.orderBy = "b.is_active";
				break;
				case "DESCRIPTION":
					params.orderBy = "b.description";
				break;
				default: 
					
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
							 INNER JOIN #erpdb_fg#.tbl_erpx_user d 
						  			 ON d.fk_user_id = c.EMP33 
				  			 WHERE (CONCAT(EMP3,' ',EMP2) LIKE :query 
				   		    OR c.EMP5 LIKE :query 
				   	 	    OR d.id LIKE :query 
				   	 	    OR d.description LIKE :query) 
				   	 	   AND d.access_type = :access_type 
				   	 	   AND d.role = :qrole 
				   	 	   AND d.division = :qdivision 
						 ) AS total, 
						 a.EMP3 AS firstname, a.EMP2 AS lastname, a.EMP5 AS position, 
						 b.id AS id, b.fk_user_id AS fk_id, b.description, b.is_active AS status, b.access_type AS category, b.role, b.division 
				  FROM #hris#.m_employee a 
				 INNER JOIN #erpdb_fg#.tbl_erpx_user b 
				       ON b.fk_user_id = a.EMP33 
	       	 WHERE (CONCAT(a.EMP3,' ',a.EMP2) LIKE :query
	   		    OR a.EMP5 LIKE :query 
	   	 	    OR b.id LIKE :query 
	   	 	    OR b.description LIKE :query) 
	   	 	   AND b.access_type = :access_type 
	   	 	   AND b.role = :qrole 
	   	 	   AND b.division = :qdivision  
	   	 	   	 #sqlOrderBy#
				 LIMIT :qlimit 
				OFFSET :qoffset 
			");
			sqlQuery.addParam(name="qlimit", value=params.limit, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="qoffset", value=(params.page-1)*params.limit, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="query", value="%"&params.query&"%", CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="access_type", value=params.category, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="qrole", value=params.role, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="qdivision", value=params.division, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			renderWith(resultset);
		}
		catch (customExcp e) {
		    renderWith(e);
		}

	}

	function getCategories() {

		var categories = [];
		roles.each(function(key, value) {
			categories.append(key);
		});
		categories.sort("textnocase","asc");
		renderWith(categories);
	}

	function getRoles() {

		structEach(roles, function(key, value) {
			if(key == params.category) {
				renderWith(value);
			}
		});

	}

	function getDivisions() {
		
		var divisions = super.getDivisions();
		renderWith(divisions);

	}

	function getAreas() {

		var areas = super.getAreas(params.division);
		renderWith(areas);
		
	}

	function getEmployees() {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(employee_db);

			sqlQuery.setSQL("
				SELECT a.EMP3 as firstname, a.EMP2 as lastname, a.EMP33 as id, a.EMP5 AS position 
				  FROM #hris#.m_employee a
				 WHERE a.EMP33 NOT IN (
				 		 SELECT fk_user_id 
				 		   FROM #erpdb_fg#.tbl_erpx_user 
				 		  WHERE role = :role 
				 		    AND division = :division 
				 		    AND access_type = :access_type 
				 	  )
				   AND a.EMP27 = 1 
				   AND CONCAT(a.EMP3,' ',a.EMP2) LIKE :query 
			");

			sqlQuery.addParam(name="query", value="%"&params.q&"%", CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="role", value=params.role, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="division", value=params.division, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="access_type", value=params.category, CFSQLTYPE="CF_SQL_VARCHAR");
			var resultset = sqlQuery.execute().getResult();
		}
		catch (customExcp e) {
		    renderWith(e);
		}
		renderWith(data=resultset);

	}

	function show() {

		var user = model("user").findByKey(params.key);
		var userPerson = model("hrisemployee").findOne(select="fullname, position", where="id='#user.fk_user_id#'");
		renderWith({
			'id': user.id,
			'fk_user_id': user.fk_user_id,
			'name': "#userPerson.fullname# - #userPerson.position#" ,
			'division': user.division,
			'role': user.role,
			'category': user.access_type,
			'is_active': user.is_active,
			'description': user.description
		});

	}

	function create() {

		if(!structKeyExists(params.FORM, "description")) {
			params.form.description = "";
		}

		var user = model("user").new();
		user.fk_user_id = params.fk_id;
		user.description = params.form.description;
		user.is_active = super.getBooleanNumber(params.form.active);
		user.created_by = params.created_by;
		user.role = params.role;
		user.division = params.division;
		user.area = '';
		user.access_type = params.category;
		user.save();

		if(user.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(user.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully created #params.form.name#.'] });
		}

	}

	function update() {

		var user = model("user").findByKey(params.key);
		var userPerson = model("hrisemployee").findOne(select="fullname, position", where="id='#user.fk_user_id#'");
		var update = user.update(category=params.form.category, role=params.form.role, division = params.form.division, description=params.form.description, is_active= super.getBooleanNumber(params.form.active), updated_by= params.updated_by);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated #userPerson.fullname#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(user.allErrors()) });
		}

	}

	function delete() {
		var user = model("user").findByKey(params.key);
		var userPerson = model("hrisemployee").findOne(select="fullname, position", where="id='#user.fk_user_id#'");
		var delete = user.delete();

		if(delete) {
			renderWith({status:'success', message: ['Successfully deleted #userPerson.fullname#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(user.allErrors()) });
		}

	}

}