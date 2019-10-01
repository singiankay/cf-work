component extends="Model" output="false"
{
	function config()
	{
		datasource("erpdb_fg");
		table("tbl_prf_items");
		setPrimaryKey("id_record");
		belongsTo(name="prf", foreignKey="id_record");
	}
}