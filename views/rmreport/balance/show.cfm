<cfoutput>
<div class="section">
	<div class="container">
		<h3 class="title">RM Balance</h3>
		<p class="subtitle">Click #linkTo(route="rmreportBalanceIndex", text="here")# to go back to List</p>
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
<cfif rcv.recordCount GT 1>
	<div class="section">
		<p>Error! 1 or more active receiving records are existing on this QR Code. Kindly inform MIS to fix this.</p>
	</div>
<cfelseif rcv.recordCount EQ 0>
	<div class="section">
		<p>No record found.</p>
	</div>
<cfelse>
	<div class="section">
		<div class="container">
			<h3 class="title">Summary</h3>
			<div class="box">
				<div class="columns">
					<div class="column is-2"><span><strong>QR Code:</strong></span></div>
					<div class="column is-10"><input type="text" class="input" value="#rcv.U_QRcode#" readonly></div>
				</div>
				<div class="columns">
					<div class="column is-half">
						<div class="columns">
							<div class="column is-one-third"><span><strong>Material No:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_ItemCode#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Material Name:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_ItemDescription#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Source Doc No:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_Reference#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Base Ref:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.Docentry#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Type:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_ItemType#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>UoM:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_Uom#" readonly></div>
						</div>
					</div>
					<div class="column is-half">
						<div class="columns">
							<div class="column is-one-third"><span><strong>Supplier Lot:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_Lotcode#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>NPI Lot:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_Lotcode2#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Supplementary Lot:</strong></span></div>
							<div class="column is-two-thirds"><input type="text" class="input" value="#rcv.U_Lotcode3#" readonly></div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Received Date:</strong></span></div>
							<div class="column is-two-thirds">#dateformat(rcv.u_fifo, 'mm/dd/yyyy')#</div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Expiry Date:</strong></span></div>
							<div class="column is-two-thirds"><span <cfif rcv.U_ExpiryDate LTE now()>class="has-text-danger"</cfif>>#dateformat(rcv.U_ExpiryDate,'mm.dd.yyyy')#</div>
						</div>
						<div class="columns">
							<div class="column is-one-third"><span><strong>Status:</strong></span></div>
							<div class="column is-two-thirds"><span><cfif rcv.Status EQ 'O'>Open<cfelseif rcv.Status EQ 'C'>Closed</cfif></span></div>
						</div>
					</div>
				</div>
			</div>
			<h3 class="title is-4">Balance</h3>
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th class="has-text-centered">Qty In</th>
						<th class="has-text-centered">Qty Out</th>
						<th class="has-text-centered">Qty Balance</th>
						<th class="has-text-centered has-text-danger">Qty NCP</th>
						<th class="has-text-centered has-text-danger">Qty Reinspect</th>
						<th class="has-text-centered has-text-danger">Qty On Hold</th>
						<th class="has-text-centered">Qty For IQC</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<tr>
							<cfif rmStatus.qty_in GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_in, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_in, '_,9.99')#</td>
							</cfif>
							<cfif rmStatus.qty_issued GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_issued, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_issued, '_,9.99')#</td>
							</cfif>
							<cfif rmStatus.qty_balance GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_balance, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_balance, '_,9.99')#</td>
							</cfif>
							<cfif rmStatus.qty_ncp GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_ncp, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_ncp, '_,9.99')#</td>
							</cfif>
							<cfif rmStatus.qty_reinspect GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_reinspect, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_reinspect, '_,9.99')#</td>
							</cfif>
							<cfif rmStatus.qty_on_hold GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_on_hold, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_on_hold, '_,9.99')#</td>
							</cfif>
							<cfif rmStatus.qty_for_iqc GTE 0>
								<td class="has-text-right">#numberFormat(rmStatus.qty_for_iqc, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.qty_for_iqc, '_,9.99')#</td>
							</cfif>
						</tr>
					</tr>
				</tbody>
			</table>
			<h3 class="title is-4">Location</h3>
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th class="has-text-centered">FORM</th>
						<th class="has-text-centered">Form No</th>
						<th class="has-text-centered">IQC-G</th>
						<th class="has-text-centered">IQC-Q</th>
						<th class="has-text-centered">IQC-S</th>
						<th class="has-text-centered">WHS-G</th>
						<th class="has-text-centered">PCK-G</th>
						<th class="has-text-centered">WHS-S</th>
						<th class="has-text-centered">WHS-R</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td class="is-info">Receiving</td>
						<td>#rcv.U_Reference#</td>
						<td class="has-text-right">#numberFormat(rcv.U_Quantity, '_,9.99')#</td>
						<td class="has-text-right"></td>
						<td class="has-text-right"></td>
						<td class="has-text-right"></td>
						<td class="has-text-right"></td>
						<td class="has-text-right"></td>
						<td class="has-text-right"></td>
					</tr>
					<cfloop query="itf">
						<tr>
							<td class="is-warning">Inventory Transfer</td>
							<td>#itf.U_Reference#</td>
							<cfif itf.U_LocationFrom EQ 3>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 3>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif itf.U_LocationFrom EQ 4>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 4>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif itf.U_LocationFrom EQ 15>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 15>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif itf.U_LocationFrom EQ 10>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 10>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif itf.U_LocationFrom EQ 9>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 9>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif itf.U_LocationFrom EQ 14>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 14>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif itf.U_LocationFrom EQ 13>
								<td class="has-text-right has-text-danger">-#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelseif itf.U_LocationTo EQ 13>
								<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
						</tr>
					</cfloop>
					<cfloop query="iss">
						<tr>
							<td class="is-primary">Issuance</td>
							<td>#iss.U_Reference#</td>
							<cfif iss.U_Location EQ "IQC-G">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif iss.U_Location EQ "IQC-Q">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif iss.U_Location EQ "IQC-S">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif iss.U_Location EQ "WHS-G">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif iss.U_Location EQ "PCK-G">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif iss.U_Location EQ "WHS-S">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
							<cfif iss.U_Location EQ "WHS-R">
								<td class="has-text-right has-text-danger">-#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<cfelse>
								<td class="has-text-right"></td>
							</cfif>
						</tr>
					</cfloop>
					<tr>
						<td colspan="2" class="has-text-right has-background-grey-lighter">Total:</td>
						<cfif rmStatus.iqc_g GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.iqc_g, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.iqc_g, '_,9.99')#</td>
						</cfif>
						<cfif rmStatus.iqc_q GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.iqc_q, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.iqc_q, '_,9.99')#</td>
						</cfif>
						<cfif rmStatus.iqc_s GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.iqc_s, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.iqc_s, '_,9.99')#</td>
						</cfif>
						<cfif rmStatus.whs_g GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.whs_g, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.whs_g, '_,9.99')#</td>
						</cfif>
						<cfif rmStatus.pck_g GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.pck_g, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.pck_g, '_,9.99')#</td>
						</cfif>
						<cfif rmStatus.whs_s GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.whs_s, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.whs_s, '_,9.99')#</td>
						</cfif>
						<cfif rmStatus.whs_r GTE 0>
							<td class="has-text-right">#numberFormat(rmStatus.whs_r, '_,9.99')#</td>
						<cfelse>
							<td class="has-text-right has-text-danger">-#numberFormat(rmStatus.whs_r, '_,9.99')#</td>
						</cfif>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
	<div class="section">
		<div class="container">
			<h3 class="title">Receiving</h3>
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th class="is-info">Document</th>
						<th class="is-info">PO No.</th>
						<th class="is-info">PO Rev</th>
						<th class="is-info">Form No</th>
						<th class="is-info">Date Received</th>
						<th class="is-info">Received By</th>
						<th class="is-info">Qty</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td class="">#rcv.U_Doctype#</td>
                 <td class="">#rcv.U_PoNo#</td>
                 <td class="">#rcv.U_RevNo#</td>
                 <td class="">#rcv.U_Reference#</td>
                 <td class="">#dateformat(rcv.U_Fifo,'mm/dd/yyyy')#</td>
                 <td class="">#rcv.U_ReceivedBy#</td>
                 <td class="">#numberFormat(rcv.U_Quantity, '_,9.99')#</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
	<div class="section">
		<div class="container">
			<h3 class="title">Inventory Transfer</h3>
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th class="is-warning">Form No</th>
						<th class="is-warning">From</th>
						<th class="is-warning">To</th>
						<th class="is-warning">Qty</th>
						<th class="is-warning">Inspected By</th>
						<th class="is-warning">Inspection Date</th>
						<th class="is-warning">Received Date</th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="itf">
						<tr>
							<td class="">#itf.U_Reference#</td>
							<td class="has-text-centered">#getLocation(locations, itf.U_LocationFrom)#</td>
							<td class="has-text-centered">#getLocation(locations, itf.U_Locationto)#</td>
							<td class="has-text-right">#numberFormat(itf.U_Quantity, '_,9.99')#</td>
							<td class="">#itf.U_Inspected2By#</td>
							<td class="has-text-right">#dateformat(itf.U_QcStart,'mm/dd/yyyy')#</td>
							<td class="has-text-right">
							    #dateformat(itf.U_Fifo,'mm/dd/yyyy')# 
							    #timeformat(itf.U_Fifo,'HH:mm tt')#
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
	</div>
	<div class="section">
		<div class="container">
			<h3 class="title">Issuance</h3>
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th class="is-primary">JO No</th>
						<th class="is-primary">JOIR No</th>
						<th class="is-primary">Location</th>
						<th class="is-primary">Qty</th>
						<th class="is-primary">Issued By</th>
						<th class="is-primary">Issuance Date</th>
						<th class="is-primary">Received By</th>
						<th class="is-primary">Reference</th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="iss">
						<tr>
							<td>#iss.U_Reference#</td>
							<td>#iss.U_Ref2#</td>
							<td class="has-text-centered">#iss.U_Location#</td>
							<td class="has-text-right">#numberFormat(iss.U_Quantity, '_,9.99')#</td>
							<td>#iss.U_IssuedBy#</td>
							<td class="has-text-right">#dateTimeFormat(iss.U_PostingDate,'mm/dd/yyyy hh:nn:ss tt')#</td>
							<td>#iss.U_ReceivedBy#</td>
							<td>#iss.U_PHFNo#</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
	</div>
</cfif>
</cfoutput>