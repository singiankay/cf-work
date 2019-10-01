component displayname="MRP Alternative" extends="app.controllers.Controller"
{	

	function config() 
	{

		provides("html, json");
	
	}

	function index() 
	{
		var firstDay = createDate(year(params.month), month(params.month), 1 );
		var lastDay = dateAdd('d', -1, dateAdd('m', 7, firstDay ));

		var alternatives = model("materialalternative").findAll(select="tbl_erpx_alternatives.id, tbl_erpx_alternatives.production_schedule_id, tbl_erpx_alternatives.process_id, tbl_erpx_alternatives.bom_no, tbl_erpx_alternatives.alternative_no, tbl_erpx_alternatives.qty ", where="tbl_erpx_production_schedule.date >= '#firstDay#' AND tbl_erpx_production_schedule.date <= '#lastDay#' AND tbl_erpx_alternatives.is_active = 1", include="productionschedule");
		renderWith(alternatives);
	}

	function show() 
	{

	}

	function create()
	{

	}

	function update()
	{
		var errors = 0;
		transaction {
			try {
				for(p in params.data.process) {
					for(b in p.bom) {
						for(a in b.alt) {
							var isAlternative = model("materialalternative").findOne(where="production_schedule_id = #params.key# AND process_id = #p.process_no# AND bom_no = '#b.bom_item#' AND alternative_no = '#a.alt_item#' AND is_active = 1");
							if(isObject(isAlternative)) {
								var update = isAlternative.update(qty=a.alloc_qty, updated_by=params.user_id, transaction=false);
								if(!update) {
									errors ++;
								}
							}
							else {
								var create = model("materialalternative").new();
								create.production_schedule_id = params.key;
								create.process_id = p.process_no;
								create.bom_no = b.bom_item;
								create.alternative_no = a.alt_item;
								create.qty = a.alloc_qty;
								create.created_by = params.user_id;
								create.save(transaction=false);
								if(create.hasErrors()) {
									errors++;
								}
							}
						}
					}
				}
				if(errors > 0) {
					transaction action="rollback";
					renderWith({status:'error', message: ['Error updating data. Please check your records again']});
				}
				else {
					transaction action="commit";
					renderWith({status:'success', message: ['Successfully updated record.']});
				}
			}
			catch(any e) { 
				transaction action="rollback"; 
				renderWith({status:'error', message: [e.message,'Error updating data. Please check your records again']});
			} 
		}

	}

	function delete()
	{

	}

}