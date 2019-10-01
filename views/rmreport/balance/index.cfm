<cfoutput>
<div class="section">
	<div class="container-fluid">
		<h3 class="title">RM Balance</h3>
	</div>
</div>
<div class="section">
	<div class="container">
		#startFormTag(method="get", route="rmreportBalanceIndex")#
			<div class="field has-addons">
					<div class="control is-expanded">
						#textFieldTag(name="qrcode", placeholder="Enter QR Code or ID Record", class="input", label=false)#
					</div>
					<div class="control">
						#submitTag(class="button is-info", value="Search QR Code")#
					</div>
			</div>
		#endFormTag()#
	</div>
</div>
<div class="section">
	<div class="container-fluid">
		<h3 class="title">Records</h3>
		<p class="subtitle">Up to 100 records shown. Click the <strong>Generate Excel</strong> button for full results.</p>
		<div class="box">
			#startFormTag(method="get", route="rmreportBalanceIndex")#
				#hiddenField(objectName="search", property="view", value=params.search.view)#
				<div class="columns">
					<cfif SESSION.rmreport.division EQ 1>
						<div class="column is-one-fifth">
							<div class="field">
								<label for="area" class="label">Area</label>
								<div class="control is-expanded">
									<div class="select is-primary is-fullwidth">
										#select(objectName="search", property="area", class="input", valueField="id", textField="area", id="area", options=areas, label=false)#
									</div>
								</div>
							</div>
						</div>
					</cfif>
					<div class="column is-one-fifth">
						<div class="field">
							<label for="mat_no" class="label">Mat No.</label>
							<div class="control">
								#textField(objectName="search", property="mat_no", class="input", id="mat_no", placeholder="Mat No.", value=params.search.mat_no, label=false)#
							</div>
						</div>
					</div>
					<div class="column is-one-fifth">
						<div class="field">
							<label for="mat_name" class="label">Mat Name</label>
							<div class="control">
								#textField(objectName="search", property="mat_name", class="input", id="mat_name", placeholder="Mat Name", value=params.search.mat_name, label=false)#
							</div>
						</div>
					</div>
					<div class="column is-one-fifth">
						<div class="field">
							<label for="docentry" class="label">DocEntry</label>
							<div class="control">
								#textField(objectName="search", property="docentry", class="input", id="docentry", placeholder="DocEntry", value=params.search.docentry, label=false)#
							</div>
						</div>
					</div>
					<div class="column is-one-fifth">
						<div class="field">
							<label for="id_record" class="label">ID Record</label>
							<div class="control">
								#textField(objectName="search", property="id_record", class="input", id="id_record", placeholder="ID Record", value=params.search.id_record, label=false)#
							</div>
						</div>
					</div>
				</div>
				<div class="columns">
					<div class="column is-one-fifth">
						<div class="field">
							<label for="supplier_lot" class="label">Supplier Lot</label>
							<div class="control">
								#textField(objectName="search", property="supplier_lot", class="input", id="supplier_lot", placeholder="Supplier Lot", value=params.search.supplier_lot, label=false)#
							</div>
						</div>
					</div>
					<div class="column is-one-fifth">
						<div class="field">
							<label for="supplementary_lot" class="label">Supplementary Lot</label>
							<div class="control">
								#textField(objectName="search", property="supplementary_lot", class="input", id="supplementary_lot", placeholder="Supplementary Lot", value=params.search.supplementary_lot, label=false)#
							</div>
						</div>
					</div>
					<div class="column is-one-fifth">
						<div class="field">
							<label for="npi_lot" class="label">NPI Lot</label>
							<div class="control">
								#textField(objectName="search", property="npi_lot", class="input", id="npi_lot", placeholder="NPI Lot", value=params.search.npi_lot, label=false)#
							</div>
						</div>
					</div>
					<div class="column">
						<label class="label">Options</label>
						<div class="field is-grouped">
							<p class="control">
								#submitTag(class="button is-danger", value="Filter")#
							</p>
							<cfif isAdmin()>
								<p class="control">
									#linkTo(
										route="rmreportBalanceGenerate", 
										class="button is-primary", 
										text="Generate Excel", 
										target="_blank",
										params="search[view]=balance&search[mat_no]="&params.search.mat_no&"&search[mat_name]="&params.search.mat_name&"&search[supplier_lot]="&params.search.supplier_lot&"&search[npi_lot]="&params.search.npi_lot&"&search[supplementary_lot]="&params.search.supplementary_lot&"&search[docentry]="&params.search.docentry&"&search[id_record]="&params.search.id_record)#
								</p>
							</cfif>
						</div>
					</div>
				</div>
			#endFormTag()#
		</div>
		<div class="tabs is-centered is-toggle is-toggle-rounded spacing-container">
			<ul>
				<cfif params.search.view EQ "balance">
					<li class="is-active">
						#linkTo(
							route="rmreportBalanceIndex", 
							text="<span class='icon is-small'><i class='fas fa-balance-scale'></i></span><span>Balance</span>", 
							encode="false",
							params="search[view]=balance&search[mat_no]="&params.search.mat_no&"&search[mat_name]="&params.search.mat_name&"&search[supplier_lot]="&params.search.supplier_lot&"&search[npi_lot]="&params.search.npi_lot&"&search[supplementary_lot]="&params.search.supplementary_lot&"&search[docentry]="&params.search.docentry&"&search[id_record]="&params.search.id_record)#
					</li>
					<li>
						#linkTo(
							route="rmreportBalanceIndex", 
							text="<span class='icon is-small'><i class='fas fa-map-marked'></i></span><span>Location</span>", 
							encode="false",
							params="search[view]=location&search[mat_no]="&params.search.mat_no&"&search[mat_name]="&params.search.mat_name&"&search[supplier_lot]="&params.search.supplier_lot&"&search[npi_lot]="&params.search.npi_lot&"&search[supplementary_lot]="&params.search.supplementary_lot&"&search[docentry]="&params.search.docentry&"&search[id_record]="&params.search.id_record)#
					</li>
				<cfelse>
					<li>
						#linkTo(
							route="rmreportBalanceIndex", 
							text="<span class='icon is-small'><i class='fas fa-balance-scale'></i></span><span>Balance</span>",
							encode="false",
							params="search[view]=balance&search[mat_no]="&params.search.mat_no&"&search[mat_name]="&params.search.mat_name&"&search[supplier_lot]="&params.search.supplier_lot&"&search[npi_lot]="&params.search.npi_lot&"&search[supplementary_lot]="&params.search.supplementary_lot&"&search[docentry]="&params.search.docentry&"&search[id_record]="&params.search.id_record)#
					</li>
					<li class="is-active">
						#linkTo(
							route="rmreportBalanceIndex", 
							text="<span class='icon is-small'><i class='fas fa-map-marked'></i></span><span>Location</span>",  
							encode="false",
							params="search[view]=location&search[mat_no]="&params.search.mat_no&"&search[mat_name]="&params.search.mat_name&"&search[supplier_lot]="&params.search.supplier_lot&"&search[npi_lot]="&params.search.npi_lot&"&search[supplementary_lot]="&params.search.supplementary_lot&"&search[docentry]="&params.search.docentry&"&search[id_record]="&params.search.id_record)#
					</li>
				</cfif>
			</ul>
		</div>
		<nav class="level">
		  <p class="level-item has-text-centered"><strong>Total:</strong>&nbsp;#numberformat(search.total.qty_balance, '_,9.99')#</p>
		</nav>
		<div class="content is-small">
			<table class="table is-bordered is-striped is-hoverable is-fullwidth is-narrow">
				<thead>
					<tr>
						<th colspan="3" class="has-text-centered is-primary">Material Information</th>
						<th colspan="3" class="has-text-centered is-warning">Lot Codes</th>
						<cfif params.search.view EQ "balance">
							<th colspan="7" class="has-text-centered">Balance</th>
						<cfelse>
							<th colspan="7" class="has-text-centered">Location</th>
						</cfif>
						<th colspan="2" class="has-text-centered is-info">Dates</th>
					</tr>
					<tr>
						<th class="has-text-centered is-primary">Material No.</th>
						<th class="has-text-centered is-primary">Material Name</th>
						<th class="has-text-centered is-primary">Area</th>
						<th class="has-text-centered is-warning">Supplier <br>Lot</th>
						<th class="has-text-centered is-warning">NPI <br>Lot</th>
						<th class="has-text-centered is-warning">Supplementary <br>Lot</th>
						<cfif params.search.view EQ "balance">
							<th class="has-text-centered">Qty <br>In</th>
							<th class="has-text-centered">Qty <br>Out</th>
							<th class="has-text-centered">Qty <br>Balance</th>
							<th class="has-text-centered has-text-danger">Qty <br>NCP</th>
							<th class="has-text-centered has-text-danger">Qty <br>Reinspect</th>
							<th class="has-text-centered has-text-danger">Qty <br>On Hold</th>
							<th class="has-text-centered">Qty <br>For IQC</th>
						<cfelse>
							<th class="has-text-centered">IQC-G</th>
							<th class="has-text-centered">IQC-Q</th>
							<th class="has-text-centered">IQC-S</th>
							<th class="has-text-centered">WHS-G</th>
							<th class="has-text-centered">WHS-R</th>
							<th class="has-text-centered">WHS-S</th>
							<th class="has-text-centered">PCK-G</th>
						</cfif>
						<th class="has-text-centered is-info">Date <br>Received</th>
						<th class="has-text-centered is-info">Exp. <br>Date</th>
					</tr>
				</thead>
				<tbody>
					<cfif isSearch>
						<cfloop query="search.partial">
							<tr>
								<td class="has-text-left">
									#linkTo(route="rmreportBalance", key=search.partial.id, text=search.partial.material_no, target="_blank")#
								</td>
								<td>#search.partial.material_name#</td>
								<td class="has-text-centered">#search.partial.area#</td>
								<td class="has-text-centered">#search.partial.supplier_lot#</td>
								<td class="has-text-centered">#search.partial.npi_lot#</td>
								<td class="has-text-centered">#search.partial.supplementary_lot#</td>
								<cfif params.search.view EQ "balance">
									<td <cfif search.partial.qty_in LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_in, '_,9.99')#</td>
									<td <cfif search.partial.qty_issued LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_issued, '_,9.99')#</td>
									<td <cfif search.partial.qty_balance LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_balance, '_,9.99')#</td>
									<td <cfif search.partial.qty_ncp LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_ncp, '_,9.99')#</td>
									<td <cfif search.partial.qty_reinspect LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_reinspect, '_,9.99')#</td>
									<td <cfif search.partial.qty_on_hold LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_on_hold, '_,9.99')#</td>
									<td <cfif search.partial.qty_for_iqc LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.qty_for_iqc, '_,9.99')#</td>
								<cfelse>
									<td <cfif search.partial.iqc_g LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.iqc_g, '_,9.99')#</td>
									<td <cfif search.partial.iqc_q LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.iqc_q, '_,9.99')#</td>
									<td <cfif search.partial.iqc_s LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.iqc_s, '_,9.99')#</td>
									<td <cfif search.partial.whs_g LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.whs_g, '_,9.99')#</td>
									<td <cfif search.partial.pck_g LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.pck_g, '_,9.99')#</td>
									<td <cfif search.partial.whs_s LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.whs_s, '_,9.99')#</td>
									<td <cfif search.partial.whs_r LT 0>class="has-text-right has-text-danger"<cfelse> class="has-text-right"</cfif>>#numberFormat(search.partial.whs_r, '_,9.99')#</td>
								</cfif>
								<td class="has-text-centered">#dateFormat(search.partial.receive_date, 'yy.mm.dd')#</td>
								<td <cfif search.partial.expiration_date LTE now()>class="has-text-centered has-text-danger"<cfelse>class="has-text-centered"</cfif>>#dateFormat(search.partial.expiration_date, 'yy.mm.dd')#</td>
							</tr>
						</cfloop>
					</cfif>
				</tbody>
			</table>
		</div>
	</div>
</div>
</cfoutput>