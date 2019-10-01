<cfparam name="q" type="string" default="">
<cfoutput>
	<section class="section">
		<div class="container">
			<div class="content">
				<header class="bd-header">
					<div class="bd-header-titles">
						<h1 class="title">PRF List</h1>
					</div>
				</header>
			</div>
		</div>
	</section>
	<section class="section">
		<div class="container">
			<div class="table-nav">
				#startFormTag(route="wmsPrintIndex", method="get")#
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
							<div class="field">
								<p class="control">
									<multiselect 
										v-model="form.customer" 
										:options="customerOptions" 
										label="text"
										track-by="id"
										@search-change="searchCustomer"
										@select="selectCustomer"
										:options-limit="25"
										placeholder="Search for Customer Name"
										:close-on-select="true" 
										:clear-on-select="true" 
										:show-labels="false"
										:loading="isLoading"
										:internal-search="false"
										:allow-empty="true"
										:preserve-search="true"  
										:preselect-first="false" >
									</multiselect>
								</p>
							</div>
						</div>
						<div class="level-item">
							<input type="text" id="customerid_holder" class="input is-expanded" v-model="form.customer.id">
						</div>
						<div class="level-item">
							<button type="button" class="button is-medium is-info is-outlined" @click="copyCustomerId">Copy</button>
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
								<th>PRF Number</th>
								<th>Revision</th>
								<th>NPI Invoice</th>
								<th>Customer Name</th>
								<th>Shipment Date</th>
								<th>Verified by</th>
								<th>Disposition</th>
							</tr>
						</thead>
						<tbody>
							<cfif prf.recordCount>
								<cfloop query="prf">
									<tr>
										<td>
											#linkTo(route="wmsPrint", key=prf.id_record, text=prf.prf_number)#
										</td>
										<td>#prf.prf_rev#</td>
										<td>#prf.npi_invoice#</td>
										<td>#getCustomerName(customerNames, prf.cust_name)#</td>
										<td>#dateFormat(prf.date_shipment, "mm/dd/yyyy")#</td>
										<td class="has-text-centered">
											<cfif prf.id_user_verify NEQ 0>
												<span class="tag is-primary">
													#getVerifierName(verifiernames, prf.id_user_verify)#
												</span>
											<cfelse>
												<span class="icon has-text-danger">
													<i class="fas fa-times-circle"></i>
												</span>
											</cfif>
										</td>
										<td>
											<cfif prf.for_shipping EQ 0>
												#getDisposition(disposition, prf.id_disposition)#
											<cfelse>
												For Shipment
											</cfif>
											
										</td>
									</tr>
								</cfloop>
							<cfelse>
								<tr>
									<td colspan="7" class="has-text-centered">No record</td>
								</tr>
							</cfif>
							
						</tbody>
					</table>
				</div>
			</div>
			<nav class="pagination" role="navigation" aria-label="pagination">
				<ul class="pagination-list">
					#paginationLinks(route="wmsPrintIndex", class="pagination-link", classForCurrent="pagination-link is-current", prependToPage="<li>", appendToPage="</li>", linkToCurrentPage=true, encode=false)#
				</ul>	
			</nav>
			<div class="spacing-container">
				<article class="message is-primary">
				  <div class="message-header">
				    <p>Searching via Customer Name</p>
				  </div>
				  <div class="message-body">
				    To search via customer name, search in the field provided on the right side of the filter and copy the customer code. Use the customer code on the table's search field instead
				  </div>
				</article>
			</div>
		</div>
	</section>
</cfoutput>