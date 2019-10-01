var app = new Vue({
	el: '#app',
	data: {
		is_alert: true,
		remarks: remarks
	},
	created: function() {
	},
	mounted: function() {

	},
	watch: {
	},
	methods: {
		clearErrors: function() {
			this.is_alert = false
		}
	}
})