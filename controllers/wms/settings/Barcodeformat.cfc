component displayname="WMS Settings - Barcode Format" extends="app.controllers.Controller"
{
	title = "WMS - Barcode Format";
	format = super.getBarcodeFormat();

	function config()
	{
		filters("restrictAccess");
		usesLayout(template="/wms/layout");
		provides("html, json");
	}

	function index()
	{
		controllerJS = 'wms/settings/barcodeformat_index';
		barcodeFormats = [];
		if(!structKeyExists(params, "q")) {
			var params.q = "";
		}
		if(!structKeyExists(params, "type")) {
			var params.type = "Motherbox";
		}
		if(!structKeyExists(params, "page")) {
			var params.page = 1;
		}
		var data = model("barcodeformat").findAll(
			where="(type = '#params.type#') AND (name LIKE '%#params.q#%' OR description LIKE '%#params.q#%' OR type LIKE '%#params.q#%') AND division=#SESSION.wms.active_division#",
			page=#params.page#, 
			perPage=25, 
			order="id DESC"
		);

		if(data.recordCount) {
			var created_by = valueList(data.created_by);
			var updated_by = valueList(data.updated_by);
			var users = listAppend(created_by, updated_by);
			var userList = model("hrisemployee").findAll(select="id,firstname,lastname", where="id IN (#users#)");
			
			for(d in data) {
				barcodeFormats.append({
					id: d.id,
					name: d.name,
					division: d.division,
					type: d.type,
					description: d.description,
					exclusions: getExclusions(d.id),
					image_path: d.image_path,
					created_by: getUserFromList(userList, d.created_by),
					updated_by: getUserFromList(userList, d.updated_by),
					date_created: d.date_created,
					date_updated: d.date_updated
				});
			}
		}
	}

	function show()
	{
		controllerJS = 'wms/settings/barcodeformat_show';
		barcodeformat = model("barcodeformat").findByKey(params.key);
		created_by = model("hrisemployee").findOne(select="fullname, image_path", where="id = #barcodeformat.created_by#");
		updated_by = model("hrisemployee").findOne(select="fullname, image_path", where="id = #barcodeformat.updated_by#");
	}

	function new()
	{
		controllerJS = 'wms/settings/barcodeformat_new';
		barcodeformat = model("barcodeformat").new();
	}

	function edit()
	{
		
	}

	function create()
	{
		barcodeformat = model("barcodeformat").new();
		barcodeformat.name = params.barcodeformat.name;
		barcodeformat.type = params.barcodeformat.type;
		barcodeformat.target = params.barcodeformat.target;
		barcodeformat.division = SESSION.wms.active_division;
		barcodeformat.description = params.barcodeformat.description;
		barcodeformat.created_by = SESSION.wms.user_id;
		barcodeformat.updated_by = SESSION.wms.user_id;
		
		var result = barcodeformat.save();
		
		if(result == true) {
			if(FORM.image_preview != "") {
				try {
					var tempDirectory = getTempDirectory();
					var tempDirectory = expandPath(".\images\tempwms\");
					var uploadDirectory = expandPath(".\images\wms\");
					var tempUpload = fileUpload(tempDirectory, "FORM.image_preview", "*", "overwrite");
					
					if (not listFindNoCase("jpg,jpeg,png", tempUpload.serverFileExt)) {
						flashInsert(error="Uploaded file should only be of jpg or png type");
						redirectTo(route="wmsSettingsBarcodeformat",key=params.key);
					}
					else {
						fileDelete("#tempDirectory##tempUpload.serverFile#");
						
						var metadata = {
							clientFile = tempUpload.clientFile,
							clientFileExt = tempUpload.clientFileExt,
							clientFileName = barcodeformat.id,
							contentSubType = tempUpload.contentSubType,
							contentType = tempUpload.contentType,
							fileSize = tempUpload.fileSize
						};

						if(!reFind(("(?i)jpe?g|png"), metaData.clientFileExt) || metaData.contentType != "image") {
							flashInsert(error="Uploaded file should only be of jpg or png type");
							redirectTo(route="wmsSettingsBarcodeformat",key=barcodeformat.id);
						}
						else {
							var uploadActual = fileUpload(uploadDirectory, "FORM.image_preview", "*", "overwrite");
							var imagePath = "#uploadActual.serverFile#";
							fileMove(uploadDirectory&uploadActual.serverFile, uploadDirectory&barcodeformat.id&"."&metaData.clientFileExt);
							var update = model("barcodeformat").updateByKey(key=barcodeformat.id, image_path=barcodeformat.id&"."&metaData.clientFileExt);
							if(update == true) {
								flashInsert(success="Successfully created record!");
								redirectTo(route="wmsSettingsBarcodeformat",key=barcodeformat.id);
							}
						}
					}
				}
				catch(any e) {
					flashInsert(error="#e.type#:#e.message#");
					redirectTo(route="wmsSettingsBarcodeformat", key=barcodeformat.id);
				}
			}
			else {
				flashInsert(success="Successfully created record!");
				redirectTo(route="wmsSettingsBarcodeformat",key=barcodeformat.id);
			}
		}
		else {
			flashInsert(error="Something happened!");
			redirectTo(route="newWmsSettingsBarcodeformat");
		}
	}

	function update()
	{
		oldformat = model("barcodeformat").findByKey(params.key);

		if(FORM.image_preview != "") {
			try {
				var tempDirectory = getTempDirectory();
				var tempDirectory = expandPath(".\images\tempwms\");
				var uploadDirectory = expandPath(".\images\wms\");
				var tempUpload = fileUpload(tempDirectory, "FORM.image_preview", "*", "overwrite");
				
				if (not listFindNoCase("jpg,jpeg,png", tempUpload.serverFileExt)) {
					flashInsert(error="Uploaded file should only be of jpg or png type");
					redirectTo(route="wmsSettingsBarcodeformat",key=params.key);
				}
				else {
					fileDelete("#tempDirectory##tempUpload.serverFile#");
					
					var metadata = {
						clientFile = tempUpload.clientFile,
						clientFileExt = tempUpload.clientFileExt,
						clientFileName = oldformat.id,
						contentSubType = tempUpload.contentSubType,
						contentType = tempUpload.contentType,
						fileSize = tempUpload.fileSize
					};

					if(!reFind(("(?i)jpe?g|png"), metaData.clientFileExt) || metaData.contentType != "image") {
						flashInsert(error="Uploaded file should only be of jpg or png type");
						redirectTo(route="wmsSettingsBarcodeformat",key=params.key);
					}
					else {
						var uploadActual = fileUpload(uploadDirectory, "FORM.image_preview", "*", "overwrite");
						var imagePath = "#uploadActual.serverFile#";
						fileMove(uploadDirectory&uploadActual.serverFile, uploadDirectory&oldformat.id&"."&metaData.clientFileExt);
					}
				}
				oldformat.update(
					name = params.barcodeformat.name,
					type = params.barcodeformat.type,
					target = params.barcodeformat.target,
					division = params.barcodeformat.division,
					description = params.barcodeformat.description,
					updated_by = SESSION.wms.user_id,
					image_path = oldformat.id&"."&metaData.clientFileExt
				);
				flashInsert(success="Successfully updated record!");
				redirectTo(route="wmsSettingsBarcodeformat",key=params.key);
			}
			catch(any e) {
				flashInsert(error="#e.type#:#e.message#");
				redirectTo(route="wmsSettingsBarcodeformat",key=params.key);
			}
		}
		else {
			oldformat.update(
				name = params.barcodeformat.name,
				type = params.barcodeformat.type,
				target = params.barcodeformat.target,
				division = params.barcodeformat.division,
				description = params.barcodeformat.description,
				updated_by = SESSION.wms.user_id
			);
			flashInsert(success="Successfully updated record!");
			redirectTo(route="wmsSettingsBarcodeformat",key=params.key);
		}
	}

	function delete()
	{
		var barcodeFormatForDelete = model("barcodeformat").deleteByKey(params.key);
		if(barcodeFormatForDelete) {
			flashInsert(success="Successfully deleted data");
			redirectTo(route="wmsSettingsBarcodeformatIndex");
		}
		else {
			flashInsert(error="Error deleting data. Please try again");
			renderView(route="wmsSettingsBarcodeformatIndex");
		}
	}

	private function getUserFromList(list, user)
	{
		for(l in arguments.list) {
			if(user == l.id) {
				return l.firstname & " " & l.lastname;
			}
		}
		return false;
	}
	
	private function getExclusions(id)
	{
		var exclusion = model("barcodeformatexclusion").findAll(where="barcode_format_id = #arguments.id#", returnType="query");
		return listToArray(Valuelist(exclusion.model_number));
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