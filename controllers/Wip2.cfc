component displayname="WIP" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

	}

	function show() {

		var iposModel = model("product").findOne(where="model_id = '#params.key#' AND is_active = 1");
		var SAPModel = model("productname").findOne(select="ItemCode, ItemName", where="ItemCode = '#params.key#' AND frozenFor = 'N'");
		var maxProcessRevision = getMaxModelRevision(iposModel.id, 0);
		var maxBomRevision = getMaxModelRevision(iposModel.id, 1);
		if(maxProcessRevision.status == 'success' && maxBomRevision.status == 'success') {

			var qModel = getIPosModel(iposModel.id, maxProcessRevision.rows.mrRevision, maxBomRevision.rows.mrRevision);
			var distinctProcesses = getDistinctProcesses(qModel.data);
			var distinctMaterials = getDistinctMaterials(qModel.data);

			if(ListLen(distinctProcesses)) {
				var ProcessNames = model("productprocessname").findAll(where="Code IN (#distinctProcesses#) AND U_Division = '#params.division_name#'");
			}
			if(ListLen(distinctMaterials)) {
				var MaterialNames = model("productname").findAll(where="ItemCode IN(#distinctMaterials#)");
			}

			if(qModel.status == "success") {

				var wipCheck = model("wipline").findAll(
					where="model_id = '#params.key#' AND division = '#params.division#' AND area = '#super.getArea(params.area)#' AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND is_active = 1", 
					include="wip"
				);
				var wipData = [];

				if(wipCheck.recordcount) {
					for(qmodelRows in qModel.data) {
						var isWip = false;
						for(wipRows in wipCheck) {
							if(wipRows.process_id == qmodelRows.process_id) {
								isWip = true;
								arrayAppend(wipData, {
									id: wipRows.id,
									process_id: wipRows.process_id,
									process_name: getProcessName(ProcessNames, qmodel.data, wipRows.process_id),
									process_order: qmodelRows.process_order,
									material_id: qmodelRows.material_id,
									material_name: getMaterialName(MaterialNames,qmodelRows.material_id),
									bom_qty: qModelRows.qty,
									wip_qty: wipRows.qty,
									has_record: true
								});
							}
						}
						if(isWip == false) {
							arrayAppend(wipData, {
								id: 0,
								process_id: qmodelRows.process_id,
								process_name: getProcessName(ProcessNames, qmodel.data, qmodelRows.process_id),
								process_order: qmodelRows.process_order,
								material_id: qmodelRows.material_id,
								material_name: getMaterialName(MaterialNames,qmodelRows.material_id),
								bom_qty: qModelRows.qty,
								wip_qty: 0,
								has_record: false
							});
						}
					}

					renderWith({
						status: 'success',
						action: 'update',
						model_id: iposModel.model_id,
						model_name: SAPModel.ItemName,
						process_rev: maxProcessRevision.rows.mrRevision,
						bom_rev: maxBomRevision.rows.mrRevision,
						data: wipData
					});
				}
				else {
					for(qModelRows in qModel.data) {
						arrayAppend(wipData, {
							id: 0,
							process_id: qmodelRows.process_id,
							process_name: getProcessName(ProcessNames, qmodel.data, qmodelRows.process_id),
							process_order: qmodelRows.process_order,
							material_id: qmodelRows.material_id,
							material_name: getMaterialName(MaterialNames,qmodelRows.material_id),
							bom_qty: qModelRows.qty,
							wip_qty: 0,
							has_record: false
						});
					}
					renderWith({
						status: 'success',
						action: 'create',
						model_id: iposModel.model_id,
						model_name: SAPModel.ItemName,
						process_rev: maxProcessRevision.rows.mrRevision,
						bom_rev: maxBomRevision.rows.mrRevision,
						data: wipData
					});
				}
			}
			else {
				renderWith(wipCheck);
			}
		}
		else {
			renderWith({status:'error', message: ["revisions not assigned properly"] });
		}

	}

	function create() {

		var errors = 0;
		var errorList = [];
		
		var isWip = model("wip").findOne(where="model_id = '#params.model_id#' AND division = '#params.division#' AND area = '#super.getArea(params.area)#' AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND is_active = 1");

		if(IsObject(isWip)) {

			var wipCheck = model("wipline").findAll(
				where="model_id = '#params.model_id#' AND division = '#params.division#' AND area = '#super.getArea(params.area)#' AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND is_active = 1", 
				include="wip"
			);

			transaction {
				try {
					for(rows in params.data) {
						if(rows.has_record == true) {
							var wipLine = model("wipline").findByKey(rows.id);
							var update = wipLine.update(qty=rows.wip_qty, updated_by=params.user_id, transaction=false);
							if(update != true) {
								errors++;
								arrayAppend(errorList, wipLine.allErrors());
							}
						}
						else {
							var create = model("wipline").new();
							create.wip_id = isWip.id;
							create.process_id = rows.process_id;
							create.qty = rows.wip_qty;
							create.is_active = 1;
							create.created_by = params.user_id;
							create.save(transaction=false);

							if(create.hasErrors()) {
								errors++;
								arrayAppend(errorList, create.allErrors());
							}
						}
					}
					if(errors) {
						transaction action="rollback";
						renderWith({status:'error', message: errorList});
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
		else {
			transaction {
				try {
					var createWip = model("wip").new();
					createWip.model_id = params.model_id;
					createWip.division = params.division;
					createWip.area = super.getArea(params.area);
					createWip.monthyear = DateFormat(params.monthyear, 'mm/dd/yyyy');
					createWip.process_rev_no = params.process_rev;
					createWip.bom_rev_no = params.bom_rev;
					createWip.is_active = 1;
					createWip.save(transaction=false);

					if(createWip.hasErrors()) {
						errors++;
						arrayAppend(errorList, createWip.allErrors());
					}
					else {
						for(rows in params.data) {
							var createWipLine = model("wipline").new();
							createWipLine.wip_id = createWip.id;
							createWipLine.process_id = rows.process_id;
							createWipLine.qty = rows.wip_qty;
							createWipLine.is_active = 1;
							createWipLine.created_by = params.user_id;
							createWipLine.save(transaction=false);

							if(createWipLine.hasErrors()) {
								errors++;
								arrayAppend(errorList, createWipLine.allErrors());
							}
						}
					}

					if(errors) {
						transaction action="rollback";
						renderWith({status:'error', message: errorList});
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

	}

	function update() {

	}

	function delete() {

	}

	function getModels() {
		
		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type='Finished Goods'");
		var SubGroupCodes = valueList(Subgroup.code);
		
		if(params.area != 0) {
			var area = super.getProductionLine(params.area);
			var SAPModels = model("productname").findAll(select="ItemName, ItemCode", where="ItmsGrpCod IN (#SubGroupCodes#) AND frozenFor = 'N' AND U_ProductionLine = '#area#'");
			var SAPModelList = getModelList(SAPModels);
			var AppModels = model("product").findAll(select="id_record, model_id",where="model_id IN (#SAPModelList#) AND is_active = 1");
			var AppModelIDs = getAppModelList(AppModels);
			var wip = model("wip").findAll(where="model_id IN (#AppModelIDs#) AND division = '#params.division#' AND area = '#params.area#' AND is_active = 1 AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M')");
		}
		else {
			var SAPModels = model("productname").findAll(select="ItemName, ItemCode", where="ItmsGrpCod IN (#SubGroupCodes#) AND frozenFor = 'N'");
			var SAPModelList = getModelList(SAPModels);
			var AppModels = model("product").findAll(select="id_record, model_id",where="model_id IN (#SAPModelList#) AND is_active = 1");
			var AppModelIDs = getAppModelList(AppModels);
			var wip = model("wip").findAll(where="model_id IN (#AppModelIDs#) AND division = '#params.division#' AND is_active = 1 AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M')");
		}
		var models = [];
		for(AppModel in AppModels) {
			arrayAppend(models, {
				id: AppModel.model_id,
				name: getModelName(SAPModels, AppModel.model_id),
				has_record: isModelInWip(wip, Appmodel.model_id)
			});
		}
		renderWith(models);
	}

	function isModelInWip(wips, model_id) {

		for(wip in arguments.wips) {
			if(wip.model_id == arguments.model_id) {
				return true;
			}
		}
		return false;

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

	}

	function getMaxModelRevision(id, type) {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.mrModel, a.mrRevision, a.mrType 
				  FROM tbl_model_revision a
				 INNER JOIN (
					SELECT MAX(mrRevision) AS mrRevision, mrModel 
					  FROM tbl_model_revision 
					 WHERE mrModel = :id 
					   AND mrType = :type
					   AND mrActive = 1 
					   AND mrApproved = 2
				) b 
				ON a.mrModel = b.mrModel 
			  AND a.mrRevision = b.mrRevision  
			  AND a.mrType = :type
			  AND a.mrActive = 1 
			  AND a.mrApproved = 2
			");
			sqlQuery.addParam(name="id", value=arguments.id, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="type", value=arguments.type, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			return { status: 'success', rows: resultset };
		}
		catch (customExcp e) {
		    return { status:'error', message: e };
		}

	}

	function getIPosModel(model_id, process_revision, bom_revision) {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.mpProcess AS process_id, a.mpOrder AS process_order, a.mpYield AS process_yield, 
						 b.mbItem AS material_id, b.mbQuantity AS qty, b.mbYield AS bom_yield, 
						 c.pSap  AS process_code 
				  FROM tbl_model_process a
				  LEFT JOIN (
				  		 SELECT mbProcess, mbItem, mbQuantity, mbYield 
				  		   FROM tbl_model_bom 
				  		  WHERE mbModel = :id 
				  		    AND mbRevision = :bom
				   ) b 
				    ON a.mpProcess = b.mbProcess 
				    INNER JOIN tbl_process c 
				    ON a.mpProcess = c.id_record 
				 WHERE a.mpModel = :id 
				   AND a.mpRevision = :process 
				 ORDER BY a.mpOrder ASC
			");
			sqlQuery.addParam(name="id", value=arguments.model_id, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="process", value=arguments.process_revision, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="bom", value=arguments.bom_revision, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			return { status:'success', data: resultset };
		}
		catch (customExcp e) {
		    return { status:'error', message: e };
		}

	}

	function getProcessName(processQuery, data, id) {
		var code = getProcessCode(arguments.data, arguments.id);

		for(processName in arguments.processQuery) {
			if(processName.Code == code) {
				return processName.U_ProcessName;
			}
		}
		return false;

	}

	function getProcessCode(data, id) {
		for(a in arguments.data) {
			if(a.process_id == arguments.id) {
				return a.process_code;
			}
		}
	}

	function getDistinctProcesses(q) {

		var processArray = [];
		for(a in arguments.q) {
			if(!arrayContains(processArray, a.process_code)) {
				arrayAppend(processArray, a.process_code);
			}
		}
		return ListQualify(arrayToList(processArray),"'");
		
	}

	function getProcessList(query) {

		return valueList(query.mpProcess);

	}

	function getBoms(model, query, revision) {

		var processes = getProcessList(query);
		if(ListLen(processes)) {
			try {
				var sqlQuery = new Query();
				sqlQuery.setDatasource(iposx);
				sqlQuery.setSQL("
					SELECT mbModel, mbProcess, mbItem, mbQuantity, mbRevision, mbYield 
					  FROM tbl_model_bom 
					 WHERE mbModel = :model 
					   AND mbProcess IN (:process) 
					   AND mbRevision = :revision
				");
				sqlQuery.addParam(name="model", value=arguments.model, CFSQLTYPE="CF_SQL_INTEGER");
				sqlQuery.addParam(name="process", value=getProcessList(query), CFSQLTYPE="CF_SQL_INTEGER", list=true);
				sqlQuery.addParam(name="revision", value=arguments.revision, CFSQLTYPE="CF_SQL_INTEGER");
				var resultset = sqlQuery.execute().getResult();
				return { status: 'success', rows: resultset };
			}
			catch (customExcp e) {
			    return { status:'error', message: e };
			}
		}
		else {
			return { status:'error', message: 'No processes' };
		}

	}

	function getDistinctMaterials(q) {

		var materialsArray = [];
		for(a in arguments.q) {
			if(!arrayContains(materialsArray, a.material_id)) {
				arrayAppend(materialsArray, a.material_id);
			}
		}
		return ListQualify(arrayToList(materialsArray),"'");

	}

	function getMaterialName(materialQuery, id) {

		for(material in arguments.materialQuery) {
			if(material.ItemCode == arguments.id) {
				return material.ItemName;
			}
		}
		return false;

	}


}