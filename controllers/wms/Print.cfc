component displayname="Print" extends="app.controllers.Controller"
{
	title = "Print";
	format = super.getBarcodeFormat();
	
	
	function config()
	{
		filters("restrictAccess");
		provides("html, json");
		usesLayout(template="/wms/layout");
	}

	function index() 
	{
		controllerJS = 'wms/print/prf_index.js';
		if(!structKeyExists(params, "q")) {
			var params.q = "";
		}
		if(!structKeyExists(params, "page")) {
			var params.page = 1;
		}
		if(isNumeric(params.q)) {
			prf = model("prf").findAll(
				where="area = #SESSION.wms.active_division# AND isactive = 1 AND id_reinspection = 0 AND  (prf_number = #params.q# OR npi_invoice LIKE '%#params.q#%' OR cust_name = '#params.q#')",
				page=#params.page#, 
				perPage=20, 
				order="date_saved DESC, date_shipment"
			);
		}
		else {
			prf = model("prf").findAll(
				where="area = #SESSION.wms.active_division# AND isactive = 1 AND id_reinspection = 0 AND (npi_invoice LIKE '%#params.q#%' OR cust_name = '#params.q#')",
				page=#params.page#, 
				perPage=20, 
				order="date_saved DESC, date_shipment"
			);
		}
		disposition = model("prfdisposition").findAll();
		var customerCode = quotedValueList(prf.cust_name);
		if(ListLen(customerCode)) {
			customerNames = model("customer").findAll(select="id,name", where="id IN (#customerCode#)");
		}
		var verifiers = valueList(prf.id_user_verify);
		if(listLen(verifiers)) {
			verifiernames = model("hrisemployee").findAll(select="id,fullname", where="id IN (#verifiers#)");
		}
	}

	function show()
	{
		controllerJS = 'wms/print/prf_show.js';
		prf = model("prf").findByKey(key=params.key);
		customerName = model("customer").findOne(where="id = '#prf.cust_name#'");

		var sqlCount = new Query();
		sqlCount.setDatasource(erpdb_fg);
		sqlCount.setSQL("
			SELECT a.id_prf_item
			  FROM tbl_shipdetails a 
			 INNER JOIN tbl_phf b 
			         ON b.id_record = a.id_phf 
			 INNER JOIN tbl_phf_items c 
			         ON c.id_record = a.id_phf_item 
			 WHERE a.id_prf = :id
			   AND a.isactive = 1 
			 GROUP BY a.id_prf_item 
			 ORDER BY a.boxm, a.boxi, a.matnumber 
		");
		sqlCount.addParam(name="id", value=params.key, CFSQLTYPE="CF_SQL_INTEGER");
		shipmentSorting = sqlCount.execute().getResult();
		
		prfitems = model("prfitem").findAll(where="id_base = #params.key#");
		var initPrfItems = model("prfitem").findAll(where="id_base = #params.key#", order="id_record, matnumber, cust_po");
		var modelNos = quotedValueList(prfitems.matnumber);
		if(ListLen(modelNos)) {
			modelNames = model("productname").findAll(select="ItemCode, ItemName, buyUnitMsr", where="ItemCode IN (#modelNos#)");
		}
		else {
			modelNames = [];
		}
		
		var prfItemIds = valueList(prfitems.id_record);
		if(ListLen(prfItemIds)) {
			shipdetails = model("shipdetails").findall(where="id_prf_item IN (#prfItemIds#)", order="id_prf_item DESC, boxm DESC boxi ASC");
		}
		else {
			shipdetails = [];
		}
		
		phfIds = valueList(shipdetails.id_phf);
		if(ListLen(phfIds)) {
			var sqlCount2 = new Query();
			sqlCount2.setDatasource(erpdb_fg);
			sqlCount2.setSQL("
				SELECT id_record, phf_no 
				  FROM tbl_phf 
				 WHERE id_record IN (:id)
			");
			sqlCount2.addParam(name="id", value=phfIds, CFSQLTYPE="CF_SQL_INTEGER", list=true);
			phfNames = sqlCount2.execute().getResult();
		}
		else {
			phfNames = [];
		}

		var verifiers = prf.id_user_chkprf1;
		verifiers = listAppend(verifiers, prf.id_user_chkprf2);
		verifiers = listAppend(verifiers, prf.id_user_chkprf3);
		verifiers = listAppend(verifiers, prf.id_user_chkprf4);
		verifiers = listAppend(verifiers, prf.id_user_chkprf5);
		verifiers = listAppend(verifiers, prf.id_user_chkprf6);
		verifiers = listAppend(verifiers, prf.id_user_chkprf7);
		verifiers = listAppend(verifiers, prf.id_user_chkprf8);
		verifiers = listAppend(verifiers, prf.id_user_chkprf9);
		verifiers = listAppend(verifiers, prf.id_user_chkprf10);
		verifiers = listRemoveDuplicates(verifiers);
		if(listLen(verifiers)) {
			verifiernames = model("hrisemployee").findAll(select="id,fullname", where="id IN (#verifiers#)");
		}
		sir = model("sir").findAll(where="id_prf = #params.key# AND is_active = 1");
		if(sir.recordCount) {
			sir_items = model("siritem").findAll(where="idbase IN (#valueList(sir.id_record)#)");
		}
		sir_box = model("siritemsbox").findAll(where="id_prf = #params.key#");
	}

	function create()
	{
		
	}

	function update()
	{

	}

	function delete()
	{

	}

	function getCustomer()
	{
		var customer = model("customer").findAll(select="id,name", where="name LIKE '%#params.q#%'");
		renderWith(customer);
	}

	function getCustomerName(customerNames, customer)
	{
		for(names in arguments.customerNames) {
			if(names.id == arguments.customer) {
				return names.name;
			}
		}
		return "";
	}

	function getVerifierName(verifiers,verifier)
	{
		for(v in arguments.verifiers) {
			if(v.id == arguments.verifier) {
				return v.fullname;
			}
		}
		return "";
	}

	function getDisposition(despacitos, disposition)
	{
		for(d in arguments.despacitos) {
			if(d.id_record == arguments.disposition) {
				return d.disposition;
			}
		}
		return "";
	}

	function getModelName(models, model)
	{
		for(m in arguments.models) {
			if(m.Itemcode == arguments.model) {
				return m.ItemName;
			}
		}
		return "";
	}

	function getModelUom(models, model)
	{
		for(m in arguments.models) {
			if(m.Itemcode == arguments.model) {
				return m.buyUnitMsr;
			}
		}
		return "";
	}

	function getTotalBoxedQty(id_prf_item)
	{
		var total = 0;
		for(s in shipdetails) {
			if(s.id_prf_item == arguments.id_prf_item) {
				total += s.qty;
			}
		}
		return total;
	}

	function getPHFNames(id_phf)
	{
		for(name in phfNames) {
			if(name.id_record == id_phf) {
				return name.phf_no;
			}
		}
		return "";
	}

	private function restrictAccess()
	{
		if(!structKeyExists(SESSION, "wms")) {
			flashInsert(error="You are not logged in");
			redirectTo(route="wmsLogin");
		}
		else {
			if(!getRole(SESSION.wms.allowed_roles)) {
				flashInsert(error="You are not allowed to access this page.");
				redirectTo(route="wmsMain");
			}
		}
	}

	private function getRole(roles) {
		for(r in arguments.roles) {
			if(r.role == 'Print' AND r.id == SESSION.wms.active_division) {
				return true;
			}
		}
		return false;
	}

}