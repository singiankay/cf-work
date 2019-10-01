component extends="Model" output="false"
{
	function config()
	{
		datasource("erpdb_fg");
		table("tbl_phf");
		
		setPrimaryKey("id_record");
	}
	
}