component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_user");

		validatesUniquenessOf(property="fk_user_id", scope="division, role, access_type", message="User is already registered");
	}
}