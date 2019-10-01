<cfoutput>
<section class="section">
	<div class="container">
		<h3 class="title">Adjustments</h3>
	</div>
</section>
<section class="section">
	<div class="container">
		<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
			<thead>
				<tr>
					<th>RR/Form No.</th>
					<th>Material Number</th>
					<th>Material Name</th>
					<th>PO No.</th>
					<th>Invoice No.</th>
					<th>Document Type</th>
					<th>Action</th>
					<th>Status</th>
					<th>QR Code</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="adjustments">
					<tr >
						<td>#linkTo(route="wmsIssuanceAdjustmentapproval", key=adjustments.id, text=getRRNumber(whlabel, adjustments.whlbl_id))#</td>
						<td>#getMaterialNumber(whlabel, adjustments.whlbl_id)#</td>
						<td>#getMaterialName(orcv, adjustments.whlbl_id)#</td>
						<td>#getPONumber(whlabel, adjustments.whlbl_id)#</td>
						<td>#getInvoiceNumber(whlabel, adjustments.whlbl_id)#</td>
						<td>#adjustments.document_type_to#</td>
						<td>#adjustments.save_type#</td>
						<td>
							<cfif adjustments.status EQ 'Pending'>
								<a class="button is-danger is-outlined is-disabled">
									<span class="icon is-small">
										<i class="fas fa-spinner"></i>
									</span>
									<span>#adjustments.status#</span>
								</a>
							<cfelse>
								<cfif adjustments.status EQ 'Approved'>
									<a class="button is-success is-disabled">
										<span class="icon is-small">
											<i class="fas fa-check"></i>
										</span>
										<span>#adjustments.status#</span>
									</a>
								<cfelseif adjustments.status EQ 'Rejected'>
									<a class="button is-danger is-disabled">
										<span class="icon is-small">
											<i class="fas fa-times"></i>
										</span>
										<span>#adjustments.status#</span>
									</a>
								</cfif>
							</cfif>
						</td>
						<td>
							<input type="text" class="input" value="#getQRCode(orcv, adjustments.whlbl_id)#">
						</td>
					</tr>
				</cfloop>
			</tbody>
		</table>
		<nav class="pagination" role="navigation" aria-label="pagination">
			<ul class="pagination-list">
				#paginationLinks(route="wmsIssuanceAdjustmentapprovalIndex", class="pagination-link", classForCurrent="pagination-link is-current", prependToPage="<li>", appendToPage="</li>", linkToCurrentPage=true, encode=false)#
			</ul>	
		</nav>
	</div>
</section>
</cfoutput>