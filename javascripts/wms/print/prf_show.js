Vue.use(Toasted)

var app = new Vue({
	el: '#app',
	data: {
		is_alert: true,
		key: null,
		prf: null,
		box_type: null,
		barcodeformats : [],
		barcode_format: null,
		show_print_modal: false,
		models: [],
		exclusions: [],
		checkedModels: [],
		check_all: false,
		q: ''
	},
	computed: {
		shipFilter: function() {
			var self = this
			var q = new RegExp('^'+this.escapeRegex(self.q)+'.*$', 'i')
			return this.models.filter(function(m) {
				if(self.q.trim().length > 0) {
					return m.lines.some(function(curr, index, arr) {
						return (curr.model_no.toString().match(q) || curr.model_name.toString().match(q) || m.boxm.toString().match(q)) && _.findIndex(self.exclusions, function(item) {
							return item.model_no == curr.model_no.toString()
						}) == -1
					}) 
				}
				else {
					return m.lines.some(function(curr, index, arr) {
						return _.findIndex(self.exclusions, function(item) {
							return item.model_no == curr.model_no.toString()
						}) == -1
					})
				}
			})
		},
		getPreview: function() {
			if(this.barcode_format == null) {
				return "../../../images/sample_128x128.png"
			}
			else {
				var checkimg = this.checkImage()
				if(checkimg == false) {
					return "../../../images/sample_128x128.png"
				}
				else {
					if(checkimg.trim().length == 0) {
						return "../../../images/sample_128x128.png"
					}
					else {
						return "../../../images/wms/"+checkimg
					}
				}
			}
		}
	},
	watch: {
		box_type: function(format) {
			this.getBarcodeFormat(format)
		},
		barcodeformats: function(f) {
			this.barcode_format = null
		},
		barcode_format: function(b) {
			if(b != null) {
				var self = this
				axios.get('../exclusion/getExclusions', {
					params: {
						format: 'json',
						id: b
					}
				})
				.then(function (response) {
					var result = response.data.map(function(item) {
						return {
							model_no: item.model_number.toString(),
							model_name: item.model_name.toString()
						}
					})
					self.exclusions = result
				})
				.catch(function (error) {
					self.$toasted.error(error).goAway(2500)
					console.log(error)
				})
			}
		},
		show_print_modal: function(status) {
			var html = document.documentElement
			if(status == true) {
				html.className = 'is-clipped'
			}
			else {
				html.className = ''
			}
		}
	},
	created: function() {
		this.key = key
		this.prf = prf
		this.getModels()
	},
	mounted: function() {
		var elements = document.querySelectorAll('.right-sidebar-sticky')
		Stickyfill.add(elements)
	},
	methods: {
		print: function() {
			var boxm = this.getFilteredModelIDs()
			var self = this
			
			if(boxm.length) {
				var self = this
				axios.post('../printapi', {
					prf: this.key,
					boxm: boxm,
					barcode_format: this.barcode_format
				})
				.then(function (response) {
					if(JSON.parse(response.data) == true) {
						var cmdShell = new ActiveXObject("WScript.Shell");
						var target_index = _.findIndex(self.barcodeformats, function (item) {
							return item.id == self.barcode_format
						})
						var target = self.barcodeformats[target_index].target
						var myPath = "\"C:\\WMS\\"+target+".lnk\""
						cmdShell.Run(myPath , 1, true)
						self.$toasted.success('Printing...').goAway(2500)
					}
					else {
						self.$toasted.error('Cannot Print. Please call MIS for assistance').goAway(2500)
					}
				})
				.catch(function (error) {
					self.$toasted.error(error).goAway(2500)
					console.log(error)
				})
			}
			else {
				this.$toasted.info('No Mother Box specified').goAway(2500)
			}
		},
		getFilteredModelIDs: function() {
			var self = this
			var filtered = this.shipFilter.filter(function(f) {
				return f.selected == true
			}).map(function(m) {
				return m.boxm
			})
			return filtered
		},
		getBarcodeFormat: function(format) {
			var self = this
			axios.get('../printapi/getBarcodeFormat', {
				params: {
					key: format
				}
			})
			.then(function(response){
				self.barcodeformats = response.data
			})
			.catch(function(error){
				self.$toasted.error(error).goAway(2500)
				console.log(error)
			})
		},
		getModels: function() {
			var self = this
			axios.get('../printapi/'+this.key, {
				params: {
					box_type: this.box_type,
					barcode_format: this.barcode_format,
					format: 'json'
				}
			})
			.then(function (response) {
				var result = _.values(response.data.reduce(function(r, _ref, index, array) {
					var boxm = _ref.boxm, model_no = _ref.model_no, model_name = _ref.model_name, qty = _ref.qty, type = _ref.type
					r[boxm] = r[boxm] || { boxm: boxm, lines: [] }
					r[boxm].lines.push({ model_no: model_no.toString(), model_name: model_name, qty: qty, type: type })
					return r
				}, {}))
				self.models = result
			})
			.catch(function (error) {
				self.$toasted.error(error).goAway(2500)
				console.log(error)
			})
		},
		escapeRegex: function(str) {
			return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
		},
		toggleModelCheckbox: function(event) {
			for(var i=0; i < this.models.length; i++) {
				this.models[i].selected = event.target.checked
			}
		},
		scrollToTop: function() {
			window.scroll({
			  top: 0, 
			  left: 0, 
			  behavior: 'smooth'
			})
		},
		clearErrors: function() {
			this.is_alert = false
		},
		showModels: function() {
			this.show_print_modal = true
		},
		hideModels: function() {
			this.show_print_modal = false			
			this.check_all = false
			for(var i=0; i < this.models.length; i++) {
				this.models[i].selected = false
			}
		},
		checkImage: function() {
			var self = this
			var item = _.findIndex(this.barcodeformats, function(item) {
				return item.id == self.barcode_format
			})
			if(item == -1) {
				return false
			}
			else {
				return this.barcodeformats[item].image_path
			}
			
		}
	},
})

