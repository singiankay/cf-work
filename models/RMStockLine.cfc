component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_rm_stock_lines");

		//standardize column names of the table
		belongsTo(name="rmstock",foreignKey="id");
	}
}