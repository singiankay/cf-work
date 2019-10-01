component displayname="MRP RM Stock" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

		var treeModels = [];
		var salesOrderLines = model("salesorderline").findAll(where="tbl_erpx_sales_orders.division = '#params.division#' AND tbl_erpx_sales_order_lines.area = '#super.getArea(params.area)#' AND 
			DATE_FORMAT(tbl_erpx_sales_order_lines.production_date, '%Y-%M') = DATE_FORMAT('#DateFormat(params.monthyear, 'yyyy-mm-dd')#', '%Y-%M') AND tbl_erpx_sales_orders.is_active = 1 AND tbl_erpx_sales_order_lines.is_active = 1 AND tbl_erpx_sales_orders.document_status = 'Posted'", order="tbl_erpx_sales_order_lines.model_id, tbl_erpx_sales_order_lines.production_date ASC", include="salesorder");
		if(salesOrderLines.recordcount) {
			var modelIds = ListRemoveDuplicates(valueList(salesOrderLines.model_id));
			var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelIds#)");
			var soLineIDs = valueList(salesOrderLines.id);
			
			if(ListLen(soLineIDs)) {
				var rmStocks = model("rmstock").findAll(where="so_line_id IN (#soLineIDs#) AND is_active = 1", include="rmstocklines", returnAs="objects");
			}
			else {
				var rmStocks = [];
			}
			var iposModelsMax = getiPosModelsMax(modelIds);

			var result = [];

			for(soLine in salesOrderLines) {
				soLineModel = getSOModel(soLine.id);
				
				if(isRMStock(rmstocks, soLine.id)) {
					rmStock = getRMStock(rmstocks, soLine.id);
					var treeModel = {};
					var customiPosModel = getiPosModel(soLineModel.model_id, rmStock.process_rev, rmStock.bom_rev);

					for(iposModel in customiPosModel.rows) {
						if(iposModel.mSap == soLineModel.model_id) {
							structAppend(treeModel, {
								so_line_id: soLine.id,
								so_id: soLine.so_id,
								record_id: rmStock.id,
								model_no: soLineModel.model_id,
								model_name: getModelName(modelNames, soLineModel.model_id),
								process_rev: iposModel.process_rev,
								bom_rev: iposModel.bom_rev,
								process: []
							});
							break;
						}
					}

					var processes = [];
					for(iposModel in customiPosModel.rows) {
						if(iposModel.mSap == soLineModel.model_id) {
							if(processes.find(iposModel.mpProcess) == 0) {
								processes.append(iposModel.mpProcess);
								arrayAppend(treeModel.process, {
									process: iposModel.mpProcess,
									code: iposModel.process_code,
									name: getProcessName(iposModel.process_code),
									order: iposModel.mpOrder,
									bom: []
								});
							}
						}
					}
					

					for(iProcess = 1; iProcess <= ArrayLen(treeModel.process); iProcess++) {
						var boms = [];
						for(iposModel in customiPosModel.rows) {
							if(iposModel.mSap == soLineModel.model_id && iposModel.mpProcess == treeModel.process[iProcess].process) {
								if(boms.find(iposModel.mbItem) == 0 && Len(trim(iposModel.mbITem)) > 0) {
									boms.append(iposModel.mbItem);
									arrayAppend(treeModel.process[iProcess].bom, {
										item: iposModel.mbItem,
										name: getMaterialInfo(iposModel.mbItem,"name"),
										group: getMaterialInfo(iposModel.mbItem,"group"),
										quantity: iposModel.mbQuantity,
										yield: iposModel.mbYield,
										stock: getBOMStock(rmStock, iposModel.mpProcess, iposModel.mbItem),
										record_id: getBOMID(rmStock, iposModel.mpProcess, iposModel.mbItem),
										alternative: []
									});
								}
							}
						}
					}

					for(iProcess = 1; iProcess <= ArrayLen(treeModel.process); iProcess++) {
						var alts = [];
						for(iposModel in customiPosModel.rows) {
							if(iposModel.mSap == soLineModel.model_id && iposModel.mpProcess == treeModel.process[iProcess].process) {
								for(iBom = 1; iBom <= ArrayLen(treeModel.process[iProcess].bom); iBom++) {
									for(iposModel2 in customiPosModel.rows) {
										if(iposModel2.mSap == soLineModel.model_id && iposModel2.mpProcess == treeModel.process[iProcess].process && iposModel2.mbItem == treeModel.process[iProcess].bom[iBom].item) {
											if(alts.find(iposModel2.maAltItem) == 0 && Len(trim(iposModel2.maAltItem)) > 0) {
												alts.append(iposModel2.maAltItem);
												arrayAppend(treeModel.process[iProcess].bom[iBom].alternative, {
													item: iposModel2.maAltItem,
													name: getMaterialInfo(iposModel2.maAltItem,"name"),
													group: getMaterialInfo(iposModel2.maAltItem,"group"),
													stock: getAlterNativeStock(rmStock, iposModel2.mpProcess, iposModel2.mbItem, iposModel2.maAltItem),
													record_id: getAlternativeID(rmStock, iposModel2.mpProcess, iposModel2.mbItem, iposModel2.maAltItem)
												});
											}
										}
									}
									
								}
							}
						}
					}
					arrayAppend(treeModels, treeModel);

				}
				else {
					var treeModel = {};
					for(iposModel in iposModelsMax.rows) {
						if(iposModel.mSap == soLineModel.model_id) {
							structAppend(treeModel, {
								so_line_id: soLine.id,
								so_id: soLine.so_id,
								record_id: false,
								model_no: soLineModel.model_id,
								model_name: getModelName(modelNames, soLineModel.model_id),
								process_rev: iposModel.process_rev,
								bom_rev: iposModel.bom_rev,
								process: []
							});
							break;
						}
					}
					
					var processes = [];
					for(iposModel in iposModelsMax.rows) {
						if(iposModel.mSap == soLineModel.model_id) {
							if(processes.find(iposModel.mpProcess) == 0) {
								processes.append(iposModel.mpProcess);
								arrayAppend(treeModel.process, {
									process: iposModel.mpProcess,
									code: iposModel.process_code,
									name: getProcessName(iposModel.process_code),
									order: iposModel.mpOrder,
									bom: []
								});
							}
						}
					}

					for(iProcess = 1; iProcess <= ArrayLen(treeModel.process); iProcess++) {
						var boms = [];
						for(iposModel in iposModelsMax.rows) {
							if(iposModel.mSap == soLineModel.model_id && iposModel.mpProcess == treeModel.process[iProcess].process) {
								if(boms.find(iposModel.mbItem) == 0 && Len(trim(iposModel.mbITem)) > 0) {
									boms.append(iposModel.mbItem);
									arrayAppend(treeModel.process[iProcess].bom, {
										item: iposModel.mbItem,
										name: getMaterialInfo(iposModel.mbItem,"name"),
										group: getMaterialInfo(iposModel.mbItem,"group"),
										quantity: iposModel.mbQuantity,
										yield: iposModel.mbYield,
										stock: 0,
										record_id: false,
										alternative: []
									});
								}
							}
						}
					}

					for(iProcess = 1; iProcess <= ArrayLen(treeModel.process); iProcess++) {
						var alts = [];
						for(iposModel in iposModelsMax.rows) {
							if(iposModel.mSap == soLineModel.model_id && iposModel.mpProcess == treeModel.process[iProcess].process) {
								for(iBom = 1; iBom <= ArrayLen(treeModel.process[iProcess].bom); iBom++) {
									for(iposModel2 in iposModelsMax.rows) {
										if(iposModel2.mSap == soLineModel.model_id && iposModel2.mpProcess == treeModel.process[iProcess].process && iposModel2.mbItem == treeModel.process[iProcess].bom[iBom].item) {
											if(alts.find(iposModel2.maAltItem) == 0 && Len(Trim(iposModel2.maAltItem)) > 0) {
												alts.append(iposModel2.maAltItem);
												arrayAppend(treeModel.process[iProcess].bom[iBom].alternative, {
													item: iposModel2.maAltItem,
													name: getMaterialInfo(iposModel2.maAltItem,"name"),
													group: getMaterialInfo(iposModel2.maAltItem,"group"),
													stock: 0,
													record_id: false
												});
											}
										}
									}
								}
							}
						}
					}
					arrayAppend(treeModels, treeModel);
					
				}
			}
			renderWith({status: 'success', rows: treeModels});
		}
		else {
			renderWith({status: 'success', rows: [] });
		}
	}

	function show() {

	}

	function getProjectedShipmentBoms() {

		var treeModels = [];
		var salesOrderLines = model("salesorderline").findAll(where="tbl_erpx_sales_orders.division = '#params.division#' AND tbl_erpx_sales_order_lines.area = '#super.getArea(params.area)#' AND tbl_erpx_sales_order_lines.production_date > date_add(date_add(LAST_DAY('#DateFormat(params.monthyear, 'yyyy-mm-dd')#'),interval 1 DAY),interval -1 MONTH) AND tbl_erpx_sales_order_lines.production_date < date_add(LAST_DAY('#DateFormat(params.monthyear, 'yyyy-mm-dd')#'), interval 4 MONTH) AND tbl_erpx_sales_orders.is_active = 1 AND tbl_erpx_sales_order_lines.is_active = 1 AND tbl_erpx_sales_orders.document_status = 'Posted'", order="tbl_erpx_sales_order_lines.model_id, tbl_erpx_sales_order_lines.production_date ASC", include="salesorder", group="model_id");
		if(salesOrderLines.recordcount) {
			var modelIds = ListRemoveDuplicates(valueList(salesOrderLines.model_id));
			var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelIds#)");
			var iposModelsMax = getiPosModelsMax(modelIds);
			var result = [];
			for(soLine in salesOrderLines) {
				soLineModel = getSOModel(soLine.id);
				
				var treeModel = {};
				for(iposModel in iposModelsMax.rows) {
					if(iposModel.mSap == soLineModel.model_id) {
						structAppend(treeModel, {
							so_line_id: soLine.id,
							so_id: soLine.so_id,
							record_id: false,
							model_no: soLineModel.model_id,
							model_name: getModelName(modelNames, soLineModel.model_id),
							process_rev: iposModel.process_rev,
							bom_rev: iposModel.bom_rev,
							process: []
						});
						break;
					}
				}
				
				var processes = [];
				for(iposModel in iposModelsMax.rows) {
					if(iposModel.mSap == soLineModel.model_id) {
						if(processes.find(iposModel.mpProcess) == 0) {
							processes.append(iposModel.mpProcess);
							arrayAppend(treeModel.process, {
								process: iposModel.mpProcess,
								code: iposModel.process_code,
								name: getProcessName(iposModel.process_code),
								order: iposModel.mpOrder,
								bom: []
							});
						}
					}
				}

				for(iProcess = 1; iProcess <= ArrayLen(treeModel.process); iProcess++) {
					var boms = [];
					for(iposModel in iposModelsMax.rows) {
						if(iposModel.mSap == soLineModel.model_id && iposModel.mpProcess == treeModel.process[iProcess].process) {
							if(boms.find(iposModel.mbItem) == 0 && Len(trim(iposModel.mbITem)) > 0) {
								boms.append(iposModel.mbItem);
								arrayAppend(treeModel.process[iProcess].bom, {
									item: iposModel.mbItem,
									name: getMaterialInfo(iposModel.mbItem,"name"),
									group: getMaterialInfo(iposModel.mbItem,"group"),
									quantity: iposModel.mbQuantity,
									yield: iposModel.mbYield,
									stock: 0,
									record_id: false,
									alternative: []
								});
							}
						}
					}
				}

				for(iProcess = 1; iProcess <= ArrayLen(treeModel.process); iProcess++) {
					var alts = [];
					for(iposModel in iposModelsMax.rows) {
						if(iposModel.mSap == soLineModel.model_id && iposModel.mpProcess == treeModel.process[iProcess].process) {
							for(iBom = 1; iBom <= ArrayLen(treeModel.process[iProcess].bom); iBom++) {
								for(iposModel2 in iposModelsMax.rows) {
									if(iposModel2.mSap == soLineModel.model_id && iposModel2.mpProcess == treeModel.process[iProcess].process && iposModel2.mbItem == treeModel.process[iProcess].bom[iBom].item) {
										if(alts.find(iposModel2.maAltItem) == 0 && Len(Trim(iposModel2.maAltItem)) > 0) {
											alts.append(iposModel2.maAltItem);
											arrayAppend(treeModel.process[iProcess].bom[iBom].alternative, {
												item: iposModel2.maAltItem,
												name: getMaterialInfo(iposModel2.maAltItem,"name"),
												group: getMaterialInfo(iposModel2.maAltItem,"group"),
												stock: 0,
												record_id: false
											});
										}
									}
								}
							}
						}
					}
				}
				arrayAppend(treeModels, treeModel);
			}
			renderWith({status: 'success', rows: treeModels});
		}
		else {
			renderWith({status: 'success', rows: [] });
		}

	}

	function create() {
		var errors = 0;
		var errorList = [];
		transaction {
			try {
				for(fgModel in params.record) {

					if(fgModel.record_id != false) {
						for(process in fgModel.process) {
							for(bom in process.bom) {
								if(bom.record_id != false) {
									var rmStockLine = model("rmstockline").findByKey(bom.record_id);
									var update = rmStockLine.update(qty=(isNumeric(bom.stock) ? bom.stock : 0), transaction=false);
									if(update != true) {
										errors++;
										arrayAppend(errorList, rmStockLine.allErrors());
									}
								}
								else {
									if(bom.stock != 0) {
										var create = model("rmstockline").new();
										create.rm_stock_id = fgModel.record_id;
										create.is_active = 1;
										create.process_id = process.process;
										create.is_alternative = 0;
										create.bom_id = bom.item;
										create.qty = (isNumeric(bom.stock) ? bom.stock : 0);
										create.save(transaction=false);
										if(create.hasErrors()) {
											errors++;
											arrayAppend(errorList, create.allErrors());
										}
									}
								}
								for(alternative in bom.alternative) {
									if(alternative.record_id != false) {
										var rmStockLine = model("rmstockline").findByKey(alternative.record_id);
										var update = rmStockLine.update(qty=(isNumeric(alternative.stock) ? alternative.stock : 0), transaction=false);

										if(update != true) {
											errors++;
											arrayAppend(errorList, rmStockLine.allErrors());
										}
									}
									else {
										if(alternative.stock != 0) {
											var create = model("rmstockline").new();
											create.rm_stock_id = fgModel.record_id;
											create.is_active = 1;
											create.process_id = process.process;
											create.is_alternative = 1;
											create.bom_id = bom.item;
											create.alternative_id = alternative.item;
											create.qty = (isNumeric(alternative.stock) ? alternative.stock : 0);
											create.save(transaction=false);
											if(create.hasErrors()) {
												errors++;
												arrayAppend(errorList, create.allErrors());
											}
										}
									}
								}
							}
						}
					}
					else {
						var createStock = model("rmstock").new();
						createStock.so_line_id = fgModel.so_line_id;
						createStock.bom_rev = fgModel.bom_rev;
						createStock.process_rev = fgModel.process_rev;
						createStock.is_active = 1;
						createStock.save(transaction=false);
						if(createStock.hasErrors()) {
							errors++;
							arrayAppend(errorList, createStock.allErrors());
						}
						else {
							for(process in fgModel.process) {
								for(bom in process.bom) {
									if(bom.stock != 0) {
										var create = model("rmstockline").new();
										create.rm_stock_id = createStock.id;
										create.is_active = 1;
										create.process_id = process.process;
										create.is_alternative = 0;
										create.bom_id = bom.item;
										create.qty = (isNumeric(bom.stock) ? bom.stock : 0);
										create.save(transaction=false);
										if(create.hasErrors()) {
											errors++;
											arrayAppend(errorList, create.allErrors());
										}
									}
									
									for(alternative in bom.alternative) {
										if(alternative.stock != 0) {
											var create = model("rmstockline").new();
											create.rm_stock_id = createStock.id;
											create.is_active = 1;
											create.process_id = process.process;
											create.is_alternative = 1;
											create.bom_id = bom.item;
											create.alternative_id = alternative.item;
											create.qty = (isNumeric(alternative.stock) ? alternative.stock : 0);
											create.save(transaction=false);
											if(create.hasErrors()) {
												errors++;
												arrayAppend(errorList, create.allErrors());
											}
										}
									}
								}
							}
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
			    return { status:'error', message: e };
			}
		}
		
	}

	function update() {

	}

	function delete() {

	}

	function isRMStock(rmstocks, id) {

		for(stock in arguments.rmstocks) {
			if(stock.so_line_id == arguments.id) {
				return true;
			}
		}

		return false;

	}

	function getRMStock(rmstocks, id) {

		for(stock in arguments.rmstocks) {
			if(stock.so_line_id == arguments.id) {
				return stock;
			}
		}

	}

	function getBOMStock(rm, process, item) {
		for(lines in arguments.rm.rmstocklines) {
			if(lines.process_id == arguments.process && lines.bom_id == arguments.item && lines.is_alternative == 0) {
				return lines.qty;
			}
		}
		return 0;
	}

	function getBOMID(rm, process, item) {
		for(lines in arguments.rm.rmstocklines) {
			if(lines.process_id == arguments.process && lines.bom_id == arguments.item && lines.is_alternative == 0) {
				return lines.id;
			}
		}
		return false;
	}

	function getAlternativeStock(rm, process, item, altItem) {
		for(lines in arguments.rm.rmstocklines) {
			if(lines.process_id == arguments.process && lines.bom_id == arguments.item && lines.is_alternative == 1 && lines.alternative_id == arguments.altItem ) {
				return lines.qty;
			}
		}
		return 0;
	}

	function getAlternativeID(rm, process, item, altItem) {
		for(lines in arguments.rm.rmstocklines) {
			if(lines.process_id == arguments.process && lines.bom_id == arguments.item && lines.is_alternative == 1 && lines.alternative_id == arguments.altItem ) {
				return lines.id;
			}
		}
		return false;
	}

	function getSOModel(so_line_id) {

		var so_line = model("salesorderline").findByKey(arguments.so_line_id);
		return so_line;

	}

	function getiPosModelsMax(models) {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.id_record, a.mSap, 
				       b.process_rev, b.mpOrder, b.mpProcess, i.pSap AS process_code, b.bom_rev, b.mbITem, b.mbQuantity, b.mbYield,  b.maFatherItem, b.maAltItem 
				  FROM tbl_model a 
				  LEFT JOIN ( 
				     SELECT c.mpModel AS model, d.process_rev, c.mpOrder, c.mpProcess, e.bom_rev, e.mbItem, e.mbQuantity, e.mbYield, e.maFatherItem, e.maAltItem   
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
						 LEFT JOIN ( 
						    SELECT f.mbModel, f.mbRevision AS bom_rev, f.mbProcess, f.mbItem, f.mbQuantity, f.mbYield, h.maFatherItem, h.maAltItem 
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
							   LEFT JOIN ( 
							      SELECT maModel, maProcess, maRevision, maFatherItem, maAltItem
							        FROM tbl_model_alt
									) h 
									  ON f.mbModel = h.maModel 
									 AND f.mbProcess = h.maProcess 
									 AND f.mbItem = h.maFatherItem 
									 AND f.mbRevision = h.maRevision
						  ) e 
						    ON c.mpModel = e.mbModel 
						   AND c.mpProcess = e.mbProcess 
					) b 
				   ON b.model = a.id_record 
				INNER JOIN tbl_process i 
				   ON b.mpProcess = i.id_record 
				WHERE a.mActive = 1 
				  AND a.mSap IN (:models) 
				ORDER BY a.id_record, b.process_rev, b.mpOrder, b.mpProcess 
			");
			sqlQuery.addParam(name="models", value=arguments.models, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			var resultset = sqlQuery.execute().getResult();
			return { status: 'success', rows: resultset };
		}
		catch (customExcp e) {
		    return { status:'error', message: e };
		}

	}

	function getiPosModel(model, process_rev, bom_rev) {

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(iposx);
			sqlQuery.setSQL("
				SELECT a.id_record, a.mSap, 
				       b.process_rev, b.mpOrder, b.mpProcess, g.pSap AS process_code, b.bom_rev, b.mbITem, b.mbQuantity, b.mbYield, b.maFatherItem, b.maAltItem 
				  FROM tbl_model a 
				  LEFT JOIN ( 
				  	  SELECT c.mpModel AS model, c.mpRevision AS process_rev, c.mpOrder, c.mpProcess, d.bom_rev, d.mbItem, d.mbQuantity, d.mbYield, d.maFatherItem, d.maAltItem 
				  	    FROM tbl_model_process c 
				  	    LEFT JOIN ( 
				  	    	 SELECT e.mbModel, e.mbRevision AS bom_rev, e.mbProcess, e.mbItem, e.mbQuantity, e.mbYield, f.maFatherItem, f.maAltItem 
				  	    	   FROM tbl_model_bom e 
				  	    	   LEFT JOIN ( 
				  	    	   	SELECT maModel, maProcess, maRevision, maFatherItem, maAltItem 
				  	    	   	  FROM tbl_model_alt
				  	    	   	) f 
				  	    	        ON e.mbModel = f.maModel 
				  	    	       AND e.mbProcess = f.maProcess
				  	    	       AND e.mbItem = f.maFatherItem 
				  	    	       AND e.mbRevision = f.maRevision 
				  	    	  WHERE e.mbRevision = :bom_rev 
				  	     ) d 
				  	       ON c.mpModel = d.mbModel 
				  	      AND c.mpProcess = d.mbProcess 
				  	WHERE c.mpRevision = :process_rev 
				  	) b 
				    ON b.model = a.id_record 
				 INNER JOIN tbl_process g 
				    ON b.mpProcess = g.id_record 
				 WHERE a.mActive = 1
				   AND a.mSap = :model 
				 ORDER BY a.id_record, b.process_rev, b.mpOrder, b.mpProcess
			");
			sqlQuery.addParam(name="model", value=arguments.model, CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="process_rev", value=arguments.process_rev, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="bom_rev", value=arguments.bom_rev, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
			return { status: 'success', rows: resultset };
		}
		catch (customExcp e) {
		    return { status:'error', message: e };
		}

	}

	function getModelName(names, id) {

		for(name in arguments.names) {
			if(arguments.id == name.ItemCode) {
				return name.ItemName;
			}
		}

	}

	function getProcessName(code) {
		var process = model("productprocessname").findOne(where="Code = '#arguments.code#'");
		return process.U_ProcessName;
	}

	function getMaterialInfo(item,request) {
		if(Len(trim(arguments.item))) {
			var mat = model("productname").findOne(select="ItemCode, ItemName, ItmsGrpCod",where="ItemCode = '#arguments.item#'");
			if(isObject(mat)) {
				if(arguments.request == "name") {
					return mat.ItemName;
				}
				else if(arguments.request == "group") {
					return mat.ItmsGrpCod;
				}
				
			}
		}
		
	}

}