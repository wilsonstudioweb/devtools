Vue.component('sql-console', {
	props: {},
	template: ` 
    <div>
        <b-container>
            <div class="card">
                <div class="card-header">SQL Command Console</div>
                <div class="card-body">
                    <form id="form-sqlcmd">
                        <div class="form-group">
                            <textarea class="form-control" v-model="cmd" id="cmd" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <button type="reset" class="btn btn-default">Reset</button>
                            <button type="button" value="" @click="sendSQL" class="btn btn-success" data-toggle="modal" data-target="#confirmcmd">Execute</button>
                        </div>
                    </form>
					<div v-if="this.sqlError" class="alert alert-danger" role="alert">
						{{this.sqlErrorMessage}}
					</div>
                </div>
            </div>
        </b-container>

        <br><br>


        <b-container fluid>
            <div id="result">
                <b-table 
                    id="table-sqlresult"
                    :items="items"
                    :fields="fields"   
                    :sort-by.sync="sortBy"
                    :sort-desc.sync="sortDesc"   		
                    sort-icon-left small striped responsive bordered
                >
                </b-table>
            </div>
        </b-container>
    </div>
    `,
	data: function() {
		return {
			cmd: 'SELECT * FROM website_servers',
			sqlresult: null,
			fields: [],
			items: [],
			isBusy: false,
			totalRecords: 0,
			perPage: 500,
			currentPage: 1,
			sortDesc: false,
			sortBy: null,
			sqlError: false,
			sqlErrorMessage: false
		};
	},
	methods: {
		sendSQL: function(dsn) {
			this.sqlError = false;
			params = {
				method: 'sqlcmd',
				returnformat: 'json',
				queryformat: 'struct'
			};
			var queryString = Object.keys(params).map((key) => key + '=' + params[key]).join('&');
			axios.post('/cfcs/dbtool.cfc?' + queryString, { sql: this.cmd }).then((r) => {
				if(r.data.success) {
				this.items = r.data.items;
				this.fields = r.data.fields;
				} else {
					this.sqlError = true;
					this.sqlErrorMessage = r.data.message;
					console.log(r.data.message);
				}
			});
		}
	},
	computed: {
		sortOptions() {
			// Create an options list from our fields
			return this.fields.filter((f) => f.sortable).map((f) => {
				//return { text: f.label, value: f.key };
			});
		},
		rows() {
			return this.items.length;
		},
		sortingBy() {
			let obj = this.fields.find((o) => o.key === this.sortBy);
			//return obj.label;
		}
	},
	created: function() {},
	mounted: function() {}
});
