component extends="Model" output="false"
{
	function config()
	{
		datasource("sapdb");
		table('dbo.NNM1');
		setPrimaryKey("Series");
	}
	
}