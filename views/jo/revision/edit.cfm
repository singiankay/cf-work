<cfoutput>
<section class="section">
	<div class="container-fluid">
		<div class="columns">
			<div class="column is-10">
				<h3 id="details" class="title">JO <strong class="has-text-primary">{{ jo.jo_number }}</strong></h3>
				<h3 class="subtitle">
					#linkTo(route="joEncodeRevision", encodeKey=params.encodeKey, key=params.key, text="&larr; Go back")#
				</h3>
				<div class="box">
					<div class="columns">
						<div class="column is-one-third">
							<div class="field">
								<label class="label">JO Number</label>
								<div class="control">
									<input type="text" :class="{ 'input' : true, 'is-danger' : errors.has('jo_number') }" v-validate="'required|unique'" data-vv-scope="jo" data-vv-as="JO Number" data-vv-validate-on="blur" name="jo_number" tabindex="1" v-model="jo.jo_number" v-cloak v-focus>
									<p class="help is-danger" v-show="errors.has('jo.jo_number')" v-cloak>{{ errors.first('jo.jo_number') }}</p>
								</div>
							</div>
							<div class="field">
								<label class="label">Designation</label>
								<div class="control">
									<input type="radio" v-model="jo_revision.designation" value="Order" class="is-checkradio" id="designation_order" name="designation" tabindex="2" v-cloak>
									<label for="designation_order">Order</label>
									<input type="radio" v-model="jo_revision.designation" class="is-checkradio" value="Stock" id="designation_stock"  name="designation" tabindex="2" v-cloak>
									<label for="designation_stock">Stock</label>
								</div>
							</div>
							<div class="field">
								<label class="label">Original JO Reference</label>
								<div class="control">
									<input :class="{ 'input' : true }" type="text" tabindex="3" v-model="jo_revision.jo_reference" v-cloak>
								</div>
							</div>
						</div>
						<div class="column is-one-third">
							<div class="field">
								<label class="label">4M Change</label>
								<div class="control">
									<input type="text" class="input" tabindex="4" v-model="jo_revision.fourm_change" v-cloak>
								</div>
							</div>
							<div class="field">
								<label class="label">6M Change</label>
								<div class="control">
									<input type="text" class="input" tabindex="4" v-model="jo_revision.sixm_change" v-cloak>
								</div>
							</div>
							<div class="field">
								<label class="label">SA Number</label>
								<div class="control">
									<input type="text" class="input" tabindex="6" v-model="jo_revision.sa_no" v-cloak>
								</div>
							</div>
						</div>
						<div class="column is-one-third">
							<div class="field">
								<label class="label">Type</label>
								<div class="field">
									<input :class="{ 'is-checkradio' : true, 'is-danger' : errors.has('jo_revision.jo_type') }" v-model="jo_revision.jo_type" data-vv-as="JO type" v-validate="'required'" data-vv-scope="jo" id="jo_type_mass_production" value="Mass Production" type="checkbox" name="jo_type" checked="checked" tabindex="7" v-cloak>
									<label for="jo_type_mass_production">Mass Production</label>
								</div>
								<div class="field">
									<input class="is-checkradio" v-model="jo_revision.jo_type" id="jo_type_regrade" value="Regrade" type="checkbox" name="jo_type" tabindex="7" v-cloak>
									<label for="jo_type_regrade">Regrade</label>
								</div>
								<div class="field">
									<input class="is-checkradio" v-model="jo_revision.jo_type" id="jo_type_retest" value="Retest" type="checkbox" name="jo_type" tabindex="7" v-cloak>
									<label for="jo_type_retest">Retest</label>
								</div>
								<div class="field">
									<input class="is-checkradio" v-model="jo_revision.jo_type" id="jo_type_rework" value="Rework" type="checkbox" name="jo_type" tabindex="7" v-cloak>
									<label for="jo_type_rework">Rework</label>
								</div>
								<div class="field">
									<input class="is-checkradio" v-model="jo_revision.jo_type" id="jo_type_reinspection" value="Reinspection" type="checkbox" name="jo_type" tabindex="7" v-cloak>
									<label for="jo_type_reinspection">Reinspection</label>
								</div>
								<p class="help is-danger" v-show="errors.has('jo.jo_type')" v-cloak>{{ errors.first('jo.jo_type') }}</p>
							</div>
						</div>
					</div>
					<div class="columns">
						<div class="column is-half">
							<div class="field">
								<label class="label">Model</label>
								<div class="control">
									<multiselect 
										v-model="jo_revision.model" :options="modelOptions" label="text" track-by="id" 
										@search-change="searchModel" @close="onTouch" 
										:options-limit="25" placeholder="Enter at least 3 characters to perform search"
										:close-on-select="true" :clear-on-select="true" :show-labels="false" :loading="isLoading"
										:internal-search="false" :allow-empty="false" :hide-selected="true" :preserve-search="true"  :preselect-first="false" 
										v-validate="'required'" :class="{ 'is-danger': errors.first('jo_revision.model')  }" data-vv-validate-on="blur" data-vv-name="model" data-vv-value-path="jo_revision.model" data-vv-scope="jo"
										:tabindex="8" v-tabindex v-cloak>
									</multiselect>
								</div>
								<p class="help is-danger" v-show="errors.has('jo.model')" v-cloak>{{ errors.first('jo.model') }}</p>
							</div>
							<div class="columns">
								<div class="column is-half">
									<div class="field">
										<label class="label">Quantity To Produce</label>
										<div class="control">
											<input :class="{ 'input' : true, 'is-danger' : errors.has('jo_revision.qty_to_produce') }" type="number" v-model="jo_revision.qty_to_produce" v-validate="'required'" data-vv-scope="jo" data-vv-as="Qty To Produce" name="qty_to_produce" placeholder="Enter Integer" tabindex="9" v-cloak>
											<p class="help is-danger" v-show="errors.has('jo_revision.qty_to_produce')" v-cloak>{{ errors.first('jo_revision.qty_to_produce') }}</p>
										</div>
									</div>
									<div class="field">
										<label class="label">Lot Code</label>
										<div class="control">
											<input :class="{ 'input' : true }" type="text" v-model="jo_revision.lot_code" placeholder="Enter LotCode" tabindex="11" v-cloak>
										</div>
									</div>
								</div>
								<div class="column is-half">
									<div class="field">
										<label class="label">Total Shipment Quantity</label>
										<div class="control">
											<input :class="{ 'input' : true, 'is-danger' : errors.has('jo_revision.total_shipment_qty') }" type="number" name="total_shipment_qty" v-model="jo_revision.total_shipment_qty" data-vv-scope="jo" data-vv-as="Total Shipment Quantity" v-validate="'required'" placeholder="Enter Integer" tabindex="10" v-cloak>
											<p class="help is-danger" v-show="errors.has('jo_revision.total_shipment_qty')" v-cloak>{{ errors.first('jo_revision.total_shipment_qty') }}</p>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="column is-half">
							<div class="field">
								<label class="label">Production Month</label>
								<div class="control">
									<vuejs-datepicker name="production_month" :input-class="{ 'input' : true, 'is-danger': errors.has('jo_revision.production_month') }" v-model="jo_revision.production_month" v-validate="'required|date_format'" data-vv-as="Production Month" data-vv-scope="jo" minimum-view="month" maximum-view="month" :format="'MMMM yyyy'" v-cloak></vuejs-datepicker>
									<p class="help is-danger" v-show="errors.has('jo_revision.production_month')" v-cloak>{{ errors.first('jo_revision.production_month') }}</p>
								</div>
							</div>
							<div class="columns">
								<div class="column is-half">
									<div class="field">
										<label class="label">Requested Start Date</label>
										<div class="control">
											<vuejs-datepicker name="requested_start_date" :input-class="{ 'input' : true, 'is-danger': errors.has('jo_revision.requested_start_date') }" v-model="jo_revision.requested_start_date" format="MMMM dd yyyy" v-validate="'required|date_format'" data-vv-as="Requested Start Date" data-vv-scope="jo" v-cloak></vuejs-datepicker>
											<p class="help is-danger" v-show="errors.has('jo_revision.requested_start_date')" v-cloak>{{ errors.first('jo_revision.requested_start_date') }}</p>
										</div>
									</div>
								</div>
								<div class="column is-half">
									<div class="field">
										<label class="label">Requested End Date</label>
										<div class="control">
											<vuejs-datepicker name="requested_end_date" :input-class="{ 'input' : true, 'is-danger': errors.has('jo_revision.requested_end_date') }" v-model="jo_revision.requested_end_date" v-model="jo_revision.requested_end_date" format="MMMM dd yyyy" v-validate="'required|date_format'" data-vv-as="Requested End Date" data-vv-scope="jo" v-cloak></vuejs-datepicker>
											<p class="help is-danger" v-show="errors.has('jo_revision.requested_end_date')" v-cloak>{{ errors.first('jo_revision.requested_end_date') }}</p>
										</div>
									</div>
								</div>
							</div>								
						</div>
					</div>
				</div>
				<h3 class="title" id="materials" v-cloak>Materials</h3>
				<div class="box" v-cloak>
					<div class="columns">
						<div class="column is-one-third">
							<div class="field">
								<label class="label">Batch No.</label>
								<div class="control">
									<input class="input" type="text" v-model="jo_revision.batch_no" tabindex="13">
								</div>
							</div>
							<label class="label">Inclusion</label>
							<div class="field">
								<input class="is-checkradio" id="include_chemicals" type="checkbox" name="include_chemicals" tabindex="14" v-model="jo_revision.include_chemicals">
								<label for="include_chemicals">Chemicals</label>
							</div>
						</div>
						<div class="column is-two-thirds">
							<div class="field">
								<label class="label">Remarks</label>
								<div class="control">
									<textarea class="textarea" v-model="jo_revision.remarks" placeholder="Enter Anything here." tabindex="15" v-cloak></textarea>
								</div>
							</div>
						</div>
					</div>
					<div class="columns">
						<div class="column is-one-third">
							<label class="label">Legend</label>
							<ul>
								<li><span class="icon"><i class="fas fa-star fa-fw"></i></span>Primary Materials</li>
								<li><span class="icon"><i class="far fa-star fa-fw"></i></span>Alternatives</li>
								<li><span class="icon has-text-link"><i class="fas fa-star fa-fw"></i></span>Materials</li>
								<li><span class="icon has-text-success"><i class="fas fa-star fa-fw"></i></span>Packaging Materials</li>
								<li><span class="icon has-text-danger"><i class="fas fa-star fa-fw"></i></span>Chemicals</li>
							</ul>
						</div>
						<div class="column is-one-third">
							<label class="label">Options</label>
							<div class="field is-grouped">
								<div class="control">
								  <button class="button is-primary" @click="calculateBom" tabindex="16">{{ calculateText }}</button>
								</div>
							</div>
						</div>
					</div>
					<div class="content is-small">
						<table class="table is-bordered is-narrow is-hoverable is-fullwidth">
							<thead>
								<tr>
									<td style="min-width: 20px; max-width: 20px;"><strong>No.</strong></td>
									<td class="is-paddingless" style="min-width: 830px; max-width: 830px;">
										<table class="table is-bordered is-narrow is-hoverable">
											<tr>
												<td style="border-top: none; border-bottom: none; min-width: 30px; max-width: 30px;"><strong>Type</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 80px; max-width: 80px;"><strong>Material No</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 180px; max-width: 180px;"><strong>Material Name</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 82px; max-width: 82px;"><strong>BOM</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 65px; max-width: 65px;"><strong>Qty Req.</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 45px; max-width: 45px;"><strong>m YR</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 66px; max-width: 66px;"><strong>RM Inv</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 79px; max-width: 79px;"><strong>WIP</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 70px; max-width: 70px;"><strong>Remaining RM Inv</strong></td>
												<td style="border-top: none; border-bottom: none; min-width: 64px; max-width: 64px;"><strong>Lacking Qty</strong></td>
												<td style="border: none; min-width: 84px; max-width: 84px;"><strong>Material for Request</strong></td>
											</tr>
										</table>
									</td>
								</tr>
							</thead>
							<tbody>
								<tr v-for="(m, index) in materials">
									<td width="20px">{{ index | materialIndex }}</td>
									<td class="is-paddingless" width="830px">
										<table class="table is-bordered is-narrow is-hoverable is-fullwidth">
											<tr>
												<td style="border-top: none; border-bottom: none; min-width: 30px; max-width: 30px;">
													<span class="icon tooltip is-tooltip-right" :class="materialClass(m.material_class, classifications)" :data-tooltip="m.material_class | materialClassification(classifications)">
													  <i class="fas fa-star"></i>
													</span>
												</td>
												<td style="border-top: none; border-bottom: none; min-width: 80px; max-width: 80px;">{{ m.material_no }}</td>
												<td style="border-top: none; border-bottom: none; min-width: 180px; max-width: 180px;">{{ m.material_name }}</td>
												<td style="border-top: none; border-bottom: none; min-width: 82px; max-width: 82px;">{{ m.bom }}</td>
												<td style="border-top: none; border-bottom: none; min-width: 65px; max-width: 65px;">{{ m.qty_required | roundOff(4) }}</td>
												<td style="border-top: none; border-bottom: none; min-width: 45px; max-width: 45px;">{{ m.yield_rate }}%</td>
												<td style="border-top: none; border-bottom: none; min-width: 66px; max-width: 66px;" :class="{ 'has-text-danger' : m.rm_inventory == 0 }">{{ m.rm_inventory | roundOff(4) }}</td>
												<td style="border-top: none; border-bottom: none; min-width: 79px; max-width: 79px;"><input type="number" class="input is-small" v-model.number="m.wip" @blur="( m.wip.length === 0 ? m.wip = 0 : false )"></td>
												<td style="border-top: none; border-bottom: none; min-width: 70px; max-width: 70px;">{{ getRemainingMaterial(m, m.material_no) | roundOff(4) }}</td>
												<td style="border-top: none; border-bottom: none; min-width: 64px; max-width: 64px;" class="has-text-danger">{{ getLackingRMInventory(m, m.material_no) | roundOff(4) }}</td>
												<td style="border: none; min-width: 84px; max-width: 84px;">{{ getMaterialForRequest(m, m.material_no) | roundOff(4) }}</td>
											</tr>
											<tr v-for="a in m.alternatives">
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 30px; max-width: 30px;">
													<span class="icon tooltip is-tooltip-right" :class="materialClass(m.material_class, classifications)" :data-tooltip="m.material_class | materialClassification(classifications)">
													  <i class="far fa-star"></i>
													</span>
												</td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 80px; max-width: 80px;">{{ a.material_no }}</td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 180px; max-width: 180px;">{{ a.material_name }}</td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 82px; max-width: 82px;"></td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 65px; max-width: 65px;"></td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 45px; max-width: 45px;"></td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 66px; max-width: 66px;" :class="{ 'has-text-danger' : a.rm_inventory == 0 }">{{ a.rm_inventory | roundOff(4)  }}</td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 79px; max-width: 79px;"><input type="number" class="input is-small" v-model.number="a.wip" @blur="( a.wip.length === 0 ? a.wip = 0 : false )"></td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 70px; max-width: 70px;">{{ getRemainingAlternative(m, m.material_no, a.material_no) | roundOff(4) }}</td>
												<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 64px; max-width: 64px;"></td>
												<td class="has-background-grey-lighter" style="border: none; min-width: 84px; max-width: 84px;"></td>
											</tr>
										</table>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<h3 class="title" id="posting">Posting</h3>
				<div class="box" v-cloak>
					<div class="content">
						<h3 class="title is-3">Approvers</h3>
						<p>A confirmation email will be sent on designated users below if declared.</p>
						<div class="columns">
							<div class="column is-half">
								<h3 class="title is-4">Planning</h3>
								<div class="field is-horizontal">
									<div class="field-label is-normal">
										<label class="label">Approver:</label>
									</div>
									<div class="field-body">
										<div class="field is-narrow">
											<div class="control">
												<div class="select is-fullwidth">
													<select v-model="pp_approver">
														<option v-for="ppa in pp_approvers" :value="ppa.id">{{ ppa.text }}</option>
													</select>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="field is-horizontal">
									<div class="field-label is-normal">
										<label class="label">Deputy:</label>
									</div>
									<div class="field-body">
										<div class="field is-narrow">
											<div class="control">
												<div class="select is-fullwidth">
													<select v-model="pp_deputy">
														<option v-for="ppd in pp_deputies" :value="ppd.id">{{ ppd.text }}</option>
													</select>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="column is-half">
								<h3 class="title is-4">Purchasers</h3>
								<div class="field is-horizontal">
									<div class="field-label is-normal">
										<label class="label">Approver:</label>
									</div>
									<div class="field-body">
										<div class="field is-narrow">
											<div class="control">
												<div class="select is-fullwidth">
													<select v-model="pu_approver">
														<option v-for="pua in pu_approvers" :value="pua.id">{{ pua.text }}</option>
													</select>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="field is-horizontal">
									<div class="field-label is-normal">
										<label class="label">Deputy:</label>
									</div>
									<div class="field-body">
										<div class="field is-narrow">
											<div class="control">
												<div class="select is-fullwidth">
													<select v-model="pu_deputy">
														<option v-for="pud in pu_deputies" :value="pud.id">{{ pud.text }}</option>
													</select>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<h3 class="title is-3">Notification</h3>
						<p>Upon approval of this JO, an email will be sent to registered users in the notification page.</p>
						<div class="field is-grouped is-grouped-right">
							<div class="control">
							  	<button type="button" class="button is-primary" :class="{ 'is-disabled' : materials.length == 0, 'is-disabled is-loading' : isSubmit == true }" :disabled="materials.length == 0 || isSubmit == true" @click="updateRevision">Update Revision</button>
								#startFormTag(method="get", route="joEncodeRedirectShow", ref="redirect")#
									#hiddenFieldTag(name="status", argumentCollection={ ':value':'redirect_status' })#
									#hiddenFieldTag(name="message", argumentCollection={ ':value':'redirect_message' })#
									#hiddenFieldTag(name="encodeKey", value=params.encodeKey )#
									#hiddenFieldTag(name="key", value=params.key )#
								#endFormTag()#
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="column is-2">
				<div class="right-sidebar-sticky">
					<scrollactive class="is-active" :offset="65">
						<aside class="menu">
							<p class="menu-label"><strong>NAVIGATION</strong></p>
							<ul class="menu-list">
								<li><a href="##details" id="nav_details" class="scrollactive-item">JO</a></li>
								<li><a href="##materials" id="nav_materials" class="scrollactive-item">Materials</a></li>
								<li><a href="##posting" id="nav_posting"  class="scrollactive-item">Posting</a></li>
							</ul>
						</aside>
					</scrollactive>
				</div>
			</div>
		</div>
	</div>
</section>
</cfoutput>