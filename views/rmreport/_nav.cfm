<cfoutput>
<nav class="navbar is-fixed-top" role="navigation" aria-label="main navigation">
	<div class="navbar-brand">
		<a class="navbar-item" href="#urlFor(route='rmreportBalanceIndex')#">
			#imageTag(source="logo_rmreports.png", width="112", height="28")#
		</a>
		<!--- <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarBasicExample">
				<span aria-hidden="true"></span>
				<span aria-hidden="true"></span>
				<span aria-hidden="true"></span>
		</a> --->
	</div>
	<div id="navbar" class="navbar-menu">
		<div class="navbar-start">
			<cfif params.route EQ "rmreportbalanceindex">
				#linkTo(route="rmreportBalanceIndex", text="Balance", class="navbar-item has-text-primary has-background-white-ter")#
			<cfelse>
				#linkTo(route="rmreportBalanceIndex", text="Balance", class="navbar-item")#
			</cfif>
			<cfif params.route EQ "rmreportSummaryIndex">
				#linkTo(route="rmreportSummaryIndex", text="Summary", class="navbar-item has-text-primary has-background-white-ter")#
			<cfelse>
				#linkTo(route="rmreportSummaryIndex", text="Summary", class="navbar-item")#
			</cfif>
			<cfif params.route EQ "rmreportBalance">
				<span class="navbar-item has-text-primary has-background-white-ter">Status</span>
			</cfif>
		</div>
		<div class="navbar-end">
			<cfif isAdmin()>
				<div class="navbar-item">
					<strong>Hello #SESSION.rmreport.firstname#!</strong>
				</div>
			<cfelse>
				<div class="navbar-item">
					<strong>Hello!</strong>
				</div>
				<div class="navbar-item">
					#linkTo(route="rmreportAdmin", text="Login as Admin", class="navbar-item")#
				</div>
			</cfif>
			<div class="navbar-item">
				<div class="navbar-item has-dropdown is-hoverable">
					<cfloop array="#divisions#" item="d">
						<cfif d.id EQ SESSION.rmreport.division>
							<a class="navbar-link">#d.code#</a>
						</cfif>
					</cfloop>
					<div class="navbar-dropdown">
						<cfloop array="#divisions#" item="d">
							<cfif d.id NEQ SESSION.rmreport.division>
								#linkTo(route="rmreportDivisionSetDivision", params="key=#d.id#", text="#d.code#", class="navbar-item" )#
							</cfif>
						</cfloop>
					</div>
				</div>
			</div>
			<div class="navbar-item">
				<div class="buttons">
					#linkTo(controller="rmreport.login", action="delete", class="button is-light", text="Logout")#
				</div>
			</div>
		</div>
	</div>
</nav>
</cfoutput>