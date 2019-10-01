component displayname="MRP Open PO Import" extends="app.controllers.Controller"
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
		var materials = [];
		var result = [];
		for(var m in params.data) {
			if(arrayFind(materials, m.MaterialID) == 0) {
				arrayAppend(materials, m.MaterialID);
			}
		}
		var verifyMaterials = model("productname").findAll(where="ItemCode IN (#listQualify(arrayToList(materials), "'")#)");
		
		for(var d in params.data) {
			arrayAppend(result, {
				material_no: d.MaterialID,
				material_name: getMaterialName(verifyMaterials, d.MaterialID),
				month: d.PODate,
				qty: d.Qty,
				status: getStatus(verifyMaterials, d),
				status_message: getStatusMessage(verifyMaterials, d)
			});
		}
		renderWith(result);
	}

	function update()
	{
		var errors = 0;
		transaction {
			try {
				for(var m in params.data) {
					var openpo = model("monthlyinventory").findOne(where="division = #params.division# AND location='OpenPO' AND material_id = '#m.material_no#' AND is_active = 1 AND monthyear = STR_TO_DATE('#m.month#', '%m/%d/%Y')");
					if(isObject(openpo)) {
						var update = openpo.update(qty=m.qty, updated_by=params.key, transaction=false);
						if(!update) {
							errors ++;
						}
					}
					else {
						var create = model("monthlyinventory").new();
						create.division = params.division;
						create.location = 'OpenPO';
						create.monthyear = m.month;
						create.created_by = params.key;
						create.material_id = m.material_no;
						create.qty = m.qty;
						create.is_active = 1;
						create.save(transaction=false);
						if(create.hasErrors()) {
							errors++;
						}
					}
				}
				if(errors) {
					transaction action="rollback";
					renderWith({status:'error', message: ['Error updating data. Please check your records again']});
				}
				else {
					transaction action="commit";
					renderWith({status:'success', message: ['Successfully updated record.']});
				}
			}
			catch(any e) {
				transaction action="rollback"; 
				renderWith({status:'error', message: [e.message]});
			}
		}
		
	}

	function delete()
	{

	}

	function isQty(qty) {
		if(isValid("float", arguments.qty)) {
			return true;
		}
		return false;
	}

	function isMaterial(materials, material)
	{
		for(m in arguments.materials) {
			if(m.ItemCode == toString(arguments.material)) {
				return true;
			}
		}
		return false;
	}

	function isDateValid(d) {
		if(isValid("date", arguments.d)) {
			return true;
		}
		return false;
	}

	function getMaterialName(materials, material)
	{
		for(m in arguments.materials) {
			if(m.ItemCode == toString(arguments.material)) {
				return m.ItemName;
			}
		}
		return false;
	}

	function getStatus(materials, data)
	{
		if(isMaterial(arguments.materials, data.MaterialID)) {
			if(isQty(data.Qty)) {
				if(isDateValid(data.PODate)) {
					return true;
				}
				else {
					return false;
				}
				
			}
			else {
				return false;
			}
		}
		else {
			return false;
		}
	}

	function getStatusMessagE(materials, data)
	{
		var errorList = [];

		if(!isMaterial(arguments.materials, data.MaterialID)) {
			errorList.append("Invalid Material");
		}
		if(!isQty(data.Qty)) {
			errorList.append("Invalid Qty");
		}
		if(!isDateValid(data.PODate)) {
			errorList.append("Invalid Date");
		}

		return errorList;
	}
}