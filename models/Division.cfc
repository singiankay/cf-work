component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("SAPDB");

		//set table name for the model
		table("[@PRODUCTLINE]");

		//standardize column names of the table
		property(name="code", column="Code");
		property(name="name", column="Name");
		property(name="id", column="U_idrecord");
		property(name="is_active", column="U_is_active");
		property(name="product_line", column="U_ProductLine");
	}
}