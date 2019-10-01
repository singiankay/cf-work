component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("SAPDB");

		//set table name for the model
		table("dbo.OCRD");
		
		property(name="id", column="CardCode");
		property(name="name", column="CardName");
		property(name="type", column="CardType");
		property(name="mail_address", column="MailAddres");

		setPrimaryKey("CardCode");
	}
}