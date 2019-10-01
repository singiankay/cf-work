<cfparam name="q" type="string" default="">
<cfoutput>
<section class="section">
	<div class="container">
		<h3 class="title">Pending JOs for Approval</h3>
		<div class="table-nav">
			#startFormTag(route="joApprovalIndex", method="get")#
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
				</nav>
			#endFormTag()#
		</div>
		<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
			<thead>
				<tr>
					<th>JO Number</th>
					<th>JO Type</th>
					<th>Rev. No</th>
					<th>Model No.</th>
					<th>Model Name</th>
					<th>Production Month</th>
					<th>Start Date</th>
					<th>End Date</th>
					<th>PP Approval</th>
					<th>PU Approval</th>
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
										<span class="tag is-warning">#j#</span>
									</cfloop>
								</td>
								<td>#jorevision.revision_no#</td>
								<td>#jorevision.model_no#</td>
								<td>#jorevision.model_name#</td>
								<td>#dateFormat(jorevision.production_month, 'mmmm YYYY')#</td>
								<td>#dateFormat(jorevision.requested_start_date, 'yy.mm.dd')#</td>
								<td>#dateFormat(jorevision.requested_end_date, 'yy.mm.dd')#</td>
								<td>#jorevision.pp_approver_status#</td>
								<td>#jorevision.pu_approver_status#</td>
							</cfif>
						</cfloop>
					</tr>
				</cfloop>
			</tbody>
		</table>
		<nav class="pagination" role="navigation" aria-label="pagination">
			<ul class="pagination-list">
				#paginationLinks(route="joEncodeIndex", class="pagination-link", classForCurrent="pagination-link is-current", prependToPage="<li>", appendToPage="</li>", linkToCurrentPage=true, encode=false)#
			</ul>
		</nav>
	</div>
</section>
</cfoutput>