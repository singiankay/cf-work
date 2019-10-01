component displayname="JO Revision" extends="app.controllers.Controller"
{
	title = "JO - Revision";

	function config()
	{
		filters("restrictAccess");
		usesLayout(template='layout');
		provides("html, json");
		usesLayout(template="/jo/layout");
	}

	function index()
	{
		var jorevision = model("jorevision").findAll(select="id, jo_id, revision_no", where="jo_id = #params.encodeKey# AND is_active = 1", order="revision_no DESC", returnAs="objects");
		renderWith(jorevision);
	}

	function show()
	{
		controllerJS = "jo/revision/show";
		jo = model("jo").findByKey(params.encodeKey);
		pp_approver_raw = model("user").findAll(select="fk_user_id", where="is_active = 1 AND role = 'PP Approver' AND division = #SESSION.jo.active_division#");
		pp_deputy_raw = model("user").findAll(select="fk_user_id", where="is_active = 1 AND role = 'PP Deputy' AND division = #SESSION.jo.active_division#");
		pu_approver_raw = model("user").findAll(select="fk_user_id", where="is_active = 1 AND role = 'PU Approver' AND division = #SESSION.jo.active_division#");
		pu_deputy_raw = model("user").findAll(select="fk_user_id", where="is_active = 1 AND role = 'PU Deputy' AND division = #SESSION.jo.active_division#");
		pp_approver = [];
		pp_deputy = [];
		pu_approver = [];
		pu_deputy = [];
		var user_ids = [];

		for(var a in pp_approver_raw) {
			if(arrayFind(user_ids, a.fk_user_id) == 0) {
				user_ids.append(a.fk_user_id);
			}
		}
		for(var d in pp_deputy_raw) {
			if(arrayFind(user_ids, d.fk_user_id) == 0) {
				user_ids.append(d.fk_user_id);
			}
		}
		for(var a in pu_approver_raw) {
			if(arrayFind(user_ids, a.fk_user_id) == 0) {
				user_ids.append(a.fk_user_id);
			}
		}
		for(var d in pu_deputy_raw) {
			if(arrayFind(user_ids, d.fk_user_id) == 0) {
				user_ids.append(d.fk_user_id);
			}
		}

		if(arrayLen(user_ids) > 0) {
			user_names = model("hrisemployee").findAll(select="id, fullname", where="id IN (#arrayToList(user_ids)#)");
			for(var ppa in pp_approver_raw) {
				pp_approver.append({
					id: ppa.fk_user_id,
					name: getFullName(user_names, ppa.fk_user_id)
				});
			}
			for(var ppd in pp_deputy_raw) {
				pp_deputy.append({
					id: ppd.fk_user_id,
					name: getFullName(user_names, ppd.fk_user_id)
				});
			}
			for(var pua in pu_approver_raw) {
				pu_approver.append({
					id: pua.fk_user_id,
					name: getFullName(user_names, pua.fk_user_id)
				});
			}
			for(var pud in pu_deputy_raw) {
				pu_deputy.append({
					id: pud.fk_user_id,
					name: getFullName(user_names, pud.fk_user_id)
				});
			}
		}
	}

	function new()
	{
		controllerJS = "jo/revision/new";
		
		if(!structKeyExists(params, "new")) {

			try {
				var sqlQuery = new Query();
				sqlQuery.setDatasource(erpdb_fg);
				sqlQuery.setSQL("
					SELECT a.id, a.revision_no, a.jo_id 
					  FROM tbl_erpx_jo_revision a
					  LEFT JOIN tbl_erpx_jo_revision b
					         ON b.jo_id = a.jo_id 
							  AND a.revision_no < b.revision_no
					 WHERE b.id IS NULL
					   AND a.jo_id = :jo_id
					   AND a.is_active = 1
				");
				sqlQuery.addParam(name="jo_id", value=params.encodeKey, CFSQLTYPE="CF_SQL_INTEGER");
				var result = sqlQuery.execute().getResult();
				params.key = result.id;
			}
			catch (customExcp e) {
				flashInsert(e.message);
			}
		}
	}

	function edit()
	{
		controllerJS = "jo/revision/edit";
	}

	function create()
	{
		var errorCounter = 0;
		var errorMessage = [];
		var itm = model("productname").findOne(select="ItemCode, ItemName, U_ProductionLine", where="ItemCode = '#params.revision.model.id#'");

		if(SESSION.jo.active_division == 1) {
			var notified = model("user").findAll(select="fk_user_id", where="FIND_IN_SET(#getArea(itm.U_ProductionLine)#, area) AND role = 'Notified' AND access_type = 'JO' AND division = #SESSION.jo.active_division# AND is_active = 1");
		}
		else {
			var notified = model("user").findAll(select="fk_user_id", where="role = 'Notified' AND access_type = 'JO' AND division = #SESSION.jo.active_division# AND is_active = 1");
		}

		var user_ids = [];

		if(params.pp_approver > 0) {
			if(arrayFind(user_ids, params.pp_approver) == 0) {
				user_ids.append(params.pp_approver);
			}
		}

		if(params.pp_deputy > 0) {
			if(arrayFind(user_ids, params.pp_deputy) == 0) {
				user_ids.append(params.pp_deputy);
			}
		}

		if(params.pu_approver > 0) {
			if(arrayFind(user_ids, params.pu_approver) == 0) {
				user_ids.append(params.pu_approver);
			}
		}

		if(params.pu_deputy > 0) {
			if(arrayFind(user_ids, params.pu_deputy) == 0) {
				user_ids.append(params.pu_deputy);
			}
		}

		for(var n in notified) {
			if(arrayFind(user_ids, n.fk_user_id) == 0) {
				user_ids.append(n.fk_user_id);
			}
		}

		transaction {
			try {
				var jo = model("jo").findByKey(params.jo.id);
				var old_revision = model("jorevision").findOne(select="id, MAX(revision_no) AS revision_no", where="jo_id = #params.jo.id# AND is_active = 1");

				jo.jo_number = params.jo.jo_number;

				if(jo.save(transaction=false)) {
					var jorevision = model("jorevision").new();
					jorevision.jo_id = jo.id;
					jorevision.revision_no = old_revision.revision_no + 1;
					jorevision.designation = params.revision.designation;
					jorevision.type = serializeJson(params.revision.jo_type);
					jorevision.jo_reference = params.revision.jo_reference;
					jorevision.fourm_change = params.revision.fourm_change;
					jorevision.sixm_change = params.revision.sixm_change;
					jorevision.sa_no = params.revision.sa_no;
					jorevision.document_date = now();
					jorevision.model_no = params.revision.model.id;
					jorevision.model_name = itm.ItemName;
					jorevision.lot_code = params.revision.lot_code;
					jorevision.qty_to_produce = params.revision.qty_to_produce;
					jorevision.total_shipment_qty = params.revision.total_shipment_qty;
					jorevision.production_month = params.revision.production_month;
					jorevision.requested_start_date = params.revision.requested_start_date;
					jorevision.requested_end_date = params.revision.requested_end_date;
					jorevision.remarks = params.revision.remarks;
					jorevision.batch_no = params.revision.batch_no;
					jorevision.include_chemicals = (params.revision.include_chemicals ? 1 : 0);
					
					if(params.pp_approver == 0) {
						jorevision.pp_evaluated_by = SESSION.jo.user_id;
						jorevision.pp_evaluated_date = now();
						jorevision.pp_approver = SESSION.jo.user_id;
						jorevision.pp_approver_status = 'Approved';
						jorevision.pp_approver_remarks = 'System Generated';
					}
					else {
						jorevision.pp_approver = params.pp_approver;
						jorevision.pp_approver_status = 'Pending';
					}
					if(params.pu_approver == 0) {
						jorevision.pu_evaluated_by = SESSION.jo.user_id;
						jorevision.pu_evaluated_date = now();
						jorevision.pu_approver = SESSION.jo.user_id;
						jorevision.pu_approver_status = 'Approved';
						jorevision.pu_approver_remarks = 'System Generated';
					}
					else {
						jorevision.pu_approver = params.pu_approver;
						jorevision.pu_approver_status = 'Pending';
					}
					
					if(params.pp_deputy != 0) {
						jorevision.pp_deputy = params.pp_deputy;
					}
					if(params.pu_deputy != 0) {
						jorevision.pu_deputy = params.pu_deputy;
					}

					if(notified.recordCount) {
						jorevision.notified = listRemoveDuplicates(valueList(notified.fk_user_id));
					}

					if(params.pp_approver == 0 && params.pu_approver == 0) {
						jorevision.status = "Approved";
					}
					else {
						jorevision.status = "Pending";
					}

					jorevision.posted_by = SESSION.jo.user_id;
					jorevision.created_by = SESSION.jo.user_id;
					jorevision.updated_by = SESSION.jo.user_id;
					jorevision.is_active = 1;
					
					if(jorevision.save(transaction=false)) {
						for(var i = 1; i <= arrayLen(params.materials); i++) {
							var jomaterial = model("jomaterial").new();
							jomaterial.jo_id = params.jo.id;
							jomaterial.revision_id = jorevision.id;
							jomaterial.assortment = i;
							jomaterial.bom = sixDecimalFormat(params.materials[i].bom);
							jomaterial.lacking_qty = fourDecimalFormat(params.materials[i].lacking_qty);
							jomaterial.material_no = params.materials[i].material_no;
							jomaterial.material_name = params.materials[i].material_name;
							jomaterial.material_class = params.materials[i].classification;
							jomaterial.material_classname = params.materials[i].classification_name;
							jomaterial.material_type = "Primary";
							jomaterial.qty_required = fourDecimalFormat(params.materials[i].qty_required);
							jomaterial.remaining_rm_inventory = fourDecimalFormat(params.materials[i].remaining_rm_inventory);
							jomaterial.rm_inventory = fourDecimalFormat(params.materials[i].rm_inventory);
							jomaterial.wip = fourDecimalFormat(params.materials[i].wip);
							jomaterial.yield_rate = params.materials[i].yield_rate;
							jomaterial.material_for_request = fourDecimalFormat(params.materials[i].material_for_request);
							jomaterial.is_active = 1;
							jomaterial.created_by = SESSION.jo.user_id;
							jomaterial.updated_by = SESSION.jo.user_id;

							if(jomaterial.save(transaction = false) == false) {
								errorCounter++;
								for(var em in jomaterial.allErrors()) {
									errorMessage.append(em.message);
								}
								break;
							}

							for(var a = 1; a <= arrayLen(params.materials[i].alt); a++) {
								var joalt = model("jomaterial").new();
								joalt.jo_id = params.jo.id;
								joalt.revision_id = jorevision.id;
								joalt.assortment = i;
								joalt.bom = 0;
								joalt.lacking_qty = 0;
								joalt.material_no = params.materials[i].alt[a].material_no;
								joalt.material_name = params.materials[i].alt[a].material_name;
								joalt.material_class = params.materials[i].alt[a].classification;
								joalt.material_classname = params.materials[i].alt[a].classification_name;
								joalt.material_type = "Alternative";
								joalt.qty_required = 0;
								joalt.remaining_rm_inventory = fourDecimalFormat(params.materials[i].alt[a].remaining_rm_inventory);
								joalt.rm_inventory = fourDecimalFormat(params.materials[i].alt[a].rm_inventory);
								joalt.wip = fourDecimalFormat(params.materials[i].alt[a].wip);
								joalt.yield_rate = 0;
								joalt.material_for_request = 0;
								joalt.is_active = 1;
								joalt.created_by = SESSION.jo.user_id;
								joalt.updated_by = SESSION.jo.user_id;

								if(joalt.save(transaction = false) == false) {
									errorCounter++;
									for(var em in joalt.allErrors()) {
										errorMessage.append(em.message);
									}
									break;
								}
							}
						}
						if(errorCounter > 0) {
							transaction action="rollback";
						}
						else {
							transaction action="commit";
						}
					}
					else {
						transaction action="rollback";
						errorCounter++;
						for(var em in jorevision.allErrors()) {
							errorMessage.append(em.message);
						}
					}
				}
				else {
					transaction action="rollback";
					errorCounter++;
					for(var em in jo.allErrors()) {
						errorMessage.append(em.message);
					}
				}
			}
			catch(any e) {
				transaction action="rollback";
				errorCounter++;
				errorMessage.append(e.message);
			}
		}

		if(errorCounter == 0) {
			if(arrayLen(user_ids) > 0) {
				user_emails = model("login").findAll(select="hris_id, email", where="hris_id IN (#arrayToList(user_ids)#)");
			}

			if(params.pp_approver > 0) {
				var email_pp_approver = emailApprover(user_emails, params.pp_approver, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
				if(email_pp_approver.status == true) {
					if(params.pp_deputy > 0) {
						var email_pp_deputy = emailApprover(user_emails, params.pp_deputy, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
						if(email_pp_deputy.status != true) {
							errorMessage.append(email_pp_deputy.message);
						}
					}
				}
				else {
					errorMessage.append(email_pp_approver.message);
				}
			}
			else {
				if(params.pu_approver > 0) {
					var email_pu_approver = emailApprover(user_emails, params.pu_approver, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
					if(email_pu_approver.status == true) {
						if(params.pu_deputy > 0) {
							var email_pu_deputy = emailApprover(user_emails, params.pu_deputy, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
							if(email_pu_deputy.status != true) {
								errorMessage.append(email_pu_deputy.message);
							}
						}
					}
					else {
						errorMessage.append(email_pu_approver.message);
					}
				}
				else {
					if(notified.recordCount) {
						var email_notified = emailNotified(user_emails, notified, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
						if(email_notified.status != true) {
							errorMessage.append(email_notified.message);
						}
					}
				}
			}
		}
		
		renderWith({
			status: (errorCounter > 0 ? false : true),
			counter: errorCounter,
			message: (arrayLen(errorMessage) > 0 ? errorMessage : ["New revision was created successfully!"])
		});
	}

	function update()
	{
		var errorCounter = 0;
		var errorMessage = [];
		var itm = model("productname").findOne(select="ItemCode, ItemName, U_ProductionLine", where="ItemCode = '#params.revision.model.id#'");
		
		if(SESSION.jo.active_division == 1) {
			var notified = model("user").findAll(select="fk_user_id", where="FIND_IN_SET(#getArea(itm.U_ProductionLine)#, area) AND role = 'Notified' AND access_type = 'JO' AND division = #SESSION.jo.active_division# AND is_active = 1");
		}
		else {
			var notified = model("user").findAll(select="fk_user_id", where="role = 'Notified' AND access_type = 'JO' AND division = #SESSION.jo.active_division# AND is_active = 1");
		}

		var user_ids = [];

		if(params.pp_approver > 0) {
			if(arrayFind(user_ids, params.pp_approver) == 0) {
				user_ids.append(params.pp_approver);
			}
		}

		if(params.pp_deputy > 0) {
			if(arrayFind(user_ids, params.pp_deputy) == 0) {
				user_ids.append(params.pp_deputy);
			}
		}

		if(params.pu_approver > 0) {
			if(arrayFind(user_ids, params.pu_approver) == 0) {
				user_ids.append(params.pu_approver);
			}
		}

		if(params.pu_deputy > 0) {
			if(arrayFind(user_ids, params.pu_deputy) == 0) {
				user_ids.append(params.pu_deputy);
			}
		}

		for(var n in notified) {
			if(arrayFind(user_ids, n.fk_user_id) == 0) {
				user_ids.append(n.fk_user_id);
			}
		}

		transaction {
			try {
				var jo = model("jo").findByKey(params.jo.id);
				jo.jo_number = params.jo.jo_number;
				
				if(jo.save(transaction=false)) {

					if(params.is_material_edit == false) {
						var delete = model("jomaterial").deleteAll(where="jo_id = #params.jo.id# AND revision_id = #params.revision.id#");
					}

					var jorevision = model("jorevision").findByKey(params.revision.id);
					jorevision.designation = params.revision.designation;
					jorevision.type = serializeJson(params.revision.jo_type);
					jorevision.jo_reference = params.revision.jo_reference;
					jorevision.fourm_change = params.revision.fourm_change;
					jorevision.sixm_change = params.revision.sixm_change;
					jorevision.sa_no = params.revision.sa_no;
					jorevision.document_date = now();
					jorevision.model_no = params.revision.model.id;
					jorevision.model_name = itm.ItemName;
					jorevision.lot_code = params.revision.lot_code;
					jorevision.qty_to_produce = params.revision.qty_to_produce;
					jorevision.total_shipment_qty = params.revision.total_shipment_qty;
					jorevision.production_month = params.revision.production_month;
					jorevision.requested_start_date = params.revision.requested_start_date;
					jorevision.requested_end_date = params.revision.requested_end_date;
					jorevision.remarks = params.revision.remarks;
					jorevision.batch_no = params.revision.batch_no;
					jorevision.include_chemicals = (params.revision.include_chemicals ? 1 : 0);
					
					if(params.pp_approver == 0) {
						jorevision.pp_evaluated_by = SESSION.jo.user_id;
						jorevision.pp_evaluated_date = now();
						jorevision.pp_approver = SESSION.jo.user_id;
						jorevision.pp_approver_status = 'Approved';
						jorevision.pp_approver_remarks = 'System Generated';
					}
					else {
						jorevision.pp_approver = params.pp_approver;
						jorevision.pp_approver_status = 'Pending';
					}
					if(params.pu_approver == 0) {
						jorevision.pu_evaluated_by = SESSION.jo.user_id;
						jorevision.pu_evaluated_date = now();
						jorevision.pu_approver = SESSION.jo.user_id;
						jorevision.pu_approver_status = 'Approved';
						jorevision.pu_approver_remarks = 'System Generated';
					}
					else {
						jorevision.pu_approver = params.pu_approver;
						jorevision.pu_approver_status = 'Pending';
					}
					
					if(params.pp_deputy != 0) {
						jorevision.pp_deputy = params.pp_deputy;
					}
					if(params.pu_deputy != 0) {
						jorevision.pu_deputy = params.pu_deputy;
					}

					if(notified.recordCount) {
						jorevision.notified = listRemoveDuplicates(valueList(notified.fk_user_id));
					}

					jorevision.posted_by = SESSION.jo.user_id;

					if(params.pp_approver == 0 && params.pu_approver == 0) {
						jorevision.status = "Approved";
					}
					else {
						jorevision.status = "Pending";
					}

					jorevision.updated_by = SESSION.jo.user_id;

					if(jorevision.save(transaction=false)) {
						for(var i = 1; i <= arrayLen(params.materials); i++) {
							if(params.is_material_edit == true) {
								var jomaterial = model("jomaterial").findByKey(params.materials[i].id);
							}
							else {
								var jomaterial = model("jomaterial").new();
								jomaterial.jo_id = params.jo.id;
								jomaterial.revision_id = params.revision.id;
								jomaterial.assortment = i;
								jomaterial.is_active = 1;
								jomaterial.created_by = SESSION.jo.user_id;
							}

							jomaterial.bom = sixDecimalFormat(params.materials[i].bom);
							jomaterial.lacking_qty = fourDecimalFormat(params.materials[i].lacking_qty);
							jomaterial.material_no = params.materials[i].material_no;
							jomaterial.material_name = params.materials[i].material_name;
							jomaterial.material_class = params.materials[i].classification;
							jomaterial.material_classname = params.materials[i].classification_name;
							jomaterial.material_type = "Primary";
							jomaterial.qty_required = fourDecimalFormat(params.materials[i].qty_required);
							jomaterial.remaining_rm_inventory = fourDecimalFormat(params.materials[i].remaining_rm_inventory);
							jomaterial.rm_inventory = fourDecimalFormat(params.materials[i].rm_inventory);
							jomaterial.wip = fourDecimalFormat(params.materials[i].wip);
							jomaterial.yield_rate = params.materials[i].yield_rate;
							jomaterial.material_for_request = fourDecimalFormat(params.materials[i].material_for_request);
							jomaterial.updated_by = SESSION.jo.user_id;
							
							if(jomaterial.save(transaction = false) == false) {
								errorCounter++;
								for(var em in jomaterial.allErrors()) {
									errorMessage.append(em.message);
								}
								break;
							}
							
							for(var a = 1; a <= arrayLen(params.materials[i].alt); a++) {
								
								if(params.is_material_edit == true) {
									var joalt = model("jomaterial").findByKey(params.materials[i].alt[a].id);
								}
								else {
									var joalt = model("jomaterial").new();
									joalt.jo_id = params.jo.id;
									joalt.revision_id = params.revision.id;
									joalt.assortment = i;
									joalt.is_active = 1;
									joalt.created_by = SESSION.jo.user_id;
								}

								joalt.bom = 0;
								joalt.lacking_qty = 0;
								joalt.material_no = params.materials[i].alt[a].material_no;
								joalt.material_name = params.materials[i].alt[a].material_name;
								joalt.material_class = params.materials[i].alt[a].classification;
								joalt.material_classname = params.materials[i].alt[a].classification_name;
								joalt.material_type = "Alternative";
								joalt.qty_required = 0;
								joalt.remaining_rm_inventory = fourDecimalFormat(params.materials[i].alt[a].remaining_rm_inventory);
								joalt.rm_inventory = fourDecimalFormat(params.materials[i].alt[a].rm_inventory);
								joalt.wip = fourDecimalFormat(params.materials[i].alt[a].wip);
								joalt.yield_rate = 0;
								joalt.material_for_request = 0;
								joalt.updated_by = SESSION.jo.user_id;
								
								if(joalt.save(transaction = false) == false) {
									errorCounter++;
									for(var em in joalt.allErrors()) {
										errorMessage.append(em.message);
									}
									break;
								}
							}
						}
						if(errorCounter > 0) {
							transaction action="rollback";
						}
						else {
							transaction action="commit";
						}
					}
					else {
						transaction action="rollback";
						errorCounter++;
						for(var em in jorevision.allErrors()) {
							errorMessage.append(em.message);
						}
					}
				}
				else {
					for(var em in jo.allErrors()) {
						transaction action="rollback";
						errorCounter++;
						errorMessage.append(em.message);
					}
				}
			}
			catch(any e) {
				transaction action="rollback";
				errorCounter++;
				errorMessage.append(e.message);
			}
		}

		if(errorCounter == 0) {
			if(arrayLen(user_ids) > 0) {
				user_emails = model("login").findAll(select="hris_id, email", where="hris_id IN (#arrayToList(user_ids)#)");
			}

			if(params.pp_approver > 0) {
				var email_pp_approver = emailApprover(user_emails, params.pp_approver, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
				if(email_pp_approver.status == true) {
					if(params.pp_deputy > 0) {
						var email_pp_deputy = emailApprover(user_emails, params.pp_deputy, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
						if(email_pp_deputy.status != true) {
							errorMessage.append(email_pp_deputy.message);
						}
					}
				}
				else {
					errorMessage.append(email_pp_approver.message);
				}
			}
			else {
				if(params.pu_approver > 0) {
					var email_pu_approver = emailApprover(user_emails, params.pu_approver, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
					if(email_pu_approver.status == true) {
						if(params.pu_deputy > 0) {
							var email_pu_deputy = emailApprover(user_emails, params.pu_deputy, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
							if(email_pu_deputy.status != true) {
								errorMessage.append(email_pu_deputy.message);
							}
						}
					}
					else {
						errorMessage.append(email_pu_approver.message);
					}
				}
				else {
					if(notified.recordCount) {
						var email_notified = emailNotified(user_emails, notified, jo.id, jorevision.id, jo.jo_number, jorevision.model_no, jorevision.model_name);
						if(email_notified.status != true) {
							errorMessage.append(email_notified.message);
						}
					}
				}
			}
		}
		
		renderWith({
			status: (errorCounter > 0 ? false : true),
			counter: errorCounter,
			message: (arrayLen(errorMessage) > 0 ? errorMessage : ["Successfully updated JO!"])
		});
	}

	function getFullName(users, user) 
	{
		for(var u in arguments.users) {
			if(u.id == arguments.user) {
				return u.fullname;
			}
		}
		return "";
	}

	private function emailApprover(emails, approver, encodeKey, key, jo_no, model_no, model_name)
	{
		var email = "";
		
		for(var m in arguments.emails) {
			if(m.hris_id == arguments.approver) {
				email = m.email;
			}
		}

		if(len(trim(email)) > 0) {
			try {
				var mailbody = "
					<html>
						<head>
							<style type='text/css'>h1{font-family:Verdana,Geneva,sans-serif;font-size:24px;font-style:normal;font-variant:normal;font-weight:700;line-height:26.4px}h3{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:700;line-height:15.4px}p{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:400;line-height:20px}</style>
						</head>
						<body>
							<p>A new JO is modified.</p>
							<p><b>JO Number</b>: #arguments.jo_no#</p>
							<p><b>Model</b>: #arguments.model_no# #arguments.model_name#</p>
							<p>Requesting for your approval.</p>
							<p><b>Division</b>: #getDivisionName()#</p>
							<p>#linkTo(route='joEncodeRevision', onlyPath=false, encodeKey=arguments.encodeKey, key=arguments.key, text='Click this Link')# to review the details of this JO.</p>
							<p>Make sure you are logged in into the interface before you click the link to be able to go to the correct link. If you are redirected to the login page, proceed to login then click the link above again.</p>
							<br>
							<p>Thank you.</p>
							<br><br><br>
							<p>- System Generated Email</p>
						</body>
					</html>
				";

				var mailService = new mail(
				  to = email,
				  from = "forms@nicera.ph",
				  subject = "JO #arguments.jo_no#, Model #arguments.model_no# #arguments.model_name# - Edited",
				  body = mailBody,
				  type = "html"
				);

				mailService.send();
				return { status: true };
			}
			catch(any e) {
				return {
					status: false,
					message: e.message
				};
			}
		}
		else {
			return {
				status: false,
				message: "No Email: #arguments.approver#"
			};
		}
	}

	private function emailNotified(emails, users, encodeKey, key, jo_no, model_no, model_name)
	{
		var user_emails = "";
		for(var u in arguments.users) {
			for(var m in arguments.emails) {
				if(u.fk_user_id == m.hris_id) {
					user_emails = user_emails.listAppend(m.email);
				}
			}
		}

		if(listLen(user_emails) > 0) {
			try {
				var mailbody = "
					<html>
						<head>
							<style type='text/css'>h1{font-family:Verdana,Geneva,sans-serif;font-size:24px;font-style:normal;font-variant:normal;font-weight:700;line-height:26.4px}h3{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:700;line-height:15.4px}p{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:400;line-height:20px}</style>
						</head>
						<body>
							<p>A new JO is created</p>
							<p><b>JO Number</b>: #arguments.jo_no#</p>
							<p><b>Model</b>: #arguments.model_no# #arguments.model_name#</p>
							<p><b>Division</b>: #getDivisionName()#</p>
							<p>#linkTo(route='joencode', onlyPath=false, encodeKey=arguments.encodeKey, key=arguments.key, text='Click this Link')# to view the full information of the JO.</p>
							<p>Make sure you are logged in into the interface before you click the link to be able to go to the correct link. If you are redirected to the login page, proceed to login then click the link above again.</p>
							<br>
							<p>Thank you.</p>
							<br><br><br>
							<p>- System Generated Email</p>
						</body>
					</html>
				";
				var mailService = new mail(
				  to = user_emails,
				  from = "forms@nicera.ph",
				  subject = "JO #arguments.jo_no#, Model #arguments.model_no# #arguments.model_name# - Created",
				  body = mailBody,
				  type = "html"
				);
				mailService.send();
				return { status: true };
			}
			catch(any e) {
				return {
					status: false,
					message: e.message 
				};
			}
		}
		else {
			return { status: true };
		}
	}

	private function getEmailByList(emails, email)
	{
		for(var e in arguments.emails) {
			if(e.test == arguments.email) {
				return { status: true, email: e.email };
			}
		}

		return { status: false, email: "" };
	}

	private function getArea(area)
	{
		if(arguments.area == 'UT-CT1') {
			return 1;
		}
		else if(arguments.area == 'UT-CT2') {
			return 2;
		}
		else if(arguments.area == 'UT-CT3') {
			return 3;
		}
		else if(arguments.area == 'UT-CT4') {
			return 4;
		}
		else if(arguments.area == 'UT-OT') {
			return 5;
		}
		else if(arguments.area == 'UT-PZT') {
			return 6;
		}
		else if(arguments.area == 'UT-PNT') {
			return 7;
		}
		else if(arguments.area == 'UT-COMMON') {
			return 8;
		}
		else if(arguments.area == 'UT-TRADED') {
			return 9;
		}
		else {
			return 0;
		}
	}

	private function fourDecimalFormat(number) {
		return numberFormat(arguments.number,'__.9999');
	}

	private function sixDecimalFormat(number) {
		return numberFormat(arguments.number, '__.999999');
	}

	function isApprover()
	{
		for(var s in SESSION.jo.allowed_roles) {
			if(s.id == SESSION.jo.active_division && (listFind("'PP Approver','PP Deputy','PU Approver','PU Deputy'", s.role) != 0)) {
				return true;
			}
		}
		return false;
	}

	function isEncoder()
	{
		for(var s in SESSION.jo.allowed_roles) {
			if(s.id == SESSION.jo.active_division && (s.role == 'Encode')) {
				return true;
			}
		}
		return false;
	}

	private function getDivisionName()
	{
		for(var d in SESSION.jo.allowed_roles) {
			if(d.id == SESSION.jo.active_division) {
				return d.name;
			}
		}
		return "";
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "jo")) {
			flashInsert(error="You are not logged in");
			redirectTo(route="joLogin");
		}
	}
}