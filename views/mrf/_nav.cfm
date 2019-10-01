<cfoutput>
<nav class="navbar is-fixed-top is-white" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item" href="#urlFor(route='joEncodeIndex')#">
      #imageTag(source="logo_jo.png", width="112", height="28")#
    </a>
    <!--- <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarBasicExample">
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
    </a> --->
  </div>
  <div id="navbar" class="navbar-menu">
    <div class="navbar-start">
      #linkTo(route="mrfRequestIndex", class="navbar-item", text="My Requests")#
      #linkTo(route="newMrfRequest", class="navbar-item", text="New Request")#
    </div>
    <div class="navbar-end">
      <div class="navbar-item">
       <strong>Hello #SESSION.mrf.firstname#!</strong>
      </div>
      <div class="navbar-item">
        <div class="navbar-item has-dropdown is-hoverable">
          <cfloop array="#SESSION.mrf.allowed_divisions#" item="d">
            <cfif d.id EQ SESSION.mrf.active_division>
              <a class="navbar-link">#d.name#</a>
            </cfif>
          </cfloop>
          <div class="navbar-dropdown">
            <cfloop array="#SESSION.mrf.allowed_divisions#" item="d">
              <cfif d.id NEQ SESSION.mrf.active_division>
                #linkTo(route="mrfDivisionSetDivision", params="key=#d.id#", text = "#d.name#", class="navbar-item" )#
              </cfif>
            </cfloop>
          </div>
        </div>
      </div>
      <div class="navbar-item">
        <div class="buttons">
          #linkTo(controller="mrf.login", action="delete", class="button is-light", text="Logout")#
        </div>
      </div>
    </div>
  </div>
</nav>
</cfoutput>