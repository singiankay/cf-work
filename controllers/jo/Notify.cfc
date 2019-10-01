component displayname="JO Encode" extends="app.controllers.Controller"
{
	title = "JO - User Notified List";

	function config()
	{
		filters("restrictAccess");
		usesLayout(template='layout');
		provides("html, json");
		usesLayout(template="/jo/layout");
	}

	function index()
	{
		controllerJS = "jo/notify/index";
		is_supervisor = this.isSupervisor();
	}

	function create()
	{
		var is_user = model("user").findOne(where="role = 'Notified' AND access_type = 'JO' AND division = #SESSION.jo.active_division# AND fk_user_id = #params.user#");

		if(isObject(is_user)) {
			if(SESSION.jo.active_division == 1 && listFind(is_user.area, params.area) == 0) {
				is_user.area = listAppend(is_user.area, params.area);
				var update = is_user.save();
				
				if(update == false || is_user.hasErrors()) {
					renderWith({
						status: false,
						message: 'Something happened, please call MIS'
					});
				}
				else {
					renderWith({
						status: true,
						message: 'Successfully saved user'
					});
				}
			}
			else {
				renderWith({
					status: false,
					message: 'User already exists'
				});
			}
		}
		else {
			var user = model("user").new();
			user.role = 'Notified';
			user.access_type = 'JO';
			if(SESSION.jo.active_division == 1) {
				user.area = params.area;
			}
			user.division = SESSION.jo.active_division;
			user.fk_user_id = params.user;
			var create = user.save();

			if(create == false || user.hasErrors()) {
				renderWith({
					status: false,
					message: 'Something happened, please call MIS'
				});
			}
			else {
				renderWith({
					status: true,
					message: 'Successfully saved user'
				});
			}
		}
	}

	function delete()
	{
		if(SESSION.jo.active_division == 1) {
			var user = model("user").findByKey(params.key);
			
			if(listLen(user.area) > 1) {
				user.area = listDeleteAt(user.area, listFind(user.area, params.area));
				var update = user.save();
				if(update == false || user.hasErrors()) {
					renderWith({
						status: false,
						message: "Error Deleting record"
					});
				}
				else {
					renderWith({
						status: true
					});
				}
			}
			else {
				var delete = user.delete();
				if(delete == false || user.hasErrors()) {
					renderWith({
						status: false,
						message: "Error Deleting record"
					});
				}
				else {
					renderWith({
						status: true
					});
				}
			}
		}
		else {
			var delete = model("user").deleteByKey(params.key);
			if(delete == true) {
				renderWith({
					status: true
				});
			}
			else {
				renderWith({
					status: false,
					message: "Error Deleting record"
				});
			}
		}
	}

	function searchUsers()
	{
		var search = [];
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(employee_db);
			sqlQuery.setSQL("
				SELECT EMP3 AS firstname, EMP2 AS lastname, EMP33 AS id 
				  FROM #hris#.m_employee 
				 WHERE EMP27 = 1 
				   AND CONCAT(EMP3,' ',EMP2) LIKE :query
			");
			sqlQuery.addParam(name="query", value="%"&params.q&"%", CFSQLTYPE="CF_SQL_VARCHAR");
			var users = sqlQuery.execute().getResult();

			var existing_users = model("user").findAll(select="fk_user_id AS id, division, area, role, access_type", where="role='Notified' AND access_type = 'JO' AND division = #SESSION.jo.active_division#");
			var existing_user_ids = listRemoveDuplicates(valueList(existing_users.id));

			if(SESSION.jo.active_division == 1) {
				for(var u in users) {
					if(listFind(existing_user_ids, u.id) != 0) {
						for(var eu in existing_users) {
							if(eu.id == u.id) {
								if(listFind(eu.area, params.area) == 0) {
									search.append({
										id: u.id,
										firstname: u.firstname,
										lastname: u.lastname
									});
								}
							}
						}
					}
					else {
						search.append({
							id: u.id,
							firstname: u.firstname,
							lastname: u.lastname
						});
					}
				}
			}
			else {
				for(var u in users) {
					if(listFind(existing_user_ids, u.id) == 0) {
						search.append({
							id: u.id,
							firstname: u.firstname,
							lastname: u.lastname
						});
					}
				}
			}
			renderWith(search);
		}
		catch (customExcp e) {
		    renderWith(e);
		}
	}

	function getUsers()
	{
		var sqlQuery = new Query();
		sqlQuery.setDatasource(erpdb_fg);
		sqlQuery.setSQL(" 
			SELECT a.id, a.fk_user_id, b.EMP2 AS lastname, b.EMP3 AS firstname, a.area 
			  FROM #erpdb_fg#.tbl_erpx_user a  
			 INNER JOIN #hris#.m_employee b 
			         ON b.EMP33 = a.fk_user_id 
			 WHERE a.access_type = 'JO' 
			   AND a.role = 'Notified' 
			   AND a.is_active = 1 
			   AND a.division = :division 
			 ORDER BY b.EMP3, b.EMP2, a.id 
		");
		sqlQuery.addParam(name="division", value=SESSION.jo.active_division, CFSQLTYPE="CF_SQL_INTEGER");
		users = sqlQuery.execute().getResult();
		var result = [];
		for(var u in users) {
			result.append({
				id: u.id,
				user_id: u.fk_user_id,
				area: listToArray(u.area),
				lastname: u.lastname,
				firstname: u.firstname
			});
		}
		renderWith(result);
	}

	function getAreas()
	{
		renderWith(super.getAreas(SESSION.jo.active_division));
	}

	function isSupervisor()
	{
		var bool = false;

		for(var s in SESSION.jo.allowed_roles) {
			if(s.id == SESSION.jo.active_division && s.role == 'PP Approver') {
				bool = true;
			}
		}
		return bool;
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "jo")) {
			flashInsert(error="You are not logged in");
			redirectTo(route="joLogin");
		}
	}
}