component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_barcode_format_exclusion");


		//standardize column names of the table
		validatesPresenceOf(properties="barcode_format_id, model_number");
		validatesUniquenessOf(properties="model_number", scope="barcode_format_id", message="Duplicate Model");
		belongsTo(name="barcodeformat", foreignKey="id");

	}
}