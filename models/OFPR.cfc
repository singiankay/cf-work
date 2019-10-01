component extends="Model" output="false"
{
	function config()
	{
		datasource("sapdb");
		table('dbo.OFPR');
		setPrimaryKey("AbsEntry");
	}
	
}