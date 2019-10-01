<cfparam name="q" type="string" default="">
<cfoutput>
<section class="section">
	<div class="container">
		<div class="table-nav">
			#startFormTag(route="joEncodeIndex", method="get")#
				<nav class="level">
					<div class="level-left">
						<div class="level-item">
							<div class="field has-addons">
								<p class="control">
									#textFieldTag(name="q", class="input is-expanded", placeholder="Enter any", value=params.q)#
								</p>
								<p class="control">
									<input type="submit" value="Search" class="button">
								</p>
							</div>
						</div>
					</div>
					<div class="level-right">
						<div class="level-item">
							#linkTo(route="newJoEncode", class="button is-normal", text="<span class='icon is-small'><i class='fas fa-plus'></i></span><span>Add New</span>", encode=false)#
						</div>
					</div>
				</nav>
			#endFormTag()#
		</div>
		<div class="content is-small">
			<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
				<thead>
					<tr>
						<th>JO Number</th>
						<th>JO Type</th>
						<th>Rev. No</th>
						<th>Model No.</th>
						<th>Model Name</th>
						<th>Lot Code</th>
						<th>Production Qty</th>
						<th>Shipment Qty</th>
						<th>Production Month</th>
						<th>Start Date</th>
						<th>End Date</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="jo">
						<tr>
							<cfloop query="jorevision">
								<cfif jorevision.jo_id EQ jo.jo_id AND jorevision.revision_no EQ jo.revision_no>
									<td>
										#linkTo(route="joEncodeRevision", encodeKey=jorevision.jo_id, key=jorevision.id, text=jo.jo_number)#
									</td>
									<td>
										<cfloop array=#deserializeJSON(jorevision.type)# item="j">
											<span class="tag is-normal">#j#</span>
										</cfloop>
									</td>
									<td>#jorevision.revision_no#</td>
									<td>#jorevision.model_no#</td>
									<td>#jorevision.model_name#</td>
									<td>#jorevision.lot_code#</td>
									<td>#jorevision.qty_to_produce#</td>
									<td>#jorevision.total_shipment_qty#</td>
									<td>#dateFormat(jorevision.production_month, 'mmmm YYYY')#</td>
									<td>#dateFormat(jorevision.requested_start_date, 'yy.mm.dd')#</td>
									<td>#dateFormat(jorevision.requested_end_date, 'yy.mm.dd')#</td>
									<td>
										<cfif jorevision.status EQ 'Pending'>
											<span class="tag is-link">#jorevision.status#</span>
										<cfelseif jorevision.status EQ 'Approved'>
											<span class="tag is-primary">#jorevision.status#</span>
										<cfelseif jorevision.status EQ 'Canceled'>
											<span class="tag is-danger">#jorevision.status#</span>
										<cfelseif jorevision.status EQ 'Returned'>
											<span class="tag is-warning">#jorevision.status#</span>
										<cfelse>
											<span class="tag is-black">#jorevision.status#</span>
										</cfif>
									</td>
								</cfif>
							</cfloop>
						</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
		<nav class="pagination" role="navigation" aria-label="pagination">
			<ul class="pagination-list">
				#paginationLinks(route="joEncodeIndex", class="pagination-link", classForCurrent="pagination-link is-current", prependToPage="<li>", appendToPage="</li>", linkToCurrentPage=true, encode=false)#
			</ul>
		</nav>
	</div>
</section>
</cfoutput>