component displayname="MRF Request" extends="app.controllers.Controller"
{
	title = "MRF - Request";
	buildings = [1,2,3];

	function config()
	{
		provides("html, json");
		usesLayout(template="/mrf/layout");
	}

	function index()
	{
		controllerJS = "mrf/request/index";
	}

	function new()
	{
		controllerJS = "mrf/request/new";
		if(SESSION.mrf.active_division == 1) {
			areas = super.getAreas(SESSION.mrf.active_division);
		}
	}

	function show()
	{

	}

	function create()
	{
		var yearNow = year(now());
		var errorCounter = 0;
		var errorMessage = [];

		transaction {
			var issuanceCounter = model("issuancecounter").findOne(select="counter", where="division = #SESSION.mrf.active_division# year = #yearNow# AND building = #params.mrf.building# AND type= 'MRF'");
			
			if(isObject(issuanceCounter)) {
				var counter = issuanceCounter.counter;
				var saveIssuanceCounter = issuanceCounter.update(counter= counter + 1, transaction= false);

				if(saveIssuanceCounter != true) {
					for(var em in issuanceCounter.allErrors()) {
						errorCounter++;
						errorMessage.append(em.message);
					}
				}
			}
			else {
				var newIssuanceCounter = model("issuancecounter").new();
				newIssuanceCounter.division = SESSION.mrf.active_division;
				newIssuanceCounter.year = yearNow;
				newIssuanceCounter.building = params.mrf.building;
				newIssuanceCounter.counter = 1;
				newIssuanceCounter.type = "MRF";
				var saveIssuanceCounter = newIssuanceCounter.save(transaction=false);

				if(saveIssuanceCounter != true) {
					for(var em in newIssuanceCounter.allErrors()) {
						errorCounter++;
						errorMessage.append(em.message);
					}
				}
			}

			if(saveIssuanceCounter == true) {
				var mrf = model("mrf").new();
				mrf.mrf_no = "#building#MRF#yearNow#-#counter#";
				mrf.jo_no = params.x;
				mrf.area = params.area;
				mrf.requested_issuance_date = params.requested_issuance_date;
				mrf.purpose = params.purpose;
				mrf.other_purpose = params.other_purpose;
				mrf.created_by = params.created_by;
				mrf.updated_by = params.updated_by;

				var approver = model("user").findOne(select="fk_user_id", where="division = #SESSION.mrf.active_division# AND access_type = 'WH' AND role = 'MRF Issuer' AND is_active = 1");
				
				if(isObject(approver)) {
					mrf.approver = approver.fk_user_id;
					mrf.approver_status = "Pending";
					mrf.approver_remarks = "";
				}
				else {
					mrf.approver = "";
					mrf.approved_by = SESSION.mrf.user_id;
					mrf.approver_status = "Approved";
					mrf.approver_remarks = "System Generated.";
				}

				var save = mrf.save(transaction=false);

				if(save == true) {
					for(var m in params.materials) {
						var materials = model("mrfmaterial").new();
						materials.mrf_id = mrf.id;
						materials.material_no = m.material_no;
						materials.material_name = m.material_name;
						materials.rm_inventory = m.rm_inventory;
						materials.remaining_inventory = m.remaining_inventory;
						materials.qty = m.qty;
						materials.transfer_to_area = m.transfer_to_area;
						var material_save = materials.save(transaction = false);
						
						if(material_save != true) {
							for(var em in materials.allErrors()) {
								errorCounter++;
								errorMessage.append(em.message);
							}
							break;
						}
					}
				}
				else {
					for(var em in mrf.allErrors()) {
						errorCounter++;
						errorMessage.append(em.message);
					}
				}

				if(errorCounter == 0) {
					transaction action="commit";
					var email = emailApprover();
				}
				else {
					transaction action="rollback";
					renderWith();
				}
			}
			else {
				transaction action="rollback";
				renderWith();
			}
		}
	}

	private function emailApprover(mrf_id, mrf_no)
	{	
		try {
			var mailbody = "
				<html>
					<head>
						<style type='text/css'>h1{font-family:Verdana,Geneva,sans-serif;font-size:24px;font-style:normal;font-variant:normal;font-weight:700;line-height:26.4px}h3{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:700;line-height:15.4px}p{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:400;line-height:20px}</style>
					</head>
					<body>
						<p>A new MRF is for Approval</p>
						<p><b>MRF Number</b>: #arguments.mrf_no#</p>
						<p><b>Division</b>: #getDivisionName()#</p>
						<p>#linkTo(route='wmsMrf', onlyPath=false, key=arguments.mrf_id, text='Click this Link')# to view the full information of the MRF.</p>
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
			  subject = "MRF No: #arguments.mrf_no# - for Approval",
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

	private function emailOwner()
	{

	}

	private function emailIssuer()
	{

	}

	function getMaterialInventory()
	{
		var groups = model("materialgroupings").findAll(select="id, code, division, type", where="division = #SESSION.mrf.active_division# AND type NOT IN ('Finished Goods', 'All')");
		
		if(SESSION.mrf.active_division == 1) {
			var area = 0;
		}
		else {
			var area = -1;
		}
		var productionArea = getProductionArea(SESSION.mrf.active_division, area);
		var material_nos = reReplace(listRemoveDuplicates(arrayToList(deserializeJSON(params.material_nos))), '"', "'", "all");

		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT b.division, a.U_productionLine area, a.ItemCode material_no, a.ItemName material_name, COALESCE(b.qty_balance, 0) AS qty_balance 
				  FROM dbo.OITM a 
				  LEFT JOIN (
				  	  SELECT rcv.U_ItemCode material_no, rcv.U_ProductLine division,
				  	     SUM((COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
				  	       + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
				  	       + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
				  	       + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
				  	       + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
				  	       + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)))) qty_balance
				  	    FROM [@FN_ORCV] rcv 
				  	    LEFT JOIN (
				  	       SELECT U_BaseRef, 
				  	          SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
				  	          SUM(CASE WHEN U_LocationTo = 4 THEN U_Quantity END) [p_IQC-Q], 
				  	          SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
				  	          SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
				  	          SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
				  	          SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
				  	          SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
				  	          SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
				  	          SUM(CASE WHEN U_LocationFrom = 4 THEN U_Quantity END) [m_IQC-Q], 
				  	          SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
				  	          SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
				  	          SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
				  	          SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
				  	          SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S]
				  	         FROM [@FN_OITF] 
				  	        WHERE Canceled = 'N' 
				  	          AND U_ItemCode IN (:material_nos)
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
				  	          SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S] 
				  	         FROM [@FN_OISS] 
				  	        WHERE Canceled = 'N' 
				  	          AND U_Release = 1 
				  	          AND U_ItemCode IN (:material_nos)
				  	        GROUP BY U_BaseRef 
				  	       ) iss_m
				  	           ON iss_m.U_BaseRef = rcv.DocEntry 
				  	   WHERE rcv.Canceled = 'N' 
				  	     AND rcv.Status = 'O' 
				  	     AND rcv.U_ItemCode IN (:material_nos)
				      GROUP BY rcv.U_ItemCode, rcv.U_ProductLine  
				  	   ) b 
				         ON b.material_no = a.ItemCode 
				 WHERE a.ItmsgrpCod IN (:groups) 
				   AND (:area_code = -1 OR a.U_ProductionLine IN (:area)) 
				   AND a.ItemCode IN (:material_nos) 
				OPTION (RECOMPILE)
			");
			sqlQuery.addParam(name="groups", value=(ListLen(valueList(groups.code)) ? valueList(groups.code) : 0), CFSQLTYPE="CF_SQL_INTEGER", list="true");
			sqlQuery.addParam(name="area", value=productionArea, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			sqlQuery.addParam(name="area_code", value=area, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="material_nos", value=material_nos, CFSQLTYPE="CF_SQL_VARCHAR", list="true");
			var resultset = sqlQuery.execute().getResult();
			var results = [];

			for(var r in resultset) {
				results.append({
					area: r.area,
					division: r.division,
					material_name: r.material_name,
					material_no: r.material_no,
					qty_balance: r.qty_balance
				});
			}

			renderWith({
				status: true,
				data: results
			});
		}
		catch(any e) {
			renderWith({
				status: false,
				message: e
			});
		}
	}

	private function getProductionArea(division, area = 0)
	{
		if(arguments.division == 1) {
			if(arguments.area == 0) {
				return "UT-CT1,UT-CT2,UT-CT3,UT-CT4,UT-OT,UT-PZT,UT-PNT,UT-TRADED,UT-COMMON";
			}
			else if(arguments.area == 1) {
				return "UT-CT1";
			}
			else if(arguments.area == 2) {
				return "UT-CT2";
			}
			else if(arguments.area == 3) {
				return "UT-CT3";
			}
			else if(arguments.area == 4) {
				return "UT-CT4";
			}
			else if(arguments.area == 5) {
				return "UT-OT";
			}
			else if(arguments.area == 6) {
				return "UT-PZT";
			}
			else if(arguments.area == 7) {
				return "UT-PNT";
			}
			else if(arguments.area == 8) {
				return "UT-COMMON";
			}
			else if(arguments.area == 9) {
				return "UT-TRADED";
			}
			else {
				return "";
			}
		}
		else {
			return "";
		}
	}

	private function getDivisionName()
	{
		for(var d in SESSION.mrf.allowed_divisions) {
			if(d.id == SESSION.mrf.active_division) {
				return d.name;
			}
		}
		return "";
	}
}