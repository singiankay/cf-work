<cfoutput>
	<div id="app">
		<section class="hero is-success is-fullheight">
			<div class="hero-body">
				<div class="container has-text-centered">
					<div class="column is-4 is-offset-4">
						<cfif NOT flashIsEmpty()>
							<transition enter-active-class="animated fadeIn" leave-active-class="animated fadeOut" appear>
								<div class="notification login-notification <cfif flashKeyExists("error")>is-danger</cfif><cfif flashKeyExists("success")>is-success</cfif> has-text-left" v-if="is_error">
									<button class="delete" @click="clearErrors()"></button>
									<cfif flashKeyExists("error")>
										<strong>Error!&nbsp;</strong>#flash("error")#
									</cfif>
									<cfif flashKeyExists("success")>
										<strong>Success!&nbsp;</strong>#flash("success")#
									</cfif>
								</div>
							</transition>
						</cfif>
						<h3 class="title has-text-grey">RM Reports</h3>
						<p class="subtitle has-text-grey">Please login to proceed</p>
						<div class="box">
							<figure class="avatar">
								<transition enter-active-class="animated fadeIn" leave-active-class="animated fadeOut" mode="out-in" appear>
									<img :src="image_placeholder" :key="image_placeholder">
								</transition>
							</figure>
							<cfif structKeyExists(URL, "redirectTo")>
								<cfif structKeyExists(URL, "redirectKey")>
									#startFormTag(route="rmreportauthenticate", params="redirectTo=#URL.redirectTo#&redirectKey=#URL.redirectKey#")#
								<cfelse>
									#startFormTag(route="rmreportauthenticate", params="redirectTo=#URL.redirectTo#")#
								</cfif>
							<cfelse>
								#startFormTag(route="rmreportauthenticate")#
							</cfif>
								<div class="field">
									<div class="control is-expanded">
										<div class="select is-fullwidth">
											#selectTag(name="division", options=divisions, valueField="", textField="", class="input is-large", label=false)#
										</div>
									</div>
								</div>
								<br>
								#buttonTag(content="Login", class="button is-block is-info is-large is-fullwidth")#
							#endFormTag()#
						</div>
						<p class="has-text-grey">
							<a href="/">Go back to Appserver</a>
						</p>
					</div>
				</div>
			</div>
		</section>
	</div>
<script>
	var app = new Vue({
		el: '##app',
		data: {
			image_placeholder: '../../images/guest.png',
			is_error: true
		},
		created: function() {
		},
		mounted: function() {
		},
		watch: {
		},
		methods: {
			clearErrors: function() {
				this.is_error = false
			}
		}
	})
</script>
</cfoutput>

