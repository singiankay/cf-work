component displayname="MRP RM Inventory" extends="app.controllers.Controller"
{	

	rmTypes = ["Materials","Chemicals","Packaging Materials"];

	function config() {

		provides("html,json");

	}

	function index() {

		var result = [];
		var rmUploads = model("monthlyinventory").findAll(select="id, material_id, location, qty", where="division='#params.division#' AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND is_active = 1");
		var materialIDs = [];
		for(rm in rmUploads) {
			if(arrayfind(materialIDs, rm.material_id) == 0) {
				arrayAppend(materialIDs, rm.material_id);
			}
		}
		var materialNames = getMaterialNames(materialIDs, params.division);

		for(rm in rmUploads) {
			for(name in materialNames) {
				if(rm.material_id == name.ItemCode) {
					arrayAppend(result, {
						id: rm.id,
						material_id: rm.material_id,
						material_name: name.ItemName,
						material_group: name.ItmsGrpCod,
						location: rm.location,
						qty: rm.qty
					});
				}
			}
			
		}

		renderWith(result);
	}

	function show() {

	}

	function create() {

	}

	function update() {

	}

	function delete() {

	}

	function getMaterialtypes() {

		var types = model("materialgroupings").findAll(where="division='#params.division#'");
		var distinctTypes = [];
		for(type in types) {
			if(arrayFind(distinctTypes, type.type) == 0) {
				arrayAppend(distinctTypes, type.type);
			}
		}
		var materialTypes = [];
		for(dt in distinctTypes) {
			var x = [];
			for(t in types) {
				if(dt == t.type) {
					arrayAppend(x, t.code);
				}
			}
			arrayAppend(materialtypes, {
				type: dt,
				code: x
			});
		}
		renderWith(materialTypes);
	}

	function getWip() {
		
		var result = [];
		var wips = model("wip").findAll(where="division ='#params.division#' AND area = '#super.getArea(params.area)#' AND DATE_FORMAT(monthyear, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND is_active = 1", include="wiplines", returnAs="objects");
		var boms = [];
		var materialIDs = [];
		for(wip in wips) {
			for(modelBom in getModelBOMs(wip.model_id, wip.process_rev_no, wip.bom_rev_no, wip.wiplines)) {
				arrayAppend(boms, modelBom); 
			}
		}
		for(bom in boms) {
			if(arrayFind(materialIDs, bom.material_id) == 0) {
				arrayAppend(materialIds, bom.material_id);
			}
		}
		var materialNames = getMaterialNames(materialIDs, params.division);
		var models = getUniqueModels(wips);

		for(name in materialNames) {
			var qty = 0;

			for(m in models) {
				var matCounter = [];
				for(bom in boms) {
					if(bom.model_no == m) {
						if(bom.material_id == name.ItemCode) {
							arrayAppend(matCounter, {
								model_no: bom.model_no,
								process_order: bom.process_order,
								mat_qty: bom.qty,
								current_process: 0
							});
						}
					}
				}
				for(bom2 in boms) {
					if(bom2.model_no == m) {
						for (i=1; i <= ArrayLen(matCounter); i++) {
							if(matCounter[i].model_no == bom2.model_no && matCounter[i].process_order <= bom2.process_order && matCounter[i].current_process < bom2.process_order) {
								matCounter[i].current_process = bom2.process_order;
							}
						}

						for(wip in wips) {
							if(wip.model_id == m) {
								for(wipline in wip.wiplines) {
									if(wipline.process_id == bom2.process) {
										if(wipline.qty > 0) {
											for (i=1; i <= ArrayLen(matCounter); i++) {
												if(matCounter[i].model_no == bom2.model_no && matCounter[i].process_order <= bom2.process_order && matCounter[i].current_process <= bom2.process_order) {
													qty += (matCounter[i].mat_qty * wipline.qty);
													matCounter[i].current_process++;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			arrayAppend(result, {
				material_no: name.ItemCode,
				material_name: name.ItemName,
				material_group: name.ItmsGrpCod,
				qty: qty
			});
		}
		renderWith(result);

	}

	function getModelBOMs(model_id, process_rev, bom_rev, wiplines) {
		var processArray = [];
		for(line in arguments.wiplines) {
			arrayAppend(processArray,line.process_id);
		}

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.id_record AS model_id, a.mSap AS model_no, b.process_rev AS process_rev, b.mpOrder AS process_order, b.mpProcess AS process, b.bom_rev, b.mbItem AS material_id, b.mbQuantity AS qty 
				  FROM tbl_model a 
				  LEFT JOIN ( 
				  	  SELECT c.mpModel AS model, c.mpRevision AS process_rev, c.mpOrder, c.mpProcess, d.bom_rev, d.mbItem, d.mbQuantity 
				  	    FROM tbl_model_process c 
				  	    LEFT JOIN ( 
				  	    	 SELECT e.mbModel, e.mbRevision AS bom_rev, e.mbProcess, e.mbItem, e.mbQuantity 
				  	    	   FROM tbl_model_bom e 
				  	    	  WHERE e.mbRevision = :bom_rev 
				  	     ) d 
				  	       ON c.mpModel = d.mbModel 
				  	      AND c.mpProcess = d.mbProcess 
				  	WHERE c.mpRevision = :process_rev 
				  	  AND c.mpPRocess IN (:process_list)
				  	) b 
				    ON b.model = a.id_record 
				 WHERE a.mActive = 1
				   AND a.mSap = :model 
				 ORDER BY a.id_record, b.process_rev, b.mpOrder 
			");
			sqlQuery.addParam(name="model", value=arguments.model_id, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="process_rev", value=arguments.process_rev, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="bom_rev", value=arguments.bom_rev, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="process_list", value=ArrayToList(processArray), CFSQLTYPE="CF_SQL_INTEGER", list=true);
			var resultset = sqlQuery.execute().getResult();
			return resultset;
		}
		catch (customExcp e) {
		    return { status:'error', message: e };
		}
	}

	function getUniqueModels(models) {

		var arr = [];
		for(m in arguments.models) {
			if(arrayFind(arr, m.model_id) == 0) {
					arrayAppend(arr, m.model_id);
			}
		}
		return arr;

	}

	function getMaterialNames(materialIDs, division) {

		var mg = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type IN ('Materials', 'Chemicals', 'Packaging Materials')");
		var materialgroups = valueList(mg.code);
		var materialList = ListQualify(ArrayToList(arguments.materialIDs),"'");
		if(listLen(materialList)) {
			var materials = model("productname").findAll(select="ItemCode, ItemName, ItmsGrpCod", where="ItemCode IN (#materialList#) AND ItmsGrpCod IN (#materialGroups#)");
			return materials;
		}
		else {
			return [];
		}
		
	}

	function getRMStocks() {

		var materialTypes = ListQualify(ArrayToList(rmTypes), "'");
		var SubGroup = model("materialgroupings").findAll(select="code", where="division = '#params.division#' AND type IN (#materialTypes#)");
		var SubGroupCodes = valueList(Subgroup.code);
		
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			// sqlQuery.setSQL("
			// 	SELECT po.DocEntry AS po_no, po_line.LineNum AS po_line_no, po_line.ItemCode AS material_no, mat.ItemName AS material_name, po_line.Quantity AS po_qty, grpo.Quantity AS grpo_qty, grpo.ShipDate AS grpo_shipdate
			// 	  FROM OPOR po 
			// 	 INNER JOIN POR1 po_line 
			// 	         ON po.DocEntry = po_line.DocEntry 
			// 	  LEFT JOIN pdn1 grpo 
			// 	         ON grpo.BaseEntry = po_line.DocEntry 
			// 	        AND grpo.BaseLine= po_line.LineNum 
			// 	        AND grpo.BaseType= po.ObjType 
			// 	 INNER JOIN OITM mat 
			// 	         ON mat.ItemCode = po_line.ItemCode 
			// 	        AND mat.ItmsGrpCod IN (:subgroupcodes)
			// 	 WHERE po.DocType = 'I'  
			// 	   AND po.Canceled = 'N' 
			// 		AND po.DocStatus = 'O' 
			// 		AND po_line.ShipDate >= :minPOYear 
			// 		AND po_line.ShipDate <= DATEADD(dd, -1, DATEADD(mm, DATEDIFF(mm, 0, :monthyear) + 1, 0)) 
			// 		AND po_line.BaseType = -1 
			// 		AND grpo.Basetype = 22
			// 		AND (grpo.TargetType = -1 OR grpo.TargetType = 18)
			// 	 ORDER BY po.DocNum, po_line.LineNum, po_line.ItemCode ASC
			// ");
			//  AND po_line.LineStatus = 'O' 
			 // AND (grpo.TargetType = -1 OR grpo.TargetType = 18)

			sqlQuery.setSQL("
				SELECT po.DocEntry AS po_no, po_line.LineNum AS po_line_no, po.U_NPIRefNo AS po_ref, po_line.ItemCode AS material_no, mat.ItemName AS material_name, mat.ItmsGrpCod AS material_group, po_line.OpenQty AS po_qty, (po_line.Quantity - po_line.OpenQty) AS grpo_qty, po_line.ShipDate AS grpo_shipdate 
				  FROM OPOR po 
				 INNER JOIN POR1 po_line 
				         ON po.DocEntry = po_line.DocEntry
				 INNER JOIN OITM mat
				         ON mat.ItemCode = po_line.ItemCode 
				        AND mat.ItmsGrpCod IN (:subgroupcodes)
				 WHERE po.DocType = 'I'  
				   AND po.Canceled = 'N' 
					AND ((
						     po.DocStatus = 'O' AND po_line.ShipDate >= :minPOYear AND po_line.ShipDate <= DATEADD(dd, -1, DATEADD(mm, DATEDIFF(mm, 0, :monthyear) + 1, 0))) 
						  OR (
						  	  po.DocStatus = 'C' AND po_line.ShipDate >= DATEADD(mm,DATEDIFF(mm,0, :monthyear),0) AND po_line.Shipdate <= DATEADD(dd, -3, DATEADD(mm, 0, DATEADD(mm, DATEDIFF(mm, 0, :monthyear)+1,0)))
						 ))
					AND po_line.BaseType = -1 
				 ORDER BY po.DocNum, po_line.LineNum, po_line.ItemCode ASC 

			");
			// sqlQuery.setSQL("
			// 	SELECT po.DocEntry AS po_no, po_line.LineNum AS po_line_no, po_line.ItemCode AS material_no, mat.ItemName AS material_name, po_line.Quantity AS po_qty, (po_line.Quantity - po_line.OpenQty) AS grpo_qty, po_line.ShipDate AS grpo_shipdate 
			// 	  FROM OPOR po 
			// 	 INNER JOIN POR1 po_line 
			// 	         ON po.DocEntry = po_line.DocEntry
			// 	 INNER JOIN OITM mat
			// 	         ON mat.ItemCode = po_line.ItemCode 
			// 	        AND mat.ItmsGrpCod IN (:subgroupcodes)
			// 	 WHERE po.DocType = 'I'  
			// 	   AND po.Canceled = 'N' 
			// 		AND po.DocStatus = 'O' 
			// 		AND po_line.ShipDate >= :minPOYear 
			// 		AND po_line.ShipDate <= DATEADD(dd, -1, DATEADD(mm, DATEDIFF(mm, 0, :monthyear) + 1, 0)) 
			// 		AND po_line.BaseType = -1 
			// 	 ORDER BY po.DocNum, po_line.LineNum, po_line.ItemCode ASC 

			// ");

			sqlQuery.addParam(name="subgroupcodes", value=SubGroupCodes, CFSQLTYPE="CF_SQL_INTEGER",list="true");
			sqlQuery.addParam(name="monthyear", value=DateFormat(params.monthyear, 'yyyy-mm-dd'), CFSQLTYPE="CF_SQL_DATE");
			sqlQuery.addParam(name="minPOYear", value=DateFormat('2017-07-01', 'yyyy-mm-dd'), CFSQLTYPE="CF_SQL_DATE");
			var resultset = sqlQuery.execute().getResult();
			renderWith(resultset);
		}
		catch (customExcp e) {
		    renderWith(e);
		}

	}
}