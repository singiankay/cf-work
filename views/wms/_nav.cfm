<cfoutput>
<nav class="navbar is-fixed-top is-white" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item" href="#urlFor(route='wmsPrintIndex')#">
      #imageTag(source="logo_wms.png", width="112", height="28")#
    </a>
    <!--- <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarBasicExample">
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
    </a> --->
  </div>
  <div id="navbar" class="navbar-menu">
    <div class="navbar-start">
      <div class="navbar-item has-dropdown is-hoverable">
        <a class="navbar-link">Barcode Printing</a>
        <div class="navbar-dropdown">
          #linkTo(controller="wms.print", action="index", class="navbar-item", text="Print")#
          #linkTo(route="wmsSettingsBarcodeformatIndex", action="index", class="navbar-item", text="Barcode Format")#
        </div>
      </div>
      <div class="navbar-item has-dropdown is-hoverable">
        <a class="navbar-link">Issuance</a>
        <div class="navbar-dropdown">
          #linkTo(route="wmsIssuanceAdjustmentapprovalIndex", class="navbar-item", text="Adjustment Approval")#
        </div>
      </div>
    </div>
    <div class="navbar-end">
      <div class="navbar-item">
       <strong>Hello #SESSION.wms.firstname#!</strong>
      </div>
      <div class="navbar-item">
        <div class="navbar-item has-dropdown is-hoverable">
          <cfloop array="#SESSION.wms.allowed_divisions#" item="d">
            <cfif d.id EQ SESSION.wms.active_division>
              <a class="navbar-link">#d.name#</a>
            </cfif>
          </cfloop>
          <div class="navbar-dropdown">
            <cfloop array="#SESSION.wms.allowed_divisions#" item="d">
              <cfif d.id NEQ SESSION.wms.active_division>
                #linkTo(route="wmsDivisionSetDivision", params="key=#d.id#", text = "#d.name#", class="navbar-item" )#
              </cfif>
            </cfloop>
          </div>
        </div>
      </div>
      <div class="navbar-item">
        <div class="buttons">
          #linkTo(controller="wms.login", action="delete", class="button is-light", text="Logout")#
        </div>
      </div>
    </div>
  </div>
</nav>
</cfoutput>