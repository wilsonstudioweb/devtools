<cfscript> 
    // if(!isDefined('session.deptlist')) { location('/admin/'); }
    // if(Listfind(session.deptlist, application.adminsDepartment.development) lt 1) { writeOutput('Permission Denied: Restricted to Developer Access Only'); exit; }
    
</cfscript>

<cfset request.title="Dev Tools - Database Tool">


<cfsavecontent variable="request.head">

<!-- REMOTE CDN CSS FILE URLS -->



	<!-- LOCAL JS PATHS -->
	<!--- <script src="//unpkg.com/gauge-chart@latest/dist/bundle.js"></script> --->
	<style>
	body section { padding-top:40px; padding-bottom:40px; padding-left:40px; padding-right:40px; }
	section:nth-child(odd)   {background: #eee; }
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
	#table-list a { 
		color:#666; text-decoration:none; border:1px solid #666666; margin:2px; 
		background-color: rgba(0,0,0,.04);
		border: 1px solid #dee2e6;
		padding:2px 10px;
		display:inline-block;
		-webkit-border-radius: 4px;
		-moz-border-radius: 4px;
		border-radius: 4px;
	}
	#table-list a .badge-secondary {
		color: #fff;
		background-color: rgba(0,0,0,.2);
    }
    #table-list a:hover {
        background-color:#dee2e6;
        color:#111;
        border: 1px solid rgba(0,0,0,.2);
    }
    #table-list a:hover::before { color:#666666; }

	#table-list a::before { color:#999; }
	.icon.dt::before, #table-list a::before {
		font-family: "FontAwesome"; font-weight: 900; content: "\f0ce";
		margin-right:4px;
		font-weight:normal;

	}

    /*
	.fa-download, .fa-print{
		text-align:center;
		margin:14px;
	}
	.fa-download::after{
		font-family:'verdana'; 
		font-size:12px; 
		text-align:center;
		color:#333;
		display: block;
		content:"Export"
	}
	.fa-print::after{
		font-family:'verdana'; 
		font-size:12px; 
		text-align:center;
		color:#333;
		display: block;
		content:"Print"
	}
*/

    #myBtn  {
        -webkit-transition: all 0.3s;
        -moz-transition: all 0.3s;
        transition: all 0.3s;
        background: #404040;
        border-radius: 7px 7px 0 0;
        bottom: 0px;
        color: #FFF;
        display: block;
        height: 9px;
        opacity: .5;
        padding: 13px 10px 35px;
        position: fixed;
        right: 10px;
        text-align: center;
        text-decoration: none;
        min-width: 49px;
        z-index: 1040;
    }


    #myBtn:hover {
    background-color: #555; /* Add a dark-grey background on hover */
    }

    .scrollToTopBtn {
    background-color: black;
    border: none;
    border-radius: 50%;
    color: white;
    cursor: pointer;
    font-size: 16px;
    line-height: 48px;
    width: 48px;
    
    /* place it at the bottom right corner */
    position: fixed;
    bottom: 30px;
    right: 30px;
    /* keep it at the top of everything else */
    z-index: 100;
    /* hide with opacity */
    opacity: 0;
    /* also add a translate effect */
    transform: translateY(100px);
    /* and a transition */
    transition: all .5s ease
    }

    .showBtn {
    opacity: 1;
    transform: translateY(0)
    }

    body #table-tabledef table thead th, body #table-tabledef table tbody td, body #table-data-container table thead th, body #table-data-container table tbody td  { 
        font-size:14px !important; 
    }
    .wrapper {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    }

    body .nav.nav-pills { margin-bottom:1em; }


    
    body .nav.nav-pills .nav-item:nth-child(1) a::before {
            font-family: "FontAwesome"; font-weight: 900; content: "\f03a";
            margin-right:4px;
            font-weight:normal;
    }
    body .nav.nav-pills .nav-item:nth-child(2) a::before {
            font-family: "FontAwesome"; font-weight: 900; content: "\f00a";
            margin-right:4px;
            font-weight:normal;
    }
    .sr-only { font-weight:normal; color:gray;  display:none;}

	body table thead th { background:#fff; }
		
	.flex-container{
		display:-webkit-flex;
		display:flex;
		-webkit-flex-wrap:wrap;
		flex-wrap:wrap;
		-webkit-justify-content:space-between;
		justify-content:space-between;
	}
	FORM.tr, DIV.tr {
		display:table-row;
	}
	#filters {
		margin-bottom:.5em; text-align:left;
	}
	#filters .btn { margin-right:2px; min-width:32px; text-align:center; }


   .table-responsive {
        max-height: 80vh;
        overflow: auto;
    }
pre code { color:rgba(255,255,255,.8); }

.table-responsive tbody td div { overflow:auto; max-height:200px; display:block; min-width:75px; }
.table-responsive table thead { cursor:pointer; }
.table-responsive table thead th {
    padding-right: 22px;
    position: relative;
}
.table-responsive table thead td input { border:0; outline:0; padding:2px 4px; }
    
