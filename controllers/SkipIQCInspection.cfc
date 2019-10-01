component displayname="Skip IQC" extends="app.controllers.Controller"
{	

	function config() {

		provides("html, json");

	}

	function index() {

		var result = [];
		var materials = model("skipiqcinspection").findAll(where="division='#params.division#'");

		if(materials.recordCount) {
			var matNos = QuotedValueList(materials.material_no);
			var matNames = model("productname").findAll(select="ItemCode,ItemName",where="ItemCode IN (#matNos#)");

			for(mat in materials) {
				for(name in matNames) {
					if(mat.material_no == name.ItemCode) {
						arrayAppend(result, {
							id: mat.id,
							division: mat.division,
							material_no: mat.material_no,
							material_name: name.ItemName,
							is_active: mat.is_active
						});
					}
				}
			}

		}
		renderWith(result);

	}

	function show() {

		var skipiqcinspection = model("skipiqcinspection").findbyKey(key=params.key, returnAs="query");
		if(skipiqcinspection.recordCount) {
			var productname = model("productname").findOne(select="ItemCode, ItemName",where="ItemCode = '#skipiqcinspection.material_no#'");
			renderWith({
				material_no: skipiqcinspection.material_no,
				material_name: productname.ItemName
			});
		}
		else {
			renderWith([]);
		}

	}

	function create() {

		var create = model("skipiqcinspection").new();
		create.division = params.division;
		create.material_no = params.form.id;
		create.is_active = 1;
		create.save();

		if(create.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(create.allErrors()) });
		}
		else {  
			renderWith({status:'success', message: ['Successfully saved #params.form.text#']});
		}

	}

	function update() {

		var update = model("skipiqcinspection").updateByKey(key=params.key, material_no=params.form.id);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated data '] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(update.allErrors()) });
		}

	}

	function delete() {

		var delete = model("skipiqcinspection").deleteByKey(params.key);

		if(delete) {
			renderWith({status:'success', message: ['Successfully deleted data'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(delete.allErrors()) });
		}

	}

	function getCustomerPN() {
	}

}