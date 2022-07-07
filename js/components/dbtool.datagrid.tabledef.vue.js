Vue.component('tabledef-datagrid', {
	props: {},
	template: ` 
	<div id="table-def-container">
		<div class="row" style="margin-bottom:4px;">
			<div class="col-md-8" style="padding-left:0;"><h3><i aria-hidden="true" class="fa fa-table fa2x"></i> {{this.table}} TABLE DEFINITION</h3></div>
			<div class="col-md-4 text-right">
				<a href="'/cfcs/dbtool.cfc?method=exporttbldesign&returnformat=json&queryformat=struct&table=' + table"  class="btn btn-sm light"><i class="fa fa-download  pull-right"></i> Export</a>
				<a href="#table-section" v-on:click="printTableDef" class="btn btn-sm btn-light"><i class="fa fa-print pull-right"></i> Print</a>
				<a href="##" class="btn btn-sm btn-light"><i class="fa-solid fa-maximize"></i></a>
			</div>
		</div>
		<div class="card">
			<div class="card-header row">
				<div class="col-4">Table: <b>{{ this.table }}</b></div>
				<div class="col-4">
					Sorted by: <b>{{ sortingBy }}</b> ({{ sortDesc ? 'Descending' : 'Ascending' }})<br>
				</div>
			</div>

			<b-table 
			id="table-tabledef"
			:items="items"
			:per-page="perPage"
			:current-page="currentPage"
			:fields="fields"      		
			:sort-by.sync="sortBy"
			:sort-desc.sync="sortDesc"
			responsive="sm"
			:sort-compare-options="{ numeric: true, sensitivity: 'base' }"
			sort-icon-left
			small striped 
			>

			</b-table>

	  </div>
        
    </div>
    `,
	data: function() {
		return {
			table: null,
			perPage: 500,
			currentPage: 1,
			sortBy: 'ordinal_position',
			sortDesc: false,
			items: [],
			fields: [
				{
					key: 'ordinal_position',
					label: '#',
					sortable: true
				},
				{
					key: 'column_name',
					label: 'Column Name',
					sortable: true
				},
				{
					key: 'is_primarykey',
					label: 'Primary key',
					sortable: true
				},
				{
					key: 'type_name',
					label: 'Data Type',
					sortable: true
				},
				{
					key: 'is_nullable',
					label: 'Nullable',
					sortable: true
				},
				{
					key: 'column_default_value',
					label: 'Default Val',
					sortable: true
				},
				{
					key: 'column_size',
					label: 'Column Size',
					sortable: true
				},
				{
					key: 'decimal_digits',
					label: 'Decimal Digits',
					sortable: true
				},
				{
					key: 'char_octet_length',
					label: 'Octet Length',
					thClass: 'd-none',
					tdClass: 'd-none',
					sortable: true
				},
				{
					key: 'is_foreignkey',
					label: 'Is Foreignkey',
					sortable: true
				},
				{
					key: 'referenced_primarykey_table',
					label: 'referenced_primarykey_table',
					thClass: 'd-none',
					tdClass: 'd-none',
					sortable: true
				},
				{
					key: 'referenced_primarykey',
					label: 'referenced_primarykey',
					thClass: 'd-none',
					tdClass: 'd-none',
					sortable: true
				},
				{
					key: 'remarks',
					label: 'Remarks',
					sortable: true
				}
			]
		};
	},
	methods: {
		getTableDef: function(table, dsn) {
			this.table = table;
			params = {
				method: 'table_design',
				returnformat: 'json',
				queryformat: 'struct',
				table: table,
				dsn: dsn,
				sort_by: this.sortBy,
				sort_dir: this.sortDesc ? 'DESC' : 'ASC'
			};
			var queryString = Object.keys(params).map((key) => key + '=' + params[key]).join('&');
			axios.get('/cfcs/dbtool.cfc?' + queryString).then((r) => {
				this.items = r.data;
			});
		},
		printTableDef: function() {
			PrintElements.print([ document.getElementById('table-def-container') ]);
		}
	},
	computed: {
		rows() {
			return this.items.length;
		},
		sortingBy() {
			let obj = this.fields.find((o) => o.key === this.sortBy);
			return obj.label;
		}
	},
	created: function(table) {
		// this.getTableDef(table);
	},
	mounted: function() {
		this.$root.$on('tableDef', (table) => {
			this.table = table;
			this.getTableDef(table);
		});
	}
});
