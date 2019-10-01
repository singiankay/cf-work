component displayname="Product" extends="app.controllers.Controller"
{	

	function config()
	{
		provides("html, json");
	}

	function index()
	{
	}

	function show()
	{
	}

	function create()
	{
	}

	function update()
	{
	}

	function delete()
	{
	}

	function search()
	{
		try {
			var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type='Finished Goods'");
			var SubGroupCodes = valueList(Subgroup.code);
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT ItemCode as id, ItemName as name  
				  FROM dbo.OITM 
				 WHERE (
				 		 	ItemCode+' '+ItemName LIKE :q
				 		OR ItemName+' '+ItemCode LIKE :q 
				 	  )
				   AND ItmsGrpCod IN (:codes)
			");
			sqlQuery.addParam(name="q", value='%#params.q#%', CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="codes", value=SubGroupCodes, CFSQLTYPE="CF_SQL_INTEGER", list="true");
			var SAPProducts = sqlQuery.execute().getResult();
			var ProductNames = quotedValueList(SAPProducts.id);

			if(listLen(ProductNames) > 0) {
				var filteredProducts = model("product").findAll(select="model_id", where="model_id IN (#quotedValueList(SAPProducts.id)#) AND is_active = 1");
				var filteredIds = ValueList(filteredProducts.model_id);
				var products = [];
				for(SAPProduct in SAPProducts) {
					if(listFindNoCase(filteredIds, SAPProduct.id)) {
						arrayAppend(products, {
							id: SAPProduct.id,
							name: SAPProduct.name
						});
					}
				}
				renderWith(products);
			}
			else {
				renderWith([]);
			}
		}
		catch (customExcp e) {
		    renderWith(e);
		}
	}
}