<cfscript> 
   // if(!isDefined('session.deptlist')) { location('/'); }
   // if(Listfind(session.deptlist, application.adminsDepartment.development) lt 1) { writeOutput('Permission Denied: Restricted to Developer Access Only'); exit; }
</cfscript>

<cfset request.title="WilsonStudioWeb - Developer Tools">


<cfsavecontent variable="request.head">
<!-- REMOTE CDN CSS FILE URLS -->
<link type="text/css" rel="stylesheet" href="/css/print.css" />

<!-- REMOTE CDN JS FILE URLS -->
<!---
<script src="//cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js" integrity="sha384-SR1sx49pcuLnqZUnnPwx6FCym0wLsk5JZuNx2bPPENzswTNFaQU1RDvt3wT4gWFG" crossorigin="anonymous"></script>
<script src="//cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta3/dist/js/bootstrap.min.js" integrity="sha384-j0CNLUeiqtyaRmlzUHCPZ+Gy5fQu0dQ6eZ/xAww941Ai1SxSY+0EQqNXNE6DZiVc" crossorigin="anonymous"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
--->
<script src="//polyfill.io/v3/polyfill.min.js?features=es2015%2CIntersectionObserver" crossorigin="anonymous"></script>


	<!-- LOCAL JS PATHS -->
	<!--- <script src="//unpkg.com/gauge-chart@latest/dist/bundle.js"></script> --->
	<style>
	body section { padding-top:40px; padding-bottom:40px; padding-left:40px; padding-right:40px; }
	section:nth-child(even)   {background: #eee; }
	#app section.page-header { margin-bottom:0; }
    #app .nav-tabs li a.active { 
        background:#fff; 
        border-left: 1px solid rgba(0,0,0,.125);
        border-right: 1px solid rgba(0,0,0,.125);
    }
    #app #gencfml-container textarea { min-height:200px; }
    #app .nav-pills .nav-link.active {
        color: #fff;
        background-color: #0d6efd;
        border: 1px solid rgba(0,0,0,.125);
        border-bottom: 0;
    }


    #app .btn-secondary {
        color: #fff;
        background-color: #6c757d;
        border-color: #6c757d;
    }

    #table-list-container .tab-content {
        border-radius:0;
        box-shadow:none;
        background-color: #FFF;
        border:0;
        border-top: 0;
        padding: 15px;
    }

    #app .row {
        margin-right:0;
        margin-left:0;
    }

    #app .card {
        position: relative;
        display: flex;
        flex-direction: column;
        min-width: 0;
        word-wrap: break-word;
        background-color: #fff;
        background-clip: border-box;
        border: 1px solid rgba(0,0,0,.125);
        border-radius: .25rem;
    }

    #app .card-header:first-child {
        border-radius: calc(.25rem - 1px) calc(.25rem - 1px) 0 0;
    }
    #app .card-header {
        padding: .5rem 1rem;
        margin-bottom: 0;
        background-color: rgba(0,0,0,.03);
        border: 1px solid rgba(0,0,0,.125);
        border-bottom:0;
    }

    #app .card-header-tabs {
        margin-right:0;
        margin-bottom: -.5rem;
        margin-left:0;
        
        border-bottom: 0;
    }
	.icon::before {
		display: inline-block;
		font-style: normal;
		font-variant: normal;
		text-rendering: auto;
		-webkit-font-smoothing: antialiased;
    }
	.fa-print::after{
		font-family:'verdana'; 
		font-size:12px; 
		text-align:center;
		color:#333;
		display: block;
		content:"Print"
	}


	.flex-container{
		display:-webkit-flex;
		display:flex;
		-webkit-flex-wrap:wrap;
		flex-wrap:wrap;
		-webkit-justify-content:space-between;
		justify-content:space-between;
	}
    .card {
    position: relative;
    display: -ms-flexbox;
    display: flex;
    -ms-flex-direction: column;
    flex-direction: column;
    min-width: 0;
    word-wrap: break-word;
    background-color: #fff;
    background-clip: border-box;
    border: 1px solid rgba(0,0,0,.125);
    border-radius: 0.25rem;
    margin:2px;
}
.card-body {
    -ms-flex: 1 1 auto;
    flex: 1 1 auto;
    min-height: 1px;
    padding: 1.25rem;
}
.card-title {
    margin-bottom: 0.75rem;

    font-size: 1.25rem;
    font-weight: 500;
    line-height: 1.2;
    margin-top: 0;
    margin-bottom: 0.5rem;
    font-weight:bold; color:#555;
}

