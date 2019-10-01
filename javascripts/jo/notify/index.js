var app = new Vue({
	el: '#app',
	components: {
		Multiselect: window.VueMultiselect.default
	},
	data: {
		users: [],
		areas: [],
		active_area: null,
		user: null,
		userOptions: [],
		isLoading: false
	},
	computed: {
		filtered_users: function() {
			var self = this
			if(division == 1) {
				return this.users.filter(function(x) {
					return _.findIndex(x.area, function(arr) {
						return arr == self.active_area
					}) != -1
				})
			}
			else {
				return this.users
			}
		}
	},
	created: function() {
		if(division == 1) {
			this.getAreas()
			this.active_area = 1
		}
		else {
			this.getUsers()
		}
	},
	watch: {
		active_area: function() {
			this.getUsers()
		}
	},
	methods: {
		search: function(q) {
			var self = this
			axios.get('notify/searchUsers', {
				params: {
					q: q,
					area: this.active_area,
					format: 'json'
				}
			})
			.then(function(response) {
				self.isLoading = false	
				self.userOptions = response.data.map(function(item) {
					return {
						id: item.id,
						text: item.firstname + " " + item.lastname
					}
				})
			})
			.catch(function(error) {
				self.isLoading = false	
				console.log(error)
			})
		},
		searchUsers: _.debounce(function(q) {
			if(q.trim().length >= 3) {
				this.isLoading = true	
				this.search(q.trim())
			}
		}, 250),
		addUser: function() {
			var self = this
			axios.post('notify', {
				user: this.user.id,
				area:this.active_area
			})
			.then(function(response) {
				if(response.data.status == true) {
					self.getUsers()
				}
				else {
					console.log(response.data.message);
				}
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		deleteUser: function(id, area) {
			var self = this
			axios.delete('notify/'+id+'?format=json', {
				params: {
					area: area
				}
			})
			.then(function(response) {
				if(response.data.status == true) {
					self.getUsers()
				}
				else {
					
				}
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		getAreas: function() {
			var self = this
			axios.get('notify/getAreas?format=json')
			.then(function(response) {
				self.areas = response.data
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		getUsers: function() {
			var self = this
			axios.get('notify/getUsers?format=json')
			.then(function(response) {
				self.users = response.data
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		clearErrors: function() {
			this.is_alert = false
		},
	}
})