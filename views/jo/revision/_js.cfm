<cfoutput>
<script>
	<cfif structKeyExists(params, "encodeKey")>
		jo_id = #params.encodeKey#
	</cfif>
	<cfif structKeyExists(params, "key")>
		jo_revision_id = #params.key#
	</cfif>
</script>
</cfoutput>