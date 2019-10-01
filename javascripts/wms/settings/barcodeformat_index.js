var app = new Vue({
	el: '#app',
	data: {
		is_alert: true
	},
	created: function() {
	},
	mounted: function() {

	},
	watch: {
	},
	methods: {
		confirmDelete: function(event) {
			var result = confirm("Are you sure you want to delete this record?")
			if(!result) {
				event.preventDefault()
			}
		},
		clearErrors: function() {
			this.is_alert = false
		}
	}
})