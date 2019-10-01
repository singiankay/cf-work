component displayname="WMS Settings - Barcode Format" extends="app.controllers.Controller"
{
	title = "WMS - Barcode Format";
	format = super.getBarcodeFormat();
	lineBreak = chr(13)&chr(10);

	function config()
	{
		provides("html, json");
	}

	function index()
	{

	}

	function show()
	{
		var shipmodels = getPRFModal(params.key);
		var sirmodels = getSirModal(params.key);
		var modelNos = ListRemoveDuplicates(quotedValueList(shipmodels.matnumber));
		var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#modelNos#)");
		var result = [];

		for(var s in shipmodels) {
			arrayAppend(result, {
				boxm: s.boxm,
				model_no: s.matnumber,
				model_name: getModelName(modelNames, s.matnumber),
				qty: s.qty,
				type: 'prf'
			});
		}

		for(var sir in sirmodels) {
			arrayAppend(result, {
				boxm: sir.boxm,
				model_no: '',
				model_name: sir.item,
				qty: sir.qty,
				type: 'sir'
			});
		}
		
		arraySort(result, function(item1, item2) {
			return item1.boxm > item2.boxm;
		});
		renderWith(result);
	}

	function create()
	{
		var barcode = model("barcodeformat").findByKey(params.barcode_format);
		var exclusions = model("barcodeformatexclusion").findAll(where="barcode_format_id = #barcode.id#");
		var prf = getPrf(params.prf);
		var prf_items = getPrfItems(params.prf);
		var shipment = getShipmentDetails(params.prf, arrayToList(params.boxm));
		var box_total = getBoxTotal(params.prf);


		var modelNames = model("productname").findAll(select="ItemCode, ItemName", where="ItemCode IN (#listRemoveDuplicates(quotedValueList(shipment.matnumber))#)");
		var box_file = createobject("java", "java.io.File").init("c:\txtfile\#barcode.id#.txt");
		var box_data = createobject("java","java.io.FileWriter").init(box_file);
		var box_content = setFormat(barcode, exclusions, prf, prf_items, shipment, modelNames, box_total);

		// var model_print = getModelPrint();
		// var sir_print = getSirPrint();
		
		box_data.write(box_content);
		box_data.flush();
		box_data.close();
		renderWith(true);
	}

	function update()
	{

	}

	function delete()
	{

	}

	function getBarcodeFormat()
	{
		var barcodeformat = model("barcodeformat").findall(where="type='#params.key#' AND division = #SESSION.wms.active_division#", order="name", returnas="objects");
		renderWith(barcodeformat);
	}

	private function setFormat(barcode, exclusions, prf, prf_items, shipment, modelNames, box_total)
	{
		var header = setHeader(arguments.barcode.id);
		
		if(arguments.barcode.id == 13) {
			var body = setFormatA(arguments.prf, arguments.prf_items, arguments.shipment);
		}
		//  5		NPS
		// 10		XA Series
		// 34		NPS (Mixed)
		// 36		NPS Series 1
		else if(arguments.barcode.id == 5 || arguments.barcode.id == 10 || arguments.barcode.id == 34 || arguments.barcode.id == 36) {
			var body = setFormatB(arguments.barcode, arguments.exclusions, arguments.prf, arguments.prf_items, arguments.shipment, arguments.modelNames, arguments.box_total);
		}
		else if(arguments.barcode.id == 1 || arguments.barcode.id == 3 || arguments.barcode.id == 6 || arguments.barcode.id == 25) {
			var body = setFormatC();
		}
		else if(arguments.barcode.id == 12) {
			var body = setFormatD();
		}
		else if(arguments.barcode.id == 2 || arguments.barcode.id == 11) {
			var body = setFormatE();
		}
		// 27		LCN-MO8T-P (Single)
		// 29		LCN-M14T-P (Single)
		// 31		LCN-S08T-P (Single)
		// 33		LCN-S14T-P (Single)
		else if(arguments.barcode.id == 27 || arguments.barcode.id == 29 || arguments.barcode.id == 31 || arguments.barcode.id == 33) {
			var body = setFormatF(arguments.barcode, arguments.exclusions, arguments.prf, arguments.prf_items, arguments.shipment, arguments.modelNames, arguments.box_total);
		}
		// 26		LCN-MO8T-P (Mixed)
		// 28		LCN-M14T-P (Mixed)
		// 30		LCN-S08T-P (Mixed)
		// 32		LCN-S14T-P (Mixed)
		else if(arguments.barcode.id == 26 || arguments.barcode.id == 28 || arguments.barcode.id == 30 || arguments.barcode.id == 32) {
			var body = setFormatG(arguments.barcode, arguments.exclusions, arguments.prf, arguments.prf_items, arguments.shipment, arguments.modelNames, arguments.box_total);
		}
		else {
			var body = setFormatZ();
		}

		return header & body;
	}

	private function setHeader(format_id)
	{
		if(arguments.format_id == 13) {
			return 'DATA_1|DATA_2|DATA_3|DATA_4|DATA_5|DATA_6|DATA_7|DATA_8|DATA_9|DATA_10|DATA_11|DATA_12|DATA_13' & lineBreak;
			return "BOXM|CUSTOMERNAME|CUSTOMERADDRESS|BOXNUMBER|BOXTOTAL|N/A||PARTNUMBER|||||LOTCODE|QTY";
		}
		else if(arguments.format_id == 5 || arguments.format_id == 10 || arguments.format_id == 34 || arguments.format_id == 36) {
			return "BOXM|CUSTOMERNAME|CUSTOMERADDRESS|MODELNO|MODELNAME|CUSTPN|CUSTPO|BOXNO|BOXTOTAL|LOTCODE|QTY" & lineBreak;
		}
		else if(arguments.format_id == 1 || arguments.format_id == 3 || arguments.format_id == 6 || arguments.format_id == 25) {
			return 'DATA_1|DATA_2|DATA_3|DATA_4|DATA_5|DATA_6|DATA_7|DATA_8|DATA_9|DATA_10|DATA_11' & lineBreak;
		}
		else if(arguments.format_id == 12) {
			return 'DATA_1|DATA_2|DATA_3|DATA_4|DATA_5|DATA_6|DATA_7|DATA_8|DATA_9|DATA_10|DATA_11|DATA_12|DATA_13|DATA_14|DATA_15' & lineBreak;
		}
		else if(arguments.format_id == 16 || arguments.format_id == 17 || arguments.format_id == 18 || arguments.format_id == 19 || arguments.format_id == 20) {
			return 'DATA_1|DATA_2|DATA_3|DATA_4|DATA_5|DATA_6|DATA_7|DATA_8' & lineBreak;
		}
		else if(arguments.format_id == 2 || arguments.format_id == 11) {
			return 'DATA_1|DATA_2|DATA_3|DATA_4|DATA_5|DATA_6|DATA_7|DATA_8|DATA_9|DATA_10|DATA_11|DATA_12|DATA_13|DATA_14|DATA_15|DATA_16|DATA_17|DATA_18|DATA_19|DATA_20|DATA_21|DATA_22|DATA_23|DATA_24|DATA_25|DATA_26|DATA_27|DATA_28|DATA_29|DATA_30|DATA_31|DATA_32|DATA_33|DATA_34|test1' & lineBreak;
		}
		else if(arguments.format_id == 26 || arguments.format_id == 27 || arguments.format_id == 28 || arguments.format_id == 29 || arguments.format_id == 30 || arguments.format_id == 31 || arguments.format_id == 32 || arguments.format_id == 33) {
			return 'BOXM|MODELNO|MODELNAME|LOTNO|QTY|BOXNO|BOXTOTAL' &lineBreak;
		}
		else {
			return 'DATA_1|DATA_2|DATA_3|DATA_4|DATA_5|DATA_6|DATA_7|DATA_8|DATA_9|DATA_10|DATA_11|DATA_12|DATA_13|DATA_14|DATA_15|DATA_16|DATA_17|DATA_18|DATA_19|DATA_20|DATA_21|DATA_22|DATA_23|DATA_24|DATA_25|DATA_26|DATA_27|DATA_28|DATA_29|DATA_30|DATA_31|DATA_32|DATA_33|DATA_34' & lineBreak;
		}
	}

	private function setFormatA()
	{
		return "";
	}

	private function setFormatB(barcode, exclusions, prf, prf_items, shipment, modelNames, box_total)
	{
		var body = "";
		var boxm = "BOXM'#arguments.prf.id_record#";
		var customer_name = getCustomerName(arguments.prf.cust_name);
		var lotcode = "";
		var qty = "";
		var cust_pn = "";
		var cust_po = "";

		var box_no_unique = getBoxNoUnique(arguments.shipment);

		for(var b in box_no_unique) {
			lotcode = "";
			qty = "";
			cust_pn = "";
			cust_po = "";
			model_no = "";
			for(var s in arguments.shipment) {
				if(s.boxm == b) {
					lotcode = listAppend(lotcode, s.lotcode);
					qty = listAppend(qty, s.qty&" pcs");
					model_no = s.matnumber;
					cust_pn = getCustomerPn(arguments.prf_items, s.id_prf_item);
					cust_po = getCustomerPo(arguments.prf_items, s.id_prf_item);
				}
			}
			lotcode = listChangeDelims(lotcode, "/");
			qty = listChangeDelims(qty, "/");

			body &= "#boxm#|#customer_name#|#arguments.prf.cust_address#|#model_no#|#getModelName(arguments.modelNames, model_no)#|#cust_pn#|#cust_po#|#b#|#arguments.box_total#|#lotcode#|#qty#" & lineBreak;
		}
		return body;
	}

	private function setFormatC()
	{
		return "";
	}

	private function setFormatD()
	{
		return "";
	}

	private function setFormatE()
	{
	}

	private function setFormatF(barcode, exclusions, prf, prf_items, shipment, modelNames, box_total)
	{
		var body = "";
		var boxm = "BOXM'#arguments.prf.id_record#";

		for(var s in arguments.shipment) {
			body &= "#boxm#|#s.matnumber#|#getModelName(arguments.modelNames, s.matnumber)#|#s.lotcode#|#s.qty#|#s.boxm#|#arguments.box_total#" & lineBreak;
		}
		return body;
	}

	private function setFormatG(barcode, exclusions, prf, prf_items, shipment, modelNames, box_total)
	{
		var body = "";
		var boxm = "BOXM'#arguments.prf.id_record#";
		var lotcode = "";
		var qty = "";

		var box_no_unique = getBoxNoUnique(arguments.shipment);
		
		for(var b in box_no_unique) {
			lotcode = "";
			qty = "";
			for(var s in arguments.shipment) {
				if(s.boxm == b) {
					lotcode = listAppend(lotcode, s.lotcode);
					qty = listAppend(qty, s.qty&" pcs");
				}
			}
			lotcode = listChangeDelims(lotcode, "/");
			qty = listChangeDelims(qty, "/");

			body &= "#boxm#|#s.matnumber#|#getModelName(arguments.modelNames, s.matnumber)#|#lotcode#|#qty#|#b#|#arguments.box_total#" & lineBreak;
		}
		return body;
	}

	private function getBoxNoUnique(shipment) {
		var boxArray = [];
		for(var s in arguments.shipment) {
			if(arrayFind(boxArray, s.boxm) == 0) {
				arrayAppend(boxArray, s.boxm);
			}
		}
		return boxArray;
	}

	private function setFormatZ()
	{
		return "";
	}

	private function getPrf(id)
	{
		var prf = model("prf").findByKey(arguments.id);
		return prf;
	}

	private function getPrfItems(id)
	{
		var items = model("prfitem").findAll(select="id_record, id_base, matnumber, cust_po, cust_pn", where="id_base = #arguments.id#");
		return items;
	}

	private function getShipmentDetails(id, boxm)
	{
		try {
			var sqlQuery = new Query();
			sqlQuery.setDatasource(erpdb_fg);
			sqlQuery.setSQL("
				SELECT matnumber, SUM(qty) AS qty, id_prf_item, lotcode, boxm, boxi, extseg, boxr 
				  FROM tbl_shipdetails 
				 WHERE isactive = 1 
				   AND id_prf = :id
				   AND boxm IN (:boxm)
				 GROUP BY matnumber, id_prf_item, lotcode, boxm, boxi, extseg, boxr
				 ORDER BY boxm, boxi
			");
			sqlQuery.addParam(name="id", value=arguments.id, CFSQLTYPE="CF_SQL_INTEGER");
			sqlQuery.addParam(name="boxm", value=arguments.boxm, CFSQLTYPE="CF_SQL_INTEGER", list="true");
			var resultset = sqlQuery.execute().getResult();
			return resultset;
		}
		catch(any e) {
			return false;
		}
	}

	private function getSir(id)
	{
		var sir = model("sir").findOne(where="id_prf = #arguments.id#");
		return sir;
	}

	private function getSirItems(sir_id)
	{
		var sir_items = model("siritem").findAll(where="idbase = #arguments.sir_id#");
		return sir_items;
	}

	private function getSirItemsBox(sir_id)
	{
		var sir_items_box = model("sirbox").findall(where="id_sir = #arguments.id_sir#");
		return sir_items_box;
	}

	private function getCustomerName(code)
	{
		if(Len(Trim(arguments.code)) > 0) {
			try {
				var sqlQuery = new Query();
				sqlQuery.setDatasource(sapdb);
				sqlQuery.setSQL("
					SELECT CardName 
					  FROM dbo.OCRD 
					 WHERE CardCode = :code
				");
				sqlQuery.addParam(name="code", value=arguments.code, CFSQLTYPE="CF_SQL_VARCHAR");
				var resultset = sqlQuery.execute().getResult();
				return resultset.CardName;
			}
			catch(any e) {
				return "ERROR: #e.message#";
			}
		}
		else {
			return "test2";
		}
	}

	private function getModelNames()
	{

	}

	function getModelName(models, model)
	{
		for(var m in arguments.models) {
			if(m.Itemcode == arguments.model) {
				return m.ItemName;
			}
		}
		return "";
	}

	private function getBoxTotal(id)
	{
		var shipments = model("shipdetails").findAll(select="id_record, id_prf, id_prf_item, id_phf, id_phf_item, matnumber, qty, lotcode, boxm, boxi, extseg, boxr", where="isactive = 1 AND id_prf = #arguments.id#");
		var max = 0;
		for(var box in shipments) {
			if(box.boxm > max) {
				max = box.boxm;
			}
		}
		return max;
	}

	private function getCustomerPo(prf_items, id)
	{
		for(var i in arguments.prf_items) {
			if(i.id_record == arguments.id) {
				return i.cust_po;
			}
		}
		return "";
	}

	private function getCustomerPn(prf_items, id)
	{
		for(var i in arguments.prf_items) {
			if(i.id_record == arguments.id) {
				return i.cust_pn;
			}
		}
		return "";
	}

	private function getPRFModal(id)
	{
		var sqlQuery = new Query();
		sqlQuery.setDatasource(erpdb_fg);
		sqlQuery.setSQL("
			SELECT boxm, matnumber, SUM(qty) as qty 
			  FROM tbl_shipdetails 
			 WHERE id_prf = :id 
			   AND isactive = 1 
			 GROUP BY boxm, matnumber
			 ORDER BY boxm, boxi
		");
		sqlQuery.addParam(name="id", value=arguments.id, CFSQLTYPE="CF_SQL_INTEGER");
		return sqlQuery.execute().getResult();
	}

	private function getSirModal(id)
	{
		var sqlQuery = new Query();
		sqlQuery.setDatasource(erpdb_fg);
		sqlQuery.setSQL("
			SELECT  c.boxm, b.item, SUM(c.qty) AS qty
			  FROM tbl_sir a 
			 INNER JOIN tbl_sir_items b 
			         ON b.idbase = a.id_record
			 INNER JOIN tbl_sir_items_box c 
			         ON c.id_sir = a.id_record 
			        AND c.id_sir_items = b.id_record 
			        AND c.id_prf = a.id_prf
			 WHERE a.id_prf = :id
			 GROUP BY c.boxm, b.item
		");
		sqlQuery.addParam(name="id", value=arguments.id, CFSQLTYPE="CF_SQL_INTEGER");
		return sqlQuery.execute().getResult();
	}
}