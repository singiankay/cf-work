component extends="Model" output="false"
{
	function config()
	{
		datasource("erpdb_fg");
		table("tbl_prf");
		
		setPrimaryKey("id_record");

		hasMany(name="prfitems", foreignKey="id_base");
	}
}