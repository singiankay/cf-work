component displayname="Main" extends="app.controllers.Controller"
{	

	function config() {

		provides("html,json");

	}

	function getDivisions() {

		// var divisions = model("division").findall(
		// 	select="id, code",
		// 	where="id < 8 AND is_active = 1", 
		// 	order="code DESC",
		// 	returnAs="objects"
		// );
		var divisions = super.getDivisions();
		renderWith(divisions);

	}

	function getDivision() {

		var division = model("division").findOne(select="id, code",where="id = '#params.id#'");
		renderWith(division);

	}

	function getAreas() {

		var areas = model("area").findAll(select="id, area", where="division = #params.division#", returnAs="objects");
		renderWith(areas);

	}

	function getArea() {

		var area = model("area").findOne(select="id, area", where="id = #params.area#");
		renderWith(area);

	}

	function getNameByID() {
		var employee = model("HRISEmployee").findOne(
			select="firstname,lastname,position", 
			where="id="&params.id
		);
		renderWith(employee);
	}
}