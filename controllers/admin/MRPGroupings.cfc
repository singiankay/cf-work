component displayname="MRP" extends="app.controllers.Controller"
{

	MaterialTypes = ["Materials", "Chemicals", "Packaging Materials", "Finished Goods"];

	function config() {

		provides("html,json");

	}

	function getDivisions()
	{
		var divisions = super.getDivisions();
		renderWith(divisions);
	}

	function getAreas()
	{
		var areas = super.getAreas(params.division);
		renderWith(areas);	
	}

	function index()
	{
		if(structKeyExists(params, "orderBy")) { 
			switch(params.orderBy) {
				case "code":
					params.orderBy = "code";
				break;
				case "divisionName":
					params.orderBy = "division";
				break;
				case "groupType":
					params.orderBy = "type";
				break;
			}
		}
		else {
			var params.orderBy = "id";
		}
		var params.ascending = super.getOrderBy(params.ascending);
		var sqlOrderBy = params.orderBy&" "&params.ascending;

		var MaterialGroupNames = model("sapmaterialgroupings").findAll(select="id,name", returnAs="objects");
		var divisionNames = model("division").findAll(select="code, name, id, product_line");
		var div = '';
		var nameID = '';

		if(len(trim(params.query)) > 0) {
			for(division in divisionNames) {
				if(division.code == trim(params.query)) {
					var div = division.id;
				}
			}
			for(sapgroupings in MaterialGroupNames) {
				if(findNoCase(trim(params.query), sapgroupings.name) > 0) {
					var nameID = sapgroupings.id;
				}
			}
		}

		if(isNumeric(trim(params.query))) {
			var MaterialGroups = model("materialgroupings").findAll(
				where="id = '#params.query#' OR code LIKE '%#params.query#%' OR code = '#nameID#' OR type LIKE '%#params.query#%' OR division = '#div#'", 
				page=params.page, 
				perPage=params.limit, 
				order=sqlOrderBy
			);
			var count = model("materialgroupings").count(
				where="id = '#params.query#' OR code LIKE '%#params.query#%' OR code = '#nameID#' OR type LIKE '%#params.query#%' OR division = '#div#'"
			);
		}
		else {
			var MaterialGroups = model("materialgroupings").findAll(
				where="code LIKE '%#params.query#%' OR type LIKE '%#params.query#%' OR code = '#nameID#' OR division = '#div#'", 
				page=params.page, 
				perPage=params.limit, 
				order=sqlOrderBy
			);
			var count = model("materialgroupings").count(
				where="code LIKE '%#params.query#%' OR type LIKE '%#params.query#%' OR code = '#nameID#' OR division = '#div#'"
			);
		}

		var resultset = [];
		for(mg in MaterialGroups) {
			for(dn in divisionNames) {
				if(dn.id == mg.division) {
					var resultDivisionName = dn.code;
				}
			}
			for(mgn in MaterialGroupNames) {
				if(mgn.id == mg.code) {
					var resultMaterialGroupName = mgn.name;
				}
			}
			arrayAppend(resultset, {
				id: mg.id,
				code: mg.code,
				division: mg.division,
				groupType: mg.type,
				divisionName: resultDivisionName,
				groupName: resultMaterialGroupName,
				total: count
			});
		}
		
		renderWith(resultset);
	}

	function show()
	{
		var materialGroup = model("materialgroupings").findByKey(params.key);
		var sapMaterialGroup = model("sapmaterialgroupings").findOne(select="id, name, product_line", where="id='#materialGroup.code#'", returnAs="objects");
		var resultset = {
			name: sapMaterialGroup.name,
			code: materialGroup.code,
			division: materialGroup.division,
			id: materialGroup.id,
			type: materialGroup.type
		};

		renderWith(resultset);
	}

	function create()
	{
		var groupings = model("materialgroupings").new();
		groupings.code = params.form.code;
		groupings.division = params.form.division;
		groupings.type = params.form.type;
		groupings.save();

		if(groupings.hasErrors()) {
			renderWith({ status:"error", message: super.getErrorList(groupings.allErrors()) });
		}
		else {
			renderWith({status:'success', message: ['Successfully created #params.form.name#.'] });
		}
	}

	function update()
	{
		var materialGroup = model("materialgroupings").findByKey(params.key);
		var update = materialGroup.update(code = params.form.code, division = params.form.division, type = params.form.type);

		if(update == true) {
			renderWith({status:'success', message: ['Successfully updated #params.form.name#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(materialGroup.allErrors()) });
		}
	}

	function delete()
	{
		var materialGroup = model("materialgroupings").findByKey(params.key);
		var delete = materialGroup.delete();
		if(delete) {
			renderWith({status:'success', message: ['Successfully deleted #params.name#.'] });
		}
		else {
			renderWith({ status:"error", message: super.getErrorList(materialGroup.allErrors()) });
		}
	}

	function getMaterialTypes()
	{
		renderWith(MaterialTypes);
	}

	function getSAPMaterialGroups()
	{
		if(isNumeric(params.q)) {
			var SAPMaterialGroups = model("sapmaterialgroupings").findAll(select="id, name, product_line", where="name LIKE '%#params.q#%' OR id = '#params.q#'", returnAs="objects");
		}
		else {
			var SAPMaterialGroups = model("sapmaterialgroupings").findAll(select="id, name, product_line", where="name LIKE '%#params.q#%'", returnAs="objects");
		}
		
		renderWith(SAPMaterialGroups);
	}

	function getSAPMaterialGroupByID()
	{
		var SAPMaterialGroup = model("sapmaterialgroupings").findOne(select="id, name, product_line", where="id='#params.id#'", returnAs="objects");
		renderWith(SAPMaterialGroup);
	}

}