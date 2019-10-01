component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_sales_order_lines");

		belongsTo(name="salesorder", foreignKey="so_id");
		hasMany(name="productionschedules", foreignKey="so_line_id");

		//standardize column names of the table
		// property(name="code", column="Code");
		validatesPresenceOf(properties="so_id");
		validatesNumericalityOf(property="qty", onlyInteger=true);
		
	}
}