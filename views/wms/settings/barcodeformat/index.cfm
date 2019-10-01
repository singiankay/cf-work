<cfparam name="type" type="string" default="Motherbox">
<cfparam name="q" type="string" default="">
<cfoutput>
<section class="section">
	<div class="container">
		<div class="content">
			<header class="bd-header">
				<div class="bd-header-titles">
					<h1 class="title">
						Barcode Format
					</h1>
				</div>
			</header>
		</div>
	</div>
</section>
<section class="section">
	<div class="container">
		<div class="table-nav">
			#startFormTag(route="wmsSettingsBarcodeformatIndex", method="get")#
			<nav class="level">
				<div class="level-left">
					<div class="level-item">
						<p class="subtitle is-5">
							<strong>Print Type</strong>
						</p>
					</div>
					<div class="level-item">
						<div class="field">
							<p class="control">
								<span class="select">
									#selectTag(name="type", options=format, selected=params.type)#
								</span>
							</p>
						</div>
					</div>
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
					<div class="field">
						<p class="control">
							#linkTo(route="newWmsSettingsBarcodeformat", class="button is-primary", text="Add New")#
						</p>
					</div>
				</div>
			</nav>
			#endFormTag()#
		</div>
		<div class="content">
			<div class="table-container">
				<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
					<thead>
						<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Description</th>
							<th>Type</th>
							<th>Exclusions</th>
							<th>Image</th>
							<th>Last Updated By</th>
							<th>Options</th>
						</tr>
					</thead>
					<tbody>
						<cfloop array="#barcodeFormats#" item="i">
							<tr>
								<td>#EncodeForHtml(i.id)#</td>
								<td>#linkTo(route="wmsSettingsBarcodeformat", key=i.id, text=EncodeForHtml(i.name))#</td>
								<td>#EncodeForHtml(i.description)#</td>
								<td>#EncodeForHtml(i.type)#</td>
								<td>
									<cfloop array="#i.exclusions#" item="e">
										<span class="tag is-info">#e#</span>
									</cfloop>
								</td>
								<td>
									<figure class="image is-128x128">
										<cfif i.image_path NEQ "">
											#imageTag(source="wms/"&i.image_path)#
										<cfelse>
											#imageTag(source="sample_128x128.png")#
										</cfif>
									</figure>
								</td>
								<td>#i.updated_by#</td>
								<td>
									#startFormTag(route="wmsSettingsBarcodeformat", key=i.id, method="delete")#
										#submitTag(class="button is-danger", value="Delete", argumentCollection={ '@click':'confirmDelete' })#
									#endFormTag()#
								</td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</div>
		</div>
		<nav class="pagination" role="navigation" aria-label="pagination">
			<ul class="pagination-list">
				#paginationLinks(route="wmsSettingsBarcodeformatIndex", class="pagination-link", classForCurrent="pagination-link is-current", prependToPage="<li>", appendToPage="</li>", linkToCurrentPage=true, encode=false)#
			</ul>	
		</nav>
	</div>
</section>
</cfoutput>