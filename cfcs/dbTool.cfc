component
    hint="I'm used to generate table data." {
	// if(Listfind(session.deptlist, application.adminsDepartment.development) lt 1) { writeOutput('Permission Denied: Restricted to Developer Access Only'); exit; }
	//session.datasourcename = (isDefined('arguments.dsn'))? arguments.dsn:application.dsn;

	request.blacklist = ['exclude_tables','Personally_Identifiable_Information','etc']; /* array of tale names to ignore, hide, restrict */
	request.PIIColumns = ['username','user_name','user_pass','userpass','pass','password','ssn','ccnumber','ccnum','ccno','cccode','credit_card','user_name_alias']; /* Array of generic column names to restrict data display */
	
	request.dbtype = 'MSSQL';
	if(request.dbtype is 'MSSQL') { request.table_schema = ''; }
	session.datasourcename = (isDefined('session.datasourcename'))? session.datasourcename : serverDSNs()[1];
	session.dbservice = (isDefined('session.datasourcename')? new dbinfo(datasource=session.datasourcename):new dbinfo() ); 


	remote function init() {
		try {
			session.dbservice = (isDefined('session.datasourcename')? new dbinfo(datasource=session.datasourcename):new dbinfo() ); 
			return this;
		} catch (any e) {
			writeDump(e); exit;
		} 
	}

 	remote function serverDSNs() { return CreateObject("java", "coldfusion.server.ServiceFactory").DataSourceService.getNames(); }

	remote function setDSN() {
		session.datasourcename = (isDefined('arguments.dsn') AND len(arguments.dsn) AND arguments.dsn neq 'null' AND arguments.dsn neq 'undefined')? arguments.dsn : serverDSNs()[1];
		cfcookie(name = 'dsn', value = session.datasourcename);
		return { success:1, message:'Datasource set to #session.datasourcename#.' }
	}

 	remote function cfserverInfo() { return session.dbservice.version(); }

	remote function mssqlserverInfo() {
		q.dbfiles = queryExecute(" SELECT file_id, name, type_desc, physical_name, size, max_size  FROM sys.database_files; ", {}, { datasource = session.datasourcename, result = "r.serverinfo" });
		q.dbinfo = queryExecute(" 
			SELECT SERVERPROPERTY('ServerName') AS [SQLServerName]
			, SERVERPROPERTY('ProductVersion') AS [SQLProductVersion]
			, SERVERPROPERTY('ProductMajorVersion') AS [ProductMajorVersion]
			, SERVERPROPERTY('ProductMinorVersion') AS [ProductMinorVersion]
			, SERVERPROPERTY('ProductBuild') AS [ProductBuild]
			, CASE LEFT(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')),4) 
				WHEN '8.00' THEN 'SQL Server 2000'
				WHEN '9.00' THEN 'SQL Server 2005'
				WHEN '10.0' THEN 'SQL Server 2008'
				WHEN '10.5' THEN 'SQL Server 2008 R2'
				WHEN '11.0' THEN 'SQL Server 2012'
				WHEN '12.0' THEN 'SQL Server 2014'
				WHEN '13.0' THEN 'SQL Server 2016'
				ELSE 'SQL Server 2016+'
			END AS [SQLVersionBuild]
			, SERVERPROPERTY('ProductLevel') AS [SQLServicePack]
			, SERVERPROPERTY('Edition') AS [SQLEdition]

			, @@VERSION AS FULL_VER
			, SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS MachineName
   			, SERVERPROPERTY('InstanceName') AS InstanceName 
			, CONNECTIONPROPERTY('local_net_address') AS local_net_address
			, DB_NAME() AS [CurrentDatabase];
		", { 
			
		}
		, { datasource = session.datasourcename, result = "r.serverinfo" } );
		
		r = QueryGetRow(q.dbinfo, 1);
		StructAppend(r, { FILES:q.dbfiles } );

		return r;

	}


	remote any function getTables(){

		try {
			sql = {
				mysql: "
					SELECT  TABLE_SCHEMA, 
							TABLE_NAME, 
							table_rows AS RECORD_COUNT,
							round(data_length * 8/1024, 2)  AS USED_SPACE, 
							round(index_length * 8/1024, 2)  AS UNUSED_SPACE, 
							round((data_length + index_length) * 8/1024, 2) AS TOTAL_SPACE, 
					FROM INFORMATION_SCHEMA.TABLES
					WHERE 	TABLE_NAME NOT IN (:blacklist)
					AND TABLE_SCHEMA = :table_schema
					AND TABLE_ROWS >=0
					#( (isDefined('arguments.filter'))? " AND TABLE_NAME LIKE :filter ":"" )#
					ORDER BY :sort_by
				",
				mssql: "
					SELECT 
						t.NAME AS TABLE_NAME,
						s.Name AS TABLE_SCHEMA,
						p.rows AS RECORD_COUNT,
						SUM(a.total_pages) * 8 AS TotalSpaceKB, 
						CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TOTAL_SPACE,
						SUM(a.used_pages) * 8 AS UsedSpaceKB, 
						CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS USED_SPACE, 
						(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
						CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UNUSED_SPACE
					FROM	sys.tables t
							INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
							INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
							INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
							LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
					WHERE	t.name NOT IN (:blacklist) AND t.NAME NOT LIKE 'dt%' 
							#( (isDefined('arguments.filter'))? " AND t.Name LIKE :filter ":"" )#
							AND t.is_ms_shipped = 0
							AND i.OBJECT_ID > 255 
					GROUP BY  t.Name, s.Name, p.Rows
					ORDER BY  TOTAL_SPACE DESC, t.Name					
				"
			}

			q.serverinfo = queryExecute(sql.mssql, {
				table_schema = { cfsqltype='CF_SQL_VARCHAR', value=request.table_schema }, 
				blacklist = { cfsqltype='CF_SQL_VARCHAR', value=request.blacklist.toList(), list=1 }, 
				filter = { cfsqltype='CF_SQL_VARCHAR', value= isDefined('arguments.filter') ? arguments.filter & '%':'' },
				sort_by = { cfsqltype='CF_SQL_VARCHAR', value=arguments.sort_by & ' ' & arguments.sort_dir }
			}, { datasource = session.datasourcename, result = "r.serverinfo" } );

            return q.serverinfo;
		} catch (any e) {
			writeDump(e); exit;
        } 
	}

    remote function databases() {
       return session.dbservice.dbnames();
    }

    remote function sqlCMD() {
		if(cgi.REMOTE_HOST is not cgi.LOCAL_ADDR){
			return { success:false, message:'Access Denied' }; abort;
		} else if (cgi.content_type EQ "application/json" OR cgi.content_type EQ "application/json;charset=UTF-8" ){
            jsonStruct = deserializeJSON(ToString(getHTTPRequestData().content));
            try {
				queryService = new Query();
    			queryService.setAttributes(result='theResult', debug=true); 	
				queryService.setDataSource(session.datasourcename);
				queryService.setSQL(jsonStruct.sql);
				qryResult = queryService.execute();
            } catch (any e) {
				return { success:false,message:listlast(e.queryError,']') }
				exit;
            } 

			try {
				if(qryResult.getresult().recordcount gte 0) { 
					result= qryResult.getresult();
					columns = [];
					for (r in qryResult.getresult().getMetaData().getColumnLabels()) {
						ArrayAppend(columns, { key: '#r#', label: '#r#', sortable: 'true' });
					}
					return  { success:true, 'fields' : columns, items: qryResult.getresult() } exit;
				} 
			} catch (any e) {
				writeOutput(e);
				writeDump(qryResult.getPrefix()); exit;
			}

        } else{
			return { success:false, message:'Not Authorized' }; abort;
		}
        
    }

	remote any function exporttbldesign(required string table, string sheetName=arguments.table, boolean includeColumnNames=true){
		local.tabledesign = session.dbService.Columns(table=arguments.table);
		QueryDeleteColumn(local.tabledesign,"ORDINAL_POSITION"); QueryDeleteColumn(local.tabledesign,"CHAR_OCTET_LENGTH");
		local.tableColumns = ListToArray(local.tabledesign.ColumnList);
		spreadsheetObj = SpreadsheetNew(arguments.sheetName, true);
		poiSheet = spreadsheetObj.getWorkBook().getSheet(arguments.sheetName);
		poiSheet.setMargin(poiSheet.LeftMargin, 0.25); poiSheet.setMargin(poiSheet.RightMargin, 0.25);
		ps = poiSheet.getPrintSetup(); ps.setLandscape(true);
		spreadsheetAddrows(spreadsheetObj,local.tabledesign,1,1,true,[""],arguments.includeColumnNames); 
		SpreadsheetFormatRow(spreadsheetObj, {autosize="true", bold="true", textwrap="true", alignment="left"}, 1 );
		for (i=0; i <= (ListLen(local.tabledesign.ColumnList)-1); i=i+1) poiSheet.autoSizeColumn( javacast("int", i) );
		SpreadsheetSetHeader(spreadsheetObj,"Table Properties", arguments.sheetname, "#DateFormat(now(),'mm/dd/yyyy')# @ #TimeFormat(now(),'h:mm tt')#");		
		letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
		headerRow = 'A1:#ListGetAt(letters,ListLen(local.tabledesign.ColumnList))#1';
		SpreadSheetAddAutoFilter(spreadsheetObj,headerRow);
		SpreadsheetAddFreezePane(spreadsheetobj,1,1);
		cfheader(name="Content-Disposition", value="attachment; filename=TBLDESIGN-#UCASE(arguments.table)#-#DateFormat(now(),'mmddyyyy')#AT#TimeFormat(now(),'hhmmsstt')#.xlsx");
		cfcontent(type="application/vnd.ms-excel", variable="#SpreadsheetReadBinary(spreadsheetObj)#" );
	}

	remote any function exporttblData(required string table, string sheetName=arguments.table, boolean includeColumnNames=true){
		// init('ws_vegasinsider');
		cnt = table_rowcount(arguments.table);
		local.tabledesign = session.dbService.Columns(table=arguments.table);
		var SQL = "SELECT * FROM #arguments.table# WITH (NOLOCK)";
		// var SQL = "SELECT ROW_NUMBER() OVER ( ORDER BY #local.tabledesign[1].column_name#  DESC) AS RowNum, * FROM #arguments.table# WITH (NOLOCK) ";
		// var SQL = "SELECT * FROM (#SQL#) AS Records  WHERE RowNum >= '#start_row#' AND RowNum < '#end_row#' ORDER BY RowNum";
		local.tblData = new Query(datasource=session.datasourcename, sql="#SQL#").execute().getResult();
		spreadsheetObj = SpreadsheetNew(arguments.sheetName, true);
		poiSheet = spreadsheetObj.getWorkBook().getSheet(arguments.sheetName);
		poiSheet.setMargin(poiSheet.LeftMargin, 0.25); poiSheet.setMargin(poiSheet.RightMargin, 0.25);
		ps = poiSheet.getPrintSetup(); ps.setLandscape(true);

		spreadsheetAddrows(spreadsheetObj,local.tblData,1,1,true,[""],arguments.includeColumnNames); 
		SpreadsheetFormatRow(spreadsheetObj, {autosize="true", bold="true", textwrap="true", alignment="left"}, 1 );
		for (i=0; i <= (ListLen(local.tblData.ColumnList)-1); i=i+1) {
			poiSheet.autoSizeColumn( javacast("int", i) );
		}
		SpreadsheetSetHeader(spreadsheetObj,"Table Data", UCASE(arguments.sheetname), "#DateFormat(now(),'mm/dd/yyyy')# @ #TimeFormat(now(),'h:mm tt')#");		
		letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z";
		headerRow = 'A1:#ListGetAt(letters,ListLen(local.tblData.ColumnList))#1';
		SpreadSheetAddAutoFilter(spreadsheetObj,headerRow);
		SpreadsheetAddFreezePane(spreadsheetobj,1,1);
		cfheader(name="Content-Disposition", value="attachment; filename=DATA-#UCASE(arguments.table)#-#DateFormat(now(),'mmddyyyy')#AT#TimeFormat(now(),'hhmmsstt')#.xlsx");
		cfcontent(type="application/vnd.ms-excel", variable="#SpreadsheetReadBinary(spreadsheetObj)#" );

	}

	remote any function GetDBbyDS(GetDBbyDS){
		if(fileexists("#SERVER.Coldfusion.rootdir#lib  eo-datasource.xml")){
			wds = FileRead("#SERVER.Coldfusion.rootdir#lib  eo-datasource.xml");
			cfwddx(action="wddx2cfml", input="#wds#", output="resds");
		}
	}


	remote any function table_list(table){
        tables_blacklist = 'cc_info,cc_trans,cc_trans_dev,cc_info_20160808';
		rs1 = session.dbService.Tables();
		q.filtered = new Query();
		q.filtered.setDBType('query');
		q.filtered.setAttributes(rs=rs1); // needed for QoQ
		q.filtered.addParam(name='TABLELIST', value='#tables_blacklist#', cfsqltype='cf_sql_varchar', list='yes');
		q.filtered.setSQL("SELECT * FROM rs where TABLE_NAME NOT IN ( :TABLELIST ) ORDER BY TABLE_TYPE, TABLE_NAME");
		result = q.filtered.execute().getResult();
		return result;
	}	


	remote any function table_primarykeys(table){
		// return session.dbService.foreignkeys(table=arguments.table);
		rs1 = session.dbService.Columns(table=arguments.table);
		q.foreignkeys = new Query();
		q.foreignkeys.setDBType('query');
		q.foreignkeys.setAttributes(rs=rs1); // needed for QoQ
		q.foreignkeys.addParam(name='PRIMARYKEY', value='YES', cfsqltype='cf_sql_varchar');
		q.foreignkeys.setSQL('SELECT * FROM rs where IS_PRIMARYKEY = :PRIMARYKEY');
		result = q.foreignkeys.execute().getResult();
		return result;
	}	

	remote any function primarykey_list(table){
		R = table_primarykeys(table=arguments.table);
		return ValueList(R.COLUMN_NAME);
	}

	remote any function table_foreignkeys(table){
		rs1 = session.dbService.Columns(table=arguments.table);
		q.foreignkeys = new Query();
		q.foreignkeys.setDBType('query');
		q.foreignkeys.setAttributes(rs=rs1); // needed for QoQ
		q.foreignkeys.addParam(name='FOREIGNKEY', value='YES', cfsqltype='cf_sql_varchar');
		q.foreignkeys.setSQL('SELECT * FROM rs where IS_FOREIGNKEY = :FOREIGNKEY');
		result = q.foreignkeys.execute().getResult();
		return result;
	}

	remote any function records(required string table, numeric currentPage='1', numeric perPage='40', numeric spaceCamelCase = 0 ){
		requestBody = toString( getHttpRequestData().content )
		arguments = deserializeJSON( requestBody );

		local.totalRecords = table_rowcount(table).record_count;
		local.totalPages =  ceiling(local.totalRecords / arguments.perPage);
		local.startRow = ceiling(((arguments.currentPage * arguments.perPage) - arguments.perPage));
		local.endRow = ceiling(arguments.currentPage * arguments.perPage);
		local.tabledesign = session.dbService.Columns(table=arguments.table)
		local.primarykeys = table_primarykeys(table=arguments.table);
		local.selectColumns = [];
		for (r in queryToArray(local.tabledesign)) {
			ArrayAppend(local.selectColumns,(arrayFind(request.PIIColumns,r.column_name))? "'PII Restricted' AS #r.column_name#":"#r.column_name#");
		}

		sql = {
			mysql: " SELECT #ArrayToList(local.selectColumns)# FROM #arguments.table# ORDER BY #( isDefined('arguments.sort_by')? arguments.sort_by : (local.primarykeys.recordcount GTE 1) ? local.primarykeys.getRow(1).COLUMN_NAME : local.tabledesign.COLUMN_NAME[1] )# #arguments.sort_dir# LIMIT #local.startRow#, #local.endRow#",
			mssql: " SELECT #ArrayToList(local.selectColumns)# FROM #arguments.table# ORDER BY #( isDefined('arguments.sort_by')? arguments.sort_by : (local.primarykeys.recordcount GTE 1) ? local.primarykeys.getRow(1).COLUMN_NAME : local.tabledesign.COLUMN_NAME[1] )# #arguments.sort_dir# OFFSET #local.startRow# ROWS FETCH NEXT #local.endRow# ROWS ONLY "
		}

		qObj = queryExecute(sql.mssql, {}, { datasource=session.datasourcename });
		
		local.columns = [];
		for (r in queryToArray(local.tabledesign)) {
			ArrayAppend(local.columns, { key: '#UCASE(r.column_name)#', label: (spaceCamelCase is 1)? '#camelToSpace(r.column_name,1)#':'#r.column_name#', sortable: 'true', data_type: '#r.type_name#', column_size:'#r.column_size#' });
		}
		
		return { 
			success: true,
			total_records: local.totalRecords, 
			total_pages: local.totalPages, 
			perPage:arguments.perPage, 
			currentPage:arguments.currentPage,  
			start_row: local.startRow, 
			end_row: local.endRow,
			next_row: local.endRow+1, 
				fields:local.columns, 
				items: qObj, 
				filters: (isDefined('arguments.filters'))? this.filters : []
		}
		
	}

	remote any function calcPagination(required query qObj, required numeric currentPage, required numeric perPage, required numeric totalRecords){

		try {	
			local.totalPages =  ceiling(arguments.totalRecords / arguments.perPage);
			local.startRow = ceiling(((arguments.currentPage * arguments.perPage) - arguments.perPage) + 1);
			local.endRow = ceiling(arguments.currentPage * arguments.perPage);
			local.columnArray = qObj.getMetaData().getColumnLabels();
			local.columns = [];
			for (r in local.columnArray) {
				intColumn = qObj.FindColumn(JavaCast( "string", r ));
				local.data_type = qObj.GetMetaData().GetColumnTypeName( JavaCast( 'int', intColumn ) );
				ArrayAppend(local.columns, { key: '#UCASE(r)#', label: '#camelToSpace(r,1)#', sortable: 'true', data_type: local.data_type });
			}
			return { 
				success: true,
				total_records: arguments.totalRecords, 
				total_pages: local.totalPages, 
				perPage:arguments.perPage, 
				currentPage:arguments.currentPage,  
				start_row: local.startRow, 
				end_row: local.endRow,
				next_row: local.endRow+1, 
				fields:local.columns, 
				items: qObj 
			}
		} catch (any e) {
			return { "success": false,"message": e.message };
		} 
	}


	remote any function paginateRecords(required query qObj, required numeric currentPage, required numeric perPage){

		try {	
			local.totalRecords = qObj.RecordCount;
			local.totalPages =  ceiling(local.totalRecords / arguments.perPage);
			local.startRow = ceiling(((arguments.currentPage * arguments.perPage) - arguments.perPage) + 1);
			local.endRow = ceiling(arguments.currentPage * arguments.perPage);
			rowRange(qObj,local.startRow,arguments.perpage);
			local.columnArray = qObj.getMetaData().getColumnLabels();
			local.columns = [];
			for (r in local.columnArray) {
				intColumn = qObj.FindColumn(JavaCast( "string", r ));
				local.data_type = qObj.GetMetaData().GetColumnTypeName( JavaCast( 'int', intColumn ) );
				ArrayAppend(local.columns, { key: '#UCASE(r)#', label: '#camelToSpace(r,1)#', sortable: 'true', data_type: local.data_type });
			}
			return { 
				success: true,
				total_records: local.totalRecords, 
				total_pages: local.totalPages, 
				perPage:arguments.perPage, 
				currentPage:arguments.currentPage,  
				start_row: local.startRow, 
				end_row: local.endRow,
				next_row: local.endRow+1, 
					fields:local.columns, 
					items: qObj 
			}
		} catch (any e) {
			return { "success": false,"message": e.message };
		} 
	}

	remote any function rowRange(required query qObj, required numeric start = 1, required numeric range = 20 ){
		// return a range of rows from a given query
		/*
		argument name="qObj" type="query" required="true";
		argument name="start" type="numeric" required="true" default="1" hint="The number of the first row to include";
		argument name="range" type="numeric" required="true" default="1" hint="The number of rows";
		*/
		var i = arguments.start+arguments.range-1;
		arguments.qObj.removeRows(i,arguments.qObj.recordcount-i);
		arguments.qObj.removeRows(0,arguments.start-1);
		return arguments.qObj;	
	}

	public any function camelToSpace(required string str, boolean capitalize){
		// Breaks a camelCased string into separate words
		/*
		argument name="str" type="string" required="true" hint="String to use (Required)";
		argument name="capitalize" type="boolean" hint="Boolean to return capitalized words (Optional)";
		*/
		var rtnStr=lcase(reReplace(arguments.str.replace('_',' ','all'),"([A-Z])([a-z])"," \1\2","ALL"));
		if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
			rtnStr=reReplace(arguments.str.replace('_',' ','all'),"([a-z])([A-Z])","\1 \2","ALL");
			rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
		}
		return trim(rtnStr);
	}

	function MSSQL2CFSQLDT (DataType) {
		var MSSQLType = 'int identity,int,bigint,smallint,tinyint,numeric,money,smallmoney,bit,decimal,float,real,datetime,smalldatetime,char,nchar,varchar,nvarchar,text,ntext';
		var CFSQLType = 'CF_SQL_INTEGER,CF_SQL_INTEGER,CF_SQL_BIGINT,CF_SQL_SMALLINT,CF_SQL_TINYINT,CF_SQL_NUMERIC,CF_SQL_MONEY4,CF_SQL_MONEY,CF_SQL_BIT,CF_SQL_DECIMAL,CF_SQL_FLOAT,CF_SQL_REAL,CF_SQL_TIMESTAMP,CF_SQL_DATE,CF_SQL_CHAR,CF_SQL_CHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_LONGVARCHAR,CF_SQL_LONGVARCHAR';
		
		if(listfindnocase(MSSQLType,DataType)) {
			return ListGetAt(CFSQLType,listfindnocase(MSSQLType,DataType));
		} else { return 'NULL'; }
	}

	remote any function codegen(table,primary_keys=''){
			qry.params = session.dbService.Columns(table=arguments.table);
			
			qry.primaryKeys = table_primarykeys(arguments.table);
			argsList = '';
			for (row in qry.params) {
				req = (!row.IS_NULLABLE)? 'required':'';
				argsList = listAppend(argsList,"#req# #row.column_name# = ''");
			}
			myresult.cfscript_function =  "public functionName(#replace(argsList,',',', ','all')#){ }";
			

			updateVARlist = '';
			updateParamlist = '';
			insertParamlist = '';
			cfupdateVARlist = '';
			cfupdateParamlist = '';
			cfinsertParamlist = '';

			for (row in qry.params) {
				updateVARlist = listAppend(updateVARlist, '#req# #row.column_name# = { cfsqltype="#MSSQL2CFSQLDT(row.type_name)#", value="##arguments.#row.column_name###", required = "#!row.IS_NULLABLE#", null = (len(trim(arguments.#row.column_name#)) eq 0)? "true":"false" }','|');
				updateParamlist = listappend(updateParamlist,'#row.column_name# = :#row.column_name#');
				insertParamlist = listappend(insertParamlist,':#row.column_name#');
			}


			savecontent variable="local.InsertSQL"{
				writeoutput('INSERT INTO #table# ( #replace(ValueList(qry.params.column_name),',',', #chr(10)##chr(9)#','all')# ) #chr(10)#');
				writeoutput('VALUES ( #replace(insertParamlist,',',', #chr(10)##chr(9)#','all')# )');
			}

			for (row in qry.params) {
				cfupdateVARlist = listAppend(updateVARlist, '#req#  = #Chr(60)#cfparam name="#row.column_name#" cfsqltype="#MSSQL2CFSQLDT(row.type_name)#", value="##arguments.#row.column_name###", null = (len(trim(arguments.#row.column_name#)) eq 0)? "true":"false" }','|');
				cfupdateParamlist = listappend(updateParamlist,'#row.column_name# = #row.column_name#');
				cfinsertParamlist = listappend(cfinsertParamlist,'#Chr(60)#cfqueryparam value="##arguments.#row.column_name###" maxLength="#row.Column_Size#" cfsqltype="#MSSQL2CFSQLDT(row.type_name)#" required = "#!row.IS_NULLABLE#" />'); // #((!row.IS_NULLABLE)?'': 'null=(len(trim(arguments.#row.column_name#)) eq 0)? "true":"false"')#
			}			
			savecontent variable="local.CFInsertSQL"{
				writeoutput('#Chr(60)#CFQUERY name="q.insert#table#" datasource="##application.dsn##">#chr(10)##chr(9)#INSERT INTO #table# (#chr(10)##chr(9)##replace(ValueList(qry.params.column_name),',',', #chr(10)##chr(9)#','all')# #chr(10)##chr(9)#) #chr(10)#');
				writeoutput('VALUES ( #chr(10)##chr(9)##replace(cfinsertParamlist,',',', #chr(10)##chr(9)#','all')##chr(10)##chr(9)# )#chr(10)##chr(9)#');
				writeoutput('#Chr(60)#/CFQUERY>');
			}

			savecontent variable="local.UpdateSQL"{
				writeoutput('UPDATE #table# #chr(10)#');
				writeoutput('SET #replace(updateParamlist,',',', #chr(10)##chr(9)#','all')#');
				writeoutput('#chr(10)#WHERE #qry.primaryKeys.column_name# = :#qry.primaryKeys.column_name# #chr(10)#');
			}		

			myresult.cfscript_insert = "q.insert#table# = queryExecute('#local.InsertSQL#', {#chr(10)##replace(updateVARlist,'|',',#chr(10)##chr(9)#','all')# #chr(10)#}, { datasource = session.datasourcename, result = 'r.insert#table#' } );";
			myresult.cfquery_insert = "#local.cfInsertSQL#";
			myresult.cfscript_update = "q.update#table# = queryExecute('#local.UpdateSQL#', {#chr(10)##replace(updateVARlist,'|',',#chr(10)##chr(9)#','all')# #chr(10)#}, { datasource = session.datasourcename, result = 'r.update#table#' } ); ";

			return myresult;
	}

	remote any function table_design(table,primary_keys=''){
		// if(!isDefined('session.dbService')) init();
        return queryToArray(session.dbService.Columns(table=arguments.table));
	}


	remote any function table_rowcount(required string table){
		q = new Query(); q.setdatasource(session.datasourcename);
		switch(request.dbtype) {
			case "MySQL":
				q.setsql("
					SELECT  table_rows AS RECORD_COUNT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '#arguments.schema#' AND TABLE_NAME = '#arguments.table#'
				");
				break;
			case "MSSQL":
				q.setsql("SELECT CAST(p.rows AS int) AS RECORD_COUNT FROM sys.tables AS tbl INNER JOIN sys.indexes AS idx ON idx.object_id = tbl.object_id and idx.index_id < 2 INNER JOIN sys.partitions AS p ON p.object_id=CAST(tbl.object_id AS int) AND p.index_id=idx.index_id WHERE ((tbl.name='#arguments.table#' AND SCHEMA_NAME(tbl.schema_id)='dbo'))");
				break;
		}
		return q.execute().getresult();
	}


	public function ucFirst(str){
		return ReReplace(str,"\b(\w)","\u\1","ALL");
	}


	remote any function webform(table){
		q.table_design = session.dbService.Columns(table=arguments.table);

		savecontent variable='webformcode' {

			writeOutput('<div class="row">');

				for (tbl in q.table_design) {

					//data = QueryGetRow(tbl.table_design, tbl.table_design.CurrentRow);

					if(tbl.IS_PRIMARYKEY == 'YES'){
						input = 'text';  inputtype = 'text'; 
					} else if(tbl.IS_FOREIGNKEY == 'YES'){
						input = 'select';
						q.tablerelation = new Query( 
							sql = "SELECT * FROM #tbl.REFERENCED_PRIMARYKEY_TABLE#",
							datasource=session.datasourcename
						).execute().getResult();
					} else if(listfindnocase('text,varchar(max),nvarchar(max)',tbl.TYPE_NAME)){
						input = 'textarea'; 
					} else if(tbl.TYPE_NAME == 'bit'){
						input = 'truefalse';
					} else if(listfindnocase('date,datetime',tbl.TYPE_NAME)){
						input = 'date';
					} else {
						input = 'text';
						switch(tbl.TYPE_NAME) {
							case 'int, int identity':
								inputtype = 'number'; input='number'; 
							case 'varchar': case 'nvarchar':
								inputtype = 'text';	
							default:	
								inputtype = 'text';			
						}
					}

					readonly = (tbl.IS_PRIMARYKEY  is 'YES')?'readonly':'';
					required = (tbl.IS_NULLABLE is 'YES')?'':'required';
					required_label_class = (tbl.IS_NULLABLE == 'YES')? '':'required';
					label_string = camelToSpace(tbl.COLUMN_NAME,1);
					label_string = (tbl.IS_PRIMARYKEY == 'NO')? replaceNoCAse(label_string,'id',''): replaceNoCase(label_string,'id','ID'); 
					label_string = ucFirst(label_string).replaceNoCase('ind','IND');

					writeOutput('<div class="form-group col-12 col-lg-4 col-md-6 col-sm-12 ">');

					if(input != 'truefalse') { 
						if(tbl.IS_PRIMARYKEY == 'YES'){
							writeOutput('<label class="control-label #required_label_class# primarykey">'& label_string &'</label>'); 
						} else {
							writeOutput('<label class="control-label #required_label_class#">'& label_string &'</label>'); 
						}
					}
					switch(input) {
						case 'select':
							// writeOutput('<select name="' & tbl.COLUMN_NAME & '" class="form-control"></select>');
							writeOutput('<div class="dropdown-emulator" data-table="#table#">');
								writeOutput('<a  class="dropdown-emulator-select">');
									writeOutput('<input type="text" name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" class="form-control" maxlength="#tbl.COLUMN_SIZE#" data-validation="#required#, length" data-validation-length="1-#tbl.COLUMN_SIZE#"  #readonly#>');
								writeOutput('</a><div class="table-wrapper">');
								htmlTable(q.tablerelation);
							writeOutput('</div></div>');
							break;
						case 'textarea':
							writeOutput('<textarea name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" class="form-control"  #readonly#></textarea>'); break;
						case 'hidden': 
							writeOutput('<input type="hidden" name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" class="form-control">'); break;
						case 'date': 
							writeOutput('<div class="input-group date"><input type="date" name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" class="form-control" maxlength="#tbl.COLUMN_SIZE#" data-validation="#required#, length" data-validation-length="1-#tbl.COLUMN_SIZE#" #readonly#><span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span></div>'); 
							break;
						case 'number': 
							writeOutput('<input type="number" name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" placeholder="' & label_string & '" class="form-control" maxlength="#tbl.COLUMN_SIZE#" data-validation="#required#, length" data-validation-length="1-#tbl.COLUMN_SIZE#" data-validation-regexp="[0-9]" autocomplete="off" data-toggle="popover" data-trigger="focus" data-placement="right" data-content="" data-original-title="" title=""  #readonly#>'); 
							break;
						case 'truefalse': 
							writeOutput('<input type="checkbox" name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" value="1" data-size="small" data-width="80" class="form-check-input" maxlength="#tbl.COLUMN_SIZE#" data-validation="#required#, length" data-validation-length="1-#tbl.COLUMN_SIZE#" data-validation-regexp="" autocomplete="off" data-toggle="popover" data-trigger="focus" data-placement="right" data-content="" data-original-title="" title=""  #readonly#>'); 
							break;
						case 'text': 
							writeOutput('<input type="text" name="' & tbl.COLUMN_NAME & '" id="' & tbl.COLUMN_NAME & '" placeholder="' & label_string & '" class="form-control" maxlength="#tbl.COLUMN_SIZE#" data-validation="#required#, length" data-validation-length="1-#tbl.COLUMN_SIZE#" data-validation-regexp="" autocomplete="off" data-toggle="popover" data-trigger="focus" data-placement="right" data-content="" data-original-title="" title=""  #readonly#>'); 
							break;
					}
					if(input == 'truefalse') { writeOutput(' <label class="form-check-label" for="' & tbl.COLUMN_NAME & '">'& label_string &'</label>'); }
					writeOutput('</div>');		
				}
			writeOutput('</div>');					
			}

	writeOutput(webformcode);

}

	remote any function html_table_design(table){
		try{
				return htmlTable(table_design(table=arguments.table, primary_keys=primarykey_list(arguments.table)));
        	} catch (any e) {
            		writeDump(e); abort;
            		rethrow; //CF9+
        	}
	}

	public string function htmlTable(required q, primary_keys=''){
		try{
				writeOutput('<table class="data-table table display table-striped table-bordered compact dataTable no-footer" cellspacing="0">');
				tHead(q=arguments.q, primary_keys =arguments.primary_keys);
				tBody(q=arguments.q, primary_keys =arguments.primary_keys);
				writeOutput('</table>');
        	
			} catch (any e) {
            		writeDump(e); abort;
            		rethrow; //CF9+
        	}
	}
	
	public string function tHead(required q, primary_keys){
		try{
			if(isArray(q)){
				writeOutput('<thead><tr>'); 
				for(column_name in structKeyList(q[1])){ writeOutput('<th>#rereplace(column_name,'_',' ','all')#</th>'); }
				writeOutput('</tr></thead>');
			} else { writeOutput('<thead></thead>'); }
		} catch (any e) {
				writeDump(e); abort;
				rethrow; //CF9+
		}
	}

	public string function tBody(required q, primary_keys){
		try{
			if(isArray(q) && ArrayLen(q) GTE 1){
				writeOutput('<tbody>');
				for(b=1; b<=ArrayLen(arguments.q); b++) {
					writeOutput('<tr row="#b#" primarykeys="#arguments.primary_keys#">');
					for(column_name in  structKeyList(q[1])){
						writeOutput('<td>#arguments.q[b][column_name]#</td>');
					}
					writeOutput('</tr>');
				}
				writeOutput('</tbody></table>');
			} else { writeOutput('<tbody></tbody>'); }
		} catch (any e) {
				writeDump(e); abort;
				rethrow; //CF9+
		}
	}



	private function queryToArray(q) {
        var s = [];
        var cols = q.columnList;
        var colsLen = listLen(cols);
        for(var i=1; i<=q.recordCount; i++) {
            var row = {};
            for(var k=1; k<=colsLen; k++) {
                row[lcase(listGetAt(cols, k))] = q[listGetAt(cols, k)][i];
            }
            arrayAppend(s, row);
        }
        return s;
    }


	remote string function updatesingle(required table){
		var sqlquery = "UPDATE #ARGUMENTS.TABLE# SET #ARGUMENTS.COLUMN# = '' WHERE #ARGUMENTS.PRIMARY_COLUMN# = " ;
	}
	
	remote string function update(required table){

		if(!ListContains('127.0.0.1,localhost', cgi.server_name)) { writeOutput('Restricted Page!'); abort; };

		local.tabledesign = table_design(table='#arguments.table#');
		local.primaryColumns = new Query(
			sql = "SELECT * FROM tabledata WHERE is_primarykey = 'YES'",
			dbtype = "query",
			tabledata = local.tabledesign
		); local.primaryColumns = local.primaryColumns.execute().getResult();

		local.setColumns = new Query(
			sql = "SELECT * FROM tabledata WHERE is_primarykey = 'NO' AND UPPER(COLUMN_NAME) IN (#UCASE(ListQualify(StructKeyList(FORM),"'"))#)",
			dbtype = "query",
			tabledata = local.tabledesign
		); local.setColumns = local.setColumns.execute().getResult();

		var sqlquery = arraynew(1); var params = structNew(); var whereArray = arraynew(1);
		
		for (i=1; i <= local.setColumns.RecordCount; i++) {
			COLUMNNAME = trim(local.setColumns.COLUMN_NAME[i]);
			switch(local.setColumns.TYPE_NAME){
				case "bit":
					ArrayAppend(sqlquery,'[#COLUMNNAME#] =  :#COLUMNNAME#');
					params[COLUMNNAME] = { value='#evaluate(COLUMNNAME)#', cfsqltype = 'CF_SQL_BIT' };
				default:
					ArrayAppend(sqlquery,'[#COLUMNNAME#] =  :#COLUMNNAME#');
					params[COLUMNNAME] = { value='#evaluate(COLUMNNAME)#', cfsqltype = 'CF_SQL_VARCHAR' };
			}
		}

		for (i=1; i <= local.primaryColumns.RecordCount; i++) {
			COLUMNNAME = trim(local.primaryColumns.COLUMN_NAME[i]);
			ArrayAppend(whereArray,'[#COLUMNNAME#] =  :#COLUMNNAME#');
			params[COLUMNNAME] = { value='#evaluate(COLUMNNAME)#' };
		}

		var SQL = "UPDATE [#arguments.table#]  SET #ArrayToList(sqlquery,', ')# WHERE #ArrayToList(whereArray,' AND ' )#";
		local.updatetable = queryExecute(SQL, params, { datasource=session.datasourcename, result = "local.myresult" });
		writeDump(local.myresult);

	}


}