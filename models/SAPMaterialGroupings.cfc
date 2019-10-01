component extends="Model" output="false"
{

	function config() {
		
		//set database name for the model
		datasource("sapdb");

		//set table name for the model
		table("dbo.OITB");

		// standardize column names of the table
		setPrimaryKey("ItmsGrpCod");
		property(name="id", column="ItmsGrpCod");
		property(name="name", column="ItmsGrpNam");
		property(name="product_line", column="U_ProductLine");
	}

}