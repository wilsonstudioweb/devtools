<cfparam name="keyword" default="">

<cfif len(keyword) >
    <cfquery name="q.results" datasource = "#session.datasourcename#" >
        select DISTINCT table_name, column_name 
        from information_schema.columns 
        where 1 =1 
        <cfloop list="#trim(keyword)#" item="i" delimiters=",| ">
            AND column_name like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(i)#%">
        </cfloop>
        ORDER BY table_name
    </cfquery>
</cfif>

<nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="/">Home</a></li>
        <li class="breadcrumb-item active" aria-current="page">DB Column Seach</li>
    </ol>
</nav>

<br>
<div class="container">

    <h3 class="panel-title">Database Column Name Search</h3>

    <p class="card-text">Search and return all tables with column names containing specific keyword(s).</p>

    <form class="form-inline" action="<cfoutput>#cgi.script_name#</cfoutput>">
        <input type="text" name="keyword" value="<cfoutput>#keyword#</cfoutput>" id="keyword" class="form-control" placeholder="Keyword(s)" style="min-width:320px;"> 
        <button type="submit" class="btn btn-primary mb-2">Search</button>
    </form>

    <cfif len(keyword) >

        <span style="float:right; display:inline-block;"> Total Results: <cfoutput>#q.results.RecordCount#</cfoutput> </span>

        <table class="table table-striped">
            <thead>
            <tr>
                <th scope="col"></th>
                <th scope="col">Table</th>
                <th scope="col">Column</th>
                <th scope="col"></th>
            </tr>
            </thead>
            <tbody>
            <cfoutput query="q.results">
            <tr>
                <th scope="row">#CurrentRow#</th>
                <td><a href="/dbtool.cfm?table=#table_name###table-section">#TABLE_NAME#</a></td>
                <td><a href="#cgi.script_name#?keyword=#column_name#">#COLUMN_NAME#</a></td>
                <td><a href="" class="btn"> </a></td>
            </tr>
            </cfoutput>
            </tbody>
        </table>
        
    </cfif>

</div>