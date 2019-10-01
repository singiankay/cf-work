component extends="Model" output="false"
{

	function config() {

		datasource("erpdb_fg");
		table("tbl_erpx_inventory_m");

		validatesUniquenessOf(property="material_id",scope="monthyear, division, location, is_active", message="Material already exists on this month");
	}

}