html div.col-border {  display:block; min-height:180px !important;  background:#fff; border:3px solid #efefef;  }
#links h5 { display:none; }
#links a { display:inline-block; width:200px; margin-bottom:4px; }
</style>

</cfsavecontent>

<div id="main">
    <section class="page-header">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <h1>Developer Tools</h1>
                </div>
            </div>
        </div>
    </section>

    <section>
        <div class="container">
            <div class="row">
                <div class="col-border col-md-12">

                    <div class="card-body" id="links">
                        <h4>Useful Links</h4>

                        <h5>Meetings</h5>
                        <a href="https://slack.com/workspace-signin" target="_new" class="btn btn-light">Slack</a>
                        <a href="https://meet.google.com/" target="_new" class="btn btn-light">Google Meet</a>
                        <a href="https://zoom.us/signin" target="_new" class="btn btn-light">Zoom</a>
                        <a href="https://signin.webex.com/signin" target="_new" class="btn btn-light">Webex</a>
                        <a href="https://streamyard.com/login" target="_new" class="btn btn-light">Streamyard</a>

                        <h5>Project Tracking</h5>
                        <a href="https://id.atlassian.com/login" target="_new" class="btn btn-light">Jira</a>
                        <a href="http://www.monday.com" target="_new" class="btn btn-light">Monday.com</a>

                        <h5>Time Tracking</h5>
                        <a href="https://id.getharvest.com/harvest/sign_in" target="_new" class="btn btn-light">Harvest</a>

                        <h5>Documentation</h5>
                        <a href="https://slab.com/login/" target="_new" class="btn btn-light">Slab.com</a>

                        <h5>Code Formatters</h5>
                        <a href="https://beautifier.io/" target="_new" class="btn btn-light">JavaScript Beautifier</a>
                        <a href="https://www.codebeautifier.com/#skip" target="_new" class="btn btn-light">CSS Formatter</a>
                        <a href="https://www.dpriver.com/pp/sqlformat.htm" target="_new" class="btn btn-light">SQL Formatter</a>

                        <h5>API Testing</h5>
                        <a href="https://identity.getpostman.com/login" target="_new" class="btn btn-light">Postman</a>
                        
                        <h5>Programming Reference</h5>
                        <a href="https://getbootstrap.com/docs/4.0/getting-started/introduction/" target="_new" class="btn btn-light">Bootstrap Docs</a>
                        <a href="https://fontawesome.com/icons/" target="_new" class="btn btn-light">Fontawesome Icons</a>
                        <a href="https://icons.getbootstrap.com/" target="_new" class="btn btn-light">Bootstrap Icons</a>
                        <a href="https://animate.style/" target="_new" class="btn btn-light">Animate.css</a>
                        
                        <h5>JavaScript / Frameworks</h5>
                        <a href="https://vuejs.org/guide/introduction.html" target="_new" class="btn btn-light">VueJS</a>
                        <a href="https://api.jquery.com/" target="_new" class="btn btn-light">jQuery</a>
                        
                        <h5>Coldfusion Reference</h5>
                        <a href="https://helpx.adobe.com/coldfusion/cfml-reference/user-guide.html" target="_new" class="btn btn-light">Adobe CFML Docs</a>
                        <a href="https://cfdocs.org/queryexecute" target="_new" class="btn btn-light">CFDocs.org</a>
                        
                
                        
                        
                        
                        
                    </div>
            </div>
            

                <div class="col-border col-md-12">
                    <div class="card-body">
                        <h5 class="card-title">Database Tool</h5>
                        <p class="card-text">View and print data definitions and properties of database tables, table specific CFML code generators, and more. </p>
                        <a href="dbtool.cfm" class="btn btn-primary">Go</a>
                    </div>
                </div>
            </div>
        <div class="row">
            <div class="col-border col-md-6">
                <div class="card-body">
                    <h5 class="card-title">Persistent Scope Variables</h5>
                    <p class="card-text">See a dump of all persistent scope varables, like application, session, cgi, ect.</p>
                    <a href="persistentVars.cfm" class="btn btn-primary">Go</a>
                </div>
            </div>
            <cfparam name="keyword" default="">
            <div class="col-border col-md-6">
                <div class="card-body">
                    <h5 class="card-title">Database Column Name Search</h5>
                    <p class="card-text">Search and return all tables with column names containing specific keyword(s). </p>
                    <form class="form-inline" action="dbcolumnsearch.cfm">
                        <div class="form-group mx-sm-3 mb-2">
                            <label for="inputPassword2" class="sr-only">Password</label>
                            <input type="text" name="keyword" value="<cfoutput>#keyword#</cfoutput>" id="keyword" class="form-control" placeholder="Keyword">
                        </div>
                        <button type="submit" class="btn btn-primary mb-2">Go</button>
                    </form>
                </div>
            </div>

            <div class="col-border col-md-6">
                <div class="card-body">
                    <h5 class="card-title">DB Entity Relationship Diagram</h5>
                    <p class="card-text">ER diagram to show relationships between tables.</p>
                    <a href="erd.cfm" class="btn btn-primary">Go</a>
                </div>
            </div>
			
            <div class="col-border col-md-6">
                <div class="card-body">
                    <h5 class="card-title">Form Builder</h5>
                    <p class="card-text">Create forms utilizing table comlun's properties on the backend to auto generate input attributes.</p>
                    <a href="formbuilder.cfm" class="btn btn-primary">Go</a>
                </div>
            </div>

            <div class="col-border col-md-6">
                <div class="card-body">
                    <h5 class="card-title">CSV Mapping Tool</h5>
                    <p class="card-text">Upload an excel or csv and map source file columns against database table columns to create a JavaScript, CFML compatible data structure.</p>
                    <a href="mappingtool.cfm" class="btn btn-primary">Go</a>
                </div>
            </div>

        </div>
    </div>
    </section>

</div>


<cfsavecontent variable="request.foot">
    <script src="/js/print_elements.js"></script>
</cfsavecontent>