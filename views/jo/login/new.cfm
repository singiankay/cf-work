<cfparam name="params.user.username" default ="">

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
						<h3 class="title has-text-grey">Job Order</h3>
						<p class="subtitle has-text-grey">Please login to proceed</p>
						<div class="box">
							<figure class="avatar">
								<transition enter-active-class="animated fadeIn" leave-active-class="animated fadeOut" mode="out-in" appear>
									<img :src="image_placeholder" :key="image_placeholder">
								</transition>
							</figure>
							<p class="login-name has-text-grey ">{{ name }}</p>
							<cfif structKeyExists(URL, "redirectTo")>
								<cfif structKeyExists(URL, "redirectKey")>
									#startFormTag(route="joauthenticate", params="redirectTo=#URL.redirectTo#&redirectKey=#URL.redirectKey#")#
								<cfelse>
									#startFormTag(route="joauthenticate", params="redirectTo=#URL.redirectTo#")#
								</cfif>
							<cfelse>
								#startFormTag(route="joauthenticate")#
							</cfif>
							
								<div class="field">
									<div class="control">
										#textField(label=false, class="input is-large", id="username", argumentCollection={ "v-model" = "username" }, placeholder="Your Username", objectName="user", property="username", required=true, value=params.user.username)#
									</div>
								</div>
								<div class="field">
									<div class="control">
										#passwordField(label=false, class="input is-large", argumentCollection={ "v-model" = "password" }, placeholder="Your Password", objectName="user", property="password", required=true)#
									</div>
								</div>
								<div class="field">
									<div class="control is-expanded">
										<div class="select is-fullwidth">
											<select v-model="selected_division" name="division" class="input is-large" required>
												<option value="" disabled v-if="!divisions.length">Select Division</option>
												<option v-for="d in divisions" :value="d.id" v-else>{{ d.name }}</option>
											</select>
										</div>
									</div>
								</div>
								<br>
								#buttonTag(content="Login", class="button is-block is-info is-large is-fullwidth", argumentCollection={ ":disabled" = "name == '' || selected_division == ''" })#
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
			username: document.getElementById("username").value,
			password: null,
			divisions: [],
			selected_division: '',
			name: "",
			is_error: true
		},
		created: function() {
			if(this.username != '') {
				this.searchUser(this.username)
			}
		},
		mounted: function() {
		},
		watch: {
			username: _.debounce(function(value) {
				this.searchUser(value)
			}, 250)
		},
		methods: {
			searchUser: function(value) {
				var self = this
				axios.get('login/getUser',{
					params: {
						format: 'json',
						username: value,
					}
				})
				.then(function (response) {
					if(response.data == false) {
						self.image_placeholder = '../../images/guest.png'
						self.name = ""
					}
					else {
						self.image_placeholder = response.data.image_path
						self.divisions = response.data.divisions
						self.name = response.data.firstname + ' ' + response.data.lastname
					}
				})
				.catch(function (error) {
					console.log(error)
				})
			},
			clearErrors: function() {
				this.is_error = false
			}
		}
	})
</script>
</cfoutput>

