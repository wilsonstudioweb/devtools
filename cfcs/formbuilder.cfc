
component hint="I'm used to generate web forms." {

	remote function getTables(){
        local.SQL =" SELECT  TABLE_SCHEMA, 
                TABLE_NAME, 
                table_rows AS RECORD_COUNT
        FROM INFORMATION_SCHEMA.TABLES
        -- WHERE 	TABLE_NAME NOT IN (:blacklist)
        WHERE TABLE_SCHEMA = 'db1091448_probateleads'
        -- AND TABLE_ROWS >=0
        ORDER BY TABLE_NAME ";
        return queryExecute(local.SQL, { }, { datasource = session.datasourcename, result = "r.tables" } );
    }

    remote function tabledef() {
        dbinfo = new dbinfo(datasource = session.datasourcename);
        return dbinfo.Columns(table=arguments.table);
    }

    remote function columnDef() {
        q.tabledef = tabledef(table=arguments.table);
        return queryExecute( " select * from q.tabledef WHERE column_name = :column_name ", { column_name = { value=arguments.column, cfsqltype="cf_sql_varchar"} }, { dbtype="query" } );
    }

}