<cfoutput>
<section class="section">
	<div class="container">
		<h3 class="title">Adjustment</h3>
		#linkTo(route="wmsIssuanceAdjustmentapprovalIndex", text='Click here ')#
		to go back to adjustment list
	</div>
</section>
<section class="section">
	<div class="container">
		<div class="columns">
			<div class="column is-half">
				<div class="content">
					<h3>Record Details</h3>
					<table class="table is-fullwidth is-bordered is-narrow">
						<tbody>
							<tr>
								<th>Material Number</th>
								<td>#orcv.U_ItemCode#</td>
							</tr>
							<tr>
								<th>Material Name</th>
								<td>#orcv.U_ItemDescription#</td>
							</tr>
							<tr>
								<th>Supplier Lot</th>
								<td>#orcv.U_Lotcode#</td>
							</tr>
							<tr>
								<th>NPI Lot</th>
								<td>#orcv.U_Lotcode2#</td>
							</tr>
							<tr>
								<th>Supplimentary Lot</th>
								<td>#orcv.U_Lotcode3#</td>
							</tr>
							<tr>
								<th>Source Doc No.</th>
								<td>#orcv.U_Reference#</td>
							</tr>
							<tr>
								<th>Received Date</th>
								<td>#orcv.U_Fifo#</td>
							</tr>
							<tr>
								<th>UOM</th>
								<td>#orcv.U_Uom#</td>
							</tr>
							<tr>
								<th>Material type</th>
								<td>#orcv.U_ItemType#</td>
							</tr>
							<tr>
								<th>QR Code</th>
								<td><input type="text" class="input" value="#orcv.U_QRcode#"></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="column is-half">
				<div class="content">
					<cfif adjustment.save_type EQ 'Create'>
						<h3>for <span class="has-text-danger">Saving</span></h3>
					<cfelseif adjustment.save_type EQ 'Update'>
						<h3>for <span class="has-text-primary">Updating</span></h3>
					</cfif>
					<table class="table is-bordered is-striped is-narrow is-hoverable">
						<cfif adjustment.save_type EQ 'Create'>
							<tbody>
								<tr>
									<td><strong>Document Type</strong></td>
									<td>#adjustment.document_type_to#</td>
								</tr>
								<tr>
									<td><strong>WH Reference Number</strong></td>
									<td>#adjustment.wh_ref_no_to#</td>
								</tr>
								<tr>
									<td><strong>Quantity</strong></td>
									<td>#adjustment.qty_to#</td>
								</tr>
								<tr>
									<td><strong>Warehouse</strong></td>
									<td>#adjustment.wh_to#</td>
								</tr>
								<tr>
									<td><strong>Area</strong></td>
									<td>#adjustment.area_to#</td>
								</tr>
								<tr>
									<td><strong>JO Number</strong></td>
									<td>#adjustment.jo_no_to#</td>
								</tr>
								<tr>
									<td><strong>Issued Date</strong></td>
									<td>#adjustment.issued_date_to#</td>
								</tr>
								<tr>
									<td><strong>Request Date</strong></td>
									<td>#adjustment.request_date_to#</td>
								</tr>
								<tr>
									<td><strong>Issued By</strong></td>
									<td>#adjustment.issued_by_to#</td>
								</tr>
								<tr>
									<td><strong>Remarks</strong></td>
									<td>#adjustment.remarks_to#</td>
								</tr>
								<tr>
									<td><strong>Approved/Rejected By</strong></td>
									<td colspan="2">#getApprover(adjustment.approved_by)#</td>
								</tr>
							</tbody>
						<cfelseif adjustment.save_type EQ 'Update'>
							<thead>
								<tr>
									<th>Fields</th>
									<th>From</th>
									<th>To</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td><strong>Document Type</strong></td>
									<td>#adjustment.document_type_from#</td>
									<td>#adjustment.document_type_to#</td>
								</tr>
								<tr>
									<td><strong>WH Reference Number</strong></td>
									<td>#adjustment.wh_ref_no_from#</td>
									<td>#adjustment.wh_ref_no_to#</td>
								</tr>
								<tr>
									<td><strong>Quantity</strong></td>
									<td>#adjustment.qty_from#</td>
									<td>#adjustment.qty_to#</td>
								</tr>
								<tr>
									<td><strong>Warehouse</strong></td>
									<td>#adjustment.wh_from#</td>
									<td>#adjustment.wh_to#</td>
								</tr>
								<tr>
									<td><strong>Area</strong></td>
									<td>#adjustment.area_from#</td>
									<td>#adjustment.area_to#</td>
								</tr>
								<tr>
									<td><strong>JO Number</strong></td>
									<td>#adjustment.jo_no_from#</td>
									<td>#adjustment.jo_no_to#</td>
								</tr>
								<tr>
									<td><strong>Issued Date</strong></td>
									<td>#adjustment.issued_date_from#</td>
									<td>#adjustment.issued_date_to#</td>
								</tr>
								<tr>
									<td><strong>Request Date</strong></td>
									<td>#adjustment.request_date_from#</td>
									<td>#adjustment.request_date_to#</td>
								</tr>
								<tr>
									<td><strong>Issued By</strong></td>
									<td>#adjustment.issued_by_from#</td>
									<td>#adjustment.issued_by_to#</td>
								</tr>
								<tr>
									<td><strong>Remarks</strong></td>
									<td>#adjustment.remarks_from#</td>
									<td>#adjustment.remarks_to#</td>
								</tr>
								<tr>
									<td><strong>Is Canceled</strong></td>
									<td>#(adjustment.canceled_from EQ 'Y' ? 'Yes' : 'No')#</td>
									<td>#(adjustment.canceled_to EQ 'Y' ? 'Yes' : 'No')#</td>
								</tr>
								<tr>
									<td><strong>Approved/Rejected By</strong></td>
									<td colspan="2">#getApprover(adjustment.approved_by)#</td>
								</tr>
							</tbody>
						</cfif>
					</table>
					<div class="field">
					  <label class="label">Supervisor's Remarks</label>
					  <div class="control">
					    <textarea class="textarea" placeholder="Response will be emailed back to requestor" v-model="remarks" v-cloak></textarea>
					  </div>
					</div>
					<cfif adjustment.status EQ 'Pending'>
						<div class="field is-grouped">
							<div class="control">
								#startFormTag(route="wmsIssuanceAdjustmentapproval", method="patch", key=params.key)#
									#hiddenField(objectName="adjustment", property="remarks", argumentCollection={ ':value':'remarks' })#
									#submitTag(value="Approve", class="button is-link")#
								#endFormTag()#
							</div>
							<div class="control">
								#startFormTag(route="wmsIssuanceAdjustmentapproval", method="delete", key=params.key)#
									#hiddenField(objectName="adjustment", property="remarks", argumentCollection={ ':value':'remarks' })#
									#submitTag(value="Reject", class="button is-danger")#
								#endFormTag()#
							</div>
							<div class="control">
								#linkTo(route="wmsIssuanceAdjustmentapprovalIndex", class="button is-text", text="Go Back")#
							</div>
						</div>
					<cfelse>
						<cfif adjustment.status EQ 'Approved'>
							<a class="button is-success is-disabled">
								<span class="icon is-small">
									<i class="fas fa-check"></i>
								</span>
								<span>#adjustment.status#</span>
							</a>
						<cfelseif adjustment.status EQ 'Rejected'>
							<a class="button is-danger is-outlined is-disabled">
							   <span>#adjustment.status#</span>
							   <span class="icon is-small">
							     <i class="fas fa-times"></i>
							   </span>
							 </a>
						</cfif>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</section>
