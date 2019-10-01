<cfoutput>
<section class="section">
	<div class="container">
		<h3 class="title">User Notification</h3>
		<p class="subtitle">Manage users that will be notified upon approval of JO</p>
	</div>
</section>
<section class="section">
	<div class="container">
		<cfif SESSION.jo.active_division EQ 1>
			<h3 class="title">Area</h3>
			<div class="field is-narrow">
				<div class="control">
					<div class="select is-primary">
					  <select v-model="active_area">
					  	<option v-for="a in areas" :value="a.id">{{ a.area }}</option>
					  </select>
					</div>
				</div>
			</div>
		</cfif>
	</div>
</section>
<section class="section">
	<div class="container">
		<div class="columns">
			<div class="column is-half">
				<h3 class="title">Users</h3>
				<div class="box">
					<transition-group name="slide" tag="div" class="field is is-grouped is-grouped-multiline" enter-active-class="animated zoomIn" leave-active-class="animated zoomOut" v-if="filtered_users.length" appear>
						<div class="control" v-for="u in filtered_users" :key="u.id" v-cloak>
							<div class="tags has-addons">
								<span class="tag is-primary">{{ u.firstname + " " + u.lastname }}</span>
								<cfif is_supervisor EQ true>
									<a class="tag is-delete" @click="deleteUser(u.id, active_area)"></a>
								</cfif>
							</div>
						</div>
					</transition-group>
					<p v-else v-cloak>No results.</p>
				</div>
			</div>
			<div class="column is-5 is-offset-1">
				<h4 class="title is-4">Add New</h4>
				<div class="field is-grouped">
					<p class="control is-expanded">
						<multiselect v-model="user" :options="userOptions" @search-change="searchUsers" label="text" track-by="id" :options-limit="25" placeholder="Search Users" :close-on-select="true" :loading="isLoading" :internal-search="false" :allow-empty="false">
						</multiselect>
					</p>
					<p class="control">
						<button class="button is-link" @click="addUser">Add User</button>
					</p>
				</div>
			</div>
		</div>
	</div>
</section>
</cfoutput>