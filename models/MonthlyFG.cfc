component extends="Model" output="false"
{

	function config() {

		datasource("erpdb_fg");
		table("tbl_erpx_fg_inventory_m");

		validatesUniquenessOf(property="model_id",scope="monthyear, division, area, is_active", message="Model already exists on this month");
	}

}