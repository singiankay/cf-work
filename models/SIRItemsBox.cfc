component extends="Model" output="false"
{
	function config()
	{
		datasource("erpdb_fg");
		table("tbl_sir_items_box");
		
		setPrimaryKey("id_record");
	}
	
}