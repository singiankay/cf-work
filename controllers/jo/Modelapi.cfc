component displayname="JO Model API" extends="app.controllers.Controller"
{
	title = "JO - Model Api";
	
	function config()
	{
		provides("html, json");
	}

	function index()
	{
		try {
			var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#SESSION.jo.active_division#' AND type = 'Finished Goods'");
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
				   AND Canceled = 'N' 
				   AND frozenFor = 'N'
			");
			sqlQuery.addParam(name="q", value='%#params.q#%', CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="codes", value=SubGroupCodes, CFSQLTYPE="CF_SQL_INTEGER", list="true");
			var SAPProducts = sqlQuery.execute().getResult();
			var ProductNames = quotedValueList(SAPProducts.id);

			if(listLen(ProductNames) > 0) {
				var filteredProducts = model("product").findAll(select="model_id", where="model_id IN (#quotedValueList(SAPProducts.id)#) AND is_active = 1");
				var filteredIds = ValueList(filteredProducts.model_id);
				var products = [];
				for(var SAPProduct in SAPProducts) {
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

	function show()
	{
		var materials = [];
		var product = model("productname").findOne(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode = '#params.key#'");
		var iposModel = getIposModel(product.ItemCode);
		if(iposModel.status == true && iposModel.data.recordCount) {
			var bomNames = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#quotedValueList(iposModel.data.material_no)#)");
			var alternatives = getAlternatives(iposModel.data);
			if(alternatives.status == true) {
				if(alternatives.data.recordCount) {
					alternativeNames = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#quotedValueList(alternatives.data.material_alt)#)");
				}
				else {
					alternativeNames = [];
				}
				if(listLen(valueList(iposModel.data.material_no)) && listLen(valueList(alternatives.data.material_alt))) {
					var rm_inventory = getRMInventories(listAppend(valueList(iposModel.data.material_no), valueList(alternatives.data.material_alt)));
				}
				else {
					if(listLen(valueList(iposModel.data.material_no))) {
						var rm_inventory = getRMInventories(valueList(iposModel.data.material_no));
					}
					else {
						var rm_inventory = getRMInventories(valueList(alternatives.data.material_alt));
					}
				}

				for(m in iposModel.data) {
					arrayAppend(materials, {
						material_no: m.material_no,
						material_name: getName(bomNames, m.material_no),
						classification: getSubgroupCode(bomNames, m.material_no),
						bom: m.qty,
						yield_rate: m.yield_rate,
						rm_inventory: getRMInventory(rm_inventory, m.material_no),
						wip: 0,
						alternatives: getMaterialAlternatives(alternatives.data, alternativeNames, rm_inventory, m.material_no)
					});
				}
				renderWith({
					model_no: product.Itemcode,
					model_name: product.ItemName,
					classification: product.ItmsGrpcod,
					process_rev: iposModel.data.process_rev,
					bom_rev: iposModel.data.bom_rev,
					materials: materials
				});
			}
			else {

			}
		}
		else {

		}
	}

	function create()
	{
		
	}

	function update()
	{
		var oitm = model("productname").findOne(select="ItemCode,ItemName", where="ItemCode = '#params.jo.model.id#'");
		transaction {
			if(params.delete == true) {
				var delete = model("jomaterial").deleteAll(where="revision_id=#params.key#", transaction=false);
			}
			var jorevision = model("jorevision").findbyKey(params.key);
			var update = jorevision.update(
				designation = params.jo.designation,
				type = serializeJson(params.jo.type),
				jo_reference = params.jo.jo_reference,
				fourm_change = params.jo.fourm_change,
				sixm_change = params.jo.sixm_change,
				sa_no = params.jo.sa_no,
				model_no = params.jo.model.id,
				model_name = oitm.ItemName,
				lot_code = params.jo.lot_code,
				qty_to_produce = params.jo.qty_to_produce,
				total_shipment_qty = params.jo.total_shipment_qty,
				production_month = params.jo.production_month,
				requested_start_date = params.jo.requested_start_date,
				requested_end_date = params.jo.requested_end_date,
				updated_by = SESSION.jo.user_id,
				transaction = false
			);

			if(jorevision.hasErrors()) {
				transaction action="rollback";
				renderWith({
					status: false,
					message: jorevision.allErrors()
				});
			}
			else {
				transaction action="commit";
				renderWith({ status: true });
			}
		}
	}

	function delete()
	{

	}

	function getMaterialGroupings()
	{
		var groupings = model("materialgroupings").findAll(select="id, code, type", where="division = #SESSION.jo.active_division# AND type != 'All'", returnAs="objects");
		renderWith(groupings);
	}

	private function getAlternatives(iposModel)
	{
		var material_nos = valueList(arguments.iposModel.material_no);
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT DISTINCT maFatherItem AS material_primary, maAltItem AS material_alt 
				  FROM tbl_model_alt 
				 WHERE maFatherItem IN (:material_list) 
				   AND maModel = :model_id
				   AND maRevision = :bom_rev 
				 ORDER BY maFatherItem
			");
			sqlQuery.addParam(name="model_id", value=arguments.iposModel.model_id, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="material_list", value=material_nos, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="bom_rev", value=arguments.iposModel.bom_rev, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			return { status: true, data: resultset };
		}
		catch (customExcp e) {
		    return { status: false, message: e };
		}
	}

	private function getIposModel(model_no) 
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.id_record AS model_id, a.mSap AS model_no, b.process_rev, b.bom_rev, b.mbITem AS material_no, SUM(b.mbQuantity) AS qty, AVG(b.mbYield) AS yield_rate 
				  FROM tbl_model a 
				 INNER JOIN ( 
				     SELECT c.mpModel AS model, d.process_rev, c.mpOrder, c.mpProcess, e.bom_rev, e.mbItem, e.mbQuantity, e.mbYield    
				       FROM tbl_model_process c 
				      INNER JOIN ( 
				          SELECT mrModel, MAX(mrRevision) AS process_rev 
				            FROM tbl_model_revision 
				           WHERE mrApproved = 2 
				             AND mrType = 0 
				             AND mrActive = 1 
				           GROUP BY mrModel
						    ) d 
						      ON c.mpRevision = d.process_rev 
						     AND c.mpModel = d.mrModel 
						 INNER JOIN ( 
						    SELECT f.mbModel, f.mbRevision AS bom_rev, f.mbProcess, f.mbItem, f.mbQuantity, f.mbYield  
						      FROM tbl_model_bom f 
						     INNER JOIN ( 
						         SELECT mrModel, MAX(mrRevision) AS bom_rev 
						           FROM tbl_model_revision 
						          WHERE mrApproved = 2 
						            AND mrType = 1 
						            AND mrActive = 1
						          GROUP BY mrModel
							      ) g 
							        ON f.mbModel = g.mrModel 
							       AND f.mbRevision = g.bom_rev 
						     ) e 
						    ON c.mpModel = e.mbModel 
						   AND c.mpProcess = e.mbProcess 
					) b 
				   ON b.model = a.id_record 
				WHERE a.mActive = 1 
				  AND a.mSap = :model
				GROUP BY id_record, model_no, process_rev, bom_rev, material_no 
				ORDER BY a.id_record, b.process_rev, b.mpOrder, b.mbITem  
			");
			sqlQuery.addParam(name="model", value=arguments.model_no, CFSQLTYPE="CF_SQL_VARCHAR");
			var resultset = sqlQuery.execute().getResult();
			return { status: true, data: resultset };
		}
		catch (customExcp e) {
		    return { status: false, message: e };
		}
	}

	private function getName(nameList, name)
	{
		for(var n in arguments.nameList) {
			if(n.ItemCode == arguments.name) {
				return n.ItemName;
			}
		}
		return "";
	}

	private function getSubgroupCode(nameList, name)
	{
		for(var n in arguments.nameList) {
			if(n.ItemCode == arguments.name) {
				return n.ItmsGrpCod;
			}
		}
		return "";
	}

	private function getMaterialAlternatives(alternatives, names, rm_inventory, material)
	{
		var alt = [];
		for(var a in arguments.alternatives) {
			if(a.material_primary == arguments.material) {
				arrayAppend(alt, {
					material_no: a.material_alt,
					material_name: getName(arguments.names, a.material_alt),
					classification: getSubgroupCode(arguments.names, a.material_alt),
					wip: 0,
					rm_inventory: getRMInventory(arguments.rm_inventory, a.material_alt)
				});
			}
		}
		return alt;
	}

	private function getRMInventories(materials)
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT rcv.U_ItemCode material_no, rcv.U_ProductLine material_group, 
				       SUM((COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				       + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				       + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				       + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				       + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)))) qty_balance 
				  FROM dbo.[@FN_ORCV] rcv 
				  LEFT JOIN (
				     SELECT U_BaseRef, 
				            SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
				            SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
				            SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
				            SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
				            SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
				            SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
				            SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
				            SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
				            SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
				            SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
				            SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
				            SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S] 
				       FROM dbo.[@FN_OITF] 
				      WHERE Canceled = 'N'
				      GROUP BY U_BaseRef 
				     ) itf
				         ON itf.U_BaseRef = rcv.Docentry 
				  LEFT JOIN (
				     SELECT U_BaseRef,
				            SUM(CASE WHEN U_Location = 'IQC-G' THEN U_Quantity END) [IQC-G], 
				            SUM(CASE WHEN U_Location = 'PCK-G' THEN U_Quantity END) [PCK-G], 
				            SUM(CASE WHEN U_Location = 'WHS-G' THEN U_Quantity END) [WHS-G], 
				            SUM(CASE WHEN U_Location = 'WHS-Q' THEN U_Quantity END) [WHS-Q], 
				            SUM(CASE WHEN U_Location = 'WHS-R' THEN U_Quantity END) [WHS-R], 
				            SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S] 
				       FROM dbo.[@FN_OISS] 
				      WHERE Canceled = 'N' 
				        AND U_Release = 1 
				      GROUP BY U_BaseRef 
				     ) iss_m
				         ON iss_m.U_BaseRef = rcv.DocEntry 
				 INNER JOIN dbo.OITM itm 
				         ON itm.Itemcode = rcv.U_ItemCode
				 WHERE rcv.Canceled = 'N' 
				   AND rcv.Status = 'O'
				   AND rcv.U_ItemCode IN (:materials) 
				 GROUP BY rcv.U_ItemCode, rcv.U_ProductLine 
				 ORDER BY rcv.U_ProductLine, rcv.U_ItemCode DESC 
			");
			sqlQuery.addParam(name="materials", value=arguments.materials, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			var resultset = sqlQuery.execute().getResult();
			return resultset;
		}
		catch (customExcp e) {
		    return { status: false, message: e };
		}
	}

	private function getRMInventory(materials, material)
	{
		for(var rm in arguments.materials) {
			if(rm.material_no == arguments.material) {
				return rm.qty_balance;
			}
		}
		return 0;
	}
}