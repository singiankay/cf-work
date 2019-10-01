component extends="Model" output="false"
{

	function config()
	{
		datasource("erpdb_fg");
		table("tbl_erpx_jo");

		hasMany(name="jorevision", foreignKey="jo_id");
	}
}