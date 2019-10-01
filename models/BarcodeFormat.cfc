component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("erpdb_fg");

		//set table name for the model
		table("tbl_erpx_barcode_format");


		//standardize column names of the table
		validatesPresenceOf(properties="name, division, type");
		hasMany(name="barcodeformatexclusions", foreignKey="barcode_format_id", dependent="delete");

	}
}