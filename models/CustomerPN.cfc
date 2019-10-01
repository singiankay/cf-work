component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_customer_pn");

		validatesUniquenessOf(property="customer_code", scope="model_id", message="Model already assigned to this customer");
		
	}
}