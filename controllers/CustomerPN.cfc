component displayname="Customer PN" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

		if(structKeyExists(params, "orderBy")) {
			switch(params.orderBy) {
				case "code":
					params.orderBy = "CardCode";
				break;
				case "name":
					params.orderBy = "CardName";
				break;
			}
		}
		else {
			params.orderBy = "CardName";
		}

		params.ascending = super.getOrderBy(params.ascending);
		var sqlOrderBy = params.orderBy&" "&params.ascending;

		try {

			var sqlCount = new Query();
			sqlCount.setDatasource(sapdb);
			sqlCount.setSQL("
				SELECT COUNT(CardName) AS CardCount
				  FROM dbo.OCRD 
				 WHERE CardName LIKE :query 
				   AND CardType = 'c'
				   AND MailAddres IS NOT NULL 
			");
			sqlCount.addParam(name="query", value="%#params.query#%", CFSQLTYPE="CF_SQL_VARCHAR");
			var resultCount = sqlCount.execute().getResult();

			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT * 
				  FROM ( 
				  	    SELECT ROW_NUMBER() OVER ( ORDER BY #sqlOrderBy# ) AS RowNum, CardCode, CardName, MailAddres 
				         FROM dbo.OCRD
				        WHERE CardName LIKE :query 
				          AND CardType = 'c'
				          AND MailAddres IS NOT NULL
				        ) AS RowConstrainedResult
				 WHERE RowNum > (:page * :perPage) - :perPage 
				   AND RowNum <= (:perPage * :page)
				 ORDER BY #sqlOrderBy#
			");
			sqlQuery.addParam(name="query", value="%#params.query#%", CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="page", value=params.page, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="perPage", value=params.limit, CFSQLTYPE="CF_SQL_INTEGER");
			var resultset = sqlQuery.execute().getResult();
		}
		catch (customExcp e) {
		    renderWith({ status:'error', message: e });
		}

		renderWith({
			data: resultset,
			total: resultCount.CardCount
		});

	
		
		// if(structKeyExists(params, "orderBy")) {
		// 	switch(params.orderBy) {
		// 		case "id":
		// 			params.orderBy = "id";
		// 		case "name":
		// 			params.orderBy = "name";
		// 		break;
		// 	}
		// }
		// else {
		// 	params.orderBy = "name";
		// }
		// params.ascending = super.getOrderBy(params.ascending);
		// var sqlOrderBy = params.orderBy&" "&params.ascending;
		
		// var customers = model("customer").findAll(
		// 	select = "id, name, type, mail_address", 
		// 	where = "name LIKE '%#params.query#%' AND type = 'c' AND mail_address IS NOT NULL", 
		// 	page = params.page, 
		// 	perPage = params.limit, 
		// 	order = sqlOrderBy
		// );
		// 
		// renderWith(model("customer").primaryKey());

		// renderWith(customers);
		
		// var customers = model("customer").findAll(
		// 	select = "id, name, type, mail_address", 
		// 	where = "name LIKE '%#params.query#%' AND type = 'c' AND mail_address IS NOT NULL"
		// );;
		// renderWith(customers);


		
		
		// if(Len(Trim(params.query)) != 0) {

		// }
		// else {
		// 	var customers = model("customer").findAll(
		// 		select="id, name, type, mail_address",
		// 		page=params.page, 
		// 		perPage=params.limit, 
		// 		order=sqlOrderBy
		// 	);
		// }

	}

	function show() {
		var cm = [];
		var customerModels = model("customerpn").findAll(where="customer_code = '#params.key#'");
		if(customerModels.recordCount) {
			var modelIDs = quotedValueList(customerModels.model_id);
			var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelIDs#)");

			for(models in customerModels) {
				for(names in modelNames) {
					if(models.model_id == names.ItemCode) {
						arrayAppend(cm, {
							id: models.id,
							model_no: models.model_id,
							model_name: names.ItemName,
							customer_pn: models.customer_pn
						});
					}
				}
			}

		}

		renderWith(cm);

	}

	function create() {

		var create = model("customerpn").new();
		create.model_id = params.form.model.id;
		create.customer_code = params.customer_pn;
		create.customer_pn = params.form.customer_pn;
		create.save();

		if(create.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(create.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully saved data.']});
		}

	}

	function update() {

		var update = model("customerpn").updateByKey(key=params.key, model_id=params.form.model.id, customer_pn=params.form.customer_pn);
			
		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated data'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(update.allErrors()) });
		}

	}

	function delete() {

		var delete = model("customerpn").deleteByKey(params.key);

		if(delete) {
			renderWith({status:'success', message: ['Successfully deleted data'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(delete.allErrors()) });
		}

	}

	function getCustomerPN() {

		var customerpn = model("customerpn").findByKey(key=params.id, returnAs="query");
		if(customerpn.recordCount) {
			var name = model("productname").findOne(select="ItemName", where="ItemCode = '#customerpn.model_id#'");
		}
		renderWith({
			id: customerpn.id,
			model: {
				id: customerpn.model_id,
				text: name.ItemName
			},
			customer_code: customerpn.customer_code,
			customer_pn: customerpn.customer_pn,
			date_created: customerpn.date_created,
			date_updated: customerpn.date_updated
		});
	
	}

	function getCustomerPNData() {
		var customerpn = model("customerpn").findOne(where="customer_code = '#params.customer_id#' AND model_id = '#params.model#' ");
		renderWith(customerpn);
	}

}