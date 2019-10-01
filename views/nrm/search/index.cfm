<cfparam name="params.material" default="">
<cfparam name="params.supplier" default="">
<cfoutput>
<section class="section">
	<div class="container">
		<cfif isQuery(materials)>
			<h3 class="title is-3">Search Results</h3>
			<!--- <h3 class="subtitle is-5">Click Material No. to show current Inventory Balance</h3> --->
		</cfif>
	</div>
</section>
<section class="section">
	<div class="container">
		<cfif Len(Trim(params.material)) GT 0 OR Len(Trim(params.supplier)) GT 0>
			<nav class="level">
				<div class="level-left">
					<div class="level-item">
						<p>Click the Material No. to show inventory.</p>
					</div>
				</div>
				<div class="level-right">
					<div class="level-item">
						#linkTo(route="nrmSearchGenerate", class="button is-normal", params="material="&params.material&"&supplier="&params.supplier, text="Generate Excel", target="_blank")#
					</div>
				</div>
			</nav>
			<cfif isQuery(materials)>
				<div class="content is-small">
					<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
						<thead>
							<tr>
								<th class="has-text-centered">Material No</th>
								<th class="has-text-centered">Material Name</th>
								<th class="has-text-centered">Price</th>
								<th class="has-text-centered">Currency</th>
								<th class="has-text-centered">UOM</th>
								<th class="has-text-centered">SPQ</th>
								<th class="has-text-centered">Last Purchase Date</th>
								<th class="has-text-centered">Lead Time (Day)</th>
								<th class="has-text-centered">Supplier</th>
								<th class="has-text-centered">Status</th>
							</tr>
						</thead>
						<tbody>
							<cfloop query="materials">
								<tr>
									<td class="has-text-centered">
										#linkTo(route="rmreportBalanceIndex", params="search[mat_no]="&materials.ItemCode, text=materials.ItemCode, target="_blank")#
									</td>
									<td class="has-text-left">#materials.ItemName#</td>
									<td class="has-text-right">#numberFormat(materials.Price, '9,999.99')#</td>
									<td class="has-text-centered">#materials.Currency#</td>
									<td class="has-text-centered">#materials.BuyUnitMsr#</td>
									<td class="has-text-right">#numberFormat(materials.MinOrdrQty, '9,999.99')#</td>
									<td class="has-text-right">#dateFormat(materials.lastPurDat, 'mm/dd/yyyy')#</td>
									<td class="has-text-right">#materials.LeadTime#</td>
									<td class="has-text-centered">#materials.CardName#</td>
									<td class="has-text-centered">
										<cfif materials.frozenFor EQ 'N'>
											<span>Active</span>
										<cfelse>
											<span class="has-text-danger">Inactive</span>
										</cfif>
									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</div>
			</cfif>
		<cfelse>
			<nav class="level">
				<div class="level-left">
					<div class="level-item">
						<p>Results not shown to improve page load performance. Please click generate excel instead. Thank you.</p>
					</div>
				</div>
				<div class="level-right">
					<div class="level-item">
						#linkTo(route="nrmSearchGenerate", class="button is-normal", params="material="&params.material&"&supplier="&params.supplier, text="Generate Excel", target="_blank")#
					</div>
				</div>
			</nav>
		</cfif>
	</div>
</section>
</cfoutput>