<script>
	<cfoutput>
		<cfif structKeyExists(VARIABLES, "adjustment")>
			<cfif structKeyExists(adjustment, "remarks")>
				var remarks = '#adjustment.remarks#';
			<cfelse>
				var remarks = '';
			</cfif>
		</cfif>
	</cfoutput>
</script>