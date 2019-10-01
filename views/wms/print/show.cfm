<cfoutput>
	<div :class="{ 'modal' : true, 'is-active' : show_print_modal == true }" v-cloak v-on:keyup.esc="hideModels">
		<div class="modal-background"></div>
		<div class="modal-card">
			<header class="modal-card-head">
				<p class="modal-card-title">Print PRF ## {{ prf }}</p>
				<button class="delete" aria-label="close" @click="hideModels"></button>
			</header>
			<section class="modal-card-body">
				<h3 class="subtitle is-5" v-if="exclusions.length"><strong>Excluded Models</strong></h3>
				<div class="field is-grouped is-grouped-multiline">
					<div class="control" v-for="x in exclusions">
						<div class="tags has-addons">
							<span class="tag is-danger">{{ x.model_no }}</span>
							<span class="tag is-info">{{ x.model_name }}</span>
						</div>
					</div>
				</div>
				<nav class="level">
					<div class="level-left">
						<div class="level-item">
							<p class="subtitle is-5"><strong>Filter</strong></p>
						</div>
						<div class="level-item">
							<div class="field">
								<p class="control">
									<input class="input" type="text" placeholder="Box##/Model No/Name" v-model="q">
								</p>
							</div>
						</div>
					</div>
					<div class="level-right">
						<p><strong>Total Items: {{ shipFilter.length }}</strong></p>
					</div>
				</nav>
				<div class="content">
					<table class="table is-bordered is-narrow is-hoverable is-fullwidth">
						<thead>
							<tr>
								<td>
									<input type="checkbox" class="is-checkradio is-circle is-danger" style="display: none;" id="check_all" @change="toggleModelCheckbox($event)" v-model="check_all">
									<label for="check_all"><strong>All</strong></label>
								</td>	
								<td><strong>BOX ##</strong></td>
								<td class="is-paddingless">
									<table>
										<tr>
											<td width="50" style="border: none;"><strong>Type</strong></td>
											<td width="90" style="border-top: none; border-bottom: none;"><strong>Model No.</strong></td>
											<td width="190" style="border-top: none; border-bottom: none;"><strong>Model Name</strong></td>
											<td width="79" style="border: none;"><strong>Qty</strong></td>
										</tr>
									</table>
								</td>
							</tr>
						</thead>
						<tbody id="template-container">
							<tr v-for="s in shipFilter" v-if="shipFilter.length">
								<td>
									<input type="checkbox" class="is-checkradio is-danger" style="display: none;" :id="'ship_'+s.boxm" v-model="s.selected">
									<label :for="'ship_'+s.boxm"></label>
								</td>
								<td><strong>{{ s.boxm }}</strong></td>
								<td class="is-paddingless">
									<table>
										<tr v-for="l in s.lines">
											<td width="50" style="border: none;"><span class="is-uppercase">{{ l.type }}</span></td>
											<td width="90" style="border-top: none; border-bottom: none;"><span>{{ l.model_no }}</span></td>
											<td width="190" style="border-top: none; border-bottom: none;"><span class="is-size-7">{{ l.model_name }}</span></td>
											<td width="79" style="border: none;"><span class="has-text-right">{{ l.qty.toLocaleString() }}</span></td>
										</tr>
									</table>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</section>
			<footer class="modal-card-foot">
				<button class="button is-danger" @click="print">Print</button>
				<button class="button" @click="hideModels">Cancel</button>
			</footer>
		</div>
	</div>
	<section class="section">
		<div class="container">
			<div class="content">
				<header class="bd-header">
					<div class="bd-header-titles">
						<h1 class="title">Print PRF</h1>
						<h5 class="subtitle">
							#linkto(route="wmsPrintIndex", text="&larr; Go back to PRF List")#
						</h5>
					</div>
				</header>
			</div>
		</div>
	</section>
	<section class="section">
		<div class="container">
			<div class="columns">
				<div class="column is-four-fifths">
					<h3 class="title" id="print">Print</h3>
					<div class="columns">
						<div class="column is-one-third">
							<div class="field">
							  <label class="label">Box Type</label>
							  <div class="control">
							    <div class="select is-fullwidth">
							      <select v-model="box_type" v-cloak>
							      	<cfloop array="#format#" item="i">
							      		<option value="#i#">#i#</option>
							      	</cfloop>
							      </select>
							    </div>
							  </div>
							</div>
							<div class="field">
							  <label class="label">Barcode Format</label>
							  <div class="control">
							    <div class="select is-fullwidth">
							      <select v-model="barcode_format" v-show="barcodeformats.length" v-cloak>
							      	<option v-for="f in barcodeformats" :value="f.id">{{ f.name }}</option>
							      </select>
							    </div>
							  </div>
							</div>
							<div class="field">
							  <div class="control">
							    <button :class="{'button is-link' : true, 'is-disabled' : barcode_format == null}" @click="showModels" :disabled="barcode_format == null">Show Models to Print</button>
							  </div>
							</div>
						</div>
						<div class="column">
							<figure class="image is-1by1">
							  <img :src="getPreview">
							</figure>
						</div>
					</div>

					<h3 class="title" id="prf_details">PRF Details</h3>
					<div class="box">
						<div class="content">
							<div class="columns">
								<div class="column is-one-half">
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">PRF No.</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.prf_number#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">NPI Invoice No.</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.npi_invoice#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Consignee Invoice No.</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.cust_invoice#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Consignee</label>
										</div>
										<div class="field-body">
											<div class="control">
												<cfif isObject(customerName)>
													<p>#customerName.name#</p>
												</cfif>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Consignee Address</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.cust_address#</p>
											</div>
										</div>
									</div>
								</div>
								<div class="column is-one-half">
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Revision No.</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.prf_rev#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Shipment Date</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#dateFormat(prf.date_shipment, "mm/dd/yyyy")#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Courier/Broker</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.courier#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Customer Name in Inspection Data</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.cust_name_inspdata#</p>
											</div>
										</div>
									</div>
									<div class="field is-horizontal">
										<div class="field-label field-data">
											<label class="label">Remarks</label>
										</div>
										<div class="field-body">
											<div class="control">
												<p>#prf.remarks#</p>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<table class="shipment-table">
							<thead>
								<tr>
									<th class="has-text-centered has-text-white-bis has-background-info" colspan="2"><p class="is-size-6">FORWARDER/COURIER</p></th>
									<th class="has-text-centered has-text-white-bis has-background-info" colspan="2"><p class="is-size-6">CUSTOMER</p></th>
									<th class="has-text-centered has-text-white-bis has-background-info" colspan="6"><p class="is-size-6 ">PACKAGING</p></th>
								</tr>
								<tr>
									<th class="has-text-centered shipment-2nd-row" colspan="2"><p class="is-medium">SOFTCOPY</p></th>
									<th class="has-text-centered shipment-2nd-row"><p class="is-medium ">HARD COPY</p></th>
									<th class="has-text-centered shipment-2nd-row"><p class="is-medium">SOFTCOPY</p></th>
									<th class="has-text-centered shipment-2nd-row" colspan="2"><p class="is-size-6">INSIDE THE CARGO</p></th>
									<th class="has-text-centered shipment-2nd-row" colspan="4"><p class="is-size-6">OUTSIDE THE CARGO</p></th>
								</tr>
								<tr>
									<th class="has-text-centered" colspan="2"><p class="is-size-6">Customer Sales Invoice</p></th>
									<cfif prf.chkprf3 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">COO</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">COO</p></th>
									</cfif>
									<cfif prf.chkprf4 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">Inspection Data</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">Inspection Data</p></th>
									</cfif>
									<cfif prf.chkprf5 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">Inspection Data</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">Inspection Data</p></th>
									</cfif>
									<cfif prf.chkprf6 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">Certificate of Conformity</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">Certificate of Conformity</p></th>
									</cfif>
									<cfif prf.chkprf7 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">Sales Invoice</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">Sales Invoice</p></th>
									</cfif>
									<cfif prf.chkprf8 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">Packaging List</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">Packaging List</p></th>
									</cfif>
									<cfif prf.chkprf9 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">QR Code</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">QR Code</p></th>
									</cfif>
									<cfif prf.chkprf10 EQ 1>
										<th class="has-text-centered has-background-warning" rowspan="2"><p class="is-size-7">Declaration of Solid Wood</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light" rowspan="2"><p class="is-size-7">Declaration of Solid Wood</p></th>
									</cfif>
								</tr>
								<tr>
									<cfif prf.chkprf1 EQ 1>
										<th class="has-text-centered has-background-warning"><p class="is-size-7">NPI Format</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light"><p class="is-size-7">NPI Format</p></th>
									</cfif>
									<cfif prf.chkprf2 EQ 1>
										<th class="has-text-centered has-background-warning"><p class="is-size-7">NC Format</p></th>
									<cfelse>
										<th class="has-text-centered has-background-grey-light"><p class="is-size-7">NC Format</p></th>
									</cfif>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td class="has-text-centered">
										<cfif prf.chkprf1 EQ 1>
											<cfif prf.id_user_chkprf1 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf1)# on #dateTimeFormat(prf.date_chkprf1, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
											    <i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf2 EQ 1>
											<cfif prf.id_user_chkprf2 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf2)# on #dateTimeFormat(prf.date_chkprf2, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf3 EQ 1>
											<cfif prf.id_user_chkprf3 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf3)# on #dateTimeFormat(prf.date_chkprf3, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf4 EQ 1>
											<cfif prf.id_user_chkprf4 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf4)# on #dateTimeFormat(prf.date_chkprf4, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf5 EQ 1>
											<cfif prf.id_user_chkprf5 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf5)# on #dateTimeFormat(prf.date_chkprf5, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf6 EQ 1>
											<cfif prf.id_user_chkprf6 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf6)# on #dateTimeFormat(prf.date_chkprf6, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf7 EQ 1>
											<cfif prf.id_user_chkprf7 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf7)# on #dateTimeFormat(prf.date_chkprf7, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf8 EQ 1>
											<cfif prf.id_user_chkprf8 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf8)# on #dateTimeFormat(prf.date_chkprf8, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf9 EQ 1>
											<cfif prf.id_user_chkprf9 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf9)# on #dateTimeFormat(prf.date_chkprf9, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
									<td class="has-text-centered">
										<cfif prf.chkprf10 EQ 1>
											<cfif prf.id_user_chkprf10 NEQ 0>
												<span class="icon is-large tooltip is-tooltip-bottom is-tooltip-danger is-tooltip-multiline" data-tooltip="Inspected by #getVerifierName(verifiernames, prf.id_user_chkprf10)# on #dateTimeFormat(prf.date_chkprf10, 'mmm dd, yyyy hh:nn tt')#">
												    <i class="fas fa-lg fa-check-circle has-text-success"></i>
												</span>
											<cfelse>
												<span class="icon is-large">
												    <i class="fas fa-lg fa-file has-text-danger"></i>
												</span>
											</cfif>
										<cfelse>
											<span class="icon is-large">
												<i class="fas fa-lg fa-file"></i>
											</span>
										</cfif>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					<h3 class="title">Shipment Details</h3>
					<cfloop query="shipmentSorting">
						<cfloop query="#prfitems#">
							<cfif prfitems.id_record EQ shipmentSorting.id_prf_item>
								<div class="box" id="prf_#prfitems.id_record#">
									<nav class="level">
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">Material No</p>
												<p class="title">#prfitems.matnumber#</p>
											</div>
										</div>
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">Material Name</p>
												<p class="title">#getModelName(modelNames,prfitems.matnumber)#</p>
											</div>
										</div>
										
									</nav>
									<nav class="level">
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">Customer P/N</p>
												<p class="title">#prfitems.cust_pn#</p>
											</div>
										</div>
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">Customer PO</p>
												<p class="title">#prfitems.cust_po#</p>
											</div>
										</div>
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">Quantity</p>
												<p class="title">#NumberFormat(prfitems.qty)#</p>
											</div>
										</div>
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">Boxed Qty</p>
												<p class="title">#NumberFormat(getTotalBoxedQty(prfitems.id_record))#</p>
											</div>
										</div>
										<div class="level-item has-text-centered">
											<div>
												<p class="heading">UOM</p>
												<p class="title">#getModelUom(modelNames,prfitems.matnumber)#</p>
											</div>
										</div>
									</nav>
									<div class="content">
										<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
											<thead>
												<tr>
													<th class="blue-sideborder has-text-white-bis has-background-info">PHF/MRF Number</th>
													<th class="blue-sideborder has-text-white-bis has-background-info">Quantity</th>
													<th class="blue-sideborder has-text-white-bis has-background-info">Lot Code</th>
													<th class="blue-sideborder has-text-white-bis has-background-info">Motherbox</th>
													<th class="blue-sideborder has-text-white-bis has-background-info">Innerbox</th>
													<th class="blue-sideborder has-text-white-bis has-background-info">Ext. Seg</th>
													<th class="blue-sideborder has-text-white-bis has-background-info">Inspected</th>
												</tr>
											</thead>
											<tbody>
												<cfloop query="shipdetails">
													<cfif shipdetails.id_prf_item EQ prfitems.id_record>
														<tr>
															<td><a class="link" @click="showPHFDetails(#shipdetails.id_phf#)">#getPHFNames(shipdetails.id_phf)#</a></td>
															<td  class="has-text-right">#Numberformat(shipdetails.qty)#</td>
															<td>#shipdetails.lotcode#</td>
															<td>#shipdetails.boxm#</td>
															<td>#shipdetails.boxi#</td>
															<td>#shipdetails.extseg#</td>
															<td>#shipdetails.boxi#</td>
														</tr>
													</cfif>
												</cfloop>
											</tbody>
										</table>
									</div>
								</div>
							</cfif>
						</cfloop>
					</cfloop>
					<cfif sir.recordCount>
						<h3 class="title">S.I.R.</h3>
						<cfloop query="sir">
							<div class="box" id="sir_#sir.id_record#">
								<nav class="level">
									<div class="level-item has-text-centered">
										<div>
											<p class="heading">SIR Number</p>
											<p class="title">#sir.sirnumber_year#-#NumberFormat(sir.sirnumber_series,'0000')#</p>
										</div>
									</div>
								</nav>
								<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
									<thead>
										<tr>
											<th class="has-text-white-bis has-background-danger">ITEM</th>
											<th class="has-text-white-bis has-background-danger">PRICE</th>
											<th class="has-text-white-bis has-background-danger">WEIGHT</th>
											<th class="has-text-white-bis has-background-danger">RECIPIENT</th>
											<th class="has-text-white-bis has-background-danger">QTY</th>
											<th class="has-text-white-bis has-background-danger">UOM</th>
											<th class="has-text-white-bis has-background-danger">BOX</th>
										</tr>
									</thead>
									<tbody>
										<cfloop query="sir_items">
											<cfif sir_items.idbase EQ sir.id_record>
												<tr>
													<td>#sir_items.item#</td>
													<td class="has-text-right">#NumberFormat(sir_items.price, '_,9.99')#</td>
													<td  class="has-text-right">#sir_items.weight#</td>
													<td>#sir_items.recipient#</td>
													<td  class="has-text-right">#NumberFormat(sir_items.qty)#</td>
													<td>#sir_items.uom#</td>
													<td>
														<div class="field is-grouped is-grouped-multiline">
															<cfloop query="sir_box">
																<cfif sir_box.id_sir_items EQ sir_items.id_record>
																	<div class="control">
																		<div class="tags has-addons">
																			<span class="tag is-dark">#sir_box.boxm#-#sir_box.boxi#</span>
																			<span class="tag is-info">#NumberFormat(sir_box.qty)#</span>
																		</div>
																	</div>
																</cfif>
															</cfloop>
														</div>
													</td>
												</tr>
											</cfif>
										</cfloop>
									</tbody>
								</table>
							</div>
						</cfloop>
					</cfif>
				</div>
				<div class="column">
					<div class="right-sidebar-sticky">
						<scrollactive class="is-active" :offset="65">
							<aside class="menu">
								<p class="menu-label"><strong>PRF #prf.prf_number#</strong></p>
								<p class="menu-label">General</p>
								<ul class="menu-list">
									<li><a href="##print" class="scrollactive-item">Print PRF</a></li>
									<li><a href="##prf_details" class="scrollactive-item">PRF Details</a></li>
								</ul>
								<p class="menu-label">
									Shipment Details
								</p>
								<ul class="menu-list">
									<cfloop query="shipmentSorting">
										<cfloop query="#prfitems#">
											<cfif prfitems.id_record EQ shipmentSorting.id_prf_item>
												<li>
													<a href="##prf_#prfitems.id_record#" class="scrollactive-item">
														<cfif prfitems.qty EQ getTotalBoxedQty(prfitems.id_record)>
															<span class="has-text">#prfitems.matnumber#</span>
														<cfelseif prfitems.qty GT getTotalBoxedQty(prfitems.id_record)>
															<span class="has-text-danger">#prfitems.matnumber#</span>
														<cfelseif prfitems.qty LT getTotalBoxedQty(prfitems.id_record)>
															<span class="has-text-warning">#prfitems.matnumber#</span>
														<cfelse>
															<span class="has-text-info">#prfitems.matnumber#</span>
														</cfif>
													</a>
												</li>
											</cfif>
										</cfloop>
									</cfloop>
								</ul>
								<p class="menu-label">
									S.I.R.
								</p>
								<ul class="menu-list">
									<cfloop query="sir">
										<li><a href="##sir_#sir.id_record#" class="scrollactive-item">#sir.sirnumber_year#-#NumberFormat(sir.sirnumber_series,'0000')#</a></li>
									</cfloop>
								</ul>
								<p class="menu-label">
									Navigation
								</p>
								<ul class="menu-list">
									<li>#linkto(route="wmsPrintIndex", text="PRF List")#</li>
									<li><a @click="scrollToTop">Go to top</a></li>
								</ul>
							</aside>
						</scrollactive>
					</div>
				</div>
			</div>
		</div>
	</section>
</cfoutput>