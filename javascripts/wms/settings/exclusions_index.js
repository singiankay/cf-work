Vue.use(Toasted)

var app = new Vue({
	el: '#app',
	components: {
		Multiselect: window.VueMultiselect.default
	},
	data: {
		is_alert: true,
		exclusions: [],
		toggleDelete: true,
		form: {
			model: '',
		},
		modelOptions: [],
		isLoading: false
	},
	created: function() {
		var self = this
		axios.all([this.getModelExclusions(key)])
		.then(axios.spread(function(a) {
			self.exclusions = a.data
		}))
		.catch(function(error) {
			self.$toasted.error(error).goAway(2500)
			console.log(error)
		})
	},
	mounted: function() {

	},
	watch: {
	},
	methods: {
		search: function(q) {
			var self = this
			axios.get('../../exclusion/getModels', {
				params: {
					q: q,
					format: 'json'
				}
			})
			.then(function(response) {
				self.isLoading = false	
				var data = response.data.map(function(item) {
					return { 
						model_no: item.id.toString(), 
						model_name: item.name.toString() , 
						text: item.id.toString() + ' ' + item.name.toString() 
					}
				})
				self.modelOptions = data
			})
			.catch(function(error) {
				self.isLoading = false	
				self.$toasted.error(error).goAway(2500)
				console.log(error)
			})
		},
		searchModel: _.debounce(function(q) {
			if(q.trim().length >= 3) {
				this.isLoading = true	
				this.search(q.trim())
			}
		}, 250),
		selectModel: function(option) {
			var self = this
			axios.post('exclusion', { model_no: option.model_no })
			.then(function (response) {
				if(response.data.result == true) {
					self.exclusions.push({
						id: response.data.id,
						barcode_format_id: response.data.barcode_format_id,
						model_number: response.data.model_number,
						model_name: response.data.model_name,
						created_by: response.data.created_by,
						created_by_id: response.data.created_by_id
					})
				}
				else {
					self.$toasted.error(response.data.errors[0].MESSAGE).goAway(2500)
					console.log(response.data.errors[0].MESSAGE)
				}
			})
			.catch(function (error) {
				self.$toasted.error(error).goAway(2500)
				console.log(error)
			})
		},
		deleteExclusion: function(id) {
			if(this.toggleDelete) {
				this.toggleDelete = false
				var self = this
				axios.delete('exclusion/'+id)
				.then(function (response) {
					self.toggleDelete = true
					if(response.data == true) {
						var index = _.findIndex(self.exclusions, function(item) {
							return item.id == id
						}) 
						self.exclusions.splice(index, 1)
						self.$toasted.success("Deleted!").goAway(2500)
					}
					else {
						self.$toasted.error("Something wrong happened").goAway(2500)
					}
				})
				.catch(function (error) {
					self.$toasted.error(error).goAway(2500)
					console.log(error)
				})
			}
		},
		getModelExclusions: function(id) {
			return axios.get('../../exclusion/getExclusions', {
				params: {
					format: 'json',
					id: id
				}
			})
		},
		clearErrors: function() {
			this.is_alert = false
		}
	}
})