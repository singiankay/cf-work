var app = new Vue({
	el: '#app',
	data: {
		is_alert: true,
	},
	methods: {
		clearErrors: function() {
			this.is_alert = false
		},
	}
})