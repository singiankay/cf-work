component extends="Model" output="false"
{
	function config()
	{
		datasource("sapdb");
		table('dbo."@FN_ORCV"');
		setPrimaryKey("DocEntry");
	}
	
}