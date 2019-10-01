<cfoutput>
	<script>
		<cfif structKeyExists(params, "key")>
			var key = #params.key#;
			var prf = #prf.prf_number#;
		</cfif>
	</script>
</cfoutput>