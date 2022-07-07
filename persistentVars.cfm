<cfsetting requesttimeout="420">
<cfset request.title="Dev Tools: Persistent Variables">

<link type="text/css" rel="stylesheet" href="/css/print.css" />

<nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="/">Home</a></li>
        <li class="breadcrumb-item active" aria-current="page">Persistent Scope Variables</li>
    </ol>
</nav>

<div id="app">
    <section>
        <div class="container">
        <div class="row">
			<h1>Persistent Scope variables</h1>
        </div>
			
		<div class="row">
			<a href="persistentVars.cfm#cgi" class="btn btn-success">CGI</a>&emsp;
            <a href="persistentVars.cfm#this" class="btn btn-success">This</a>&emsp;
            <a href="persistentVars.cfm#appl" class="btn btn-success">Application</a>&emsp;
            <a href="persistentVars.cfm#ses" class="btn btn-success">Session</a>&emsp;
            <a href="persistentVars.cfm#ck" class="btn btn-success">Cookie</a>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <h3><a name="cgi"></a><br><br>CGI</h3>
                <p>CGI variables sent from the browser are placed into the CGI scope. CGI variables are available for the current request.<br>Contains environment variables identifying the context in which a page was requested. The variables available depend on the browser and server software.</p>
                <cfdump var="#cgi#"/>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <h3><a name="this"></a><br><br>This</h3>
                <p>Exists only in ColdFusion components or cffunction tags that are part of a containing object such as a ColdFusion Struct.<br>Exists for the duration of the component instance or containing object. Data in the This scope is accessible from outside the component or container by using the instance or object name as a prefix.</p>
                <cfdump var="#this#"/>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <h3><a name="appl"></a><br><br>Application</h3>
                <p>Application variables are shared amongst all connected clients for the current named application.<br>This scope is available across requests for the life of the application, which may terminate on server shutdown, application malfunction, or application timeout.</p>
                <cfdump var="#application#"/>
            </div>
        </div>
        
        <div class="row">
            <div class="col-sm-12">
                <h3><a name="ses"></a><br><br>Session</h3>
                <p>Contains variables that are associated with one client and persist only as long as the client maintains a session.<br>They are stored in the server's memory and can be set to time out after a period of inactivity.</p>
                <cfdump var="#session#"/>
            </div>
        </div>
        
        <div class="row">
            <div class="col-sm-12">
                <h3><a name="ck"></a><br><br>Cookie</h3>
                <p>Contains variables maintained in a user's browser as cookies. Cookies are stored in a file on the browser, so they are available across browser sessions and applications, but only to the browser storing that cookie.</p>
                <cfdump var="#cookie#"/>
            </div>
        </div>

    </div>
    </section>
</div>

<br><br>