.table-responsive table thead td { padding:0; }
.table-responsive table thead th::after {
    content: ' \f0dc ';
    font-family: "Font Awesome 5 Free";
    font-weight: 900;
    color: rgba(0,0,0,.1);
    display: inline-block;
    display: inline-block;
    right: 6px;
    position: absolute;     
}

.table-responsive table thead th.active { border-bottom:2px solid #0d6efd; }
.table-responsive table thead th.active.asc::after { 
    content: ' \f0dd ';
    font-family: "Font Awesome 5 Free";
    font-weight: 900;
    color: #0d6efd;
    display: inline-block;
    margin-left: 4px;
    position: absolute;
}
.table-responsive table thead th.active.desc::after { 
    content: ' \f0de ';
    font-family: "Font Awesome 5 Free";
    font-weight: 900;
    color: #0d6efd;
    display: inline-block;
    margin-left: 4px;
    position: absolute;
}
ol.breadcrumb { margin:0;}

h3 { text-transform:uppercase; font-size:1.25em; }
</style>

</cfsavecontent>


    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">Database Tool</li>
        </ol>
    </nav>


    <section class="page-header">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <h1>Database Tool</h1>
                    <p>View and print data definitions and properties of database tables, table specific CFML code generators, and more.</p>
                    <p>Name, SQL data type, size, decimal precision, default value, maximum length in bytes of a character or integer data type column, whether nulls are allowed, ordinal position, remarks, whether the column is a primary key, whether the column is a foreign key, the table that the foreign key refers to, the key name the foreign key refers to</p>
                </div>
            </div>
        </div>
    </section>
    <!---
    <section>
        <div class="container">
            <div class="form-group row">
                <label for="dsn" class="col-sm-2 col-form-label">Datasource</label>
                <div class="col">
                    <select v-model="dsn" id="dsn" @change="setDSN"  class="form-control">
                        <option disabled value="">Please select one</option>
                        <option  v-for="datasource in datasources" :value="datasource">{{ datasource }}</option>
                    </select>
                </div>
            </div>
        </div>
    </section>
--->

    <section>
        <div class="container">
            <db-statsinfo></db-statsinfo>
        </div>
    </section>

    <section>
        <div class="container">
          <tables-datagrid></tables-datagrid>
        </div>
    </section>


    <div v-show="this.activeTable !== null">

        <section>
            <div class="container">
                <!--- <h3><i aria-hidden="true" class="fa fa-table fa2x"></i> {{ this.activeTable }} Table Definition </h3> --->   
                <tabledef-datagrid></tabledef-datagrid>
            </div>
        </section>


        <section>
            <div class="container">
                <!--- <h3><i aria-hidden="true" class="fa fa-table fa2x"></i> {{ this.activeTable }} Table Data</h3> --->
                <tabledata-datagrid></tabledef-datagrid>
            </div>
        </section>


        <section>
            <div class="container">
                <h3>Web Form Generator</h3>
                <form-builder></form-builder>
            </div>
        </section>


        <section>
            <div class="container">
                <h3>Code Generators</h3>
                <gencfml-builder></gencfml-builder>
            </div>
        </section>

    </div>


    <!---
    <section id="table-section" v-show="this.activeTable !== null">        
        <b-container fluid>
            <h2><i class="fa fa-table fa2x"></i> {{ this.activeTable }}</h2>
            <b-card no-body>
                <b-tabs card>
                    <b-tab active>
                        <template :totalRecords="this.totalRecords" #title>
                            Records <b-badge pill variant="secondary">{{ totalRecords }}</b-badge>
                        </template>
                        <tabledata-datagrid></tabledef-datagrid>
                    </b-tab>
                    <b-tab title="Table Definition">
                        <tabledef-datagrid></tabledef-datagrid>
                    </b-tab>
                    <b-tab title="Web Form Generator"></b-tab>
                        <form-builder></form-builder>
                    </b-tab>
                    <b-tab title="CFML Generator">
                        <gencfml-builder></gencfml-builder>
                    </b-tab>
                </b-tabs>
            </b-card>
        </b-container>
    </section>
    --->



    <section id="sqlconsole-section" style="background:#eee;">
        <div class="container">
            <sql-console></sql-console>
        </div>
    </section>

    <a onclick="topFunction()" id="myBtn" class="scroll-to-top hidden-mobile visible pe-no-print" href="#" ><i class="fa fa-chevron-up"></i></a>
</div>


<cfsavecontent variable="request.foot">

    <script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js?lang=css&amp;skin=sunburst"></script> 
    
<script>
	mybutton = document.getElementById("myBtn");

	// When the user scrolls down 20px from the top of the document, show the button
	window.onscroll = function() {scrollFunction()};

	function scrollFunction() {
	  mybutton.style.display = (document.body.scrollTop > 640 || document.documentElement.scrollTop > 640)? 'block' : 'none';
	}

	// When the user clicks on the button, scroll to the top of the document
	function topFunction() {
	  document.body.scrollTop = 0; // For Safari
	  document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
	}
</script>
</cfsavecontent>
