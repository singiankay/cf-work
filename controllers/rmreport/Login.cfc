component displayname="WMS Login" extends="app.controllers.Controller"
{
	title = "WMS - Login";
	divisions = super.getDivisions();
	
	function config()
	{
		usesLayout(template='layout');
		provides("html, json");
		verifies(post=true, only="create");
	}

	function new() 
	{
		if(structKeyExists(SESSION, "rmreport.division")) {
			redirectTo(route="rmreportBalanceIndex");
		}
	}

	function admin()
	{
		if(structKeyExists(SESSION, "rmreport.username")) {
			redirectTo(route="rmreportBalanceIndex");
		}
		else {
			user = model("user").new();
		}
	}

	function show()
	{

	}

	function create()
	{
		if(structKeyExists(params, "division")) {
			lock scope="Session" timeout="2" type="exclusive" {
				SESSION.rmreport.division = params.division;
			}
			flashInsert(success="Successfully logged in!");
			if(structKeyExists(params, "redirectTo")) {
				if(structKeyExists(params, "redirectKey")) {
					redirectTo(route=params.redirectTo, key=params.redirectKey);
				}
				else {
					redirectTo(route=params.redirectTo);
				}
			}
			else {
				redirectTo(route="rmreportBalanceIndex");
			}
		}
		else {
			flashInsert(error="Access denied!");
			redirectTo(action="new");
		}
	}

	function createAdmin()
	{
		var login = model("login").findOne(select="hris_id, username", where="username = '#params.user.username#' AND password = '" & hash(params.user.password, 'sha') & "'");
		
		if(isObject(login)) {
			var loginErp = model("user").findAll(select="fk_user_id, division, role, access_type", where="fk_user_id = #login.hris_id# AND access_type = 'WH' AND role = 'RM Reports' AND is_active = 1", returnAs="query");

			if(loginErp.recordCount) {
				var employee = model("hrisemployee").findOne(select="fullname, lastname, firstname, middlename, position, date_hired, image_path", where="id = #login.hris_id#");
				var divisions = super.getDivisions();
				var allowedRoles = [];
				var allowedDivisions = [];
				var listDivisions = listRemoveDuplicates(valueList(loginErp.division));

				for(d in listDivisions) {
					allowedDivisions.append({
						id: d,
						name: getDivision(divisions, d)
					});
				}

				for(row in loginErp) {
					allowedRoles.append({ id: row.division, role: row.role, name: getDivision(divisions, row.division)});
				}

				lock scope="Session" timeout="2" type="exclusive" {
					SESSION.rmreport.user_id = login.hris_id;
					SESSION.rmreport.username = login.username;
					SESSION.rmreport.lastname =  employee.lastname;
					SESSION.rmreport.firstname =  employee.firstname;
					SESSION.rmreport.middlename =  employee.middlename;
					SESSION.rmreport.position =  employee.position;
					SESSION.rmreport.datehired =  employee.date_hired;
					SESSION.rmreport.allowed_roles = allowedRoles;
					SESSION.rmreport.allowed_divisions = allowedDivisions;
					
					if(employee.image_path == "") {
						SESSION.wms.picture = "http://npi-appserver/employee/econtacts/img/void.png";
					}
					else {
						SESSION.wms.picture = "http://npi-appserver/employee/personnel/"&employee.image_path;
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
					redirectTo(route="rmreportBalanceIndex");
				}
			}
			else {
				user = model("login").new(params.user);
				flashInsert(error="Access denied!");
				redirectTo(route="rmreportAdmin", params="user.username=#params.user.username&rewriteURLParams()#");
			}
		}
		else {
			user = model("login").new(params.user);
			flashInsert(error="Invalid password!");
			redirectTo(route="rmreportAdmin", params="user.username=#params.user.username&rewriteURLParams()#");
		}
	}

	function update()
	{
		
	}

	function delete()
	{
		structDelete(SESSION, "rmreport");
		user = model("login").new();
		flashInsert(success="Successfully log out!");
		redirectTo(action="new");
	}

	private function rewriteURLParams() {
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
				var login = model("user").findAll(select="id, access_type, area, division, is_active, role", where = "fk_user_id = '#user.hris_id#' AND access_type = 'WH' AND role = 'RM Reports'");
				var allowed_divisions = getUniqueDivisions(login);
				
				renderWith({
					'user_id': user.hris_id,
					'firstname': user.firstname,
					'lastname': user.lastname,
					'position': user.position,
					'date_hired': user.date_hired,
					'image_path': Len(Trim(user.image_path)) > 0 ? image_path&user.image_path : image_blank,
					'client': login,
					'divisions': allowed_divisions
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

	function getDivision(divisions, division) 
	{
		for(d in arguments.divisions) {
			if(arguments.division == d.id) {
				return d.code;
			}
		}
		return false;
	}

	function getUniqueDivisions(login)
	{
		var divisions = super.getDivisions();
		var unique_divisions = [];
		var allowed_divisions = [];

		for(var row in arguments.login) {
			if(arrayfind(unique_divisions, row.division) == 0) {
				allowed_divisions.append({
					id: row.division,
					name: getDivision(divisions, row.division)
				});
				unique_divisions.append(row.division);
			}
		}
		return allowed_divisions;
	}
}