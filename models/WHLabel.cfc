component extends="Model" output="false"
{
	function config() {
		
		datasource("erpdb");
		table("tbl_whlbl_main");
		
		setPrimaryKey("id_record");
	}
}