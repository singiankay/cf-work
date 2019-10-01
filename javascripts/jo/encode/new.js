Vue.use(VeeValidate);

var app = new Vue({
	el: '#app',
	components: {
		Multiselect: window.VueMultiselect.default,
		vuejsDatepicker: vuejsDatepicker,
		ValidationProvider: VeeValidate.ValidationProvider
	},
	data: {
		is_alert: true,
		jo: {
			jo_number: '',
			designation: 'Order',
			jo_reference: '',
			sixm_change: '',
			fourm_change: '',
			sa_no: '',
			model: null,
			lot_code: '',
			type: ['Mass Production'],
			qty_to_produce: 0,
			total_shipment_qty: 0,
			production_month: null,
			requested_start_date: null,
			requested_end_date: null,
			remarks: '',
			batch_no: '',
			include_chemicals: true
		},
		modelOptions: [],
		materials: [],
		classifications: [],
		pp_approvers: [],
		pp_approver: null,
		pp_deputies: [],
		pp_deputy: null,
		pu_approvers: [],
		pu_approver: null,
		pu_deputies: [],
		pu_deputy: null,
		redirect_status: false,
		redirect_message_raw: [],
		isSubmit: false,
		isLoading: false,
		isTouched: false,
	},
	computed: {
		isShouldValidate: function() {
      	return this.isTouched && this.jo.model === null
    	},
    	canComputeMaterial: function() {
    		if(typeof this.jo.model === 'object' && this.jo.model != null) {
    			return true
    		}
    		else {
    			return false
    		}
    	},
    	canSave: function() {
    		if(this.canComputeMaterial == true && this.materials.length) {
    			return true
    		}
    		else {
    			return false
    		}
    	},
    	calculateText: function() {
    		if(this.canComputeMaterial == true && this.materials.length) {
    			return "Recalculate"
    		}
    		else {
    			return "Calculate"
    		}
    	},
    	redirect_message: function() {
    		return JSON.stringify(this.redirect_message_raw)
    	}
	},
	created: function() {
		axios.defaults.headers.get['Pragma'] = 'no-cache'
		axios.defaults.headers.get['Cache-Control'] = 'no-cache, no-store'
		var self = this
		axios.get('../modelApi/getMaterialGroupings?format=json')
		.then(function(response) {
			self.classifications = response.data
		})
		.catch(function(error) {
			console.log(error)
		})
		
		this.$nextTick(function() {
			this.getApprover('pp_approver')
			this.getApprover('pp_deputy')
			this.getApprover('pu_approver')
			this.getApprover('pu_deputy')
		})

		var isUnique = function(value) {
			return axios.get('../encode/isJoUnique/'+value)
			.then(function(response) {
				if(response.data.status == true) {
					return {
						valid: response.data.status
					}
				}
				else {
					return {
						valid: response.data.status,
						data: {
							message: 'Jo Number is already taken'
						}
					}
				}
			})
			.catch(function(error) {
				console.log(error)
			})
		}

		this.$validator.extend("unique", {
			validate: isUnique,
			getMessage: function(field, params, data) {
				return data.message
			}
		})
	},
	mounted: function() {
		var elements = document.querySelectorAll('.right-sidebar-sticky')
		Stickyfill.add(elements)
	},
	watch: {
		isShouldValidate: function(val) {
			this.$validator.validate("jo.model")
		},
		'jo.model.id': function() {
			this.materials = []
		},
		'jo.qty_to_produce': function() {
			this.materials = []
		}
	},
	methods: {
		searchModel: function(query) {
			if(query.length > 2) {
				this.isLoading = true
				this.search(query)
			}
		},
		search: _.debounce(function(query) {
			var self = this
			axios.get('../modelApi/', {
				params: {
					format: 'json',
					q: query
				}
			})
			.then(function(response) {
				self.isLoading = false
				var data = response.data.map(function(item) {
					return { 
						id: item.id.toString(), 
						text: item.id + ' ' + item.name,
					}
				})
				self.modelOptions = data
			})
			.catch(function(error) {
				console.log(error)
			})
		}, 250),
		onTouch: function() {
			this.isTouched = true
		},
		createJo: function() {
			var self = this
			this.$validator.validate("jo.*")
			.then(function(result) {
				if (result === true) {
					self.create()
				}
				else {
					alert("Please ensure all fields required are valid and completed.")
				}
			})
		},
		create: function() {
			this.isSubmit = true
			var self = this
			axios.post('../encode/?format=json', {
				jo: this.jo,
				materials: this.materials.map(function(item) {
					return {
						material_name: item.material_name,
						material_no: item.material_no,
						classification: item.classification,
						classification_name: self.getMaterialType(item.classification),
						bom: item.bom,
						yield_rate: item.yield_rate,
						qty_required: item.qty_required,
						rm_inventory: item.rm_inventory,
						wip: item.wip,
						remaining_rm_inventory: self.getRemainingMaterial(item, item.material_no),
						lacking_qty: self.getLackingRMInventory(item, item.material_no),
						material_for_request: self.getMaterialForRequest(item, item.material_no),
						alt: item.alternatives.map(function(alt) {
							return {
								material_no: alt.material_no,
								material_name: alt.material_name,
								classification: alt.classification,
								classification_name: self.getMaterialType(alt.classification),
								rm_inventory: alt.rm_inventory,
								wip: alt.wip,
								remaining_rm_inventory: self.getRemainingAlternative(item, item.material_no, alt.material_no)
							}
						})
					}
				}),
				pp_approver: this.pp_approver,
				pp_deputy: this.pp_deputy,
				pu_approver: this.pu_approver,
				pu_deputy: this.pu_deputy
			})
			.then(function(response) {
				self.redirect_status = response.data.status
				self.redirect_message_raw = response.data.message
				
				self.$nextTick(function() {
					self.$refs.redirect.submit()
				})
			})
			.catch(function(error) {
				console.log(error)
				self.isSubmit = false
			})
		},
		calculateBom: function() {
			this.materials = []
			var self = this
			axios.get('../modelApi/'+this.jo.model.id)
			.then(function(response) {
				self.materials = response.data.materials.map(function(item) {
					return {
						material_no: item.material_no.toString(),
						material_name: item.material_name,
						classification: item.classification,
						bom: item.bom,
						qty_required: item.bom * self.jo.qty_to_produce / (item.yield_rate / 100),
						rm_inventory: item.rm_inventory,
						wip: item.wip,
						yield_rate: item.yield_rate,
						alternatives: item.alternatives.map(function(alt) {
							return {
								classification: alt.classification,
								material_name: alt.material_name,
								material_no: alt.material_no.toString(),
								rm_inventory: alt.rm_inventory,
								wip: alt.wip
							}
						})
					}
				}).sort(function(a,b) {
					if(a.classification > b.classification) {
						return 1
					}
					else if(a.classification < b.classification) {
						return -1
					}
					else {
						return 0
					}
				})
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		getApprover: function(approver) {
			var self = this
			axios.get('../approver?format=json', {
				params: {
					approver: approver
				}
			})
			.then(function(response) {
				if(approver == 'pp_approver') {
					if(response.data.length > 0) {
						self.pp_approvers = response.data
					}
					else {
						self.pp_approvers = [{
							id: 0,
							text: 'Auto-approve'
						}]
					}
					self.pp_approver = self.pp_approvers[0].id
				}
				else if(approver == 'pp_deputy') {
					if(response.data.length > 0) {
						self.pp_deputies = response.data
					}
					else {
						self.pp_deputies = [{
							id: 0,
							text: 'None'
						}]
					}
					self.pp_deputy = self.pp_deputies[0].id
				}
				else if(approver == 'pu_approver') {
					if(response.data.length > 0) {
						self.pu_approvers = response.data
					}
					else {
						self.pu_approvers = [{
							id: 0,
							text: 'Auto-approve'
						}]
					}
					self.pu_approver = self.pu_approvers[0].id
				}
				else if(approver == 'pu_deputy') {
					if(response.data.length > 0) {
						self.pu_deputies = response.data
					}
					else {
						self.pu_deputies = [{
							id: 0,
							text: 'None'
						}]
					}
					self.pu_deputy = self.pu_deputies[0].id
				}
			})
			.catch(function(error) {

			})
		},
		getRemainingBom: function(material ,material_no) {
			var mfr = this.getMaterialForRequest(material, material_no)
			var rm_inventory = 0
			rm_inventory += material.rm_inventory
			material.alternatives.forEach(function(a) {
				rm_inventory += a.rm_inventory
			})
			if(rm_inventory - mfr >= 0) {
				return rm_inventory - mfr 
			}
			else {
				return 0
			}
		},
		getRemainingMaterial: function(material, material_no) {
			var mfr = this.getMaterialForRequest(material, material_no)
			var rm_inventory = material.rm_inventory

			if(rm_inventory >= mfr) {
				return rm_inventory - mfr
			}
			else {
				return 0
			}
		},
		getRemainingAlternative: function(material, material_no, alternative_no) {
			var mfr = this.getMaterialForRequest(material, material_no)
			var rm_inventory = 0
			rm_inventory += material.rm_inventory

			if(mfr >= rm_inventory) {
				for(var i = 0; i < material.alternatives.length; i++) {
					rm_inventory += material.alternatives[i].rm_inventory
					if(material.alternatives[i].material_no == alternative_no) {
						break
					}
				}
				if(rm_inventory >= mfr) {
					return rm_inventory - mfr
				}
				else {
					return 0
				}
			}
			else {
				for(var i = 0; i < material.alternatives.length; i++) {
					if(material.alternatives[i].material_no == alternative_no) {
						return material.alternatives[i].rm_inventory;
					}
				}
			}
		},
		getLackingRMInventory: function(material, material_no) {
			var mfr = this.getMaterialForRequest(material, material_no)
			var rm_inventory = 0
			rm_inventory += material.rm_inventory
			material.alternatives.forEach(function(a) {
				rm_inventory += a.rm_inventory
			})
			if(mfr -rm_inventory >= 0) {
				return  mfr - rm_inventory
			}
			else {
				return 0
			}
		},
		getMaterialForRequest: function(material, material_no) {
			var wip = 0
			
			if(material.wip) {
				wip += material.wip
			}
			material.alternatives.forEach(function(a) {
				if(a.wip) {
					wip += a.wip
				}
			})
			if(material.qty_required - (wip * material.bom) >= 0) {
				return material.qty_required - (wip * material.bom)
			}
			else {
				return 0
			}
		},
		getMaterialType: function(value) {
			var self = this
			if(_.findIndex(self.classifications, function(item) { return item.code == value }) != -1) {
				return _.find(self.classifications, function(item) {
					return item.code == value
				}).type
			}
			else {
				return ""
			}
		},
		materialClass: function(value, classifications) {
			if(_.findIndex(classifications, function(item) { return item.code == value }) != -1) {
				var type = _.find(classifications, function(item) {
					return item.code == value
				}).type
				
				if(type == "Materials") {
					return "has-text-link"
				}
				else if(type == "Packaging Materials") {
					return "has-text-success"
				}
				else if(type == "Chemicals") {
					return "has-text-danger"
				}
			}
			else {
				return ""
			}
		},
		clearErrors: function() {
			this.is_alert = false
		},
	},
	filters: {
		numberFormat: function(value) {
			if(!value) {
				return 0
			}
			else {
				return new Intl.NumberFormat().format(value)
			}
		},
		roundOff: function(number, precision) {
			var factor = Math.pow(10, precision)
			var tempNumber = number * factor
			var roundedTempNumber = Math.round(tempNumber)
			return roundedTempNumber / factor
		},
		materialClassification: function(value, classifications) {
			if(_.findIndex(classifications, function(item) { return item.code == value }) != -1) {
				return _.find(classifications, function(item) {
					return item.code == value
				}).type
			}
			else {
				return ""
			}
		},
		materialIndex: function(value) {
			return value + 1
		},
		
	},
	directives: {
		tabindex: {
			inserted: function(el) {
				el.setAttribute('tabindex', 8);
			}
		},
		focus: {
			inserted: function(el) {
				el.focus()
			}
		},
	}
})