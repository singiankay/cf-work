component displayname="WMS Issuance - Adjustment Approval" extends="app.controllers.Controller"
{
	title = "WMS - Adjustment Approval";

	function config()
	{
		filters(through="restrictAccess");
		usesLayout(template="/wms/layout");
		provides("html, json");
	}

	function index()
	{
		controllerJS = 'wms/issuance/adjustmentapproval_index';
		if(!structKeyExists(params, "page")) {
			var params.page = 1;
		}
		adjustments = model("issuanceadjustment").findAll(
			where="division = #SESSION.wms.active_division# AND is_active = 1", 
			page=#params.page#, 
			perPage=20, 
			order="id DESC"
		);

		if(adjustments.recordCount) {
			whlabel = model("whlabel").findAll(where="id_record IN (#listRemoveDuplicates(valueList(adjustments.whlbl_id))#)");
			orcv = model("orcv").findAll(select="U_ItemCode, U_IDRecord, U_ItemDescription, U_QRCode", where="U_IDRecord IN (#listRemoveDuplicates(valueList(adjustments.whlbl_id))#)");
		}
	}

	function show()
	{
		controllerJS = 'wms/issuance/adjustmentapproval_show';
		adjustment = model("issuanceadjustment").findByKey(params.key);
		issuanceTotal = 0;
		orcv = model("orcv").findOne(select="Docentry, U_ItemCode, U_ItemDescription, U_Reference, U_Fifo, U_Lotcode, U_Lotcode2, U_Lotcode3, U_Uom, U_ItemType, U_QRCode", where="u_idrecord = #adjustment.whlbl_id# AND Canceled = 'N'");
		oiss = model("oiss").findAll(select="DocEntry, U_ItemCode, U_ItemDescription, U_DocType, U_Reference, U_Location, U_Ref2, U_Quantity, U_ReceivedBy, U_ShipDate, U_Fifo, U_IssuedBy, U_Postingdate, UpdateDate, Canceled, ",where="U_IDRecord = #adjustment.whlbl_id# AND Canceled = 'N'");
		for(var o in oiss) {
			issuanceTotal += o.U_Quantity;
		}
	}


	function update()
	{
		var adjustment = model("issuanceadjustment").findByKey(params.key);
		var orcv = model("orcv").findOne(where="canceled = 'N' AND U_IDRecord = #adjustment.whlbl_id#");
		var orcv_count = model("orcv").count(where="canceled = 'N' AND U_IDrecord = #adjustment.whlbl_id#");
		if(orcv_count != 1) {
			flashInsert(error="Cannot Update Record. Zero or multiple receiving record exists. Please contact MIS!");
			redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
		}
		else {
			
			// Determine Save Type Then Process it
			if(adjustment.save_type == "Create") {
				var process_issuance = createIssuance(adjustment.id);
			}
			else if(adjustment.save_type == "Update") {
				var oiss = model("oiss").findone(where="DocEntry = #adjustment.issuance_id#");
				var process_issuance = updateIssuance(adjustment.id);
			}
			
			if(process_issuance.status == true) {
				if(adjustment.save_type == "Update" && adjustment.qty_from == adjustment.qty_to) {
					var update_adjustment_status = updateAdjustmentStatus(adjustment.id, "Approved", params.adjustment.remarks, orcv.U_QRCode);
					if(update_adjustment_status) {
						var notify_encoder = notifyEncoder(adjustment.created_by, "Approved", orcv.U_QRCode);
						if(notify_encoder) {
							flashInsert(success="Successfully approved record!");
							redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
						}
						else {
							flashInsert(error="Email notification to encoder failed. Please contact MIS.");
							redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
						}
					}
					else {
						flashInsert(error="Record was saved but cannot update Adjustment Status. Please contact MIS.");
						redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
					}
				}
				else {
					var reconcile_record = reconcileRecord(adjustment.whlbl_id);
					if(reconcile_record) {
						var update_adjustment_status = updateAdjustmentStatus(adjustment.id, "Approved", params.adjustment.remarks, orcv.U_QRCode);
						if(update_adjustment_status) {
							var notify_encoder = notifyEncoder(adjustment.created_by, "Approved", orcv.U_QRCode);
							if(notify_encoder) {
								flashInsert(success="Successfully approved record!");
								redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
							}
							else {
								flashInsert(error="Email notification to encoder failed. Please contact MIS.");
								redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
							}
						}
						else {
							flashInsert(error="Record was saved but cannot update Adjustment Status. Please contact MIS.");
							redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
						}
					}
					else {
						flashInsert(error="Error Reconciling record. Please contact MIS.");
						redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
					}
				}
			}
			else {
				flashInsert(error="Error updating issuance record. Please contact MIS. Error info: #process_issuance.message#");
				redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
			}
		}
	}

	function delete()
	{
		var adjustment = model("issuanceadjustment").findByKey(params.key);
		if(adjustment.save_type == "Create") {
			var orcv = model("orcv").findOne(select="U_QRCode", where="U_IDRecord = #adjustment.whlbl_id# AND Canceled = 'N'");
			var reject = updateAdjustmentStatus(params.key, "Rejected", params.adjustment.remarks, orcv.U_QRCode);
			if(reject) {
				var notify_encoder = notifyEncoder(adjustment.created_by, "Rejected", orcv.U_QRCode);
				if(notify_encoder) {
					flashInsert(success="Successfully rejected record!");
					redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
				}
				else {
					flashInsert(error="Email notification to encoder failed. Please contact MIS.");
					redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
				}
			}
		}
		else {
			var oiss = model("oiss").findone(where="DocEntry = #adjustment.issuance_id#");

			var reject = updateAdjustmentStatus(params.key, "Rejected", params.adjustment.remarks, oiss.U_QRCode);
			if(reject) {
				var notify_encoder = notifyEncoder(adjustment.created_by, "Rejected", oiss.U_QRCode);
				if(notify_encoder) {
					flashInsert(success="Successfully rejected record!");
					redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
				}
				else {
					flashInsert(error="Email notification to encoder failed. Please contact MIS.");
					redirectTo(route="wmsIssuanceAdjustmentapproval", key=params.key);
				}
			}
		}
	}

	private function createIssuance(id)
	{
		var adjustment = model("issuanceadjustment").findByKey(arguments.id);
		var custom_date = Month(adjustment.date_created) &'/1/'& Year(adjustment.date_created);
		var orcv = model("orcv").findOne(where="canceled = 'N' AND U_IDRecord = #adjustment.whlbl_id#");
		var onnm = model("onnm").findOne(select="autokey, dfltseries", where="objectcode='fn_oiss'");
		var period = model("ofpr").findOne(select="absentry", where="f_refdate = '#createodbcdate(custom_date)#'");
		var pcmodel = model("mdousr").findOne(select="code", where="name = #CGI.REMOTE_ADDR#");
		
		if(isObject(pcmodel)) {
			var pcname = pcmodel.code;
		}
		else {
			var pcname = "";
		}

		// Assign Data From Adjustment Table
		var oiss = model("oiss").new();
		oiss.U_doctype = adjustment.document_type_to;
		oiss.U_Reference = adjustment.wh_ref_no_to;
		oiss.U_Quantity = adjustment.qty_to;
		oiss.U_Location = adjustment.wh_to;
		if(adjustment.division == 1) {
			oiss.U_ReceivedBy = adjustment.area_to;
		}
		oiss.U_Ref2 = adjustment.jo_no_to;
		if(isDate(adjustment.issued_date_to)) {
			oiss.U_ShipDate = adjustment.issued_date_to;
		}
		if(isDate(adjustment.request_date_to)) {
		oiss.U_Fifo = adjustment.request_date_to;
		}
		oiss.U_IssuedBy = adjustment.issued_by_to;
		oiss.U_Remarks = adjustment.remarks_to;
		oiss.Canceled = adjustment.canceled_to;
		oiss.UpdateDate = createODBCDateTime(now());
		oiss.UpdateTime = timeformat(now(),'HHmm');
		oiss.U_TerminalId = adjustment.pc_name;
		if(adjustment.is_for_issue) {
			oiss.U_PostingDate = createODBCDateTime(now());
			oiss.U_Release = 1;
		}

		// Assign Data From SAP
		oiss.DocEntry = onnm.autokey;
		oiss.DocNum = onnm.autokey;
		oiss.Period = period.absentry;
		oiss.Series = onnm.dfltseries;
		oiss.CreateDate = createODBCDateTime(now());
		oiss.CreateTime = timeformat(now(),'HHmm');
		oiss.U_ItemDescription = orcv.U_ItemDescription;
		oiss.U_UOM = orcv.U_Uom;
		oiss.U_ItemType = orcv.U_ItemType;
		
		oiss.U_ProductLine = getSessionDivision(SESSION.wms.active_division); 
		
		oiss.Object = "FN_OISS"; 
		oiss.Usersign = 3;
		oiss.DataSource = 'I';
		oiss.U_QRCode = orcv.U_QRCode; 
		oiss.U_ItemCode = orcv.U_ItemCode;
 		oiss.U_LotCode = orcv.U_Lotcode; 
		oiss.U_LotCode2 = orcv.U_Lotcode2; 
		oiss.U_LotCode3 = orcv.U_Lotcode3; 
		oiss.U_PHFNo = orcv.U_Reference; 
		oiss.U_ProdDate = createodbcdate(orcv.U_Fifo); 
		oiss.U_BaseRef = orcv.Docentry;  
		oiss.U_idrecord = orcv.U_IDRecord;
		oiss.u_remarks1 = 'manual_issued';
		
		var oiss_create = oiss.save();

		if(oiss_create == true) {
			var next_id = onnm.autokey + 1; 
			var onnm_update = updateOnnm(next_id);
			if(onnm_update.status == true) {
				var nnm1_update = updateNnm1(next_id);
				if(nnm1_update.status == true) {
					return { status: true };
				}
				else {
					return { status: false, message: nnm1_update.message  };
				}
			}
			else {
				return { status: false, message: onnm_update.message };
			}
		}
		else {
			var errorMessage = oiss.allErrors();
			return { status: false, message: errorMessage[1].message };
		}
		
	}

	private function updateIssuance(id)
	{
		var adjustment = model("issuanceadjustment").findByKey(arguments.id);
		var oiss = model("oiss").findOne(where="DocEntry = #adjustment.issuance_id#");

		oiss.U_doctype = adjustment.document_type_to;
		oiss.U_Reference = adjustment.wh_ref_no_to;
		oiss.U_Quantity = adjustment.qty_to;
		oiss.U_Location = adjustment.wh_to;

		if(adjustment.division == 1) {
			oiss.U_ReceivedBy = adjustment.area_to;
		}

		oiss.U_Ref2 = adjustment.jo_no_to;
		if(isDate(adjustment.issued_date_to)) {
			oiss.U_ShipDate = adjustment.issued_date_to;
		}
		if(isDate(adjustment.request_date_to)) {
		oiss.U_Fifo = adjustment.request_date_to;
		}

		oiss.U_IssuedBy = adjustment.issued_by_to;
		oiss.U_Remarks = adjustment.remarks_to;
		oiss.Canceled = adjustment.canceled_to;
		oiss.UpdateDate = createODBCDateTime(now());
		oiss.UpdateTime = timeformat(now(),'HHmm');
		oiss.U_TerminalId = adjustment.pc_name;
		if(adjustment.is_for_issue) {
			oiss.U_PostingDate = createODBCDateTime(now());
			oiss.U_Release = 1;
		}
		var status = oiss.save();
		if(status == true) {
			return { status: true };
		}
		else {
			var errorMEssage = oiss.allErrors();
			return { status: false, message: errorMessage[1].message };
		}
	}

	private function updateOnnm(value)
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				UPDATE dbo.ONNM 
				   SET AutoKey = :value
				 WHERE ObjectCode = 'FN_OISS'
			");
			sqlQuery.addParam(name="value", value=arguments.value, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute();
			return { status: true };
		}
		catch(any e) {
			return { status: false, message: e.message };
		}
	}

	private function updateNnm1(value)
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				UPDATE dbo.NNM1 
				   SET NextNumber = :value 
		 	    WHERE ObjectCode = 'FN_OISS'
			");
			sqlQuery.addParam(name="value", value=arguments.value, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute();
			return { status: true };
		}
		catch(any e) {
			return { status: false, message: e.message };
		}
	}

	private function updateAdjustmentStatus(id, status, remarks, qrcode)
	{
		var adjustment = model("issuanceadjustment").findByKey(arguments.id);
		adjustment.status = arguments.status;
		adjustment.remarks = arguments.remarks;
		adjustment.approved_by = SESSION.wms.user_id;
		adjustment.updated_by = SESSION.wms.user_id;
		return adjustment.save();
	}

	private function reconcileRecord(id)
	{
		var orcv = model("orcv").findOne(where="canceled = 'N' AND U_IDRecord = #arguments.id#");
		
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT COALESCE(rcv.U_Quantity, 0) qty_in,
				       COALESCE(CASE WHEN rcv.u_isinspected = 0 THEN rcv.U_Quantity END, 0) qty_for_iqc,
				       (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				       + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				       + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				       + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				       + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				       + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) qty_balance,
				       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) qty_ncp,
				       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) qty_on_hold, 
				       COALESCE(itf.[p_reinspect], 0) - (COALESCE(itf.[m_reinspect], 0) + COALESCE(iss_m.[reinspect], 0)) qty_reinspect,
				       COALESCE(iss_m.issued_qty, 0) qty_issued, 
				       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) 
				       + COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) 
				       + COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) 
				       + COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) qty_unissued 
				  FROM dbo.[@FN_ORCV] rcv 
				  LEFT JOIN (
				     SELECT U_BaseRef, 
				            SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
				            SUM(CASE WHEN U_LocationTo = 4 THEN U_Quantity END) [p_IQC-Q], 
				            SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
				            SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
				            SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
				            SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
				            SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
				            SUM(CASE WHEN U_LocationTo = 15 THEN U_Quantity END) [p_IQC-S],
				            SUM(CASE WHEN U_LocationFrom = 10 AND U_LocationTo = 4 THEN U_Quantity END) [p_reinspect],
				            SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
				            SUM(CASE WHEN U_LocationFrom = 4 THEN U_Quantity END) [m_IQC-Q], 
				            SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
				            SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
				            SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
				            SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
				            SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S], 
				            SUM(CASE WHEN U_LocationFrom = 15 THEN U_Quantity END) [m_IQC-S],
				            SUM(CASE WHEN U_LocationFrom = 4 AND RIGHT(U_Reference, 2) = 're' THEN U_Quantity END) [m_reinspect]
				       FROM dbo.[@FN_OITF] 
				      WHERE Canceled = 'N'
				      GROUP BY U_BaseRef 
				     ) itf
				         ON itf.U_BaseRef = rcv.Docentry 
				  LEFT JOIN (
				     SELECT U_BaseRef,
				            SUM(CASE WHEN U_Location = 'IQC-G' THEN U_Quantity END) [IQC-G], 
				            SUM(CASE WHEN U_Location = 'IQC-Q' THEN U_Quantity END) [IQC-Q], 
				            SUM(CASE WHEN U_Location = 'PCK-G' THEN U_Quantity END) [PCK-G], 
				            SUM(CASE WHEN U_Location = 'WHS-G' THEN U_Quantity END) [WHS-G], 
				            SUM(CASE WHEN U_Location = 'WHS-Q' THEN U_Quantity END) [WHS-Q], 
				            SUM(CASE WHEN U_Location = 'WHS-R' THEN U_Quantity END) [WHS-R], 
				            SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S], 
				            SUM(CASE WHEN U_Location = 'IQC-S' THEN U_Quantity END) [IQC-S], 
				            SUM(CASE WHEN RIGHT(U_Reference, 2) = 're' THEN U_quantity END) [reinspect], 
				            SUM(U_Quantity) issued_qty
				       FROM dbo.[@FN_OISS] 
				      WHERE Canceled = 'N' 
				        AND U_Release = 1 
				      GROUP BY U_BaseRef 
				     ) iss_m
				         ON iss_m.U_BaseRef = rcv.DocEntry 
				 INNER JOIN dbo.OITM itm 
				         ON itm.Itemcode = rcv.U_ItemCode
				 WHERE rcv.Canceled = 'N' 
				   AND rcv.U_Idrecord = :id
			");

			sqlQuery.addParam(name="id", value=arguments.id, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();

			orcv.U_Qty_Balance = resultset.qty_balance;
			orcv.U_Qty_Rework = resultset.qty_reinspect;
			orcv.U_Qty_OnHold = resultset.qty_on_hold;
			orcv.U_Qty_Scrap = resultset.qty_ncp;
			orcv.U_Qty_ForIQC = resultset.qty_for_iqc;
			orcv.U_IsBalanced = 1;

			if(resultset.qty_balance == 0) {
				orcv.Status = 'C';
			}
			else {
				orcv.Status = 'O';
			}
			return orcv.save();
		}
		catch (customExcp e) {
		    return false;
		}
	}

	private function notifyEncoder(user_id, status, qr)
	{
		var encoder_login = model("login").findOne(select="email", where="hris_id = #arguments.user_id#");
		
		if(isValid("email", encoder_login.email)) {
			var encoder_profile = model("hrisemployee").findOne(select="gender, fullname", where="id = #arguments.user_id#");
			var mailBody = "<html><head>";
			mailBody &= "<style>h1{font-family:Verdana,Geneva,sans-serif;font-size:24px;font-style:normal;font-variant:normal;font-weight:700;line-height:26.4px}h3{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:700;line-height:15.4px}p{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:400;line-height:20px}</style>";
			mailBody &= "</head><body>";
			if(encoder_profile.gender == "Male") {
				mailBody &= "<h3>Dear Mr. #encoder_profile.fullname#,</h3>";
			}
			else {
				mailBody &= "<h3>Dear Miss #encoder_profile.fullname#,</h3>";
			}
			mailBody &= "<p>This is to inform you that your request for issuance adjustment has been <strong>#LCase(arguments.status)#</strong>.</p>";
			mailBody &= "<p>Kindly see below QR for reference.</p>";
			mailBody &= "<h3>#arguments.qr#</h3>";
			mailBody &= "<br /><br /><br />";
			mailBody &= "<p>- System generated email.</p>";
			mailBody &= "</body></html>";
			try {	
				var mailService = new mail(
					to = encoder_login.email,
					from = "forms@nicera.ph",
					subject = "Issuance Adjustment - #arguments.status#",
					body = mailBody,
					type = "html"
				);
				mailService.send();
				return true;
			}
			catch(any e) {
				return false;
			}
		}
	}

	private function getMaterialNumber(whlbl, id)
	{
		for(rows in arguments.whlbl) {
			if(rows.id_record == arguments.id) {
				return rows.id_material;
			}
		}
		return false;
	}

	private function getMaterialName(rcv, id)
	{
		for(rows in arguments.rcv) {
			if(rows.U_IDRecord == arguments.id) {
				return rows.U_ItemDescription;
			}
		}
		return false;
	}

	private function getQRcode(rcv, id)
	{
		for(rows in arguments.rcv) {
			if(rows.U_IDRecord == arguments.id) {
				return rows.U_QRCode;
			}
		}
		return false;
	}

	private function getPONumber(whlbl, id)
	{
		for(rows in arguments.whlbl) {
			if(rows.id_record == arguments.id) {
				return rows.ponumber;
			}
		}
		return false;
	}

	private function getInvoiceNumber(whlbl, id)
	{
		for(rows in arguments.whlbl) {
			if(rows.id_record == arguments.id) {
				return rows.invoicenumber;
			}
		}
		return false;
	}

	private function getRRNumber(whlbl, id)
	{
		for(rows in arguments.whlbl) {
			if(rows.id_record == arguments.id) {
				return rows.formnumber;
			}
		}
		return false;
	}

	private function getApprover(id)
	{
		if(Len(Trim(arguments.id))) {
			var approver = model("hrisemployee").findOne(select="fullname", where="id = #arguments.id#");
			return approver.fullname;
		}
		return "";
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "wms")) {
			flashInsert(error="You are not logged in");
			if(structKeyExists(params, "key")) {
				redirectTo(route="wmsLogin", params="redirectto=#params.route#&redirectkey=#params.key#");
			}
			else {
				redirectTo(route="wmsLogin", params="redirectto=#params.route#");
			}
		}
		else {
			if(!getRole(SESSION.wms.allowed_roles)) {
				flashInsert(error="You are not allowed to access this page.");
				redirectTo(route="wmsMain");
			}
		}
	}

	private function getRole(roles)
	{
		for(r in arguments.roles) {
			if(r.role == 'Issuance Adjustment' AND r.id == SESSION.wms.active_division) {
				return true;
			}
		}
		return false;
	}

	private function getSessionDivision(id) {
		for(d in SESSION.wms.allowed_divisions) {
			if(d.id == arguments.id) {
				return d.name;
			}
		}
		return "";
	}
}