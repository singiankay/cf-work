component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_sales_orders");

		hasMany(name="salesorderlines",foreignKey="id");

		//standardize column names of the table
		validatesPresenceOf(properties="division, so_date, customer_id, document_status");
		// validatesUniquenessOf(property="so_no", scope="division", condition="this.is_active IS 1 AND this.document_status IS NOT 'Void' AND this.so_no IS NOT ''", message="Sales order number is already used");
	}
}