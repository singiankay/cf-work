component displayname="Sales Order" extends="app.controllers.Controller"
{	
	shipmentStatus = ["","Forecast","Balance","Shipped","Canceled","On Hold"];
	documentStatus = ["Drafted","Posted","Void"];

	function config() {

		provides("html,json");

	}
	
	function index() {

		if(structKeyExists(params, "orderBy")) {
			switch(params.orderBy) {
				case "so_number":
					params.orderBy = "so_no";
				break;
			}
		}
		else {
			params.orderBy = "id";
		}
		params.ascending = super.getOrderBy(params.ascending);
		var sqlOrderBy = params.orderBy&" "&params.ascending;

		if(LEN(Trim(params.query)) != 0) {
			var filterByCustomerName = model("customer").findAll(select="id",where="name LIKE '%#trim(params.query)#%' AND mail_address IS NOT NULL AND type = 'c'");
			var filteredCustomerID =  quotedValueList(filterByCustomerName.id);
			
			if(listLen(filteredCustomerID) > 0) {
				sqlCustomerIDSmt = "customer_id IN (#filteredCustomerID#) OR";
			}
			else {
				sqlCustomerIDSmt = "";
			}

			if(isNumeric(trim(params.query))) {
				var ordersQuery = model("salesorder").findAll(
					where="division='#params.division#' AND is_active = 1 AND (#sqlCustomerIDSmt# document_status LIKE '%#Trim(params.query)#%' OR so_no LIKE '%#trim(params.query)#%' OR shipment_status LIKE '%#Trim(params.query)#%' OR remarks LIKE '%#Trim(params.query)#%' OR id = '#trim(params.query)#')",
					page=params.page, 
					perPage=params.limit, 
					order=sqlOrderBy
				);
				var count = model("salesorder").count(
					where="division='#params.division#' AND is_active = 1 AND (#sqlCustomerIDSmt# document_status LIKE '%#Trim(params.query)#%' OR so_no LIKE '%#trim(params.query)#%' OR shipment_status LIKE '%#Trim(params.query)#%' OR remarks LIKE '%#Trim(params.query)#%' OR id = '#trim(params.query)#')"
				);
			}
			else {
				var ordersQuery = model("salesorder").findAll(
					where="division='#params.division#' AND is_active = 1 AND (#sqlCustomerIDSmt# document_status LIKE '%#Trim(params.query)#%' OR so_no LIKE '%#trim(params.query)#%' OR shipment_status LIKE '%#Trim(params.query)#%' OR remarks LIKE '%#Trim(params.query)#%')",
					page=params.page, 
					perPage=params.limit, 
					order=sqlOrderBy
				);
				var count = model("salesorder").count(
					where="division='#params.division#' AND is_active = 1 AND (#sqlCustomerIDSmt# document_status LIKE '%#Trim(params.query)#%' OR so_no LIKE '%#trim(params.query)#%' OR shipment_status LIKE '%#Trim(params.query)#%' OR remarks LIKE '%#Trim(params.query)#%')"
				);
			}
		}
		else {
			var ordersQuery = model("salesorder").findAll(
				where="division='#params.division#'",
				page=params.page, 
				perPage=params.limit, 
				order=sqlOrderBy
			);
			var count = model("salesorder").count(
				where="division='#params.division#'"
			);
		}

		if(listLen(ordersQuery.customer_id) > 0) {
			sqlCustomerNameSmt = "id IN (#quotedValueList(ordersQuery.customer_id)#) AND";
		}
		else {
			sqlCustomerNameSmt = "";
		}
		var customers = model("customer").findAll(select="id,name", where="#sqlCustomerNameSmt# type = 'c' AND mail_address IS NOT NULL");

		var result = [];

		for(orders in ordersQuery) {
			for(customer in customers) {
				if(customer.id == orders.customer_id) {
					var customer_name = customer.name;
				}
			}
			arrayAppend(result, {
				id: orders.id,
				so_number: orders.so_no, 
				so_date: DateFormat(orders.so_date, 'mmm dd, YYYY'), 
				customer_name: customer_name, 
				remarks: orders.remarks, 
				document_status: orders.document_status, 
				shipment_status: orders.shipment_status,
				total: count
			});
		}
		renderWith(result);
		
	}

	function show() {

		var SalesOrder = model("salesorder").findOne(where="id=#params.key#");
		var CustomerName = model("customer").findOne(select="name",where="id = '#SalesOrder.customer_id#'");

		var result = {
			division: SalesOrder.division,
			id: SalesOrder.id,
			so_number: SalesOrder.so_no, 
			so_date: DateFormat(SalesOrder.so_date, 'mmm dd, YYYY'), 
			customer_id: SalesOrder.customer_id,
			customer_name: CustomerName.name, 
			remarks: SalesOrder.remarks, 
			document_status: SalesOrder.document_status, 
			shipment_status: SalesOrder.shipment_status
		};
		renderWith(result);
		
	}

	function create() {
		
		var proceed = 0;
		if(Len(Trim(params.form.so_no))) {
			var soChecker = model("salesorder").count(where="so_no = '#params.form.so_no#' AND division = '#params.division#' AND is_active = 1 AND document_status = 'Posted'");
			if(!soChecker) {
				proceed = 1;
			}
		}
		else {
			proceed = 1;
		}

		if(proceed == 1) {
			var salesorder = model("salesorder").new();
			salesorder.division = params.division;
			salesorder.is_active = 1;
			salesorder.created_by = params.created_by;
			salesorder.so_no = params.form.so_no;
			salesorder.customer_id = params.form.customer.id;
			salesorder.so_date = params.form.date;
			salesorder.remarks = params.form.remarks;
			salesorder.document_status = "Posted";
			salesorder.save();

			if(salesorder.hasErrors()) {
				renderWith({ status:"error", message: super.getErrorList(salesorder.allErrors()) });
			}
			else {  
				renderWith({status:'success', message: ['Successfully Created a New Sales Order SO No. is #salesorder.id#'], id: salesorder.id  });
			}
		}
		else {
			renderWith({status:'error', message: ['Sales order number is already used']  });
		}		

	}

	function update() {

		var proceed = false;
		if(Len(Trim(params.form.so_no))) {
			var soChecking = model("salesorder").findOne(where="so_no = '#params.form.so_no#' AND division = '#params.division#' AND is_active = 1 AND document_status = 'Posted'");
			if(soChecking.id == params.key) {
				proceed = true;
			}
			else {
				renderWith({status:'error', message: ['Sales order number is already used']  });
			}
		}
		else {
			proceed = true;
		}
		if(proceed == true) {
			var salesOrder = model("salesorder").findByKey(params.key);
			switch(params.document_action) {
				case 'update':
					var update = salesOrder.update(
						so_no = Trim(params.form.so_no),
						so_date = params.form.date, 
						customer_id = params.form.customer.id, 
						remarks = params.form.remarks,
						shipment_status = params.form.shipment_status,
						updated_by = params.updated_by
					);
					var updateAction = "updated";
				break;
			}

			if(update) {
				if(Len(Trim(params.form.so_no))) {
					renderWith({
						status: 'success',
						message: ['Successfully #updateAction# sales order no #params.form.so_no#.']
					});
				}
				else {
					renderWith({
						status: 'success',
						message: ['Successfully #updateAction# sakes irder.']
					});
				}
			}
			else {
				renderWith({ status:"error", message: super.getErrorList(salesOrder.allErrors()) });
			}
		}

	}

	function delete() {

		var salesOrder = model("salesorder").findByKey(params.key);
		var delete = salesOrder.update(document_status="Void", updated_by = params.updated_by);

		if(delete) {
			renderWith({status:'success', message: ['Successfully voided sales order no. #params.key#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(salesOrder.allErrors()) });
		}

	}

	function getCustomers() {
		
		var customerNameSearch = model("customer").findAll(select="id, name", where="name LIKE '%#trim(params.q)#%' AND mail_address IS NOT NULL AND type = 'c'", orderBy="name ASC");
		renderWith(customerNameSearch);

	}

	function getShipmentStatus() {

		renderWith(shipmentStatus);

	}

}