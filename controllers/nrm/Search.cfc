component displayname="NRM" extends="app.controllers.Controller"
{
	title = "NRM - Search";

	function config()
	{
		usesLayout(template="/nrm/layout_public");
	}

	function index()
	{
		controllerJS = "nrm/search/index";
		suppliers = getSuppliers();

		param name="params.material" default="";
		param name="params.supplier" default="";

		if(len(trim(params.material)) > 0 || len(trim(params.supplier)) > 0) {
			materials = getMaterials(params.material, params.supplier);
			
			if(!isQuery(materials)) {
				flashInsert(error=materials);
			}
		}
		else {
			materials = "";
		}
	}

	function generate()
	{
		param name="params.material" default="";
		param name="params.supplier" default="";

		controllerJS = "rmreport/rmbalance_index";
		suppliers = getSuppliers();
		materials = getMaterials(params.material, params.supplier);
		
		if(isQuery(materials)) {
			var spreadsheetObj = spreadsheetNew('NRM');
			spreadsheetAddRow(spreadsheetObj, 'NRM');
			spreadsheetSetCellValue(spreadsheetObj, 'Generated Last', 2, 1);
			spreadsheetSetCellValue(spreadsheetObj, #dateFormat(now(), 'm/d/yyyy')#, 2, 4);
			spreadsheetAddFreezePane(spreadsheetObj, 0, 3);
			spreadsheetMergeCells(spreadsheetObj, 1, 1, 1, 3);
			spreadsheetMergeCells(spreadsheetObj, 2, 2, 1, 3);
			SpreadsheetformatCell(spreadsheetObj,{ color= 'teal', bold=true, alignment='left' },1,1);
			SpreadsheetformatCell(spreadsheetObj,{ color= 'teal', bold=true, alignment='left' },2,1);
			SpreadsheetformatCell(spreadsheetObj,{ color= 'teal', dataformat='m/d/yyyy' },2,4);

			var headerList = "Material No.,Material Name,Price,Currency,UOM,SPQ,Last Purchase Date,Lead Time (Day),Supplier,Status";
			spreadsheetAddRow(spreadsheetObj, headerList);
			spreadsheetformatrow(spreadsheetObj,{ bold=true, alignment='center_selection', textwrap=true },3);
			spreadsheetSetRowHeight(spreadsheetObj, 3, 24);
			SpreadSheetAddAutofilter(Spreadsheetobj, "A3:J3");

			for(var m in materials) {
				spreadsheetSetCellFormula(spreadsheetObj, 'HYPERLINK("#urlFor(route='rmreportBalanceIndex', params='search[mat_no]='&materials.ItemCode, onlyPath=false)#","#m.ItemCode#")', materials.currentRow+3, 1);
					spreadsheetFormatCell(spreadsheetObj, { color= 'teal', dataformat='@', alignment='center' }, materials.currentRow+3, 1);
				spreadsheetSetCellValue(spreadsheetObj, m.ItemName, materials.currentRow+3, 2);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, materials.currentRow+3, 2);
				spreadsheetSetCellValue(spreadsheetObj, m.Price, materials.currentRow+3, 3);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, materials.currentRow+3, 3);
				spreadsheetSetCellValue(spreadsheetObj, m.Currency, materials.currentRow+3, 4);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, materials.currentRow+3, 4);
				spreadsheetSetCellValue(spreadsheetObj, m.BuyUnitMsr, materials.currentRow+3, 5);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, materials.currentRow+3, 5);
				spreadsheetSetCellValue(spreadsheetObj, m.MinOrdrQty, materials.currentRow+3, 6);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, materials.currentRow+3, 6);
				spreadsheetSetCellValue(spreadsheetObj, dateFormat(m.lastPurDat, 'm/d/yyyy'), materials.currentRow+3, 7);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='m/d/yyyy', alignment='right' }, materials.currentRow+3, 7);
				spreadsheetSetCellValue(spreadsheetObj, m.LeadTime, materials.currentRow+3, 8);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, materials.currentRow+3, 8);
				spreadsheetSetCellValue(spreadsheetObj, m.CardName, materials.currentRow+3, 9);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, materials.currentRow+3, 9);
				spreadsheetSetCellValue(spreadsheetObj, (m.frozenFor == 'N' ? 'Active' : 'Inactive'), materials.currentRow+3, 10);
					spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, materials.currentRow+3, 10);
			}

			spreadsheetSetColumnWidth(spreadsheetObj, 1, 12);
			spreadsheetSetColumnWidth(spreadsheetObj, 2, 48);
			spreadsheetSetColumnWidth(spreadsheetObj, 3, 16);
			spreadsheetSetColumnWidth(spreadsheetObj, 4, 10);
			spreadsheetSetColumnWidth(spreadsheetObj, 5, 8);
			spreadsheetSetColumnWidth(spreadsheetObj, 6, 12);
			spreadsheetSetColumnWidth(spreadsheetObj, 7, 22);
			spreadsheetSetColumnWidth(spreadsheetObj, 8, 18);
			spreadsheetSetColumnWidth(spreadsheetObj, 9, 48);
			spreadsheetSetColumnWidth(spreadsheetObj, 10, 8);

			cfheader(name="Content-Disposition", value="inline; filename=nrm.xls");
			cfcontent(type="application/vnd.ms-excel", variable="#SpreadSheetReadBinary(spreadsheetObj)#");
		}
		else {
			flashInsert(error=materials.message);
		}
	}

	private function getSuppliers()
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL(" 
				SELECT CardCode, CardName
				  FROM dbo.npi_oitm 
				 WHERE ItmsGrpCod IN (:groupcode)
				 GROUP BY CardCode, CardName 
				 ORDER BY CardName 
			");
			sqlQuery.addParam(name="groupcode", value="148", CFSQLTYPE="CF_SQL_INTEGER", list="true");
			return sqlQuery.execute().getResult();
		}
		catch(any e) {
			return e;
		}
	}

	private function getMaterials(material, supplier)
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(sapdb);
			sqlQuery.setSQL("
				SELECT ItemCode, ItemName, ItmsGrpCod, CardCode, CardName, Price, BuyUnitMsr, Currency, LeadTime, LastPurDat, MinOrdrQty, PurPackUn, PurPackMsr, frozenfor
				  FROM dbo.npi_oitm 
				 WHERE (:mat IS NULL OR ItemCode + ' ' + ItemName LIKE :material)
				   AND (:supplier IS NULL OR CardCode = :supplier) 
				 ORDER BY LastPurDat DESC 
				OPTION (RECOMPILE)
			");
			sqlQuery.addParam(name="mat", value=trim(arguments.material), CFSQLTYPE="CF_SQL_VARCHAR", null=(Len(Trim(arguments.material)) == 0 ? true : false));
			sqlQuery.addParam(name="material", value='%#arguments.material#%', CFSQLTYPE="CF_SQL_VARCHAR");
			sqlQuery.addParam(name="supplier", value=trim(arguments.supplier), CFSQLTYPE="CF_SQL_VARCHAR", null=(Len(Trim(arguments.supplier)) == 0 ? true : false));
			return sqlQuery.execute().getResult();
		}
		catch(any e) {
			return e;
		}
	}
}