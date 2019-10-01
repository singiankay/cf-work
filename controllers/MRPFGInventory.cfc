component displayname="MRP FG Inventory" extends="app.controllers.Controller"
{	

	function config() {

		provides("html,json");

	}

	function index() {

		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type='Finished Goods'");
		var SubGroupCodes = valueList(Subgroup.code);
		
		if(params.area != 0) {
			var area = super.getProductionLine(params.area);
			var SAPModels = model("productname").findAll(select="ItemName, ItemCode", where="ItmsGrpCod IN (#SubGroupCodes#) AND frozenFor = 'N' AND U_ProductionLine = '#area#'");
			var SAPModelList = getModelList(SAPModels);
			var AppModels = model("product").findAll(select="id, model_id",where="model_id IN (#SAPModelList#) AND is_active = 1");
			var AppModelIDs = getAppModelList(AppModels);
			var fg = model("monthlyfg").findAll(where="model_id IN (#AppModelIDs#) AND division = '#params.division#' AND area = '#super.getArea(params.area)#' AND is_active = 1 AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M')");
		}
		else {
			var SAPModels = model("productname").findAll(select="ItemName, ItemCode", where="ItmsGrpCod IN (#SubGroupCodes#) AND frozenFor = 'N'");
			var SAPModelList = getModelList(SAPModels);
			var AppModels = model("product").findAll(select="id, model_id",where="model_id IN (#SAPModelList#) AND is_active = 1");
			var AppModelIDs = getAppModelList(AppModels);
			var fg = model("monthlyfg").findAll(where="model_id IN (#AppModelIDs#) AND division = '#params.division#' AND is_active = 1 AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M')");
		}

		var models = [];
		for(AppModel in AppModels) {
			arrayAppend(models, {
				id: (isModelInFG(fg, Appmodel.model_id) ? getMonthlyFGID(fg,Appmodel.model_id) : 0),
				model_id: AppModel.model_id,
				name: getModelName(SAPModels, AppModel.model_id),
				qty: (isModelInFG(fg, Appmodel.model_id) ? getMonthlyFGQty(fg,Appmodel.model_id) : 0),
				has_record: isModelInFG(fg, Appmodel.model_id)
			});
		}
		renderWith(models);

	}

	function show() {

		if(params.type == 'create') {
			var appModel = model("product").findOne(select="id, model_id", where="model_id = '#params.key#' AND is_active = 1");
			var sapModel = model("productname").findOne(select="ItemName, ItemCode", where="ItemCode = '#params.key#'");
			if(isObject(appModel) && isObject(sapModel)) {
				renderWith({
					model_id: appModel.model_id,
					model_name: sapModel.ItemName,
					qty: 0
				});
			}
			else {
				renderWith([]);
			}
		}
		else if(params.type == 'update') {
			var fgInventory = model("monthlyfg").findOne(where="id='#params.id#'");
			var sapModel = model("productname").findOne(select="ItemName, ItemCode", where="ItemCode = '#params.key#'");
			if(isObject(fgInventory) && isObject(sapModel)) {
				renderWith({
					model_id: fgInventory.model_id,
					model_name: sapModel.ItemName,
					qty: fgInventory.fg_qty
				});
			}
			else {
				renderWith([]);
			}
		}

	}

	function create() {

		renderWith(params);
		var monthlyfg = model("monthlyfg").new();
		monthlyfg.division = params.division;
		monthlyfg.area = super.getArea(params.area);
		monthlyfg.monthyear = DateFormat(params.monthyear, 'mm/dd/yyyy');
		monthlyfg.model_id = params.model_id;
		monthlyfg.fg_qty = params.qty;
		monthlyfg.created_by = params.user_id;
		monthlyfg.is_active = 1;
		monthlyfg.save();

		if(monthlyfg.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(monthlyfg.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully updated FG Inventory of #params.model_id#'], id: monthlyfg.id  });
		}

	}

	function update() {

		var fgInventory = model("monthlyfg").findByKey(params.key);
		var update = fgInventory.update(division= params.division, area= super.getArea(params.area), monthyear= DateFormat(params.monthyear, 'mm/dd/yyyy'), model_id= params.model_id, fg_qty= params.qty, updated_by= params.user_id);
		
		if(update) {
			renderWith({status:'success', message: ['Successfully updated FG Inventory of  #params.model_id#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(fgInventory.allErrors()) });
		}

	}

	function verifyExcel() {
		var result = [];
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		var area = super.getArea(params.area);
		var modelsArray = [];
		for(m in params.data) {
			arrayAppend(modelsArray, m.ModelNumber);
		}
		var modelsList = ListQualify(arrayToList(modelsArray),"'");

		// var checkRecords = model("monthlyfg").findAll(select="id, model_id",where="division = '#params.division#' AND area = '#area#' AND monthyear >= '#firstDay#' AND monthyear <= '#lastDay#' AND model_id IN (#modelsList#)");
		var checkModels = model("product").findAll(select="model_id", where="model_id IN (#modelsList#) AND is_active = 1");
		
		var result = [];
		for(m in params.data) {
			if(isModelInFG(checkModels, m.ModelNumber)) {
					arrayAppend(result, {
						model_no: m.ModelNumber,
						model_name: m.ModelName,
						qty: m._Qty,
						status: super.isNumber(m._Qty),
						description: (super.isNumber(m._Qty) ? "" : "Qty is not a number"  )
					});
			}
			else {
				arrayAppend(result, {
					model_no: m.ModelNumber,
					model_name: m.ModelName,
					qty: m._Qty,
					status: false,
					description: "Model doesn't exist"
				});
			}
		}

		renderWith(result);
	}

	function uploadExcel() {

		var result = [];
		var errors = 0;
		var errorList = [];
		
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 1, firstDay ));
		var area = super.getArea(params.area);
		var modelsArray = [];
		for(m in params.data) {
			arrayAppend(modelsArray, m.ModelNumber);
		}
		var modelsList = ListQualify(arrayToList(modelsArray),"'");

		var checkRecords = model("monthlyfg").findAll(select="id, model_id",where="division = '#params.division#' AND area = '#area#' AND monthyear >= '#firstDay#' AND monthyear <= '#lastDay#' AND model_id IN (#modelsList#)");
		var checkModels = model("product").findAll(select="model_id", where="model_id IN (#modelsList#) AND is_active = 1");
		
		var result = [];

		transaction {
			try {
				for(m in params.data) {
					if(isModelInFG(checkModels, m.ModelNumber)) {
						if(isModelInRecords(checkRecords, m.ModelNumber)) {
							var fgrecord = model("monthlyfg").findByKey(getModelInRecords(checkRecords, m.ModelNumber));
							var update = fgrecord.update(fg_qty=m._Qty, updated_by=params.user_id, transaction=false);
							if(update != true) {
								errors++;
								arrayAppend(errorList, fgrecord.allErrors());
							}
							else {
								arrayAppend(result, {
									model_no: m.ModelNumber,
									model_name: m.ModelName,
									qty: m._Qty,
									status: true,
									description: ""
								});
							}
						}
						else {
							if(m._Qty != 0) {
								var create = model("monthlyfg").new();
								create.model_id = m.ModelNumber;
								create.fg_qty = m._Qty;
								create.division = params.division;
								create.area = area;
								create.monthyear = params.month;
								create.is_active = 1;
								create.created_by = params.user_id;
								create.save(transaction=false);

								if(create.hasErrors()) {
									errorst++;
									arrayAppend(errorList, create.allErrors());
								}
								else {
									arrayAppend(result, {
										model_no: m.ModelNumber,
										model_name: m.ModelName,
										qty: m._Qty,
										status: true,
										description: ""
									});
								}
							}
						}
					}
					else {
						arrayAppend(result, {
							model_no: m.ModelNumber,
							model_name: m.ModelName,
							qty: m._Qty,
							status: false,
							description: "Model doesn't exist"
						});
					}
				}
				if(errors) {
					renderWith({ status:'error', message: errorList });
				}
				else {
					transaction action="commit";
					renderWith({status:'success', message: ["Successfully uploaded data"]});
				}
			}
			catch (customExcp e) {
				transaction action="rollback";
				renderWith({ status:'error', message: e });
			}
		}
		

	}

	function getModelList(data) {

		var modelArrays = [];
		for(data in arguments.data) {
			arrayAppend(modelArrays, data.ItemCode);
		}
		modelList = arrayToList(modelArrays);
		return listQualify(modelList, "'");

	}

	function getAppModelList(data) {

		var modelArrays = [];
		for(data in arguments.data) {
			arrayAppend(modelArrays, data.model_id);
		}
		modelList = arrayToList(modelArrays);
		return listQualify(modelList, "'");

	}

	function getModelName(models, model_id) {

		for(model in arguments.models) {
			if(model.ItemCode == arguments.model_id) {
				return model.ItemName;
			}
		}
		return false;
	}

	function isModelInFG(fgs, model_id) {

		for(fg in arguments.fgs) {
			if(fg.model_id == arguments.model_id) {
				return true;
			}
		}
		return false;
	}

	function isModelInRecords(records, model_id) {

		for(fg in arguments.records) {
			if(fg.model_id == arguments.model_id) {
				return true;
			}
		}

		return false;

	}

	function getModelInRecords(records, model_id) {

		for(fg in arguments.records) {
			if(fg.model_id == arguments.model_id) {
				return fg.id;
			}
		}

		return false;

	}

	function getMonthlyFGID(fgs, model_id) {

		for(fg in arguments.fgs) {
			if(fg.model_id == arguments.model_id) {
				return fg.id;
			}
		}

		return false;

	}

	function getMonthlyFGQty(fgs, model_id) {

		for(fg in arguments.fgs) {
			if(fg.model_id == arguments.model_id) {
				return fg.fg_qty;
			}
		}

		return false;

	}
}