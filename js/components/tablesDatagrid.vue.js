Vue.component('tables-datagrid', {
	props: {
		items: []
	},
	template: ` 
	<div>
        <h2>Database tables</h2>	
		<div class="row">
			<div class="col-4">Current Page: {{ currentPage }}</div>
			<div class="col-8 mt-9">Sorting By: <b>{{ sortBy }}</b>, Sort Direction: <b>{{ sortDesc ? 'Descending' : 'Ascending' }}</b></div>
		</div>
   
		<b-table 
			id="table-tables"

			:items="items"
			:per-page="perPage"
			:current-page="currentPage"

			:fields="fields"      		
            :sort-by.sync="sortBy"
			:sort-desc.sync="sortDesc"
            
			responsive="sm"

			 :sort-compare-options="{ numeric: true, sensitivity: 'base' }"
			sort-icon-left
            small borderless
        >
		</b-table>
		
		<div class="row">
			<b-pagination
				v-model="currentPage"
				aria-controls="table-tables"
				hide-goto-end-buttons 			
				:total-rows="rows"
				:per-page="perPage"
				limit="20"
				pills 
			>
			</b-pagination>
		</div>
		
    </div>
    `,
	data: function() {
		return {
			datasources: [],
			dsn: 'boneheadwear',
			tables: [],
			table: null,
			perPage: 20,
			currentPage: 1,
			sortBy: 'TABLENAME',
			sortDesc: true,
            fields: [
                {
                    key: 'TABLENAME',
                    label: 'Table Name',
                    sortable: true
                },
                {
                    key: 'ROWCOUNTS',
                    label: 'Record Count',
                    sortable: true
                },
                {
                    key: 'SCHEMANAME',
                    label: 'Schema',
                    sortable: true
                },
                {
                    key: 'USEDSPACEKB',
                    label: 'Used Space',
                    sortable: true
                },
                {
                    key: 'UNUSEDSPACEKB',
                    label: 'Unused Space',
                    sortable: true
                },
                {
                    key: 'TOTALSPACEKB',
                    label: 'Total space',
                    sortable: true
                }
                ]
            },
            items: []

	
		};
	},
	methods: {
		getDSNs: function() {
			axios.get('/cfcs/dbtool.cfc?method=serverDSNs&returnformat=json&queryformat=struct').then((r) => {
				this.datasources = r.data;
			});
		},
		setDSN: function() {
			axios.post('/cfcs/dbtool.cfc?method=setDSN&returnformat=json&queryformat=struct&dsn=' + this.dsn);
		},
		getTables: function() {
			axios.get('/cfcs/dbtool.cfc?method=table_list&returnformat=json&queryformat=struct').then((r) => {
				this.items = r.data;
				console.log(this.items.length);
			});
		}
	},
	computed: {
		rows() {
			console.log(this.datagrids[0].tables[0].items.length);
			return this.datagrids[0].tables[0].items.length;
		}
	},
	created: function() {
		// this.getItems();
		this.getDSNs();

		this.getTables();
	}
});
