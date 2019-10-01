component displayname="RM Report - Summary" extends="app.controllers.Controller"
{
	title = "RM Report - Summary";
	divisions = super.getDivisions();

	function config()
	{
		filters(through="restrictAccess");
		usesLayout(template="/rmreport/layout");
		provides("html, json");
	}

	function index()
	{
		if(SESSION.rmreport.division == 1) {
			param name="params.search.area" default= 0;
		}
		else {
			param name="params.search.area" default= -1;
		}

		controllerJS = "rmreport/rmsummary_index";
		var getArea = super.getAreas(SESSION.rmreport.division);

		areas = [{ id: 0 , area: 'All'}];
		for(a in getArea) {
			areas.append({ id: a.id, area: a.area });
		}
		search = model("rmreportsummary").new(argumentCollection=params.search);
		isSearch = search.getSummary();

		if (!isSearch) {
			flashInsert(error="There was an error with your search filters");
		}
	}

	function generate()
	{
		if(SESSION.rmreport.division == 1) {
			param name="params.search.area" default= 0;
		}
		else {
			param name="params.search.area" default= -1;
		}

		var getArea = super.getAreas(SESSION.rmreport.division);

		areas = [{ id: 0 , area: 'All'}];
		for(a in getArea) {
			areas.append({ id: a.id, area: a.area });
		}
		search = model("rmreportsummary").new(argumentCollection=params.search);
		isSearch = search.getSummary();
		if (!isSearch) {
			flashInsert(error="There was an error with your search filters");
		}
		else {
			var spreadsheetObj = spreadsheetNew('RM Inventory Summary');
			spreadsheetAddFreezePane(spreadsheetObj, 0, 3);
			SpreadSheetAddAutofilter(Spreadsheetobj, "A3:F3");

			spreadsheetAddRow(spreadsheetObj, 'RM Inventory Summary');
			spreadsheetSetCellValue(spreadsheetObj, 'Generated Last', 2, 1);
			spreadsheetSetCellValue(spreadsheetObj, #dateFormat(now(), 'm/d/yyyy')#, 2, 4);
			spreadsheetMergeCells(spreadsheetObj, 1, 1, 1, 3);
			spreadsheetMergeCells(spreadsheetObj, 2, 2, 1, 3);
			SpreadsheetformatCell(spreadsheetObj,{bold=true,alignment='left'},1,1);
			SpreadsheetformatCell(spreadsheetObj,{bold=true,alignment='left'},2,1);
			SpreadsheetformatCell(spreadsheetObj,{dataformat='m/d/yyyy'},2,4);
			var headerList = "Area,Material No,Material Name,Classification,Material Type,Qty Balance";
			spreadsheetAddRow(spreadsheetObj, headerList);
			spreadsheetformatrow(spreadsheetObj,{ bold=true, alignment='center_selection', textwrap=true },3);
			spreadsheetSetRowHeight(spreadsheetObj, 4, 24);

			for(var row in search.result) {
				spreadsheetSetCellValue(spreadsheetObj, row.area, search.result.currentRow+3, 1);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.result.currentRow+3, 1);
				spreadsheetSetCellValue(spreadsheetObj, row.material_no, search.result.currentRow+3, 2);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.result.currentRow+3, 2);
				spreadsheetSetCellValue(spreadsheetObj, row.material_name, search.result.currentRow+3, 3);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.result.currentRow+3, 3);
				spreadsheetSetCellValue(spreadsheetObj, row.classification, search.result.currentRow+3, 4);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.result.currentRow+3, 4);
				spreadsheetSetCellValue(spreadsheetObj, row.material_type, search.result.currentRow+3, 5);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.result.currentRow+3, 5);
				spreadsheetSetCellValue(spreadsheetObj, row.qty_balance, search.result.currentRow+3, 6);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.result.currentRow+3, 6);
			}
			spreadsheetSetColumnWidth(spreadsheetObj, 1, 14);
			spreadsheetSetColumnWidth(spreadsheetObj, 2, 14);
			spreadsheetSetColumnWidth(spreadsheetObj, 3, 48);
			spreadsheetSetColumnWidth(spreadsheetObj, 4, 20);
			spreadsheetSetColumnWidth(spreadsheetObj, 5, 18);
			spreadsheetSetColumnWidth(spreadsheetObj, 6, 14);

			cfheader(name="Content-Disposition", value="inline; filename=rmbalance.xls");
			cfcontent(type="application/vnd.ms-excel", variable="#SpreadSheetReadBinary(spreadsheetObj)#");
		}


	}

	function isAdmin()
	{
		if(structKeyExists(SESSION.rmreport, "allowed_roles")) {
			for(var s in SESSION.rmreport.allowed_roles) {
				if(s.role == 'RM Reports' && s.id == SESSION.rmreport.division) {
					return true;
				}
			}
			return false;
		}
		else {
			return false;
		}
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "rmreport")) {
			flashInsert(error="You are not logged in");
			if(structKeyExists(params, "key")) {
				redirectTo(route="rmreportlogin", params="redirectto=#params.route#&redirectkey=#params.key#");
			}
			else {
				redirectTo(route="rmreportlogin", params="redirectto=#params.route#");
			}
		}
	}
}