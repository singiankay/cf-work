component extends="Model" output="false"
{
	function config() {

		datasource("erpdb_fg");
		table("tbl_erpx_skip_iqc");

		validatesUniquenessOf(property="material_no", scope="division", message="Material Number is already assigned");
		
	}
}