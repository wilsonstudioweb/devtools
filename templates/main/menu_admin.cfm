
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                  <li class="nav-item">
                    <a class="nav-link active" aria-current="page" href="/">Home</a>
                  </li>

                  <!---
                  <li class="nav-item">
                    <a class="nav-link disabled" href="#" tabindex="-1" aria-disabled="true">Disabled</a>
                  </li>
                  --->
                </ul>

                <div class="text-end">
                  <cfif (isDefined('session.user') AND session.user.isAuthenticated) or (isDefined('session.admin') AND session.admin.isAuthenticated)>
                    <a href="<cfoutput>#cgi.script_name#?logout</cfoutput>" class="btn btn-outline-light me-2">Logout</a>
                  <cfelse>
                    <a href="/login.cfm" class="btn btn-outline-light me-2">Login</a>
                  </cfif>
                  
                  <button type="button" class="btn btn-warning">Sign-up</button>
                </div>
              </div>