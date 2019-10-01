<cfoutput>
	<section class="section">
		<div class="container-fluid">
			<div class="columns">
				<div class="column is-10">
					<h3 id="details" class="title">JO <strong class="has-text-primary">#jo.jo_number#</strong></h3>
					<h3 class="subtitle">
						#linkTo(route="joEncodeIndex", text="&larr; Go back to list")#
					</h3>
					<div class="box">
						<div class="columns">
							<div class="column is-one-third">
								<div class="field">
									<label class="label">JO Number</label>
									<div class="control">
										<input type="text" class="input is-readonly" readonly="readonly" :value="jo.jo_number" v-cloak>
									</div>
								</div>
								<div class="field">
									<label class="label">Designation</label>
									<div class="control">
										<input type="text" class="input is-readonly" readonly="readonly" :value="jo_revision.designation" v-cloak>
									</div>
								</div>
								<div class="field">
									<label class="label">Original JO Reference</label>
									<div class="control">
										<input class="input is-readonly" type="text" :value="jo_revision.jo_reference" readonly="readonly" v-cloak>
									</div>
								</div>
							</div>
							<div class="column is-one-third">
								<div class="field">
									<label class="label">4M Change</label>
									<div class="control">
										<input type="text" class="input is-readonly" readonly="readonly" :value="jo_revision.fourm_change" v-cloak>
									</div>
								</div>
								<div class="field">
									<label class="label">6M Change</label>
									<div class="control">
										<input type="text" class="input is-readonly" readonly="readonly" :value="jo_revision.sixm_change" v-cloak>
									</div>
								</div>
								<div class="field">
									<label class="label">SA Number</label>
									<div class="control">
										<input type="text" class="input is-readonly" readonly="readonly" :value="jo_revision.sa_no" v-cloak>
									</div>
								</div>
							</div>
							<div class="column is-one-third">
								<div class="field">
									<label class="label">Type</label>
									<div class="field">
										<input class="is-checkradio" id="jo_type_mass_production" value="Mass Production" type="checkbox" readonly="readonly" v-model="jo_revision.jo_type" v-cloak>
										<label for="jo_type_mass_production">Mass Production</label>
									</div>
									<div class="field">
										<input class="is-checkradio" id="jo_type_regrade" value="Regrade" type="checkbox" readonly="readonly" v-model="jo_revision.jo_type" v-cloak>
										<label for="jo_type_regrade">Regrade</label>
									</div>
									<div class="field">
										<input class="is-checkradio" id="jo_type_retest" value="Retest" type="checkbox" readonly="readonly" v-model="jo_revision.jo_type" v-cloak>
										<label for="jo_type_retest">Retest</label>
									</div>
									<div class="field">
										<input class="is-checkradio" id="jo_type_rework" value="Rework" type="checkbox" readonly="readonly" v-model="jo_revision.jo_type" v-cloak>
										<label for="jo_type_rework">Rework</label>
									</div>
									<div class="field">
										<input class="is-checkradio" id="jo_type_reinspection" value="Reinspection" type="checkbox" readonly="readonly" v-model="jo_revision.jo_type" v-cloak>
										<label for="jo_type_reinspection">Reinspection</label>
									</div>
								</div>
							</div>
						</div>
						<div class="columns">
							<div class="column is-half">
								<div class="field">
									<label class="label">Model</label>
									<div class="control">
										<input type="text" class="input is-readonly" :value="model" readonly="readonly">
									</div>
								</div>
								<div class="columns">
									<div class="column is-half">
										<div class="field">
											<label class="label">Quantity To Produce</label>
											<div class="control">
												<input class="input is-readonly" type="number" readonly="readonly" :value="jo_revision.qty_to_produce" v-cloak>
											</div>
										</div>
										<div class="field">
											<label class="label">Lot Code</label>
											<div class="control">
												<input class="input is-readonly" type="text" readonly="readonly" :value="jo_revision.lot_code" v-cloak>
											</div>
										</div>
									</div>
									<div class="column is-half">
										<div class="field">
											<label class="label">Total Shipment Quantity</label>
											<div class="control">
												<input class="input is-readonly" type="number" readonly="readonly" :value="jo_revision.total_shipment_qty" v-cloak>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="column is-half">
								<div class="field">
									<label class="label">Production Month</label>
									<div class="control">
										<input class="input is-readonly" type="text" readonly="readonly" :value="monthView(jo_revision.production_month)" v-cloak>
									</div>
								</div>
								<div class="columns">
									<div class="column is-half">
										<div class="field">
											<label class="label">Requested Start Date</label>
											<div class="control">
												<input class="input is-readonly" type="text" readonly="readonly" :value="dateView(jo_revision.requested_start_date)" v-cloak>
											</div>
										</div>
									</div>
									<div class="column is-half">
										<div class="field">
											<label class="label">Requested End Date</label>
											<div class="control">
												<input class="input is-readonly" type="text" readonly="readonly" :value="dateView(jo_revision.requested_end_date)" v-cloak>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<p class="field has-text-centered">
							<strong>Document Status: &nbsp; </strong>
							<span>{{ jo_revision.status }}</span>
						</p>
					</div>
					<h3 class="title" id="materials">Materials</h3>
					<div class="box">
						<div class="columns">
							<div class="column is-one-third">
								<div class="field">
									<label class="label">Batch No.</label>
									<div class="control">
										<input class="input is-readonly" readonly="readonly" type="text" :value="jo_revision.batch_no">
									</div>
								</div>
								<div class="field">
									<label class="label">Inclusion</label>
									<div class="field">
										<input class="is-checkradio is-readonly" id="include_chemicals" type="checkbox" name="include" readonly="readonly" v-model="jo_revision.include_chemicals">
										<label for="include_chemicals">Chemicals</label>
									</div>
								</div>
							</div>
							<div class="column is-two-thirds">
								<div class="field">
									<label class="label">Remarks</label>
									<div class="control">
										<textarea class="textarea is-readonly" readonly="readonly" v-model="jo_revision.remarks" placeholder="Enter Anything here." tabindex="15" v-cloak></textarea>
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
													<td style="border-top: none; border-bottom: none; min-width: 45px; max-width: 45px;"><strong>Mat YR</strong></td>
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
								<tbody v-if="materials.length">
									<tr v-for="(m, mI) in materials">
										<td width="20px">{{ m.assortment }}</td>
										<td class="is-paddingless" style="min-width: 830px; max-width: 830px;">
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
													<td style="border-top: none; border-bottom: none; min-width: 65px; max-width: 65px;">{{ m.qty_required }}</td>
													<td style="border-top: none; border-bottom: none; min-width: 45px; max-width: 45px;">{{ m.yield_rate }}</td>
													<td style="border-top: none; border-bottom: none; min-width: 66px; max-width: 66px;" :class="{ 'has-text-danger' : m.rm_inventory == 0 }">{{ m.rm_inventory }}</td>
													<td style="border-top: none; border-bottom: none; min-width: 79px; max-width: 79px;">{{ m.wip }}</td>
													<td style="border-top: none; border-bottom: none; min-width: 70px; max-width: 70px;">{{ m.remaining_rm_inventory }}</td>
													<td style="border-top: none; border-bottom: none; min-width: 64px; max-width: 64px;" class="has-text-danger">{{ m.lacking_qty }}</td>
													<td style="border: none; min-width: 84px; max-width: 84px;">{{ m.material_for_request }}</td>
												</tr>
												<tr v-for="(a, aI) in m.alternatives">
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
													<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 66px; max-width: 66px;" :class="{ 'has-text-danger' : m.rm_inventory == 0 }">{{ a.rm_inventory }}</td>
													<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 79px; max-width: 79px;">{{ a.wip }}</td>
													<td class="has-background-grey-lighter" style="border-top: none; border-bottom: none; min-width: 70px; max-width: 70px;">{{ a.remaining_rm_inventory }}</td>
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
					<div class="box">
						<div class="columns">
							<div class="column is-half">
								<p class="subtitle is-5 is-spaced">Planning</p>
								<table class="table is-bordered is-fullwidth is-narrow" v-if="jo_revision.pp_approver_status == 'Pending'">
									<tr>
										<th>Status</th>
										<td class="has-text-centered has-background-warning">{{ jo_revision.pp_approver_status }}</td>
									</tr>
									<tr>
										<th>Approver</th>
										<td class="has-text-centered">{{ jo_revision.pp_approver }}</td>
									</tr>
									<tr>
										<th>Deputy</th>
										<td class="has-text-centered">{{ jo_revision.pp_deputy }}</td>
									</tr>
								</table>
								<table class="table is-bordered is-fullwidth is-narrow" v-else-if="jo_revision.pp_approver_status == 'Approved' || jo_revision.pp_approver_status == 'Disapproved'">
									<tr>
										<th>Status</th>
										<td class="has-text-centered" :class="(jo_revision.pp_approver_status == 'Approved' ? 'has-background-success' : 'has-background-danger')">{{ jo_revision.pp_approver_status }}</td>
									</tr>
									<tr>
										<th>Evaluated By</th>
										<td class="has-text-centered">{{ jo_revision.pp_evaluated_by }}</td>
									</tr>
									<tr>
										<th>Date</th>
										<td class="has-text-centered">{{ jo_revision.pp_evaluated_date | dateView }}</td>
									</tr>
								</table>
							</div>
							<div class="column is-half">
								<p class="subtitle is-5 is-spaced">Purchasing</p>
								<table class="table is-bordered is-fullwidth is-narrow" v-if="jo_revision.pu_approver_status == 'Pending'">
									<tr>
										<th>Status</th>
										<td class="has-text-centered has-background-warning">{{ jo_revision.pu_approver_status }}</td>
									</tr>
									<tr>
										<th>Approver</th>
										<td class="has-text-centered">{{ jo_revision.pu_approver }}</td>
									</tr>
									<tr>
										<th>Deputy</th>
										<td class="has-text-centered">{{ jo_revision.pu_deputy }}</td>
									</tr>
								</table>
								<table class="table is-bordered is-fullwidth is-narrow" v-else-if="jo_revision.pu_approver_status == 'Approved' || jo_revision.pu_approver_status == 'Disapproved'">
									<tr>
										<th>Status</th>
										<td class="has-text-centered" :class="(jo_revision.pu_approver_status == 'Approved' ? 'has-background-success' : 'has-background-danger')">{{ jo_revision.pu_approver_status }}</td>
									</tr>
									<tr>
										<th>Evaluated By</th>
										<td class="has-text-centered">{{ jo_revision.pu_evaluated_by }}</td>
									</tr>
									<tr>
										<th>Date</th>
										<td class="has-text-centered">{{ jo_revision.pu_evaluated_date | dateView }}</td>
									</tr>
								</table>
							</div>
						</div>
						<div class="columns">
							<div class="column is-half">
								<div class="field" v-if="jo_revision.pp_approver_status == 'Approved' || jo_revision.pp_approver_status == 'Disapproved'">
									<label class="label">Remarks</label>
									<div class="control">
										<textarea class="textarea is-readonly" readonly="readonly" placeholder="PP Remarks">{{ jo_revision.pp_approver_remarks }}</textarea>
									</div>
								</div>
								<div class="field"  v-if="jo_revision.pp_approver_status == 'Pending' && (jo_revision.pp_approver_id == #SESSION.jo.user_id# || jo_revision.pp_deputy_id == #SESSION.jo.user_id#)">
									<label class="label">Remarks</label>
									<div class="control">
										<textarea class="textarea" placeholder="PP Remarks" v-model="pp_remarks"></textarea>
									</div>
								</div>
								<div class="field is-grouped is-grouped-centered" v-if="jo_revision.pp_approver_status == 'Pending' && (jo_revision.pp_approver_id == #SESSION.jo.user_id# || jo_revision.pp_deputy_id == #SESSION.jo.user_id#)">
									<p class="control">
										<form :action="'#urlFor("joApproverIndex")#/'+current_rev_id" method="post">
											#hiddenFieldTag(name="remarks", argumentCollection={ ':value':'pp_remarks' })#
											#hiddenFieldTag(name="type", value="pp")#
											#hiddenFieldTag(name="_method", value="patch")#
											<button type="submit" class="button is-primary">Approve</button>
										</form>
									</p>
									<p class="control">
										<form :action="'#urlFor("joApproverIndex")#/'+current_rev_id" method="post">
											#hiddenFieldTag(name="remarks", argumentCollection={ ':value':'pp_remarks' })#
											#hiddenFieldTag(name="type", value="pp")#
											#hiddenFieldTag(name="_method", value="delete")#
											<button type="submit" class="button is-danger" :class="{ 'is-disabled' : pp_remarks.trim().length <= 0 }" :disabled="pp_remarks.trim().length <= 0">Disapprove</button>
										</form>
									</p>
								</div>
							</div>
							<div class="column is-half">
								<div class="field" v-if="jo_revision.pu_approver_status == 'Approved' || jo_revision.pu_approver_status == 'Disapproved'">
									<label class="label">Remarks</label>
									<div class="control">
										<textarea class="textarea is-readony" readonly="readonly" placeholder="PP Remarks">{{ jo_revision.pu_approver_remarks }}</textarea>
									</div>
								</div>
								<div class="field"  v-if="jo_revision.pu_approver_status == 'Pending' && (jo_revision.pu_approver_id == #SESSION.jo.user_id# || jo_revision.pu_deputy_id == #SESSION.jo.user_id#)">
									<label class="label">Remarks</label>
									<div class="control">
										<textarea class="textarea" placeholder="PU Remarks" v-model="pu_remarks"></textarea>
									</div>
								</div>
								<div class="field is-grouped is-grouped-centered" v-if="jo_revision.pu_approver_status == 'Pending' && (jo_revision.pu_approver_id == #SESSION.jo.user_id# || jo_revision.pu_deputy_id == #SESSION.jo.user_id#)">
									<p class="control">
										<form :action="'#urlFor("joApproverIndex")#/'+current_rev_id" method="post">
											#hiddenFieldTag(name="remarks", argumentCollection={ ':value':'pu_remarks' })#
											#hiddenFieldTag(name="type", value="pu")#
											#hiddenFieldTag(name="_method", value="patch")#
											<button type="submit" class="button is-primary">Approve</button>
										</form>
									</p>
									<p class="control">
										<form :action="'#urlFor("joApproverIndex")#/'+current_rev_id" method="post">
											#hiddenFieldTag(name="remarks", argumentCollection={ ':value':'pu_remarks' })#
											#hiddenFieldTag(name="type", value="pu")#
											#hiddenFieldTag(name="_method", value="delete")#
											<button type="submit" class="button is-danger" :class="{ 'is-disabled' : pu_remarks.trim().length <= 0 }" :disabled="pu_remarks.trim().length <= 0">Disapprove</button>
										</form>							
									</p>
								</div>
							</div>
						</div>
						<div class="columns">
							<div class="column is-one-third">
								<p class="subtitle is-5 is-spaced">JO Document</p>
								<table class="table is-bordered is-fullwidth">
									<tr>
										<th>Document Status</th>
										<td class="has-text-centered">{{ jo_revision.status }}</td>
									</tr>
									<tr>
										<th>Created By</th>
										<td class="has-text-centered">{{ jo_revision.posted_by }}</td>
									</tr>
									<tr>
										<th>Date</th>
										<td class="has-text-centered">{{ jo_revision.document_date | dateView  }}</td>
									</tr>
								</table>
							</div>
							<div class="column is-two-thirds">
								#startFormTag(method="delete", route="joEncode", key=params.key)#
									<cfif isEncoder()>
										<p class="subtitle is-5 is-spaced" v-if="jo_revision.status == 'Canceled'">Cancellation Remarks</p>
										<p class="subtitle is-5 is-spaced" v-else-if="current_rev_id == max_rev.id">Revise/Cancel JO</p>
										<div class="field">
											<textarea class="textarea is-readonly is-danger" readonly="readonly" v-if="jo_revision.status == 'Canceled'">{{ jo_revision.cancel_remarks }}</textarea>
											#textareaTag(name="remarks", class="textarea", required=true, placeholder="Cancel JO Remarks", label=false, argumentCollection={ 'v-model': 'cancel_remarks', 'v-else-if': "jo_revision.posted_by_id == #SESSION.jo.user_id# && current_rev_id == max_rev.id && jo_revision.status != 'Canceled'" })#
										</div>
										<div class="field is-grouped is-grouped-centered" v-if="jo_revision.posted_by_id == #SESSION.jo.user_id# && current_rev_id == max_rev.id">
											<div class="control" v-if="current_rev_id == max_rev.id && jo_revision.status == 'Returned'">
												<a :href="'#urlFor("joEncodeIndex")#/'+jo_no+'/revision/'+current_rev_id+'/edit'" class="button is-info" v-cloak>Edit Revision</a>
											</div>
											<div class="control" v-else-if="jo_revision.status == 'Approved' || jo_revision.status == 'Canceled'">
												<a :href="'#urlFor("joEncodeIndex")#/'+jo_no+'/revision/new'" class="button is-info" v-cloak>New Revision</a>
											</div>
											<div class="control" v-if="jo_revision.status != 'Canceled'">
												<button type="submit" class="button is-danger" :class="{'is-disabled' : cancel_remarks.trim().length <= 0 }" :disabled="cancel_remarks.trim().length <= 0" @click="confirmCancel" v-cloak>Cancel JO</button>
											</div>
										</div>
									<cfelse>
										<p class="subtitle is-5 is-spaced" v-if="jo_revision.status == 'Canceled'">Cancellation Remarks</p>
										<div class="field" v-if="jo_revision.status == 'Canceled'">
											<textarea class="textarea is-readonly is-danger" readonly="readonly" v-cloak>{{ jo_revision.cancel_remarks }}</textarea>
										</div>
									</cfif>
								#endFormTag()#
							</div>
							
						</div>
					</div>
				</div>
				<div class="column is-2">
					<div class="right-sidebar-sticky">
						<scrollactive class="is-active" :offset="65">
							<aside class="menu">
								<p class="menu-label"><strong>LATEST REVISION</strong></p>
								<ul class="menu-list">
									<li v-cloak><span>Rev. {{ max_rev_no }}</span></li>
								</ul>
								<p class="menu-label"><strong>SHOW REVISION NO.</strong></p>
								<ul class="menu-list">
									<li v-for="r in revisions" v-cloak><a :href="'#urlFor(route="joEncodeRevisionIndex", encodeKey=params.encodeKey)#/'+r.id" :class="{'is-active' : r.id == #params.key#}">{{ r.revision_no }}</a></li>
								</ul>
								<p class="menu-label"><strong>NAVIGATION</strong></p>
								<ul class="menu-list">
									<li><a href="##details" class="scrollactive-item">JO Details</a></li>
									<li><a href="##materials" class="scrollactive-item">Materials</a></li>
									<li><a href="##posting" class="scrollactive-item">Posting</a></li>
								</ul>
							</aside>
						</scrollactive>
					</div>
				</div>
			</div>
		</div>
	</section>
</cfoutput>