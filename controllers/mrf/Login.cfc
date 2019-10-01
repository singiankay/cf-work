component displayname="JO Login" extends="app.controllers.Controller"
{
	title = "MRF - Login";
	divisions = super.getDivisions();

	function config()
	{
		usesLayout(template='layout');
		provides("html, json");
		verifies(post=true, only="create");
	}

	function new()
	{
		if(structKeyExists(SESSION, "mrf.username")) {
			redirectTo(route="mrfRequestIndex");
		}
		else {
			user = model("user").new();
		}
	}

	function create()
	{
		var login = model("login").findOne(select="hris_id, username", where="username = '#params.user.username#' AND password = '" & hash(params.user.password, 'sha') & "'");
		
		if(isObject(login)) {
			var employee = model("hrisemployee").findOne(select="fullname, lastname, firstname, middlename, position, date_hired, image_path", where="id = #login.hris_id#");

			lock scope="Session" timeout="2" type="exclusive" {
				SESSION.mrf.user_id = login.hris_id;
				SESSION.mrf.username = login.username;
				SESSION.mrf.lastname =  employee.lastname;
				SESSION.mrf.firstname =  employee.firstname;
				SESSION.mrf.middlename =  employee.middlename;
				SESSION.mrf.position =  employee.position;
				SESSION.mrf.datehired =  employee.date_hired;
				SESSION.mrf.allowed_divisions = getDivisions();
				SESSION.mrf.active_division = params.division;
				
				if(employee.image_path == "") {
					SESSION.mrf.picture = "http://npi-appserver/employee/econtacts/img/void.png";
				}
				else {
					SESSION.mrf.picture = "http://npi-appserver/employee/personnel/"&employee.image_path;
				}
			}

			flashInsert(success="Successfully logged in. Welcome, #employee.fullname#!");
			if(structKeyExists(params, "redirectTo")) {
				if(structKeyExists(params, "redirectKey")) {
					redirectTo(route=params.redirectTo, key=params.redirectKey);
				}
				else {
					redirectTo(route=params.redirectTo);
				}
			}
			else {
				redirectTo(route="mrfRequestIndex");
			}
		}
		else {
			user = model("login").new(params.user);
			flashInsert(error="Invalid password!");
			redirectTo(action="new", params="user.username=#params.user.username&rewriteURLParams()#");
		}
	}

	function delete()
	{
		structDelete(SESSION, "mrf");
		user = model("login").new();
		flashInsert(success="Successfully log out!");
		redirectTo(action="new");
	}

	private function rewriteURLParams()
	{
		if(structKeyExists(params, "redirectTo")) {
			if(structKEyExists(params, "redirectKey")) {
				return "&redirectTo=#params.redirectTo#&redirectKey=#params.redirectKey#";
			}
			else {
				return "&redirectTo=#params.redirectTo#";
			}
		}
		else {
			return "";
		}
	}

	function getUser() 
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(employee_db);
			sqlQuery.setSQL("
				SELECT a.EMP33 AS hris_id, a.EMP3 AS firstname, a.EMP2 AS lastname, a.EMP5 AS position, a.EMP23 AS image_path, a.EMP6 AS date_hired   
				FROM hris.m_employee a
				INNER JOIN login.tbl_login b 
				ON a.EMP33 = b.Emp33 
				WHERE b.username = :username 
				  AND b.Active = :active 
				LIMIT 1 
			");
			sqlQuery.addParam(name="username", value=params.username, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="active", value=1, CFSQLTYPE="CF_SQL_INTEGER");
			var user = sqlQuery.execute().getResult();
			
			if(user.recordCount) {
				
				renderWith({
					'user_id': user.hris_id,
					'firstname': user.firstname,
					'lastname': user.lastname,
					'position': user.position,
					'date_hired': user.date_hired,
					'image_path': Len(Trim(user.image_path)) > 0 ? image_path&user.image_path : image_blank,
					'client': login
				});
			}
			else {
				renderWith(false);
			}

			
		}
		catch (customExcp e) {
		    renderWith(e);
		}
	}

	function getDivisions()
	{
		var unique_divisions = [];
		var allowed_divisions = [];

		for(var row in divisions) {
			if(arrayFind(unique_divisions, row.id) == 0) {
				allowed_divisions.append({
					id: row.id,
					name: row.code
				});
				unique_divisions.append(row.id);
			}
		}
		return allowed_divisions;
	}
}