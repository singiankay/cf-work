component displayname="Production Schedule" extends="app.controllers.Controller"
{

	function config() {
		provides("html,json");
	}

	function index() {
		
		var productionSchedules = model("salesorderline").findOne(where="id = #params.so_line_id#", include="productionschedules", joinType="outer");
		renderWith(productionSchedules);

	}

	function show() {

		var schedule = model("productionschedule").findByKey(params.key);
		var user =getUser(schedule.updated_by);
		renderWith({
			id: schedule.id,
			so_line_id: schedule.so_line_id,
			date: schedule.date,
			date_created: schedule.date_created,
			date_updated: schedule.date_updated,
			updated_by: getUser(schedule.updated_by),
			qty: schedule.qty,
			remarks: schedule.remarks,
			so_line_id: schedule.so_line_id
		});

	}

	function create() {

		var create = model("productionschedule").new();
		create.so_line_id = params.so_line_id;
		create.date = params.form.date;
		create.qty = params.form.qty;
		create.remarks = params.form.remarks;
		create.encoded_by = params.user_id;
		create.updated_by = params.user_id;
		create.save();

		if(create.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(create.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully Created a Production Schedule for  SO Line No. #params.so_line_id#']});
		}

	}

	function update() {

		var line = model("productionschedule").findByKey(params.form.id);
		update = line.update(date=DateFormat( params.form.date, 'mmm dd, YYYY'), qty=params.form.qty, remarks=params.form.remarks, updated_by=params.user_id);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated Production Schedule No. #params.form.id#'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(line.allErrors()) });
		}

	}

	function delete() {

		var schedule = model("productionschedule").findByKey(params.key);
		var delete = schedule.delete();

		if(delete) {
			renderWith({status:'success', message: ['Successfully deleted Production Schedule No. #params.key#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(schedule.allErrors()) });
		}

	}

	function getUser(user_id) {

		var user = model("hrisemployee").findone(select="fullname", where="id = #arguments.user_id#");
		return user.fullname;

	}
}