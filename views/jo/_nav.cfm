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
      #linkTo(route="joEncodeIndex", class="navbar-item", text="JO List")#
      #linkTo(route="newJoEncode", class="navbar-item", text="Add New")#
      #linkTo(route="joApprovalIndex", class="navbar-item", text="JO Approval")#
      #linkTo(route="joNotifyIndex", class="navbar-item", text="Notify Users")#
    </div>
    <div class="navbar-end">
      <div class="navbar-item">
       <strong>Hello #SESSION.jo.firstname#!</strong>
      </div>
      <div class="navbar-item">
        <div class="navbar-item has-dropdown is-hoverable">
          <cfloop array="#SESSION.jo.allowed_divisions#" item="d">
            <cfif d.id EQ SESSION.jo.active_division>
              <a class="navbar-link">#d.name#</a>
            </cfif>
          </cfloop>
          <div class="navbar-dropdown">
            <cfloop array="#SESSION.jo.allowed_divisions#" item="d">
              <cfif d.id NEQ SESSION.jo.active_division>
                #linkTo(route="joDivisionSetDivision", params="key=#d.id#", text = "#d.name#", class="navbar-item" )#
              </cfif>
            </cfloop>
          </div>
        </div>
      </div>
      <div class="navbar-item">
        <div class="buttons">
          #linkTo(controller="jo.login", action="delete", class="button is-light", text="Logout")#
        </div>
      </div>
    </div>
  </div>
</nav>
</cfoutput>