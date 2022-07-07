


<script>
function cfqueryparam(field){
    switch (field.data_type) {
        case 'DATE':
            field.cfsql_type = 'cf_sql_date'; break;
        case 'DATETIME':
        case 'TIMESTAMP':
            field.cfsql_type = 'cf_sql_timestamp'; break;
        case 'INTEGER':
        case 'INT':
            field.cfsql_type = 'cf_sql_bigint'; break;
        case 'BIGINT':
            field.cfsql_type = ''; break;
        case 'BIT':
            field.cfsql_type = 'cf_sql_bit'; break;
        case 'VARCHAR': 
        case 'CHAR':
            field.cfsql_type = 'cf_sql_varchar'; break;
        default:
            field.cfsql_type = field.data_type; break;
    }

    return '&lt;cfqueryparam value="' & field.column_name & '" cfsqltype="' & field.cfsql_type & '">';
}
</script>