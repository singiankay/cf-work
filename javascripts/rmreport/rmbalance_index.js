Vue.use(Toasted)

var app = new Vue({
	el: '#app',
	components: {
		vuejsDatepicker: vuejsDatepicker,
	},
	data: {
		is_alert: true,
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