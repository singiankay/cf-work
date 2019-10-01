<cfoutput>
<section class="section">
	<div class="container">
		<h1 class="title">Material Requisition Form</h1>
	</div>
</section>
<section class="section">
	<div class="container">
		<h3 class="title is-4">Document</h3>
		<div class="columns">
			<div class="column is-offset-4">
				<div class="columns">
					<div class="column is-3">
						<div class="field">
							<label for="jo_no" class="label">JO No.</label>
							<input type="text" name="jo_no" class="input" v-model="mrf.jo_no">
						</div>
					</div>
					<div class="column is-2">
						<div class="field">
							<label for="building" class="label">Building</label>
							<div class="select is-fullwidth">
								<cfset buildingClass = "errors.has('building')" >
								<cfset buildingArgument = {
										'v-model.number': 'mrf.building',
										'v-validate': '"required"',
										':class': '{ active : "#buildingClass#" }'
								}>
								#selectTag(
									name="building", 
									options=buildings, 
									includeBlank=false, 
									argumentCollection=buildingArgument, 
									label=false)#
								<p class="help is-danger" v-show="errors.has('building')" v-cloak>{{ errors.first('building') }}</p>
							</div>
						</div>
					</div>
					<cfif SESSION.mrf.active_division EQ 1>
						<div class="column is-3">
							<div class="field">
								<label for="area" class="label">Area</label>
								<div class="select is-fullwidth">
									<cfset areaClass = "errors.has('area')" >
									<cfset areaArgument = {
										'v-model.number': 'mrf.area',
										'v-validate': '"required"',
										':class': '{ active: "#areaClass#" }'
									}>
									#selectTag(
										name="area", 
										options=areas, 
										argumentCollection=areaArgument, 
										label=false)#
									<p class="help is-danger" v-show="errors.has('area')" v-cloak>{{ errors.first('area') }}</p>
								</div>
							</div>
						</div>
					</cfif>
					<div class="column is-4">
						<div class="field">
							<label for="issuance_date" class="label">Requested Issuance Date</label>
							<vuejs-datepicker name="issuance_date" :input-class="{ 'input' : true, 'is-danger': errors.has('issuance_date') }" v-model="mrf.issuance_date" format="MMMM dd yyyy" v-validate="'required|date_format'" data-vv-as="Requested Issuance Date" v-cloak></vuejs-datepicker>
							<p class="help is-danger" v-show="errors.has('issuance_date')" v-cloak>{{ errors.first('issuance_date') }}</p>
						</div>
					</div>
				</div>
			</div>
		</div>
		<h3 class="title is-4">Utilities & Explanation</h3>
		<div class="columns">
			<div class="column is-4 is-offset-4">
				<div class="field">
				  <input class="is-checkradio" id="pe_evaluation" type="checkbox" name="pe_evaluation" v-model="mrf.purpose" value="For PE Evaluation">
				  <label for="pe_evaluation">For PE Evaluation</label>
				</div>
				<div class="field">
				  <input class="is-checkradio" id="chemicals_for_pn" type="checkbox" name="chemicals_for_pn" v-model="mrf.purpose" value="Chemicals for PN">
				  <label for="chemicals_for_pn">Chemicals for PN</label>
				</div>
				<div class="field">
				  <input class="is-checkradio" id="for_shipment" type="checkbox" name="for_shipment" v-model="mrf.purpose" value="For Shipment">
				  <label for="for_shipment">For Shipment</label>
				</div>
				<div class="field">
				  <input class="is-checkradio" id="packmats_for_pn" type="checkbox" name="packmats_for_pn" v-model="mrf.purpose" value="Packaging Materials for PN">
				  <label for="packmats_for_pn">Packaging Materials for PN</label>
				</div>
				<div class="field">
				  <input class="is-checkradio" id="packmats_for_wh" type="checkbox" name="packmats_for_wh" v-model="mrf.purpose" value="Packaging Materials for WH">
				  <label for="packmats_for_wh">Packaging Materials for WH</label>
				</div>
				<div class="field">
				  <input class="is-checkradio" id="additional_materials" type="checkbox" name="additional_materials" v-model="mrf.purpose" value="Additional Materials Due to Abnormality">
				  <label for="additional_materials">Additional Materials Due to Abnormality</label>
				</div>
			</div>
			<div class="column is-4">
				<div class="field">
				  <input class="is-checkradio" id="ng_sample" type="checkbox" name="ng_sample" v-model="mrf.purpose" value="NG Sample">
				  <label for="ng_sample">NG Sample</label>
				</div>
				<div class="field">
				  <input class="is-checkradio" id="qc_sample" type="checkbox" name="qc_sample" v-model="mrf.purpose" value="QC Sample">
				  <label for="qc_sample">QC Sample</label>
				</div>
				<div class="field">
					<label for="others" class="label">Others</label>
					<textarea name="others" class="textarea" v-model="mrf.others"></textarea>
				</div>
			</div>
		</div> 
	</div>
