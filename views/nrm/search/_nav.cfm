<cfoutput>
#startFormTag(method="get", route="nrmSearchIndex")#
	<nav class="navbar is-fixed-top is-primary" role="navigation" aria-label="main navigation">
		<div class="navbar-brand">
		  <a class="navbar-item" href="#urlFor(route='nrmSearchIndex')#">
		    #imageTag(source="logo_nrm.png", width="112", height="28")#
		  </a>
		  <!--- <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarBasicExample">
		    <span aria-hidden="true"></span>
		    <span aria-hidden="true"></span>
		    <span aria-hidden="true"></span>
		  </a> --->
		</div>
		<div id="navbar" class="navbar-menu">
			<div class="navbar-start"></div>
			<div class="navbar-end">
					<div class="navbar-item">
						<div class="field is-grouped">
							<div class="field-label is-normal">
								<label class="label has-text-white">Material No./Name</label>
							</div>
							<div class="control">
								#textFieldTag(name="material", type="text", class="input", value=(structKeyExists(params, "material") ? params.material : ""))#
							</div>
						</div>
					</div>
					<div class="navbar-item">
						<div class="field is-grouped">
							<div class="field-label is-normal">
								<label class="label has-text-white">Supplier</label>
							</div>
							<div class="control">
								<div class="select is-fullwidth is-primary">
									#selectTag(name="supplier", options=suppliers, valueField="cardCode", selected=(structKeyExists(params, "supplier") ? params.supplier : ""), textField="cardName", label=false)#
								</div>
							</div>
						</div>
					</div>
					<div class="navbar-item">
						<p class="control">
							<button type="submit" class="button is-primary is-inverted">
								<span class="icon">
									<i class="fas fa-search" aria-hidden="true"></i>
								</span>
								<span>Search</span>
							</button>
							<!--- <a class="button is-primary is-inverted">
								<span class="icon">
									<i class="fas fa-search" aria-hidden="true"></i>
								</span>
								<span>Search</span>
							</a> --->
						</p>
					</div>
			</div>
		</div>
	</nav>
#endFormTag()#
</cfoutput>