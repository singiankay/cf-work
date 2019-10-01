<cfscript>

	// Use this file to set variables for the Application.cfc's "this" scope.

	// Examples:
	// this.name = "MyAppName";
	// this.sessionTimeout = CreateTimeSpan(0,0,5,0);

	this.serialization.preservecaseforstructkey = true;
	this.serialization.serializeQueryAs = "struct";
	this.sessionTimeout = createTimespan(0, 9, 0, 0);
</cfscript>
