component displayname="JO Encode Show API" extends="app.controllers.Controller"
{
	title = "JO - Encode Show API";
	
	function config()
	{
		provides("html, json");
	}

	function index()
	{

	}

	function show()
	{
		var jorevision = model("jorevision").findByKey(params.key);
		var jo = model("jo").findByKey(select="", key=jorevision.jo_id);
		var user_ids = "";
		user_ids = listAppend(user_ids, jorevision.pp_evaluated_by);
		user_ids = listAppend(user_ids, jorevision.pp_approver);
		user_ids = listAppend(user_ids, jorevision.pp_deputy);	
		user_ids = listAppend(user_ids, jorevision.pu_evaluated_by);
		user_ids = listAppend(user_ids, jorevision.pu_approver);
		user_ids = listAppend(user_ids, jorevision.pu_deputy);
		user_ids = listAppend(user_ids, jorevision.posted_by);
		user_ids =listRemoveDuplicates(user_ids);

		if(listLen(user_ids) > 0) {
			var names = model("hrisemployee").findAll(select="id, fullname", where="id IN (#user_ids#)");
		}
		else {
			var names = model("hrisemployee").findAll(select="id, fullname", where="id = 0");
		}

		renderWith({
			jo: jo,
			jo_revision: {
				id: jorevision.id,
				jo_id: jorevision.jo_id,
				revision_no: jorevision.revision_no,
				designation: jorevision.designation,
				jo_type: deserializeJSON(jorevision.type),
				jo_reference: jorevision.jo_reference,
				sa_no: jorevision.sa_no,
				fourm_change: jorevision.fourm_change,
				sixm_change: jorevision.sixm_change,
				model_no: jorevision.model_no,
				model_name: jorevision.model_name,
				lot_code: jorevision.lot_code,
				qty_to_produce: jorevision.qty_to_produce,
				total_shipment_qty: jorevision.total_shipment_qty,
				production_month: jorevision.production_month,
				requested_start_date: jorevision.requested_start_date,
				requested_end_date: jorevision.requested_end_date,
				remarks: jorevision.remarks,
				cancel_remarks: jorevision.cancel_remarks,
				batch_no: jorevision.batch_no,
				include_chemicals: jorevision.include_chemicals,
				status: jorevision.status,
				pp_evaluated_by: getName(names, jorevision.pp_evaluated_by),
				pp_evaluated_date: jorevision.pp_evaluated_date,
				pp_approver: getName(names, jorevision.pp_approver),
				pp_approver_id: jorevision.pp_approver,
				pp_deputy: getName(names, jorevision.pp_deputy),
				pp_deputy_id: jorevision.pp_deputy,
				pp_approver_status: jorevision.pp_approver_status,
				pp_approver_remarks: jorevision.pp_approver_remarks,
				pu_evaluated_by: getName(names, jorevision.pu_evaluated_by),
				pu_evaluated_date: jorevision.pu_evaluated_date,
				pu_approver: getName(names, jorevision.pu_approver),
				pu_approver_id: jorevision.pu_approver,
				pu_deputy: getName(names, jorevision.pu_deputy),
				pu_deputy_id: jorevision.pu_deputy,
				pu_approver_status: jorevision.pu_approver_status,
				pu_approver_remarks: jorevision.pu_approver_remarks,
				posted_by: getName(names, jorevision.posted_by),
				posted_by_id: jorevision.posted_by,
				document_date: jorevision.document_date
			}
		});
	}

	private function getName(names, name)
	{
		for(var n in arguments.names) {
			if(n.id == arguments.name) {
				return n.fullname;
			}
		}
		return "";
	}
}