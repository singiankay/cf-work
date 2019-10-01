Vue.use(VeeValidate);

var app = new Vue({
	el: '#app',
	components: {
		vuejsDatepicker: vuejsDatepicker,
		ValidationProvider: VeeValidate.ValidationProvider
	},
	data: {
		is_alert: true,
		mrf: {
			jo_no: '',
			building: null,
			area: null,
			issuance_date: '',
			purpose: [],
			others: ''
		},
		materials: [],
	},
	computed: {
		isValidated: function() {
			if((this.mrf.purpose.length > 0 || (this.mrf.others != null && this.mrf.others.trim().length > 0)) && this.isMaterialValidated == true ) {
				return true
			}
			return false
		},
		isMaterialValidated: function() {
			if(this.materials.length > 0) {
				for(var m in this.materials) {
					if(m.status == false) {
						return false
					}
				}
				return true
			}
			return false
		},
		material_balance: function() {
			return _.values(this.materials.reduce(function(r, _ref, index, array) {
				var material_no = _ref.material_no, rm_inventory = _ref.rm_inventory, qty_required = _ref.qty_required
				if(_ref.status == true) {
					r[material_no] = r[material_no] ? (r[material_no].qty_required += qty_required, r[material_no]) : { material_no: material_no, rm_inventory: rm_inventory, qty_required: qty_required }
				}
				return r
			}, {}))
		}
	},
	created: function(){
		var isNonzeroInteger = function(value) {
			return new Promise(function(resolve) {
				if(value > 0) {
					return resolve({
						valid: true
					}) 
				}
				else {
					return resolve({
						valid: false,
						data: {
							message: 'Cannot request value of 0 or less.'
						}
					})	
				}
			})
		}
		this.$validator.extend("nonzero", {
			validate: isNonzeroInteger,
			getMessage: function(field, params, data) {
				return data.message
			}
		})
	},
	methods: {
		save: function() {
			var self = this
			this.$validator.validateAll()
			.then(function(result) {
				if(result) {
					axios.post('../request/?format=json', {
						mrf: self.mrf,
						materials: self.materials
					})
					.then(function(response) {

					})
					.catch(function(error) {

					})
				}
			})

		},
		getRemainingInventory: function(material_no) {
			var is_material = _.some(this.material_balance, function(m) {
				return m.material_no == material_no
			})
			if(is_material) {
				var material = _.find(this.material_balance, function(m) {
					return m.material_no == material_no
				})

				return material.rm_inventory - material.qty_required
			}
		},
		searchMaterial: _.debounce(function(material) {
			material.is_loading = true
			material.status = false
			material.material_name = ""
			var material_nos = []
			material_nos.push(material.material_no)

			var self = this

			axios.get('getMaterialInventory?format=json', {
				params: {
					material_nos: JSON.stringify(material_nos)
				}
			})
			.then(function(response) {
				material.is_loading = false
				if(response.data.status == true) {
					response.data.data.forEach(function(m) {
						if( material.material_no == m.material_no.toString()) {
							material.material_name = m.material_name
							material.rm_inventory = m.qty_balance
							material.status = true
						}
					})
				}
			})
			.catch(function(error) {
				console.log(error)
				material.is_loading = false
			})
		},250),
		addMaterial: function() {
			this.materials.push({
				material_no: '',
				material_name: '',
				rm_inventory: 0,
				qty_required: 0,
				area: 0,
				is_loading: false,
				status: false
			})
		},
		removeMaterial: function(index) {
			this.materials.splice(index, 1)
		},
		clearErrors: function() {
			this.is_alert = false
		},
	}
})