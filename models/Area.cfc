component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_area");

		//standardize column names of the table
		property(name="id", column="id");
		property(name="division", column="division");
		property(name="area", column="area");
		
		
	}
}