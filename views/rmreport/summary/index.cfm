<cfoutput>
<div class="section">
	<div class="container">
		<h3 class="title">RM Balance Summary</h3>
	</div>
</div>
<div class="section">
	<div class="container">
		<h3 class="title">Records</h3>
		<div class="box">
			#startFormTag(method="get", route="rmreportSummaryIndex")#
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
					<div class="column">
						<label class="label">Options</label>
						<div class="field is-grouped">
							<cfif SESSION.rmreport.division EQ 1>
								<p class="control">
									#submitTag(class="button is-danger", value="Filter")#
								</p>
							</cfif>
							<p class="control">
								#linkTo(
									route="rmreportSummaryGenerate", 
									class="button is-primary", 
									text="Generate Excel", 
									target="_blank"
								)#
							</p>
						</div>
					</div>
				</div>
			#endFormTag()#
		</div>
		<div class="content is-small">
			<table class="table is-bordered is-striped is-hoverable is-fullwidth is-narrow">
				<thead>
					<tr>
						<th>Area</th>
						<th>Material No</th>
						<th>Material Name</th>
						<th>Classification</th>
						<th>Material Type</th>
						<th>Qty Balance</th>
					</tr>
				</thead>
				<tbody>
					<cfif isSearch>
						<cfloop query="search.result">
							<tr>
								<td>#search.result.area#</td>
								<td>#linkTo(route="rmreportBalanceIndex", params="search[mat_no]="&search.result.material_no, text=search.result.material_no, target="_blank")#</td>
								<td>#search.result.material_name#</td>
								<td>#search.result.classification#</td>
								<td>#search.result.material_type#</td>
								<td class="has-text-right">#numberFormat(search.result.qty_balance, '_,9.99')#</td>
							</tr>
						</cfloop>
					</cfif>
				</tbody>
			</table>
		</div>
	</div>
</div>
</cfoutput>