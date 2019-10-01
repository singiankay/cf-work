component extends="Model" output="false"
{
	function config()
	{
		datasource("sapdb");
		table('dbo.ONNM');
		setPrimaryKeys("ObjectCode,DocSubType");
	}
	
}