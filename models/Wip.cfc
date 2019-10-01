component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_wip");
		hasMany(name="wiplines", foreignKey="wip_id");
	}
}