</section>
<section class="section">
	<div class="container">
		<h3 class="title" id="materials">Materials</h3>
		<div class="field">
			<button class="button" @click="addMaterial">Add Material</button>
		</div>
		<div class="content is-small">
			<table class="table is-bordered is-hoverable is-narrow">
				<thead>
					<tr>
						<th class="has-text-centered" style="width: 3%">No.</th>
						<th class="has-text-centered" style="width: 10%">Material No</th>
						<th class="has-text-centered" style="width: 30%">Material Name</th>
						<th class="has-text-centered" style="width: 12%">RM Inventory</th>
						<th class="has-text-centered" style="width: 10%">Qty Required</th>
						<th class="has-text-centered" style="width: 12%">Remaining Inventory</th>
						<th class="has-text-centered" style="width: 8%">Transfer To</th>
						<th class="has-text-centered" style="width: 5%">Status</th>
						<th class="has-text-centered" style="width: 5%">Options</th>
					</tr>
				</thead>
				<tbody>
					<tr v-for="(m, index) in materials" v-bind:key="index">
						<td class="has-text-right"><strong>{{ index + 1 }}</strong></td>
						<td>
							<div class="control is-small" :class="{ 'is-loading' : m.is_loading }">
								<input type="text" class="input is-rounded is-small" @input="searchMaterial(m)" v-model="m.material_no">
							</div>
						</td>
						<td>
							<p>{{ m.material_name }}</p>
						</td>
						<td class="has-text-right">
							<p v-if="m.status == true">{{ m.rm_inventory }}</p>
						</td>
						<td class="has-text-right">
							<p class="control">
								<input type="number" class="input is-rounded is-small has-text-left" :class="{ 'is-danger' :  errors.has('qty_required_'+index) || getRemainingInventory(m.material_no) < 0  }" v-model.number="m.qty_required" v-validate="'required|nonzero'" :data-vv-name="'qty_required_'+index" data-vv-validate-on="blur">
							</p>
						</td>
						<td class="has-text-right">
							<p v-if="m.status == true" :class="{'has-text-danger' : getRemainingInventory(m.material_no) < 0 }">{{ getRemainingInventory(m.material_no) }}</p>
						</td>
						<td>
							<p class="select is-fullwidth">
								<select v-model.number="m.area">
									<option value="0" selected="selected"></option>
									<cfif SESSION.mrf.active_division EQ 1>
										<cfloop array="#areas#" item="a">
											<option value=#a.id#>#a.area#</option>
										</cfloop>
									</cfif>
								</select>
							</p>
						</td>
						<td class="has-text-centered">
							<span class="icon has-text-success" v-if="m.status == true && m.is_loading == false" key="true">
							  <i class="fas fa-check" key="true"></i>
							</span>
							<span class="icon has-text-danger" v-else-if="m.status == false && m.is_loading == false" key="false">
							  <i class="fas fa-times" key="false"></i>
							</span>
							<span class="icon" v-else>
							  <i class="fas fa-spinner fa-pulse" key="loading"></i>
							</span>
						</td>
						<td class="has-text-centered">
							<a @click="removeMaterial(index)" class="is-link">Remove</a>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="field is-grouped is-grouped-centered">
			<p class="control">
				<button class="button is-primary is-large" :class="{ 'is-disabled' : isValidated == false }" :disabled="isValidated == false" @click="save">Submit MRF</button>
			</p>
		</div>
	</div>
</section>
</cfoutput>