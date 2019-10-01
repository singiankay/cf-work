Vue.use(Toasted)

var app = new Vue({
	el: '#app',
	components: {
		Multiselect: window.VueMultiselect.default
	},
	data: {
		is_alert: true,
		form: {
			customer: '',
		},
		customerOptions: [],
		isLoading: false
	},
	created: function() {
	},
	mounted: function() {

	},
	watch: {
	},
	methods: {
		search: function(q) {
			var self = this
			axios.get('print/getCustomer', {
				params: {
					q: q,
					format: 'json'
				}
			})
			.then(function(response) {
				self.isLoading = false	
				var data = response.data.map(function(item) {
					return { 
						id: item.ID.toString(), 
						text: item.NAME.toString()
					}
				})
				self.customerOptions = data
			})
			.catch(function(error) {
				self.isLoading = false	
				self.$toasted.error(error).goAway(2500)
				console.log(error)
			})
		},
		searchCustomer: _.debounce(function(q) {
			if(q.trim().length >= 3) {
				this.isLoading = true	
				this.search(q.trim())
			}
		}, 250),
		selectCustomer: function(customer) {
			console.log(customer)
		},
		copyCustomerId: function() {
			var element = document.getElementById('customerid_holder')
			element.focus()
			element.select()
			try {
				document.execCommand('copy')
			}
			catch(err) {
				console.log("Error copying")
			}
		},
		clearErrors: function() {
			this.is_alert = false
		}
	}
})