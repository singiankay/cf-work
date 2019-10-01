var app = new Vue({
	el: '#app',
	data: {
		filename: null,
		is_alert: true
	},
	created: function() {
		
	},
	mounted: function() {

	},
	watch: {
	},
	methods: {
		showFile: function() {
			if(this.$refs.filefield.files[0].name) {
				this.filename = this.$refs.filefield.files[0].name
			}
		},
		clearFile: function() {
			var input = this.$refs.filefield
			input.type = 'text'
			input.type = 'file'
			this.filename = null
		},
		clearErrors: function() {
			this.is_alert = false
		}
	}
})