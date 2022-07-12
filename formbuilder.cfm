<cfscript> 
    // if(!isDefined('session.deptlist')) { location('/admin/'); }
    //  if(Listfind(session.deptlist, application.adminsDepartment.development) lt 1) { writeOutput('Permission Denied: Restricted to Developer Access Only'); exit; }

    function getTables(){

        local.SQL = { 
            mysql:  " 
                SELECT  TABLE_SCHEMA, 
                        TABLE_NAME, 
                        table_rows AS RECORD_COUNT
                FROM INFORMATION_SCHEMA.TABLES
                -- WHERE 	TABLE_NAME NOT IN (:blacklist)
                WHERE TABLE_SCHEMA = 'db1091448_probateleads'
                -- AND TABLE_ROWS >=0
                ORDER BY TABLE_NAME
            ",
            mssql: " 
                DECLARE @sql nvarchar(MAX)

                SELECT
                    @sql = COALESCE(@sql + ' UNION ALL ', '') +
                        'SELECT
                            ''' + s.name + ''' AS ''TABLE_SCHEMA'',
                            ''' + t.name + ''' AS ''TABLE_NAME'',
                            COUNT(*) AS RECORD_COUNT
                            FROM ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name)
                    FROM sys.schemas s
                    INNER JOIN sys.tables t ON t.schema_id = s.schema_id
                    ORDER BY
                        s.name,
                        t.name

                EXEC(@sql)
                "
        }

       local.tables = queryExecute(local.SQL.mssql, { }, {  datasource = session.datasourcename, result = "r.tables" } );
       return local.tables;
    }
    
    q.dbtables = getTables();

    // writeDump(q.dbtables); abort;
</cfscript>

<cfset request.title="Form Builder">

<cfsavecontent variable="request.head">

    <!-- REMOTE CDN CSS FILE URLS -->
    <!--- <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.min.css" /> --->
    <link type="text/css" rel="stylesheet" href="/css/print.css" />
    <link type="text/css" rel="stylesheet" href="css/formbuilder.css" />

    <!-- REMOTE CDN JS FILE URLS -->
    <!---
    <script src="//cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js" integrity="sha384-SR1sx49pcuLnqZUnnPwx6FCym0wLsk5JZuNx2bPPENzswTNFaQU1RDvt3wT4gWFG" crossorigin="anonymous"></script>
    <script src="//cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta3/dist/js/bootstrap.min.js" integrity="sha384-j0CNLUeiqtyaRmlzUHCPZ+Gy5fQu0dQ6eZ/xAww941Ai1SxSY+0EQqNXNE6DZiVc" crossorigin="anonymous"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>

    <script src="//polyfill.io/v3/polyfill.min.js?features=es2015%2CIntersectionObserver" crossorigin="anonymous"></script> <!--- Polyfill is a service which accepts a request for a set of browser features and returns only the polyfills that are needed by the requesting browser. --->
    <script src="/vendor/vue/2.6.14/vue.js"></script>
    <script src="/vendor/axios/0.25.0/axios.min.js"></script>
    <script src="/vendor/vue/vue-router/3.5.3/vue-router.js"></script>
    <script src="/vendor/vue/bootstrap-vue/2.21.2/bootstrap-vue.min.js"></script>
    --->

    <script src="/vendor/vue/bootstrap-vue/2.21.2/bootstrap-vue-icons.min.js"></script> 
    <script src="/vendor/sortable/1.8.4/Sortable.min.js"></script>
    <script src="/vendor/vue/vue-draggable/2.20.0/vuedraggable.umd.min.js"></script>

	<!-- LOCAL JS PATHS -->
	<!--- <script src="//unpkg.com/gauge-chart@latest/dist/bundle.js"></script> --->

    <style>
        label.primary-key::after {
            content: ' \f084 ';
            font-family: "Font Awesome 5 Free"; 
            font-weight: 900; 
            color: rgba(0,0,0,.2);
            transform: rotate(225deg);
            display:inline-block;
            margin-left:4px;
        }
        label.required::after {
            content: ' \2a ';
            font-family: "Font Awesome 5 Free"; 
            font-weight: 900; 
            color: rgba(0,0,0,.2);
            display:inline-block;
            margin-left:4px;
            
        }

        body div.modal { display:block; }
    </style>
</cfsavecontent> 



    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">Form Builder</li>
        </ol>
    </nav>

    <section class="container">
        <h1>Webform Builder</h1>
        <div class="col-md-12" id="leftcol">
            <p><strong>Notice:</strong> This tool is unfinished and has been published as it may still be useful in its current state. Use your web browser's developer tools to copy the generated source code for now. <strong>All planned features are not yet implemented</strong>. </p>

            <p><strong>How to use</strong>: Click on a table name from the "DATABASE TABLES" select box to populate the chained "COLUMNS" select box below. The generated field name & ids will match the database table column names. 
            Double click on a column to generate a formfield to the page. Form field attributes (labels, input type, name, id, maxlength, required, etc.. ) will be auto generated utilizing the table comlun's properties. You can re-order the form items by drag and drop.</p>
        </div>
        <form-builder></form-builder>
    </section>



    <section>
        <!---
        <b-container>
            <b-form-group  label-cols="4" label-cols-lg="2" label="Datasource" label-for="dsn">
                <b-form-select  @change="setDSN" v-model="dsn" :options="datasources"></b-form-select>
            </b-form-group>
        </b-container>
    --->
    </section>


    <a onclick="topFunction()" id="myBtn" class="scroll-to-top hidden-mobile visible pe-no-print" href="#" ><i class="fa fa-chevron-up"></i></a>


<cfsavecontent variable ="request.foot">
    <script src="/js/print_elements.js"></script>
    <script src="https://unpkg.com/v-switch-case@1.0.2/dist/v-switch.min.js"></script>
    <script src="/js/formbuilder.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
</cfsavecontent>

