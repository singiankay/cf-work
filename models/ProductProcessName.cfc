component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("sapdb");

		//set table name for the model
		table('dbo."@PN_OPRC"');

		setPrimaryKey("Code");
		
	}
}