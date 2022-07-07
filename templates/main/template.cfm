<cfscript>
  if(isDefined('request.content')){ 
    local.targetpage = request.content 
  } else {
    savecontent variable="local.targetpage" {  include ARGUMENTS.targetPage; }
  }
</cfscript>

<!doctype html>
<html lang="en">
    <head>
        <title><cfoutput>#(isDefined('request.title')? request.title:'Lifestyle Community | Adult Personals | Clubs & Events')#</cfoutput></title>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <!--- // BEGIN // Include CSS Files Below Here --->
  
        <!--- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous"> --->
        <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/css/bootstrap.css" crossorigin="anonymous">
        <link rel="stylesheet" href="//use.fontawesome.com/releases/v5.2.0/css/all.css" crossorigin="anonymous">
        <script src="https://kit.fontawesome.com/8ee51bf85f.js" crossorigin="anonymous"></script>


        <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.min.css" />
        <link type="text/css" rel="stylesheet" href="/css/print.css" />
        
        <!-- REMOTE CDN JS FILE URLS -->
        <!---
        <script src="//cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js" integrity="sha384-SR1sx49pcuLnqZUnnPwx6FCym0wLsk5JZuNx2bPPENzswTNFaQU1RDvt3wT4gWFG" crossorigin="anonymous"></script>
        <script src="//cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta3/dist/js/bootstrap.min.js" integrity="sha384-j0CNLUeiqtyaRmlzUHCPZ+Gy5fQu0dQ6eZ/xAww941Ai1SxSY+0EQqNXNE6DZiVc" crossorigin="anonymous"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
        --->
        <script src="//polyfill.io/v3/polyfill.min.js?features=es2015%2CIntersectionObserver" crossorigin="anonymous"></script> <!--- Polyfill is a service which accepts a request for a set of browser features and returns only the polyfills that are needed by the requesting browser. --->
        <script src="/vendor/vue/2.6.14/vue.js"></script>
        <script src="/vendor/axios/0.25.0/axios.min.js"></script>
        <script src="/vendor/vue/vue-router/3.5.3/vue-router.js"></script>
        <script src="/vendor/vue/bootstrap-vue/2.21.2/bootstrap-vue.min.js"></script>
        <script src="/vendor/vue/bootstrap-vue/2.21.2/bootstrap-vue-icons.min.js"></script> 


        <style>
          html * { box-sizing:border-box; }
          html .container { max-width:1280px; }
          html body { font-family: system-ui, -apple-system, -apple-system-font, 'Segoe UI', 'Roboto', sans-serif; }
          html body .bg-dark { background-color:#990000 !important; }
          footer .btn, nav .btn { background-color:#660000; }
          footer .btn:hover, , html body nav .btn:hover { background-color:#880000; color:#fff; }
          html body .btn-warning { color: #212529; background-color: #ffc107; border-color: #ffc107; }
          html body .btn-success { color: #fff; background-color: #28a745; border-color: #28a745; }
          .txt-warning { color:#990000; }
        </style>

        <!--- // END // Include CSS Files Below Here --->
        <cfscript>
            /* inject CSS file include(s) into template by setting request.css */
            if(isDefined('request.css') AND isArray(request.css)){
                for(cssfile in request.css) writeoutput('<link rel="stylesheet" href="#trim(cssfile)#" crossorigin="anonymous" />#chr(10)#'); 
            } else if(isDefined('request.css')) {
                writeoutput('<link rel="stylesheet" href="#trim(request.css)#" crossorigin="anonymous" />');
            }
            /* inject JavaScript file include(s) into template by setting request.css */
            if( isDefined('request.js') AND isArray(request.js) ){
                for(jsfile in request.js) writeoutput('<script src="#trim(jsfile)#" crossorigin="anonymous"></script>#chr(10)#'); 
            } else if(isDefined('request.js')) {
                writeoutput('<script src="#trim(request.js)#" crossorigin="anonymous"></script>');
            }
        </cfscript>
        <!--- // BEGIN // Include JavaScript Files Below Here --->

        <!--- // END // Include JavaScript Files Below Here --->
        <cfscript>if(isDefined('request.head')) writeoutput(request.head);</cfscript>
    </head>

    <body>
      <div id="app">
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <a class="navbar-brand" href="#" style="line-height:42px;">
          <i class="fa fa-tools"></i>
          <cfoutput>#ucase(this.sitename)#</cfoutput></span>
        </a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <cfinclude template="menu.cfm">

      </nav>

  <header> </header>

        
<cfscript>writeOutput(local.targetpage);</cfscript>

<footer class="bg-dark text-center text-white">
  <!-- BEGIN: Copyright -->
  <div class="text-center p-3" style="background-color: rgba(0, 0, 0, 0.2);">
   &#169; <cfoutput>#year(now())#</cfoutput> Copyright: <a class="text-white" href="<cfoutput>//#cgi.server_name#/</cfoutput>"><cfoutput>#this.companyname#</cfoutput>. All rights Reserved</a>
  </div>
  <!-- END: Copyright -->
</footer>
</div>
        <!-- Optional JavaScript -->
        <!-- jQuery first, then Popper.js, then Bootstrap JS -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/popper.js/1.11.0/umd/popper.min.js" crossorigin="anonymous"></script>
        <script src="//cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/js/bootstrap.min.js" crossorigin="anonymous"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.1/umd/popper.min.js" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="/js/print_elements.js"></script>
        <script src="https://unpkg.com/sql-formatter@2.3.3/dist/sql-formatter.min.js"></script>
        
        <script src="/js/components/dbtool.statsinfo.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        <script src="/js/components/dbtool.datagrid.tables.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        <script src="/js/components/dbtool.datagrid.tabledef.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        <script src="/js/components/dbtool.datagrid.tabledata.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        <script src="/js/components/dbtool.sqlconsole.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        <script src="/js/components/dbtool.formbuilder.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        <script src="/js/components/dbtool.cfmlgen.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>
        
        <script src="/js/dbtool.main.vue.js?<cfoutput>#CreateUUID()#</cfoutput>"></script>


        <cfscript>if(isDefined('request.foot')) writeoutput(request.foot);</cfscript>

      
    </body>
</html>