<section class="section">	
	<div class="container">
		<h3 class="title">Issuance Records</h3>
		<div class="content is-small">
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th>Doctype</th>
						<th>WH Ref No</th>
						<th>Location</th>
						<th>JO No</th>
						<th>Qty</th>
						<th>Section</th>
						<th>Issued Date</th>
						<th>Request Date</th>
						<th>Issued By</th>
						<th>Released Date</th>
						<th>Update Date</th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="oiss">
						<tr <cfif adjustment.save_type EQ 'Update' AND adjustment.issuance_id EQ oiss.Docentry>class="is-selected"</cfif>>
							<td>#oiss.U_Doctype#</td>
							<td>#oiss.U_Reference#</td>
							<td>#oiss.U_Location#</td>
							<td>#oiss.U_Ref2#</td>
							<td class="has-text-right">#NumberFormat(oiss.U_Quantity)#</td>
							<td>#oiss.U_ReceivedBy#</td>
							<td>#DateFormat(oiss.U_ShipDate, 'mm/dd/yyyy')#</td>
							<td>#DateFormat(oiss.U_Fifo, 'mm/dd/yyyy')#</td>
							<td>#oiss.U_IssuedBy#</td>
							<td>#DateFormat(oiss.U_PostingDate, 'mm/dd/yyyy')#</td>
							<td>#DateFormat(oiss.UpdateDate, 'mm/dd/yyyy')#</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<div class="tags has-addons">
			  <span class="tag is-medium">Total</span>
			  <span class="tag is-link is-medium">#NumberFormat(issuanceTotal)#</span>
			</div>
		</div>
	</div>
</section>
</cfoutput>