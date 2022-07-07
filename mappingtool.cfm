    <cffunction name="upload" access="remote" returntype="any" output="false" hint="">
        <cfargument name="uploaddir" required="false" default="#getTempDirectory()#" type="string" hint="Absolute path filepath, function will created dir of the dir path doesn't exist." />
        <cfargument name="mimeTypes" required="false" default="text/csv, application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" type="string" hint="Comma delimited list of header mine/types to accept." />
        <cfscript>
            try { 
                uploadFile = fileUploadAll(getTempDirectory(), arguments.mimeTypes, "Overwrite", true );
                tmpServerFile = uploadFile[1].SERVERDIRECTORY & '\' & uploadFile[1].CLIENTFILE;
                return tmpServerFile;
            } catch (any e) {
                writeDump(e); abort;
                return { success:false, message:'#e.message# #e.detail#' }
            }
        </cfscript>
    </cffunction>

    <cfscript>
        obj.dbtool = createObject("component", "cfcs.dbtool");

        function getTables(){
            sql  = {
                mysql: " 
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
                            'SELECT ''' + s.name + ''' AS ''TABLE_SCHEMA'',  ''' + t.name + ''' AS ''TABLE_NAME'',  COUNT(*) AS RECORD_COUNT FROM ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name)
                        FROM sys.schemas s
                        INNER JOIN sys.tables t ON t.schema_id = s.schema_id
                        ORDER BY s.name, t.name
                    EXEC(@sql) 
                "
            }
           return queryExecute(sql.mssql, { }, {  result = "r.serverinfo" } );
        }
        
        q.dbtables = getTables();

        if(isDefined('files')){
            result = upload('#files#');
            json.dt =  DeserializeJSON(FileRead(expandpath('json\mysql_data_types.json')));

            function dtSelect(TypeName){
                savecontent variable="local.select" {
                    writeoutput('<select name="data_type"  class="form-control input-sm datatype" id="">');
                    for(r in json.dt){
                        writeoutput('<optgroup label="#ucase(r.category)#" >');
                            for(o in r.data_types){
                                writeoutput('<option value="#o.data_type#" title="#o.desc#" #(o.data_type is TypeName)?'selected':''#>#o.data_type#</option>');
                            }
                        writeoutput('</optgroup>');
                    }
                    writeoutput('</select>');       
                }
                return local.select;  
            }

 

            if(listlast(result,'.') is 'csv'){
                foo = csvToQuery(fileRead(result));
            } else {
                cfspreadsheet(action="read", src=result, query="foo", headerrow=1, excludeHeaderRow=true);
            }

            cols = getMetadata(foo);

        }

function csvToQuery(csvString){
    var rowDelim = chr(10);
    var colDelim = ",";
    var numCols = 1;
    var newQuery = QueryNew("");
    var arrayCol = ArrayNew(1);
    var i = 1;
    var j = 1;

    csvString = trim(csvString);

    if(arrayLen(arguments) GE 2) rowDelim = arguments[2];
    if(arrayLen(arguments) GE 3) colDelim = arguments[3];

    arrayCol = listToArray(listFirst(csvString,rowDelim),colDelim);

    for(i=1; i le arrayLen(arrayCol); i=i+1) queryAddColumn(newQuery, arrayCol[i], ArrayNew(1));

    for(i=2; i le listLen(csvString,rowDelim); i=i+1) {
        queryAddRow(newQuery);
        for(j=1; j le arrayLen(arrayCol); j=j+1) {
            if(listLen(listGetAt(csvString,i,rowDelim),colDelim) ge j) {
                querySetCell(newQuery, arrayCol[j],listGetAt(listGetAt(csvString,i,rowDelim),j,colDelim), i-1);
            }
        }
    }
    return newQuery;
}
    </cfscript>

 
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" integrity="sha512-SfTiTlX6kk+qitfevl/7LibUOeJWlt9rbyDn92a1DqWOw9vWG2MFoays0sgObmWazO5BQPiFucnnEAjpAB+/Sw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

        <script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js?lang=css&amp;skin=sunburst"></script>

        <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>

        <!-- Boostrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
                
        <style>
        body{ padding:10px; }
            optgroup { border-bottom:1px solid #eee; }
            label { cursor:pointer; }
        </style>
        <script>


            var localCache = {
                /**
                 * timeout for cache in millis
                 * @type {number}
                 */
                timeout: 30000,
                /** 
                 * @type {{_: number, data: {}}}
                 **/
                data: {},
                remove: function (url) {
                    delete localCache.data[url];
                },
                exist: function (url) {
                    return !!localCache.data[url] && ((new Date().getTime() - localCache.data[url]._) < localCache.timeout);
                },
                get: function (url) {
                    console.log('Getting in cache for url - ' + url);
                    return localCache.data[url].data;
                },
                set: function (url, cachedData, callback) {
                    localCache.remove(url);
                    localCache.data[url] = {
                        _: new Date().getTime(),
                        data: cachedData
                    };
                    if ($.isFunction(callback)) callback(cachedData);
                }
            };

            var pendingRequests = {};
            $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
                var key = options.url;
                if (!pendingRequests[key]) {
                    pendingRequests[key] = jqXHR;
                } else{
                    // jqXHR.abort (); // commit triggered after abandonment
                    pendingRequests[key].abort(); // abort the first triggered submission
                }

                if (options.cache) {
                    var complete = originalOptions.complete || $.noop, url = originalOptions.url, normalizedRequest = $.Deferred();
                    //remove jQuery cache as we have our own localCache
                    options.cache = false;
                    options.beforeSend = function () {
                        if (localCache.exist(url)) {
                            complete(localCache.get(url));
                            return false;
                        }
                        return true;
                    };
                    options.complete = function (data, textStatus) {
                        pendingRequests[key] = null;  if ($.isFunction(complete)) { complete.apply(this, arguments); }
                        localCache.set(url, data, complete);
                    };
                }
            });

            var column_val;
            var dbtables = <cfoutput>#SerializeJSON(q.dbtables,'struct')#</cfoutput>;

            $(document).on('change','#main_table',function(){
                thisVal = $(this).val();
                delete localCache.data['cfcs/dbtool.cfc?table=' + thisVal];
                $('.tableselect').empty();
                $('<option />').attr({ value:thisVal, selected:'true' }).text(thisVal).appendTo('.tableselect:empty')
                $('.tableselect').trigger('change');
            }).on('focus','.tableselect',function(){
                thisval = $(this).val();
                $(this).empty();
                for(i in dbtables){
                    isSelected = (dbtables[i]['TABLE_NAME'] == thisval)?true:false;
                    $('<option />').attr({ value:dbtables[i]['TABLE_NAME'], selected:isSelected }).text(dbtables[i]['TABLE_NAME']).appendTo($(this));
                }
                $(this).trigger('change');
            }).on('change','.tableselect',function(){
                parenttr = $(this).closest("tr");
                table = $(this).val();
                tableProps(table,parenttr);
            }).on('focus','select.column',function(){
                    parenttr = $(this).closest("tr");
                    table = parenttr.find('select.tableselect').val();
                    tableProps(table,parenttr,$(this));
            }).on('click','select.column option',function(){

            }).on('input','select.column',function(){
                parenttr = $(this).closest("tr");                
                TableName = parenttr.find('.tableselect').val();
                current_val = $(this).val(); 
                parenttr.find('select.datatype option[value=' + $(this).data('datatype') + ']').attr('selected', true);
                selected[parenttr.find('.tableselect').val()].push($(this).val());
                createStruct();
            }).on('change',':input',function(){
                createStruct();
            }).ready(function(){
                createStruct();


            });


            function createStruct(){
                var data=[];
                $('table#formtable').find('tbody tr').each(function(){
                    var row={};
                    $(this).find('input[type=text],input[type=hidden],select,textarea,:input:checked').each(function(){
                        row[$(this).attr('name')]=$(this).val();
                    });
                    data.push(row);
                });
                $('.prettyprint code').html(JSON.stringify(data, null, 4));
            }

            function copyToClipboard(elementid) {
                var copyText = document.getElementById(elementid);
                var x = document.createElement("TEXTAREA");
                var t = document.createTextNode(copyText.innerHTML);
                x.appendChild(t);               
                x.select();
                x.setSelectionRange(0, 99999);               
                navigator.clipboard.writeText(x.value); 
                alert("Copied the text: " + x.value);
            }

            function arrayRemove(arr, value) { 
                return arr.filter(function(ele){ 
                    return ele != value; 
                });
            }
            
            var selected = [];
            function tableProps(table,parenttr){

                selected[table] = [];

                $('table#formtable').find('tbody tr').each(function(){
                    selectVal = $(this).find('select.column').val();
                    if(selectVal !== ''){
                        TableName = $(this).find('.tableselect').val();
                        if(TableName == table) selected[table].push(selectVal);
                    }
                });

                var ajax = $.ajax({
                    async: false, 
                    type: "POST",
                    url: 'cfcs/dbtool.cfc?table=' + table,
                    data: {
                        method: 'table_design',
                        returnformat: 'json', 
                        queryformat: 'struct'
                    }, 
                    cache: true,
                    complete: function(result) {
                        result = jQuery.parseJSON(result.responseText); 
                        selectVal = (parenttr.find('select.column').val() !== '')? parenttr.find('select.column').val() : parenttr.find(':input[name=source_column_name]').val();
                        parenttr.find('.column option:not(:first)').remove();
                        $.each(result, function(i, r) {
                            if(selected[table].indexOf(r.column_name) < 0 || r.column_name == selectVal) {
                                $('<option />').attr({ value:r.column_name /*, data-datatype: r.type_name, data-nullabe: r.is_nullable */ }).text(r.column_name).appendTo(parenttr.find('select.column'));
                            }
                            el = document.getElementsByClassName("column");
                            var wrap = document.getElementById('formtable')
                        });
                        if(selectVal !== '') parenttr.find('select.column').val(selectVal);

                    }
                });
            }


            <!---
            $(document).on('submit','form',function(e){
                e.preventDefault();
                var filename = $("#files").val();
                let result = fetch('<cfoutput>#cgi.script_name#</cfoutput>', { method: 'POST', body: new FormData(document.querySelector("#fileupload"))})
            });
            --->
        
        </script>




  

<br><br>

    <div class="container">
        <div class="card">
            <div class="card-header">
                File Mapping Tool
            </div>
            <div class="card-body text-left">
                <h5 class="card-title">Choose File</h5>
                <p class="card-text">Select an Excel or CSV file to upload and parse.</p>
                <form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" id="fileupload" enctype="multipart/form-data"> 
                    <input type="file" id="files" name="files" />
                    <input type="submit" value="Upload File" class="btn btn-primary" />
                </form>
            </div>
        </div>


        <cfif isDefined('files')>

<br>

        <div class="card">
            <div class="card-body">
                <h5 class="card-title">Default Destination Table</h5>
                <div class="card-text">
                    <p>This option allows to specify default destination table dropdown-select column. All source columns may be mapped independently to separate table columns, overwritting the default destination table.</p>
                    <select id="main_table">
                        <cfoutput query="q.dbtables">
                            <option value="#table_name#">#table_name# <cfif RECORD_COUNT GT 0>(#RECORD_COUNT#)</cfif></option>
                        </cfoutput>
                    </select>
                </div>
            </div>
        </div>

        <br>


            <pre class="prettyprint" style="max-height:420px; overflow:auto; position:relative;">
                <button class="btn btn-sm btn-dark btn-copy" style="top:10px; right:10px; float:right; position:sticky;" onClick="javascript:copyToClipboard('code')"><i class="fa fa-copy"></i> Copy to clipboard</button>
                <code style="color:#efefef;" id="code"></code>
            </pre>

            <p>Source file has <span class="badge rounded-pill bg-secondary"><cfoutput>#ArrayLen(cols)#</cfoutput></span> available columns</p>

        </div>

            <table class="table table-striped table-sm" id="formtable">
                <thead class="thead-dark">
                    <tr>
                        <th>#</th>
                        <th></th>
                        <th>Source Column</th>
                        <th>Alias</th>
                        <th>Data Type</th>
                        <th>Table</th>
                        <th>Column</th>
                    </tr>
                </thead>
                <tbody>

            <cfscript>
                    i=0;
                    for(col in cols){
                        i++; column_alias = replace(ReReplaceNoCase(replace(col.name,'_',' ','all'),"\b(\w)","\u\1","ALL"),' ','_','all');
                        writeOutput('<tr>
                                <input type="hidden" name="source_column_index" value="#i#">
                                <input type="hidden" name="source_column_name" value="#col.name#">
                                <td>#i#</td>
                                <td><input type="checkbox" name="include_column" value="1" id="#column_alias##i#"></td>
                                <td><label for="#column_alias##i#">#col.name#<label></td>
                                <td><input type="text" name="source_column_alias" value="#column_alias#"   class="form-control input-sm"></td>
                                <td>#dtSelect(
                                    (isDefined('col.TypeName'))? col.TypeName:'VARCHAR'
                                    
                                    )#</td>
                                <td>
                                    <select name="table" class="form-control input-sm  tableselect" id="#i#">
                                        <option></option>
                                    </select>
                                </td>
                                <td>
                                    <select name="column" data-source-column="#col.name#"  class="form-control input-sm column" id="#i#">
                                        <option></option>
                                    </select>
                                </td>
                            </tr>');
                    }
            </cfscript>
        </tbody>
        </table>

    </cfif>
