<cfoutput>
<cfif NOT flashIsEmpty()>
	<transition enter-active-class="animated fadeIn" leave-active-class="animated fadeOut" appear>
		<cfif flashKeyExists("success")>
			<div class="notification wms-notification is-success has-text-left" v-if="is_alert">
				<button class="delete" @click="clearErrors()"></button>
				<strong>Success!&nbsp;</strong>#flash("success")#
			</div>
		<cfelseif flashKeyExists("error")>
			<div class="notification wms-notification is-danger has-text-left" v-if="is_alert">
				<button class="delete" @click="clearErrors()"></button>
				<strong>Error!&nbsp;</strong>#flash("error")#
			</div>
		</cfif>
	</transition>
<cfelse>
</cfif>
</cfoutput>