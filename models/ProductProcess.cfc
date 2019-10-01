component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("iposxdb");

		//set table name for the model
		table("tbl_model_process");

		// hasMany(name="salesorderline",foreignKey="so_id");

		//standardize column names of the table
	}
}