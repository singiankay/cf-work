component extends="Model" output="false"
{
	function config()
	{
		datasource("erpdb_fg");
		table("tbl_shipdetails");
		
		setPrimaryKey("id_record");
	}
}