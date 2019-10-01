component displayname="Login" extends="app.controllers.Controller"
{	

	PageTitle = "Login";


	function config() {

		provides("html,json");

	}
	

	function index() {

		user = model("login");

	}


	function validate() {

		userCount = model("login").count(where="username = '#params.form.username#'");
		if(userCount) {
			user = model("login").findOne(select = "username, password", where = "username ='"&params.form.username&"'");
			if (user.password == hash(params.form.password,'sha')) {
				renderWith({ status:"success", message: ["Authenticated. Please select division"] });
			} else {
				renderWith({ status:"error", message: ["Invalid Password"] });
			}
		}
		else {
			renderWith({ status:"error", message: ["Username Does Not Exist"] });
		}

	}

	function show() {
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
			sqlQuery.addParam(name="username", value=params.key, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="active", value=1, CFSQLTYPE="CF_SQL_INTEGER");
			var user = sqlQuery.execute().getResult();
		}
		catch (customExcp e) {
		    renderWith(e);
		}
		var clientAdmin = model("admin").findOne(where = "fk_user_id ='#user.hris_id#'");
		var clientUser = model("user").findAll(select="id, access_type, area, division, is_active, role", where = "fk_user_id = '#user.hris_id#'");
		renderWith({
			'user_id': user.hris_id,
			'firstname': user.firstname,
			'lastname': user.lastname,
			'position': user.position,
			'date_hired': user.date_hired,
			'image_path': Len(Trim(user.image_path)) > 0 ? image_path&user.image_path : image_blank,
			'admin': clientAdmin,
			'client': clientUser
		});
	}


	function getDivision() {

		var user = model("login").findOne(select = "hris_id", where = "username ='"&params.username&"'");
		userRole = model("admin").findOne(select = "id, roles, role_access", where = "fk_emp33 ='"&user.hris_id&"'");
		renderWith(userRole);

	}


	function getHRISData() {
		
	}


	function login() {

		divisions = model("division").findall(
			select="code",
			where="id < 8 AND is_active = 1", 
			order="code ASC"
		);

	}

	
}