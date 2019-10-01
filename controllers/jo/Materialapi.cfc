component displayname="JO Material API" extends="app.controllers.Controller"
{
	title = "JO - Material Api";
	
	function config()
	{
		provides("html, json");
	}

	function index()
	{

	}

	function show()
	{
		var mats = model("jomaterial").findAll(select="id, jo_id, revision_id, assortment, material_no, material_name, material_class, material_classname, material_type, bom, qty_required, yield_rate, rm_inventory, wip, remaining_rm_inventory, lacking_qty, material_for_request", where="revision_id = #params.key# AND is_active = 1", order="assortment", returnAs="objects");
		var assortment = [];
		var materials = [];

		for(var m in mats) {
			if(arrayFind(assortment, m.assortment) == 0) {
				assortment.append(m.assortment);
			}
		}

		for(var a in assortment) {
			for(var m in mats) {
				if(m.assortment == a && m.material_type == "Primary") {
					materials.append({
						id: m.id,
						jo_id: m.jo_id,
						assortment: m.assortment,
						material_no: m.material_no,
						material_name: m.material_name,
						material_class: m.material_class,
						material_classname: m.material_classname,
						material_type: m.material_type,
						bom: m.bom,
						qty_required: m.qty_required,
						yield_rate: m.yield_rate,
						rm_inventory: m.rm_inventory,
						wip: m.wip,
						remaining_rm_inventory: m.remaining_rm_inventory,
						lacking_qty: m.lacking_qty,
						material_for_request: m.material_for_request,
						alternatives: setAlternatives(mats, m.assortment)
					});
				}
			}
		}

		renderWith(materials);
	}

	private function setAlternatives(mats, assortment)
	{
		var alts = [];
		for(var m in arguments.mats) {
			if(arguments.assortment == m.assortment && m.material_type == "Alternative") {
				alts.append({
					id: m.id,
					material_no: m.material_no,
					material_name: m.material_name,
					material_class: m.material_class,
					material_classname: m.material_classname,
					material_type: m.material_type,
					rm_inventory: m.rm_inventory,
					wip: m.wip,
					remaining_rm_inventory: m.remaining_rm_inventory
				});
			}
		}
		return alts;
	}

	function create()
	{
		var jo = model("jorevision").findByKey(params.id);
		var update = model("jorevision").updateByKey(key=params.id, batch_no = params.batch_no, remarks = params.remarks, include_chemicals = (params.include_chemicals == true ? 1 : 0 ));
		if(update == true) {
			var delete = model("jomaterial").deleteAll(where="revision_id=#params.id#");
			var errorCounter = 0;
			var errorMessage = [];
			
			if(isObject(jo)) {
				transaction {
					try {
						for(var i = 1; i <= arrayLen(params.materials); i++) {
							var jomaterial = model("jomaterial").new();
							jomaterial.revision_id = jo.id;
							jomaterial.jo_id = jo.jo_id;
							jomaterial.assortment = i;
							jomaterial.bom = sixDecimalFormat(params.materials[i].bom);
							jomaterial.lacking_qty = fourDecimalFormat(params.materials[i].lacking_qty);
							jomaterial.material_no = params.materials[i].material_no;
							jomaterial.material_name = params.materials[i].material_name;
							jomaterial.material_class = params.materials[i].classification;
							jomaterial.material_classname = params.materials[i].classification_name;
							jomaterial.material_type = "Primary";
							jomaterial.qty_required = fourDecimalFormat(params.materials[i].qty_required);
							jomaterial.remaining_rm_inventory = fourDecimalFormat(params.materials[i].remaining_rm_inventory);
							jomaterial.rm_inventory = fourDecimalFormat(params.materials[i].rm_inventory);
							jomaterial.wip = fourDecimalFormat(params.materials[i].wip);
							jomaterial.yield_rate = params.materials[i].yield_rate;
							jomaterial.material_for_request = fourDecimalFormat(params.materials[i].material_for_request);
							jomaterial.is_active = 1;
							jomaterial.created_by = SESSION.jo.user_id;
							jomaterial.updated_by = SESSION.jo.user_id;
							var save_material = jomaterial.save(transaction = false);
							
							if(save_material == false) {
								errorCounter++;
								errorMessage.append(jomaterial.allErrors());
							}
							
							for(var a = 1; a <= arrayLen(params.materials[i].alt); a++) {
								var joalt = model("jomaterial").new();
								joalt.revision_id = jo.id;
								joalt.jo_id = jo.jo_id;
								joalt.assortment = i;
								joalt.bom = 0;
								joalt.lacking_qty = 0;
								joalt.material_no = params.materials[i].alt[a].material_no;
								joalt.material_name = params.materials[i].alt[a].material_name;
								joalt.material_class = params.materials[i].alt[a].classification;
								joalt.material_classname = params.materials[i].alt[a].classification_name;
								joalt.material_type = "Alternative";
								joalt.qty_required = 0;
								joalt.remaining_rm_inventory = fourDecimalFormat(params.materials[i].alt[a].remaining_rm_inventory);
								joalt.rm_inventory = fourDecimalFormat(params.materials[i].alt[a].rm_inventory);
								joalt.wip = fourDecimalFormat(params.materials[i].alt[a].wip);
								joalt.yield_rate = 0;
								joalt.material_for_request = 0;
								joalt.is_active = 1;
								joalt.created_by = SESSION.jo.user_id;
								joalt.updated_by = SESSION.jo.user_id;
								var save_alt = joalt.save(transaction = false);

								if(save_alt == false) {
									errorCounter++;
									errorMessage.append(joalt.allErrors());
								}
							}

						}

						if(errorCounter > 0) {
							transaction action="rollback";
						}
						else {
							transaction action="commit";

						}
					}
					catch(any e) {
						transaction action="rollback";
						errorCounter++;
						errorMessage.append({ MESSAGE: e });
					}
				}
				renderWith({
					status: (errorCounter > 0 ? false : true),
					message: errorMessage
				});
			}
			else {
				renderWith({
					status: false,
					message: [{ MESSAGE: "Model revision not found!" }]
				});
			}
		}
		else {
			renderWith({
				status: false,
				message: [{ MESSAGE: "Error updating revision details!" }]
			});
		}
	}

	function update()
	{

	}

	function delete()
	{

	}


}