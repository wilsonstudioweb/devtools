<div class="collapse navbar-collapse" id="navbarNavDropdown">
  <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
    <li class="nav-item">
      <a class="nav-link active" aria-current="page" href="/">Home</a>
    </li>
  </ul>
  <form class="form-inline my-2 my-lg-0">


    <div class="form-group row">
      <label for="dsn" class="col col-form-label" style="color:#fff">Datasource</label>
      <div class="col">
          <select v-model="dsn" id="dsn" @change="setDSN"  class="form-control">
              <option disabled value="">Please select one</option>
              <option  v-for="datasource in datasources" :value="datasource">{{ datasource }}</option>
          </select>
      </div>
  </div>
      <!--- <input type="search" class="form-control mr-sm-2" placeholder="Search..." aria-label="Search"> --->
      <!---
      <cfif (isDefined('session.user') AND session.user.isAuthenticated) or (isDefined('session.admin') AND session.admin.isAuthenticated)>
        <a href="<cfoutput>#cgi.script_name#?logout</cfoutput>" class="btn btn-success  my-2 my-sm-02">Logout</a>
      <cfelse>
        <a href="/login.cfm" class="btn btn-success btn-sm  my-2 my-sm-0" style="margin-right:4px;">Login</a>
        <button type="button" class="btn btn-warning btn-sm  my-2 my-sm-0">Sign-up</button>
      </cfif> 
    --->
  </form>
</div>