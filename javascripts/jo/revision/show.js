var app = new Vue({
	el: '#app',
	data: {
		is_alert: true,
		jo_no: jo_id,
		revisions: [],
		current_rev_id: jo_revision_id,
		max_rev: [],
		jo: {},
		jo_revision: {},
		materials: [],
		classifications: [],
		pp_remarks: '',
		pu_remarks: '',
		cancel_remarks: ''
	},
	computed: {
		model: function() {
			return this.jo_revision.model_no + ' ' + this.jo_revision.model_name
		},
		max_rev_id: function() {
			if (typeof this.max_rev != "undefined") {
			   return this.max_rev.id
			}
			else {
				return null
			}
		},
		max_rev_no: function() {
			if (typeof this.max_rev != "undefined") {
			   return this.max_rev.revision_no
			}
			else {
				return null
			}
		},
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
			this.getJoRevisions()
			this.getJo()
			this.getMaterials()
		})
	},
	mounted: function() {
		var elements = document.querySelectorAll('.right-sidebar-sticky')
		Stickyfill.add(elements)
	},
	methods: {
		confirmCancel: function(e) {
			var r = confirm('Are you sure you want to cancel this JO?')
			if(!r) {
				e.preventDefault()
			}
		},
		getJoRevisions: function() {
			var self = this
			axios.get('../revision?format=json')
			.then(function(response) {
				self.revisions = response.data
				if(response.data.length) {
					self.max_rev = response.data[0]
				}
			})
			.catch(function(error) {
				console.log(error)
			})
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
					model_no: response.data.jo_revision.model_no,
					model_name: response.data.jo_revision.model_name,
					qty_to_produce: response.data.jo_revision.qty_to_produce,
					total_shipment_qty: response.data.jo_revision.total_shipment_qty,
					lot_code: response.data.jo_revision.lot_code,
					fourm_change: response.data.jo_revision.fourm_change,
					sixm_change: response.data.jo_revision.sixm_change,
					sa_no: response.data.jo_revision.sa_no,
					production_month: new Date(response.data.jo_revision.production_month),
					requested_start_date: new Date(response.data.jo_revision.requested_start_date),
					requested_end_date: new Date(response.data.jo_revision.requested_end_date),
					batch_no: response.data.jo_revision.batch_no,
					include_chemicals: response.data.jo_revision.include_chemicals,
					remarks: response.data.jo_revision.remarks,
					cancel_remarks: response.data.jo_revision.cancel_remarks,
					pp_approver: response.data.jo_revision.pp_approver,
					pp_approver_id: response.data.jo_revision.pp_approver_id,
					pp_approver_remarks: response.data.jo_revision.pp_approver_remarks,
					pp_approver_status: response.data.jo_revision.pp_approver_status,
					pp_deputy: response.data.jo_revision.pp_deputy,
					pp_deputy_id: response.data.jo_revision.pp_deputy_id,
					pp_evaluated_by: response.data.jo_revision.pp_evaluated_by,
					pp_evaluated_date: new Date(response.data.jo_revision.pp_evaluated_date),
					pu_approver: response.data.jo_revision.pu_approver,
					pu_approver_id: response.data.jo_revision.pu_approver_id,
					pu_approver_remarks: response.data.jo_revision.pu_approver_remarks,
					pu_approver_status: response.data.jo_revision.pu_approver_status,
					pu_deputy: response.data.jo_revision.pu_deputy,
					pu_deputy_id: response.data.jo_revision.pu_deputy_id,
					pu_evaluated_by: response.data.jo_revision.pu_evaluated_by,
					pu_evaluated_date: new Date(response.data.jo_revision.pu_evaluated_date),
					posted_by: response.data.jo_revision.posted_by,
					posted_by_id: response.data.jo_revision.posted_by_id,
					document_date: new Date(response.data.jo_revision.document_date),
					status: response.data.jo_revision.status
				}
			})
			.catch(function(error) {
				console.log(error)
			})
		},
		getMaterials: function() {
			var self = this
			axios.get('../../../materialapi/'+this.current_rev_id+'?format=json')
			.then(function(response) {
				self.materials = response.data
			})
			.catch(function(error) {
				console.log(error)
			})
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
		clearErrors: function() {
			this.is_alert = false
		},
		moment: function () {
			return moment()
		},
		monthView: function(value) {
			return moment(value).format("MMMM YYYY")
		},
		dateView: function(value) {
			return moment(value).format("MMMM DD YYYY")
		}
	},
	filters: {
		monthView: function(value) {
			return this.moment(value).format("MMMM YYYY")
		},
		dateView: function(value) {
			return this.moment(value).format("MMMM DD YYYY")
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
	}
})