component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_production_schedule");

		belongsTo(name="salesorderline", foreignKey="id");
		hasMany(name="materialalternatives", foreignKey="production_schedule_id");

		//standardize column names of the table
		// property(name="code", column="Code");
		validatesPresenceOf(properties="so_line_id");
		validatesNumericalityOf(property="qty", onlyInteger=true);
		
	}
}