Vue.use(VeeValidate)

var app = new Vue({
	el: '#app',
	components: {
		Multiselect: window.VueMultiselect.default,
		vuejsDatepicker: vuejsDatepicker,
		ValidationProvider: VeeValidate.ValidationProvider
	},
	data: {
		is_alert: true,
		jo_no: jo_id,
		current_rev_id: jo_revision_id,
		jo: {},
		jo_revision: {},
		modelOptions: [],
		materials: [],
		classifications: [],
		pp_remarks: null,
		pu_remarks: null,
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
		isLoading: false,
		isTouched: false,
		isSubmit: false
	},
	computed: {
		calculateText: function() {
			if(this.materials.length) {
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
	mounted: function() {
		var elements = document.querySelectorAll('.right-sidebar-sticky')
		Stickyfill.add(elements)
	},
	created: function() {
		axios.defaults.headers.get['Pragma'] = 'no-cache'
		axios.defaults.headers.get['Cache-Control'] = 'no-cache, no-store'
		var self = this
		axios.get('../../../modelApi/getMaterialGroupings?format=json')
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
			this.getJo()
			this.getRevisionMaterials()
		})

		var isUnique = function(value) {
			return axios.get('../../../encode/isJoUnique/'+value, {
				params: {
					current_jo: self.jo_no,
					test: "test"
				}
			})
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
	watch: {
		'jo_revision.model.id': function() {
			this.materials = []
		},
		'jo_revision.qty_to_produce': function() {
			this.materials = []
		}
	},
	methods: {
		newRevision: function() {
			var self = this
			this.isSubmit = true
			axios.post('./?format=json', {
				jo: this.jo,
				revision: this.jo_revision,
				materials: this.materials.map(function(item) {
					return {
						material_name: item.material_name,
						material_no: item.material_no,
						classification: item.material_class,
						classification_name: self.getMaterialType(item.material_class),
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
								classification: alt.material_class,
								classification_name: self.getMaterialType(alt.material_class),
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
				pu_deputy: this.pu_deputy,
				is_material_edit: this.isMaterialEdit
			})
			.then(function(response) {
				self.redirect_status = response.data.status
				self.redirect_message_raw = response.data.message
				
				self.$nextTick(function() {
					console.log(response.data)
					self.$refs.redirect.submit()
				})
			})
			.catch(function(error) {
				console.log(error)
				self.isSubmit = false
			})
		},
		searchModel: function(query) {
			if(query.length > 2) {
				this.isLoading = true
				this.search(query)
			}
		},
		search: _.debounce(function(query) {
			var self = this
			axios.get('../../../modelApi/', {
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
		getJo: function() {
			var self = this
			axios.get('../../../encodeshowapi/'+this.current_rev_id+'?format=json')
			.then(function(response) {
				self.jo = response.data.jo,
				self.jo_revision = {
					id: response.data.jo_revision.id,
					jo_id: response.data.jo_revision.jo_id,
					revision_no: response.data.jo_revision.revision_no,
					designation: response.data.jo_revision.designation,
					jo_reference: response.data.jo_revision.jo_reference,
					jo_type: response.data.jo_revision.jo_type,
					model: {
						id: response.data.jo_revision.model_no.toString(),
						text: response.data.jo_revision.model_no.toString() + ' ' + response.data.jo_revision.model_name
					},
					qty_to_produce: response.data.jo_revision.qty_to_produce,
					total_shipment_qty: response.data.jo_revision.total_shipment_qty,
					lot_code: response.data.jo_revision.lot_code,
					fourm_change: response.data.jo_revision.fourm_change,
					sixm_change: response.data.jo_revision.sixm_change,
					sa_no: response.data.jo_revision.sa_no,
					production_month: response.data.jo_revision.production_month,
					requested_start_date: response.data.jo_revision.requested_start_date,
					requested_end_date: response.data.jo_revision.requested_end_date,
					batch_no: response.data.jo_revision.batch_no,
					include_chemicals: (response.data.jo_revision.include_chemicals == 1 ? true : false),
					remarks: response.data.jo_revision.remarks,
					pp_approver: response.data.jo_revision.pp_approver,
					pp_approver_id: response.data.jo_revision.pp_approver_id,
					pp_approver_remarks: response.data.jo_revision.pp_approver_remarks,
					pp_approver_status: response.data.jo_revision.pp_approver_status,
					pp_deputy: response.data.jo_revision.pp_deputy,
					pp_deputy_id: response.data.jo_revision.pp_deputy_id,
					pp_evaluated_by: response.data.jo_revision.pp_evaluated_by,
					pp_evaluated_date: response.data.jo_revision.pp_evaluated_date,
					pu_approver: response.data.jo_revision.pu_approver,
					pu_approver_id: response.data.jo_revision.pu_approver_id,
					pu_approver_remarks: response.data.jo_revision.pu_approver_remarks,
					pu_approver_status: response.data.jo_revision.pu_approver_status,
					pu_deputy: response.data.jo_revision.pu_deputy,
					pu_deputy_id: response.data.jo_revision.pu_deputy_id,
					pu_evaluated_by: response.data.jo_revision.pu_evaluated_by,
					pu_evaluated_date: response.data.jo_revision.pu_evaluated_date,
					posted_by: response.data.jo_revision.posted_by,
					posted_by_id: response.data.jo_revision.posted_by_id,
					document_date: response.data.jo_revision.document_date,
					status: response.data.jo_revision.status
				}
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		getRevisionMaterials: function() {
			var self = this
			axios.get('../../../materialapi/'+this.current_rev_id+'?format=json')
			.then(function(response) {
				self.materials = response.data
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		getApprover: function(approver) {
			var self = this
			axios.get('../../../approver?format=json', {
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
				console.log(error)
			})
		},
		calculateBom: function() {
			var self = this
			
			axios.get('../../../modelapi/'+this.jo_revision.model.id+'?format=json')
			.then(function(response) {
				self.materials = response.data.materials.map(function(item) {
					return {
						alternatives: item.alternatives.map(function(alt) {
							return {
								id: null,
								material_class: alt.classification,
								material_no: alt.material_no,
								material_name: alt.material_name,
								material_type: "Alternative",
								rm_inventory: alt.rm_inventory,
								wip: alt.wip
							}
						}),
						bom: item.bom,
						id: null,
						material_class: item.classification,
						material_no: item.material_no,
						material_name: item.material_name,
						material_type: "Primary",
						qty_required : item.bom * self.jo_revision.qty_to_produce / (item.yield_rate / 100),
						rm_inventory: item.rm_inventory,
						wip: item.wip,
						yield_rate: item.yield_rate,
					}
				}).sort(function(a,b) {
					if(a.material_class > b.material_class) {
						return 1
					}
					else if(a.material_class < b.material_class) {
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
		joStatus: function(status) {
			if(status == 'Returned') {
				return "is-danger"
			}
			else if(status == 'Pending') {
				return "is-warning"
			}
			else if(status == 'Approved') {
				return "is-primary"
			}
		},
		onTouch: function() {
			this.isTouched = true
		},
		clearErrors: function() {
			this.is_alert = false
		}
	},
	filters: {
		monthView: function(value) {
			return value
		},
		dateView: function(value) {
			return value
		},
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
				el.setAttribute('tabindex', 8)
			}
		},
		focus: {
			inserted: function(el) {
				el.focus()
			}
		},
	}
})