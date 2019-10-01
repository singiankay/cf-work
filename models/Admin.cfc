component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_admin");

		//standardize column names of the table
		// property(name="code", column="Code");
		validatesPresenceOf(properties="fk_user_id,applications");
		validatesUniquenessOf(property="fk_user_id", message="User is already registered as an Admin");
		validatesNumericalityOf(property="fk_user_id", onlyInteger=true);
	}
}