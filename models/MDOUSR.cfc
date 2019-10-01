component extends="Model" output="false"
{
	function config()
	{
		datasource("sapdb");
		table('dbo."@MD_OUSR"');
		setPrimaryKey("DocEntry");
	}
	
}