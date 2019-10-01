component displayname="JO Encode" extends="app.controllers.Controller"
{
	title = "JO - Approver List";

	function config()
	{
		filters("restrictAccess");
		usesLayout(template='layout');
		provides("html, json");
		usesLayout(template="/jo/layout");
	}

	function index()
	{
		if(params.approver == "pp_approver") {
			var approver = "PP Approver";
		}
		else if(params.approver == "pp_deputy") {
			var approver = "PP Deputy";
		}
		else if(params.approver == "pu_approver") {
			var approver = "PU Approver";
		}
		else if(params.approver == "pu_deputy") {
			var approver = "PU Deputy";
		}
		else {
			var approver ="";
		}

		var sqlQuery = new Query();
		sqlQuery.setDatasource(erpdb_fg);
		sqlQuery.setSQL(" 
			SELECT a.id, a.fk_user_id, b.EMP2 AS lastname, b.EMP3 AS firstname, a.area 
			  FROM #erpdb_fg#.tbl_erpx_user a  
			 INNER JOIN #hris#.m_employee b 
			         ON b.EMP33 = a.fk_user_id 
			 WHERE a.access_type = 'JO' 
			   AND a.role = :approver 
			   AND a.is_active = 1 
			   AND a.division = :division 
			 ORDER BY b.EMP3, b.EMP2, a.id 
		");
		sqlQuery.addParam(name="approver", value=approver, CFSQLTYPE="CF_SQL_VARCHAR");
		sqlQuery.addParam(name="division", value=SESSION.jo.active_division, CFSQLTYPE="CF_SQL_INTEGER");
		users = sqlQuery.execute().getResult();
		var result = [];
		for(var u in users) {
			result.append({
				id: u.fk_user_id,
				text: u.firstname & ' ' & u.lastname
			});
		}
		renderWith(result);
	}

	function update()
	{
		var jo_revision = model("jorevision").findByKey(params.key);
		var jo = model("jo").findByKey(jo_revision.jo_id);

		var user_ids = [];

		if(arrayFind(user_ids, jo_revision.pu_approver) == 0) {
			user_ids.append(jo_revision.pu_approver);
		}

		if(jo_revision.pu_deputy > 0) {
			if(arrayFind(user_ids, jo_revision.pu_deputy) == 0) {
				user_ids.append(jo_revision.pu_deputy);
			}
		}

		if(listLen(jo_revision.notified) > 0) {
			for(var n in jo_revision.notified) {
				if(arrayFind(user_ids, n) == 0) {
					user_ids.append(n);
				}
			}
		}

		if(arrayFind(user_ids, jo_revision.posted_by) == 0) {
			user_ids.append(jo_revision.posted_by);
		}

		user_emails = model("login").findAll(select="hris_id, email", where="hris_id IN (#arrayToList(user_ids)#)");
		
		if(params.type == 'pp') {
			jo_revision.pp_evaluated_by = SESSION.jo.user_id;
			jo_revision.pp_evaluated_date = now();
			jo_revision.pp_approver_status = 'Approved';
			jo_revision.pp_approver_remarks = params.remarks;

			if(jo_revision.pu_approver_status == 'Approved') {
				jo_revision.status = 'Approved';
			}
		}
		else if(params.type == 'pu') {
			jo_revision.pu_evaluated_by = SESSION.jo.user_id;
			jo_revision.pu_evaluated_date = now();
			jo_revision.pu_approver_status = 'Approved';
			jo_revision.pu_approver_remarks = params.remarks;
			
			if(jo_revision.pp_approver_status == 'Approved') {
				jo_revision.status = 'Approved';
			}
		}
		if(jo_revision.save() == true) {
			if(jo_revision.pp_approver_status == 'Approved' && jo_revision.pu_approver_status == 'Approved') {
				if(listLen(listRemoveDuplicates(listAppend(jo_revision.notified, jo_revision.posted_by))) > 0) {
					var email_notified = emailNotified(user_emails, listRemoveDuplicates(listAppend(jo_revision.notified, jo_revision.posted_by)), jo_revision.jo_id, jo_revision.id, jo.jo_number, jo_revision.model_no, jo_revision.model_name);
					if(email_notified.status == true) {
						flashInsert(success="Successfully approved JO!");
					}
					else {
						flashInsert(error=email_notified.message);
					}
				}
				else {
					flashInsert(success="Successfully approved JO!");
				}
			}
			else {
				if(jo_revision.pp_approver_status == 'Approved' && jo_revision.pu_approver_status == 'Pending') {
					var email_pu_approver = emailApprover(user_emails, jo_revision.pu_approver, jo_revision.jo_id, jo_revision.id, jo.jo_number, jo_revision.model_no, jo_revision.model_name);
					if(email_pu_approver.status == true) {
						if(len(trim(jo_revision.pu_deputy)) != 0) {
							var email_pu_deputy = emailApprover(user_emails, jo_revision.pu_deputy, jo_revision.jo_id, jo_revision.id, jo.jo_number, jo_revision.model_no, jo_revision.model_name);
							if(email_pu_deputy.status == true) {
								flashInsert(success="Successfully approved JO!");
							}
							else {
								flashInsert(error="133 "&email_pu_deputy.message);
							}
						}
						else {
							flashInsert(success="Successfully approved JO!");
						}
					}
					else {
						flashInsert(error="137 "&email_pu_approver.message);
					}
				}
			}
		}
		else {
			flashInsert(error="Error in JO Approval.");
		}

		redirectTo(route="joEncodeRevision", encodeKey=jo_revision.jo_id, key=jo_revision.id);
	}

	function delete()
	{
		var jo_revision = model("jorevision").findByKey(params.key);
		var jo = model("jo").findByKey(jo_revision.jo_id);
		var user_email = model("login").findOne(select="hris_id, email", where="hris_id = #jo_revision.posted_by#");

		if(params.type == 'pp') {
			jo_revision.pp_evaluated_by = SESSION.jo.user_id;
			jo_revision.pp_evaluated_date = now();
			jo_revision.pp_approver_status = 'Disapproved';
			jo_revision.pp_approver_remarks = params.remarks;
		}
		else if(params.type == 'pu') {
			jo_revision.pu_evaluated_by = SESSION.jo.user_id;
			jo_revision.pu_evaluated_date = now();
			jo_revision.pu_approver_status = 'Disapproved';
			jo_revision.pu_approver_remarks = params.remarks;
		}
		
		jo_revision.status = "Returned";

		if(jo_revision.save() == true) {
			var email_returned = emailReturned(user_email.email, jo_revision.jo_id, jo_revision.id, jo.jo_number, jo_revision.model_no, jo_revision.model_name);
			if(email_returned.status == true) {
				flashInsert(success="Successfully processed request. JO is now returned.");
			}
			else {
				flashInsert(error=email_returned.message);
			}
		}
		else {
			flashInsert(error="Error processing request.");
		}

		redirectTo(route="joEncodeRevision", encodeKey=jo_revision.jo_id, key=jo_revision.id);
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
							<p>A new JO is prepared.</p>
							<p><b>JO Number</b>: #arguments.jo_no#</p>
							<p><b>Model</b>: #arguments.model_no# #arguments.model_name#</p>
							<p>Requesting for your approval.</p>
							<p><b>Division</b>: #getDivisionName()#</p>
							<p>#linkTo(route='joEncode', onlyPath=false, encodeKey=arguments.encodeKey, key=arguments.key, text='Click this Link')# to review the details of this JO.</p>
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
				  subject = "JO #arguments.jo_no#, Model #arguments.model_no# #arguments.model_name# - Approval",
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
				if(u == m.hris_id) {
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
							<p>#linkTo(route='joEncodeRevision', onlyPath=false, encodeKey=arguments.encodeKey, key=arguments.key, text='Click this Link')# to view the full information of the JO.</p>
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

	private function emailReturned(owner, encodeKey, key, jo_no, model_no, model_name)
	{
		try {
			var mailbody = "
				<html>
					<head>
						<style type='text/css'>h1{font-family:Verdana,Geneva,sans-serif;font-size:24px;font-style:normal;font-variant:normal;font-weight:700;line-height:26.4px}h3{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:700;line-height:15.4px}p{font-family:Verdana,Geneva,sans-serif;font-size:14px;font-style:normal;font-variant:normal;font-weight:400;line-height:20px}</style>
					</head>
					<body>
						<p>A JO for approval was returned.</p>
						<p><b>JO Number</b>: #arguments.jo_no#</p>
						<p><b>Model</b>: #arguments.model_no# #arguments.model_name#</p>
						<p><b>Division</b>: #getDivisionName()#</p>
						<p>#linkTo(route='joEncodeRevision', onlyPath=false, encodeKey=arguments.encodeKey, key=arguments.key, text='Click this Link')# to view the full information of the JO.</p>
						<p>Make sure you are logged in into the interface before you click the link to be able to go to the correct link. If you are redirected to the login page, proceed to login then click the link above again.</p>
						<br>
						<p>Thank you.</p>
						<br><br><br>
						<p>- System Generated Email</p>
					</body>
				</html>
			";
			var mailService = new mail(
			  to = arguments.owner,
			  from = "forms@nicera.ph",
			  subject = "JO #arguments.jo_no#, Model #arguments.model_no# #arguments.model_name# - Returned",
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