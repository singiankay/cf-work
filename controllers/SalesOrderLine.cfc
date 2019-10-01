component displayname="Sales Order Line" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

		var salesOrderLines = model("salesorderline").findAll(where="so_id='#params.salesOrderKey#' AND is_active = 1");
		var customerIDs = ListQualify(valueList(salesOrderLines.customer_id),"'");
		var modelNames = ListQualify(valueList(salesOrderLines.model_id),"'");
		
		if(ListLen(modelNames) && ListLen(customerIDs)) {
			var customerNames = model("customer").findAll(select="id, name", where="id IN (#customerIDs#)");
			var productNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#quotedValueList(salesOrderLines.model_id)#)");
			var lines = [];

			for(soline in salesOrderLines) {
				ArrayAppend(lines, {
					id: soline.id,
					so_id: soline.so_id,
					area: soLine.area,
					model_id: soline.model_id,
					model_name: getModelName(productnames, soline.model_id),
					qty: soline.qty,
					customer_id: soline.customer_id,
					customer_name: getCustomerName(customerNames, soline.customer_id),
					customer_pn: soline.customer_pn,
					customer_pn: soline.customer_po,
					requested_delivery_date: DateFormat( soline.requested_delivery_date, 'mmm dd, YYYY'), 
					confirmed_date: DateFormat( soline.confirmed_date, 'mmm dd, YYYY'), 
					remarks: soline.remarks
				});
			}
			renderWith(lines);
		}
		else {
			renderWith([]);
		}

	}

	function show() {

		var salesorderline = model("salesorderline").findByKey(#params.key#);
		var customer = model("customer").findOne(select="id, name",where="id = '#salesorderline.customer_id#'");
		var name = model("productname").findOne(select="ItemName",where="ItemCode = '#salesorderline.model_id#'");
		var show = {
			model: {
				id: salesorderline.model_id,
				text: name.ItemName
			},
			customer: {
				id: salesorderline.customer_id,
				text: customer.name
			},
			area: salesorderline.area,
			qty: salesorderline.qty,
			customer_pn: salesorderline.customer_pn,
			customer_po: salesorderline.customer_po,
			requested_delivery_date: salesorderline.requested_delivery_date,
			confirmed_date: salesorderline.confirmed_date,
			remarks: salesorderline.remarks
		};
		renderWith(show);

	}

	function create() {

		var create = model("salesorderline").new();
		create.so_id = params.salesOrderKey;
		create.area = super.getArea(params.form.area);
		create.model_id = params.form.model.id;
		create.customer_id = params.form.customer.id;
		create.qty = params.form.qty;
		create.customer_pn = params.form.customer_pn;
		create.customer_po = params.form.customer_po;
		create.requested_delivery_date = params.form.requested_delivery_date;
		create.confirmed_date = params.form.confirmed_date;
		create.remarks = params.form.remarks;
		create.save();

		if(create.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(create.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully Created a Line in SO No. #params.salesOrderKey#']});
		}

	}

	function update() {

		var update = model("salesorderline").updateByKey(key=params.key, area=super.getArea(params.form.area), model_id=params.form.model.id, customer_id=params.form.customer.id, qty=params.form.qty, customer_pn=params.form.customer_pn, customer_po=params.form.customer_po, requested_delivery_date=params.form.requested_delivery_date, confirmed_date=params.form.confirmed_date, remarks=params.form.remarks);
		
		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated Sales Order No. #params.salesOrderKey# on Model #params.old.model.id# #params.old.model.text#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(update.allErrors()) });
		}

	}

	function delete() {

		var line = model("salesorderline").findByKey(params.key);
		var delete = line.update(is_active=0);
		
		var formModel = deserializeJSON(params.form);
		if(isObject(line)) {
			if(delete == true) {
				renderWith({status:'success', message: ['Successfully deleted Sales Order on Model #formModel.model.id# #formModel.model.text#.'] });
			}
			else {
				renderWith({ status:"error", message: super.getErrorList(delete.allErrors()) });
			}
		}
		else {
			renderWith({ status:"error", message: ['Error deleting. Line Cannot be found'] });
		}
		
	}

	function getCustomer() {

		var customer = model("customer").findOne(select="id, name",where="id = '#params.customer_id#'");
		renderWith({
			id: customer.id,
			name: customer.name
		});

	}

	function getCustomerName(customers, id) {

		for(customer in arguments.customers) {
			if(customer.id == arguments.id) {
				return customer.name;
			}
		}
		return false;

	}

	function getModelName(models, id) {

		for(model in arguments.models) {
			if(model.ItemCode == arguments.id) {
				return model.ItemName;
			}
		}
		return false;

	}

}