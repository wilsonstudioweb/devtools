Vue.component('tables-datagrid', {
	props: {},
	template: ` 
	<div id="table-list-container">


		<h3>Database Tables</h3>

        <p class="pe-no-print">Click on a table name below to view its data definition and properties used to form the table.</p>
		<div id="filters">
			<button@click="getTables(this.dsn)" class="btn btn-secondary btn-sm">All Tables</button>
	  		<button v-for="L in pjArray" @click="getTables(this.dsn,L)" class="btn btn-secondary btn-sm">{{ L }}</button>
		</div>
<div>

    <b-tabs pills>

      <b-tab title="List" active>
			<div id="table-list" class="wrapper">
				<div v-for="item in items" @click="tableDef(item.TABLE_NAME)">
					<a href="#table-section">{{ item.TABLE_NAME }} <b-badge pill variant="secondary">{{ item.RECORD_COUNT }}</b-badge></a>
				</div>
			</div>	  
	  </b-tab>

      <b-tab title="Details">    
	
		<div class="row">
			<div class="col-4">
				Sorted by: <b>{{ sortingBy }}</b> ({{ sortDesc ? 'Descending' : 'Ascending' }})<br>
			</div>
			<div class="col-4 pe-no-print">Current Page: {{ currentPage }}</div>
			<div class="col-4 pe-no-print">
                <a href="#table-list-container" v-on:click="printTableDef"><i class ="fa fa-print fa-2x pull-right"></i></a>
            </div>
		</div>

      <b-col lg="6" class="my-1 pe-no-print" >
        <b-form-group
          label="Filter"
          label-for="filter-input"
          label-cols-sm="3"
          label-align-sm="right"
          label-size="sm"
          class="mb-0"
        >
          <b-input-group size="sm">
            <b-form-input
              id="filter-input"
              v-model="filter"
              type="search"
              placeholder="Type to Search"
            ></b-form-input>

            <b-input-group-append>
              <b-button :disabled="!filter" @click="filter = ''">Clear</b-button>
            </b-input-group-append>
          </b-input-group>
        </b-form-group>
      </b-col>
   
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
			:filter="filter"
      		:filter-included-fields="filterOn"
			 @filtered="onFiltered"
			sort-icon-left
            small striped 
        >
            <template v-slot:cell(TABLE_NAME)="data">
				   <a href="#table-section" class="icon dt" @click="tableDef(data.value)" size="sm" >{{ data.value }}</a>
            </template>

            <template v-slot:cell(RECORD_COUNT)="data">
                <b-badge pill variant="primary">{{ data.value }}</b-badge>
            </template>

            <template v-slot:cell(USED_SPACE)="data">
                {{ data.value }} <span class="small">MB</span>
            </template>	
			
			<template v-slot:cell(UNUSED_SPACE)="data">
                {{ data.value }} <span class="small">MB</span>
            </template>

			<template v-slot:cell(TOTAL_SPACE)="data">
                {{ data.value }} <span class="small">MB</span>
            </template>	

            <template #cell(action)="data">
                <a href="https://www.google.com" size="sm" >Edit</a>
            </template>

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
	  </b-tab>
    </b-tabs>

</div>

		
    </div>
    `,
	data: function() {
		return {
			perPage: 500,
			currentPage: 1,
			sortBy: 'TABLE_NAME',
			sortDesc: false,
			filter: null,
			filterOn: [],
			items: [],
			pjArray: [],
			filter: null,
			fields: [
				{
					key: 'TABLE_NAME',
					label: 'Table Name',
					sortable: true
				},
				{
					key: 'RECORD_COUNT',
					label: 'Record Count',
					sortable: true
				},
				{
					key: 'TABLE_SCHEMA',
					label: 'Schema',
					thClass: 'd-none',
					tdClass: 'd-none',
					sortable: true
				},
				{
					key: 'USED_SPACE',
					label: 'Used Space',
					sortable: true
				},
				{
					key: 'UNUSED_SPACE',
					label: 'Unused Space',
					sortable: true
				},
				{
					key: 'TOTAL_SPACE',
					label: 'Total space',
					sortable: true
				},
				{
					key: 'action',
					label: 'Action',
					thClass: 'd-none',
					tdClass: 'd-none'
				}
			],
			chart_props: {
				labels: [],
				data: [],
				backgroundColor: []
			}
		};
	},
	methods: {
		getTables: function(dsn, filter) {
			params = {
				method: 'getTables',
				returnformat: 'json',
				queryformat: 'struct',
				dsn: dsn,
				filter: filter !== undefined ? filter : '',
				sort_by: this.sortBy,
				sort_dir: this.sortDesc ? 'DESC' : 'ASC'
			};
			var queryString = Object.keys(params).map((key) => key + '=' + params[key]).join('&');
			axios.get('/cfcs/dbtool.cfc?' + queryString).then((r) => {
				this.items = r.data;
			});


		},
		tableDef: function(newtable) {
			this.$root.$emit('tableChange', newtable);
			this.$root.$emit('tableDef', newtable);
			this.$root.$emit('tableRecords', newtable);
			this.$root.$emit('genWebform', newtable);
			this.$root.$emit('genCFML', newtable);

			//alert(tablename);
		},
		printTableDef: function() {
			PrintElements.print([ document.getElementById('table-list-container') ]);
		},
		onFiltered(filteredItems) {
			// Trigger pagination to update the number of buttons/pages due to filtering
			this.totalRows = filteredItems.length;
			this.currentPage = 1;
		},
		filterAlpha(results) {
			return results
				.map((item) => item.TABLE_NAME.substring(0, 1).toUpperCase())
				.filter((value, index, self) => self.indexOf(value) === index);
		}
	},
	computed: {
		sortOptions() {
			// Create an options list from our fields
			return this.fields.filter((f) => f.sortable).map((f) => {
				return { text: f.label, value: f.key };
			});
		},
		rows() {
			return this.items.length;
		},
		sortingBy() {
			let obj = this.fields.find((o) => o.key === this.sortBy);
			return obj.label;
		}
	},
	created: function() {
		this.getTables();
	},
	mounted: function() {
		this.$root.$on('refreshTables', (dsn) => {
			this.getTables(dsn);
		});
	}
});
