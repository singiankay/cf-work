<cfscript>
  // Place functions here that should be available globally in your application.
	function getImageAssetPath(required string filename){
		return get("rootPath") & "/" & get("imagePath") & "/" & arguments.filename;
	}

	function getJSAssetPath(required string filename){
		return get("rootPath") & "/" & get("javascriptPath") & "/" & arguments.filename;
	}
</cfscript>
