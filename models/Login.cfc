component extends="Model" output="false"
{
	function config() {

		datasource("login");
		table("tbl_login");
		
		property(name="id", column="ID");
		property(name="hris_id", column="Emp33");
		property(name="employee_id", column="Employee_ID");
		property(name="username", column="Username");
		property(name="password", column="Password");
		property(name="password_2016", column="password_2016");
		property(name="email", column="Email");
		property(name="captcha", column="Captcha");
		property(name="internal", column="internal");
		property(name="phone_number", column="myphone");
		property(name="mobile_number", column="mymobile");
		property(name="skype", column="skype");
		property(name="is_active", column="Active");
		property(name="is_econtacts", column="econtacts");
		property(name="date_saved", column="date_saved");
		property(name="is_eforms", column="iseforms");
		property(name="is_ememo", column="isememo");
		property(name="is_external", column="isexternal");
		
	}
}