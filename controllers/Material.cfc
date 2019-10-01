component extends="Controller"
{

	function config() {

		provides("html, json");

	}

	function index() {

	}

	function search() {

		var subgroupcodes = model("materialgroupings").findAll(where="division= '#params.division#'");
		if(subgroupcodes.recordCount) {
			var grouplist = listRemoveDuplicates(valuelist(subgroupcodes.code));
			try {
				var sqlQuery = new Query();
				sqlQuery.setDatasource(sapdb);
				sqlQuery.setSQL("
					SELECT ItemCode, ItemName 
					  FROM dbo.OITM 
					 WHERE ItmsGrpCod IN (:grouplist) 
					   AND Itemcode+' '+ItemName LIKE :query
				");
				sqlQuery.addParam(name="grouplist", value=grouplist, CFSQLTYPE="CF_SQL_INTEGER", list="true");
				sqlQuery.addParam(name="query", value="%"&params.query&"%", CFSQLTYPE="CF_SQL_VARCHAR");
				var resultset = sqlQuery.execute().getResult();
				renderWith(resultset);
			}
			catch(customExcp e) {
		   	renderWith(e);
			}
		}
		else {
			renderWith([]);
		}
		

	}
}