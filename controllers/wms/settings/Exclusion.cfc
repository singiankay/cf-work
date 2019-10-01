component displayname="WMS Settings - Exclusion" extends="app.controllers.Controller"
{
	title = "WMS - Exclusion";

	function config()
	{
		filters("restrictAccess");
		usesLayout(template="/wms/layout");
		provides("html, json");
	}

	function index()
	{
		controllerJS = 'wms/settings/exclusions_index';
		barcodeformat = model("barcodeformat").findByKey(params.barcodeformatKey);
	}

	function show()
	{

	}

	function new()
	{

	}
	
	function edit()
	{

	}

	function create()
	{
		var create = model("barcodeformatexclusion").new();
		create.barcode_format_id = params.barcodeformatKey;
		create.model_number = '#params.model_no#';
		create.created_by = SESSION.wms.user_id;
		var result = create.save();
		if(result == true) {
			var newData = model("barcodeformatexclusion").findByKey(create.id);
			var modelName = model("productname").findOne(select="ItemCode, ItemName", where="ItemCode = '#newData.model_number#'");
			var exclusionCreator = model("hrisemployee").findOne(select="id, fullname", where="id = #newData.created_by#");
			
			renderWith({
				result: result,
				id: newData.id,
				barcode_format_id: newData.barcode_format_id,
				model_number: newData.model_number,
				model_name: modelName.ItemName,
				created_by: exclusionCreator.fullname,
				created_by_id: newData.created_by
			});
		}
		else {
			renderWith({
				result: result,
				errors: create.allErrors()
			});
		}
	}

	function update()
	{

	}

	function delete()
	{
		var delete = model("barcodeformatexclusion").deleteByKey(params.key);
		renderWith(delete);
			
	}

	function getExclusions()
	{
		var exclusions = model("barcodeformatexclusion").findAll(where="barcode_format_id = #params.id#");
		if(exclusions.recordCount) {
			var exclusionUserIDs = ListRemoveDuplicates(valueList(exclusions.created_by));
			var modelIDs = ListRemoveDuplicates(quotedValueList(exclusions.model_number));
			var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelIDs#)");
			var exclusionCreators = model("hrisemployee").findAll(select="id, fullname", where="id IN (#exclusionUserIDs#)");
			var result = [];
			for(var x in exclusions) {
				result.append({
					id: x.id,
					barcode_format_id: x.barcode_format_id,
					model_number: x.model_number,
					model_name: getModelName(modelNames, x.model_number),
					created_by: getFullname(exclusionCreators, x.created_by),
					created_by_id: x.created_by
				});
			}
			renderWith(result);
		}
		else {
			renderWith([]);
		}
		
	}

	function getModels()
	{
		try {
			var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#SESSION.wms.active_division#' AND type='Finished Goods'");
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

	function getFullname(userList, user)
	{
		for(u in arguments.userList) {
			if(u.id == arguments.user) {
				return u.fullname;
			}
		}
		return false;
	}

	function getModelName(names, name) {
		for(n in arguments.names) {
			if(n.ItemCode == arguments.name) {
				return n.ItemName;
			}
		}
		return false;
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "wms")) {
			flashInsert(error="You are not logged in");
			redirectTo(route="wmsLogin");
		}
		else {
			if(!getRole(SESSION.wms.allowed_roles)) {
				flashInsert(error="You are not allowed to access this page.");
				redirectTo(route="wmsMain");
			}
		}
	}

	private function getRole(roles) {
		for(r in arguments.roles) {
			if(r.role == 'Print' AND r.id == SESSION.wms.active_division) {
				return true;
			}
		}
		return false;
	}
	
}