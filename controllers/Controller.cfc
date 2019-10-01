/**
 * This is the parent controller file that all your controllers should extend.
 * You can add functions to this file to make them available in all your controllers.
 * Do not delete this file.
 *
 * NOTE: When extending this controller and implementing `config()` in the child controller, don't forget to call this
 * base controller's `config()` via `super.config()`, or else the call to `protectsFromForgery` below will be skipped.
 *
 * Example controller extending this one:
 *
 * component extends="Controller" {
 *   function config() {
 *     // Call parent config method
 *     super.config();
 *
 *     // Your own config code here.
 *     // ...
 *   }
 * }
 */
component extends="wheels.Controller" 
{

	employee_db = "employee_db";
	hris = "hris";
	erpdb_fg = "erpdb_fg";
	sapdb = "sapdb";
	iposx = "iposxdb";
	
	login = "login";
	image_path = "http://npi-appserver/employee/personnel/";
	image_blank = "http://npi-appserver/employee/econtacts/img/void.png";


	JOTypeDefaults = [
		{"name":"Mass Production","status":"active"},
		{"name":"Regrade","status":"active"},
		{"name":"Retest","status":"active"},
		{"name":"Rework","status":"active"},
		{"name":"Reinspection","status":"active"},
		{"name":"Engineering Sample","status":"active"},
		{"name":"For Audit","status":"active"},
		{"name":"Special Run","status":"active"}
	];

	JOTypeArray = [
		"Mass Production", 
		"Regrade", 
		"Retest", 
		"Rework", 
		"Reinspection", 
		"Engineering Sample", 
		"For Audit", 
		"Special Run"
	];
	
	JOStatus = ["Drafted","Pending","Posted"];

	ProductionLine = [
		{ id:21, name:'UT-CT1', area: 1 },
		{ id:22, name:'UT-CT2', area: 2 },
		{ id:23, name:'UT-CT3', area: 3 },
		{ id:24, name:'UT-CT4', area: 4 },
		{ id:25, name:'UT-OT', area: 5 },
		{ id:26, name:'EP-UT', area: 6 },
		{ id:27, name:'UT-PNT', area: 7}
	];


	// function config(name="includeForgeryProtection" type="boolean" required="false" default="true") {

	// 	if(arguments.includeForgeryProtection) {
	// 		protectsFromForgery();
	// 	}

	// }

	function config() {
	}


	function getErrorList(errorsArray)
	{
		var errors = [];
		for(error in arguments.errorsArray) {
			ArrayAppend(errors, error.message);
		}
		return errors;
	}


	function isStringEmpty(str)
	{
		if(arguments.str == "") {
			return true;
		}
		else {
			return false;
		}
	}

	function getBooleanNumber(condition)
	{
		if(arguments.condition == true) {
			return 1;
		}
		else if(arguments.condition == false) {
			return 0;
		}
	}

	function isNumber(number)
	{
		if(isNumeric(arguments.number)) {
			return true;
		}
		else {
			return false;
		}
	}


	function isArrayEmpty(arraystr)
	{
		if(ArrayLen(arguments.arraystr) <= 0) {
			return true;
		}
		else {
			return false;
		}
	}


	function setStatus(status,message)
	{
		var alert = structNew();
		alert.status = arguments.status;
		alert.message = arguments.message;
		return alert;
	}


	function getOrderBy(str)
	{
		if(arguments.str == 0) {
			return "DESC";
		}
		else if(arguments.str == 1) {
			return "ASC";
		}
	}

	function isZeroToNull(zero)
	{
		if(arguments.zero == 0) {
			return "";
		}
		else {
			return arguments.zero;
		}
	}

	function getDivisions()
	{
		var divisions = model("division").findall(
			select="id, code",
			where="id < 8 OR id = 28", 
			order="code ASC",
			returnAs="objects"
		);
		return divisions;
	}

	function getAreas(division)
	{
		var areas = model("area").findAll(select="id, area", where="division = #arguments.division#", order="id ASC", returnAs="objects");
		return areas;	
	}

	function getArea(area)
	{
		if(arguments.area == 0) {
			return '';
		}
		else {
			return arguments.area;
		}
	}

	function getProductionLine(area)
	{
		for(lines in ProductionLine) {
			if(lines.area == arguments.area) {
				return lines.name;
			}
		}
	}

	function getBarcodeFormat()
	{
		return ['Motherbox','Innerbox'];
	}
}