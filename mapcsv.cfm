    <cffunction name="upload" access="remote" returntype="any" output="false" hint="">
        <cfargument name="uploaddir" required="false" default="#getTempDirectory()#" type="string" hint="Absolute path filepath, function will created dir of the dir path doesn't exist." />
        <cfargument name="mimeTypes" required="false" default="text/csv, application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" type="string" hint="Comma delimited list of header mine/types to accept." />
        <cfscript>
            // include "/includes/s3auth.cfm";
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
                local.SQL = " 
                SELECT  TABLE_SCHEMA, 
                        TABLE_NAME, 
                        table_rows AS RECORD_COUNT
                FROM INFORMATION_SCHEMA.TABLES
                -- WHERE 	TABLE_NAME NOT IN (:blacklist)
                WHERE TABLE_SCHEMA = 'db1091448_probateleads'
                -- AND TABLE_ROWS >=0
                ORDER BY TABLE_NAME
            ";

           return queryExecute(local.SQL, { }, {  result = "r.serverinfo" } );
        }
        
        q.dbtables = getTables();

        if(isDefined('files')){
            result = upload('#files#');
            json.dt =  DeserializeJSON(FileRead(expandpath('json\mysql_data_types.json')));

            function dtSelect(TypeName){
                savecontent variable="local.select" {
                    writeoutput('<select name=""  class="form-control input-sm" id="">');
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
    
            cfspreadsheet( action="read", src=result, query="foo", headerrow=1, excludeHeaderRow=true );
            cols = getMetadata(foo);

        }
    </cfscript>

    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
        
        <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>

        <!-- Boostrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
                
        <style>
            h1 { text-align: center }
            p { text-align: center; margin-top: 20px }
            optgroup { border-bottom:1px solid #eee; }
        </style>
        <script>
            var dbtables = <cfoutput>#SerializeJSON(q.dbtables,'struct')#</cfoutput>;
            $(document).on('change','#main_table',function(){
                thisVal = $(this).val(); console.log(thisVal);
                $('.tableselect').empty();
                $('<option />').attr({ value:thisVal, selected:'true' }).text(thisVal).appendTo('.tableselect:empty')
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
                if($(this).val()==''){
                    parenttr = $(this).closest("tr");
                    table = parenttr.find('select.tableselect').val();
                    tableProps(table,parenttr);
                } else {
                    thisval = $(this).val();
                }
            }).ready(function(){
 
            });

            function tableProps(table,parenttr){
                $.ajax({
                    type: "GET",
                    url: 'cfcs/dbtool.cfc',
                    data: {
                        method: 'table_design',
                        returnformat: 'json', 
                        queryformat: 'struct', 
                        table: table
                    }, 
                    success: function(result) {
                        result = jQuery.parseJSON(result); 
                        parenttr.find('.column').empty();
                        $('<option />').text('').appendTo(parenttr.find('select.column'));
                        $.each(result, function(i, r) {
                            $('<option />').attr({ value:r.column_name }).text(r.column_name).appendTo(parenttr.find('select.column'));
                            console.log(r.column_name);
                        });
                    }
                });
            }

            console.log(dbtables);

            <!---
            $(document).on('submit','form',function(e){
                e.preventDefault();
                var filename = $("#files").val();
                let result = fetch('<cfoutput>#cgi.script_name#</cfoutput>', { method: 'POST', body: new FormData(document.querySelector("#fileupload"))})
            });
            --->
        
        </script>
    </head>

    <body>





    <div class="page-header">
        <h1>Bootstrap Upload Control </h1>
    </div>




    <div class="container">

            <form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" id="fileupload" enctype="multipart/form-data"> 
                <input type="file" id="files" name="files" multiple="multiple" />
                <p> <input type="submit" value="Upload Files" class="btn btn-lg btn-primary" /> </p>
            </form>



            <select id="main_table">
                <cfoutput query="q.dbtables">
                    <option value="#table_name#">#table_name# <cfif RECORD_COUNT GT 0>(#RECORD_COUNT#)</cfif></option>
                </cfoutput>
            </select>


            <table class="table table-striped table-sm">
                <thead class="thead-dark">
                    <tr>
                        <th>#</th>
                        <th>Source Column</th>
                        <th>Alias</th>
                        <th>Data Type</th>
                        <th>Table</th>
                        <th>Column</th>
                    </tr>
                </thead>
                <tbody>

            <cfscript>
                if(isDefined('files')){
                    i=0;
                    for(col in cols){
                        i++;
                        writeOutput('<tr>
                                <td>#i#</td>
                                <td>#col.name#</td>
                                <td><input name="alias#1#" value="#replace(ReReplaceNoCase(replace(col.name,'_',' ','all'),"\b(\w)","\u\1","ALL"),' ','_','all')#"   class="form-control input-sm"></td>
                                <td>#dtSelect(col.TypeName)#</td>
                                <td>
                                    <select name="table#i#" class="form-control input-sm  tableselect" id="#i#">
                                        <option></option>
                                    </select>
                                </td>
                                <td>
                                    <select name="column#i#" data-source-column="#col.name#"  class="form-control input-sm column" id="#i#">
                                        <option></option>
                                    </select>
                                </td>
                            </tr>');
                    }
                }
            </cfscript>
        </tbody>
        </table>
        
</div>

</body>
</html>