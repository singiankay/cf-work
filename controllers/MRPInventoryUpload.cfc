component displayname="MRP Inventory Upload" extends="app.controllers.Controller"
{	
	InventoryLocation = ['Production','InTransit','WH/IQC','OpenPO'];

	function config()
	{
		provides("html,json");
	}

	function index()
	{
		var inventory =  model("monthlyinventory").findAll(select="id, division, DATE_FORMAT(monthyear, '%Y-%M') AS monthyear, material_id, location, qty, is_active, created_by, updated_by, date_created, date_updated", where="DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND division = '#params.division#' AND location='#params.location#' AND is_active = 1");
		var materials = [];
		if(inventory.recordcount) {
			inventoryIDs = quotedValueList(inventory.material_id);
			var inventoryNames = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#inventoryIDs#)");
			for(data in inventory) {
				arrayAppend(materials, {
					id: data.id,
					material_id: data.material_id,
					material_name: getMaterialName(inventoryNames, data.material_id),
					qty: data.qty
				});
			}
			renderWith(materials);
		}
		else {
			renderWith([]);
		}
	}

	function show()
	{
		var inventory = model("monthlyinventory").findByKey(params.key);
		var materialName = model("productname").findOne(select="ItemName",where="ItemCode = '#inventory.material_id#'");

		renderWith({
			material_id: inventory.material_id,
			material_text: materialName.ItemName,
			qty: inventory.qty,
			location: inventory.location,
			monthyear: inventory.monthyear
		});
	}

	function create()
	{
		var inventory = model("monthlyinventory").new();
		inventory.division = params.division;
		inventory.monthyear = DateFormat(params.monthyear, 'mm/dd/yyyy');
		inventory.location = params.location;
		inventory.material_id = params.form.material.id;
		inventory.qty = params.form.qty;
		inventory.is_active = 1;
		inventory.created_by = params.user_id;
		inventory.save();
		
		if(inventory.hasErrors()) {
			renderWith({status:'error', message: super.getErrorList(inventory.allErrors()) });
		}
		else {
			renderWith({status:'success', message: ['Successfully created inventory #params.form.material.text#'] });
		}
	}

	function update()
	{
		var inventory = model("monthlyinventory").findOne(where="id = #params.key#");
		var update = inventory.update(material_id=params.form.material.id, qty=params.form.qty,updated_by=params.user_id);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated record no. #params.key#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(inventory.allErrors()) });
		}
	}

	function delete()
	{

		var inventory = model("monthlyinventory").findOne(where="id = #params.key#");
		var update = inventory.update(is_active=0);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully deleted record no. #params.key#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(inventory.allErrors()) });
		}

	}

	function verifyExcel()
	{
		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type IN ('Materials', 'Chemicals', 'Packaging Materials')");
		var SubGroupCodes = valueList(Subgroup.code);
		var materialIDs = getMaterialIds(params.data);
		var verifiedData = [];

		if(listLen(materialIDs)) {
			var checkMaterials = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#materialIDs#) AND ItmsGrpCod IN (#SubGroupCodes#)");
			for(data in params.data) {
				if(isImportMaterialInMaterials(checkMaterials, data.MaterialID)) {
					arrayAppend(verifiedData, {
						material_id: data.MaterialID,
						material_name: getMaterialName(checkMaterials, data.MaterialID),
						qty: data.Qty,
						status: isQty(data.Qty),
						status_message: (isQty(data.Qty) ? "" : "Invalid Qty")
					});
				}
				else {
					arrayAppend(verifiedData, {
						material_id: data.MaterialID,
						material_name: '',
						qty: data.Qty,
						status: false,
						status_message: "Material does not exist"
					});
				}
				renderWith(verifiedData);
			}
		}
		else {
			renderWith([]);
		}
	}

	function uploadExcel()
	{
		var firstDay = createDate(year(params.monthyear), month(params.monthyear), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type IN ('Materials', 'Chemicals', 'Packaging Materials')");
		var SubGroupCodes = valueList(Subgroup.code);
		var materialIDs = getMaterialIds(params.data);
		// var materialrecords = model("monthlyinventory").findAll(where="monthyear >= '#firstDay#' AND monthyear <= '#lastDay#' AND division = '#params.division#' AND location = '#params.location#' AND is_active = 1");
		var checkMaterials = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#materialIDs#) AND ItmsGrpCod IN (#SubGroupCodes#)");
		var errors = 0;
		var errorList = [];
		
		transaction {
			try {
				for(data in params.data) {
					if(isImportMaterialInMaterials(checkMaterials, data.MaterialID)) {
						if(isQty(data.Qty)) {
							var inv = model("monthlyinventory").findOne(where="material_id = '#data.MaterialID#' AND monthyear >= '#firstDay#' AND monthyear <= '#lastDay#' AND division = '#params.division#' AND location = '#params.location#' AND is_active = 1");
							if(isObject(inv)) {
								var update = inv.update(qty=data.Qty, updated_by=params.user_id, transaction=false);
								if(update != true) {
									errors++;
									arrayAppend(errorList, inv.allErrors());
								}
							}
							else {
								var create = model("monthlyinventory").new();
								create.division = params.division;
								create.monthyear = DateFormat(params.monthyear, 'mm/dd/yyyy');
								create.location = params.location;
								create.material_id = data.MaterialID;
								create.qty = data.Qty;
								create.is_active = 1;
								create.created_by = params.user_id;
								create.save(transaction=false);
								if(create.hasErrors()) {
									errors++;
									arrayAppend(errorList, create.allErrors());
								}
													
							}
						}
						else {
							errors++;
							arrayAppend(errorList, "Invalid Qty: #data.Qty#");
						}
					}
					else {
						errors++;
						arrayAppend(errorList, "Material does not exist: #data.MaterialID#");
					}
				}
				if(errors) {
					transaction action="rollback";
					renderWith({status:'error', message: errorList });
				}
				else {
					transaction action="commit";
					renderWith({status:'success', message: ["Successfully updated data"]});
				}
			}
			catch (customExcp e) {
				transaction action="rollback";
				renderWith({ status:'error', message: e });
			}
		}
	}

	function searchMaterials() {
		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#'");
		var SubGroupCodes = valueList(Subgroup.code);
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT ItemCode, ItemName 
				  FROM ( 
				       SELECT ItemCode, ItemName, ROW_NUMBER() 
				         OVER (ORDER BY ItemCode) as row 
				         FROM dbo.OITM 
				         WHERE ItmsGrpCod IN (:subgroupcodes) 
				           AND ItemCode+' '+ItemName LIKE :query 
				           AND frozenFor = 'N' 
				       ) a 
				 WHERE row <= 50 
			");
			sqlQuery.addParam(name="subgroupcodes", value=SubGroupCodes, CFSQLTYPE="CF_SQL_INTEGER",list="true");
			sqlQuery.addParam(name="query", value="%"&params.q&"%", CFSQLTYPE="CF_SQL_VARCHAR");
			var resultset = sqlQuery.execute().getResult();
			renderWith(resultset);
		}
		catch (customExcp e) {
		    renderWith(e);
		}
		
	}

	function getMaterialIDs(data) {

		var materialIDsArray = [];
		for(data in arguments.data) {
			arrayAppend(materialIDsArray, trim(data.MaterialID));
		}
		materialIDList = arrayToList(materialIDsArray);
		return listQualify(materialIDList,"'");

	}

	function getInventoryLocations() {

		renderWith(InventoryLocation);

	}

	function getMaterialName(checkMaterials, MaterialID) {

		for(rows in arguments.checkMaterials) {
			if(trim(arguments.MaterialID) == rows.ItemCode) {
				return rows.ItemName;
			}
		}
		return false;

	}

	function isImportMaterialInMaterials(checkMaterials, MaterialID) {

		for(rows in arguments.checkMaterials) {
			if(arguments.MaterialID == rows.ItemCode) {
				return true;
			}
		}
		return false;

	}

	function isImportDuplicateInMaterialRecords(checkMaterialRecords, MaterialID) {

		for(rows in arguments.checkMaterialRecords) {
			if(arguments.MaterialID == rows.material_id) {
				return true;
			}
		}
		return false;

	}

	function isQty(qty) {
		if(isValid("float", arguments.qty)) {
			return true;
		}
		return false;
	}
}