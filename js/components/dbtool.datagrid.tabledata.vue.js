Vue.component('tabledata-datagrid', {
	props: {},
	template: ` 
	<div id="table-data-container">

		<div class="row" style="margin-bottom:4px;">
			<div class="col-md-8" style="padding-left:0;"><h3 style="display:inline-block;"><i aria-hidden="true" class="fa fa-table fa2x"></i> {{this.table}} TABLE DATA</h3> <b-badge pill variant="secondary">{{ this.totalRecords }}</b-badge></div>
			<div class="col-md-4 text-right">
				<a v-bind:href="'/cfcs/dbtool.cfc?method=exporttblData&returnformat=json&queryformat=struct&dsn=leadsdb_new&table=' + table"  class="btn btn-sm light"><i class="fa fa-download  pull-right"></i> Export</a>
				<a href="#table-section" v-on:click="printTableDef" class="btn btn-sm btn-light"><i class="fa fa-print pull-right"></i> Print</a>
				<a href="##" class="btn btn-sm btn-light"  @click="fullScreen('#table-data-container')"><i class="fa-solid fa-maximize"></i></a>
			</div>
			<div class="col-4 pe-only-print" style="text-align:right; font-family:italic; font-size:12px;">Generated: {{this.datetimestamp}} </div>
		</div>

		<div class="card">
			<div class="card-header row">
					<div class="col-1" v-show="totalPages > 1"><button @click="prevPage()" class="btn btn-sm btn-light" v-show="currentPage !== 1 ? true:false "><i class="fa fa-chevron-left"></i></button></div>
					
					<div class="col-3 pe-no-print font-weight-light small">Displaying {{ this.currentPage }} of {{ this.totalPages }} pages</div>
					
					<div class="col-4 text-center font-weight-bold text-uppercase">{{this.table}}</div>
					
					<div class="col-3  font-weight-light small">Sorted by: <b>{{ this.sortBy }}</b> ({{ sortDesc ? 'DESC' : 'ASC' }})<br></div>
					
					
					<div class="col-5 pe-only-print" style="text-align:right; font-family:italic; font-size:12px;">Generated: {{this.datetimestamp}} </div>
					
					<div class="col-1 text-right" v-show="totalPages > 1"><button @click="nextPage()" class="btn btn-sm btn-light" v-show="currentPage !== totalPages ? true:false "><i class="fa fa-chevron-right "></i></button></div>
			</div>
			
			<div class="table-responsive">
				<table class="table table-bordered table-striped table-sm">
					<thead>
					<tr>
						<td align="center">#</td>
						<th v-for="field in fields" @click="sortCol(field.key);" :class="sortClass(field.key)" >{{ field.label }}</th>
					</tr>
					<tr>
						<td align="center"><i class="fa fa-filter"></i></td>
						<td v-for="field in fields"><input type="text" placeholder=""></td>
					</tr>
					</thead>
					<tbody style="max-height:80vh;">
					<tr v-for="(row, index) in items">
					<td>{{ (index+1) + (currentPage * perPage) - perPage }}</td>
						<td v-for="value in row"><div>{{ value }}</div></td>
					</tr>
					</tbody>
				</table>
			</div>

			<div class="row">
				<b-pagination
					v-model="currentPage"
					aria-controls="table-tabledata"
					hide-goto-end-buttons 			
					:total-rows="totalRecords"
					:per-page="perPage"
					limit="20"
					pills 
				>
				</b-pagination>
			</div>

        </div>


    </div>
    `,
	data: function() {
		return {
			isBusy: false,
			table: null,
			totalPages: null,
			totalRecords: 0,
			perPage: 100,
			currentPage: 1,
			sortOrder: null, 
			sortAsc: false,
			sortDesc: false,
			sortBy: null,
			filter: null,
			filterOn: [],
			items: [],
			fields: [],
			filters: null,
			datetimestamp: null,
			isLoading: true,
			fsElem:document.fullscreenElement
		};
	},
	methods: {
		fullScreen: function(elem){
		   this.fsElem = document.fullscreenElement;
		   // If no element is in full-screen
		   if(this.fsElem !== null) {
			   document.exitFullscreen().then(function() {
				   // element has exited fullscreen mode
				   $('#btn-toggle-fullscreen i.fa').removeClass('fa-compress');
				   $('#btn-toggle-fullscreen i.fa').addClass('fa-arrows-alt');
			   }).catch(function(error) {
				   // element could not exit fullscreen mode
				   // error message
				   console.log(error.message);
			   });
		   } else {
			   document.querySelector(elem).requestFullscreen({ navigationUI: "show" }).then(function() {
				$('#btn-toggle-fullscreen i.fa').removeClass('fa-arrows-alt');
				$('#btn-toggle-fullscreen i.fa').addClass('fa-compress');
			   }).catch(function(error) {
				   
			   });
		   }
		},
		sortClass(col){
			return (this.sortBy == col)? (this.sortDesc)? 'active desc' : 'active asc' : ''
		},
		sortCol(col){
			this.sortBy = col;
			this.sortOrder = (this.sortDesc)? 'desc':'asc';
			this.sortDesc = !this.sortDesc;
			this.sortAsc = !this.sortDesc;
			this.getRecords(this.table);
		},
		isActiveCol(col){
			return (this.sortBy == col)? true:false;
		},
		toggleBusy: function() {
			this.isBusy = !this.isBusy;
		},
		getRecords: function(table) {
			this.fields = [];
			// this.items = [];
			this.isBusy = true;
			this.table = table;
			params = {
				method: 'records',
				filters: this.filters,
				returnformat: 'json',
				queryformat: 'struct',
				table: this.table,
				currentPage: this.currentPage,
				perPage: this.perPage,
				sort_by: this.sortBy,
				sort_dir: this.sortDesc ? 'DESC' : 'ASC',
				spaceCamelCase: 0
			};
			var queryString = Object.keys(params).map((key) => key + '=' + params[key]).join('&');
			let axiosConfig = {
				headers: {
					'Content-Type': 'application/json;charset=UTF-8',
					'Access-Control-Allow-Origin': '*'
				}
			};
			axios
				.post('/cfcs/dbtool.cfc?' + queryString, JSON.stringify(params), axiosConfig)
				.then((r) => {
					// console.log(r.data);
					this.fields = r.data.fields;
					this.items = r.data.items;
					this.totalRecords = r.data.total_records;
					this.totalPages = r.data.total_pages;
					this.$root.$emit('setDataVars', { activeTable: table, totalRecords: this.totalRecords });
					this.isBusy = false;
					this.isLoading = false;

					var table = document.getElementById('table-tabledata');
					// table.deleteTHead();
					// var header = table.createTHead(-1);
					// var row = header.insertRow(0);
					/*
					this.fields.forEach((field) => {
						var th = document.createElement('th');
						var input = this.genInput(field);
						input.setAttribute('autocomplete', 'off');
						input.setAttribute('autocorrect', 'off');
						input.setAttribute('autocapitalize', 'none');
						input.setAttribute('spellcheck', 'none');
						input.onchange = this.inputChange;
						th.appendChild(input);
						row.appendChild(th);
					});
					*/
				})
				.then((r) => {});
		},
		inputChange: function(event) {
			if (event.target.type == 'select-one') {
				event.target.options[event.target.selectedIndex].setAttribute('selected', true);
			}
			var form = document.createElement('form');
			form.appendChild(event.target.parentElement.parentElement.cloneNode(true));
			var data = Object.fromEntries(new FormData(form).entries());
			jsonData = Object.entries(data).reduce(
				(a, [ k, v ]) => (v == null || v.trim() == '' ? a : ((a[k] = v), a)),
				{}
			);
			this.filters = JSON.stringify(jsonData);
			this.getRecords(this.table);
		},
		nextPage: function() {
			if (this.currentPage < this.totalPages) {
				this.currentPage = this.currentPage + 1;
				this.getRecords(this.table);
			}
		},
		prevPage: function() {
			if (this.currentPage != 1) {
				this.currentPage = this.currentPage - 1;
				this.getRecords(this.table);
			}
		},
		tableDef: function(table) {
			this.$root.$emit('tableDef', table);
		},
		printTableDef: function() {
			PrintElements.print([ document.getElementById('table-data-container') ]);
		},
		onFiltered(filteredItems) {
			// Trigger pagination to update the number of buttons/pages due to filtering
			this.totalRows = filteredItems.length;
			this.currentPage = 1;
		},
		localeDateTimeStamp() {
			return new Date().toLocaleString();
		},
		spaceCamelCase(s) {
			s = s
				.replaceAll('/_ind', '/_IND')
				.replaceAll('name', 'Name')
				.replaceAll('_', ' ')
				.replace(/([a-z])([A-Z])/g, '$1 $2');
			return s.replaceAll(/&.*;/g, ' ').replace(/(^\w{1})|(\s+\w{1})/g, (letter) => letter.toUpperCase());
		},
		genLabel: function(field) {
			var label = document.createElement('label');
			label.htmlFor = field.key;
			label.innerText = this.spaceCamelCase(field.label);
			return label.outerHTML;
		},
		genInput: function(field) {
			switch (field.data_type) {
				case 'BIT':
					var input = document.createElement('select');
					break;
				default:
					var input = document.createElement('input');
					break;
			}
			switch (field.key) {
				case 'PASSWORD':
				case 'PASS':
					input.type = 'password';
					break;
				case 'PHONE':
				case 'PHONE2':
					input.type = 'tel';
					input.pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
					break;
				case 'EMAIL':
				case 'EMAIL2':
					input.type = 'email';
					input.pattern =
						'^(?![.-_])((?![-._][-._])[a-z0-9-._]){0,63}[a-z0-9]@(?![-])((?!--)[a-z0-9-]){0,63}[a-z0-9].(|((?![-])((?!--)[a-z0-9-]){0,63}[a-z0-9].))(|([a-z]{2,14}.))[a-z]{2,14}$';
					input.autocapitalize = 'off';
					input.spellcheck = false;
					input.autocorrect = 'off';
					input.spellcheck = 'off';
					break;
				default:
					switch (field.data_type) {
						case 'DATE':
							input.type = 'date';
							break;
						case 'DATETIME':
						case 'TIMESTAMP':
							input.type = 'datetime-local';
							break;
						case 'INTEGER':
						case 'INT':
							input.type = 'number';
							break;
						case 'BIGINT':
							input.type = 'number';
							break;
						case 'BIT':
							var option = document.createElement('option');
							option.text = '';
							input.add(option, -1);

							var option = document.createElement('option');
							option.text = 'true';
							option.value = 1;
							input.add(option, -1);

							var option = document.createElement('option');
							option.text = 'false';
							option.value = 0;
							input.add(option, -1);
							break;
						case 'VARCHAR':
						case 'CHAR':
							input.type = 'text';
							break;
						default:
							input.type = 'text';
							break;
					}
			}
			input.name = field.key;
			input.id = field.key;
			input.placeholder = this.spaceCamelCase(field.label);
			input.className = 'form-control';
			/*
			input.setAttribute('data-toggle', 'popover');
			input.setAttribute('data-trigger', 'focus');
			input.setAttribute('data-container', 'body');
			input.setAttribute('data-placement', 'top');
			*/
			/*
			const config = {
				title: 'I am a title',
				content: 'This text will show up in the body of the PopOver',
				placement: 'auto', // can use any of Popover's placements(top, bottom, right, left etc)
				container: 'null', // can pass in the id of a container here, other wise just appends to body
				boundary: 'scrollParent',
				boundaryPadding: 5,
				delay: 0,
				offset: 0,
				animation: true,
				trigger: 'hover', // can be 'click', 'hover' or 'focus'
				html: false // if you want HTML in your content set to true.
			};

			const toolpop = new PopOver(input, config, this.$root);
*/
			// input.setAttribute('v-b-popover.hover.top', 'I am popover directive content!');
			// input.setAttribute('data-content', this.spaceCamelCase(field.label));
			return input;
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
		}
	},
	created: function() {
		this.datetimestamp = this.localeDateTimeStamp();
	},
	mounted: function() {
		this.$root.$on('tableRecords', (table) => {
			this.filters = null;
			this.sortOrder = null; 
			this.sortAsc = false;
			this.sortDesc = false;
			this.sortBy =null;
			this.getRecords(table);
			this.datetimestamp = this.localeDateTimeStamp();
		});
	}
});


	
		/*
		<b-table 
            id="table-tabledata"
            emptyText="There are no records to show"
            :items="items"
            :fields="fields"      		
            :sort-by.sync="sortBy"
            :sort-desc.sync="sortDesc"
            :busy.sync="this.isBusy" 
            :sort-compare-options="{ numeric: true, sensitivity: 'base' }"
            :filter="filter"
            :filter-included-fields="filterOn"
            @filtered="onFiltered"
            sort-icon-left small striped responsive bordered sticky-header="700px"
        >

      <template #table-busy>
        <div class="text-center text-dark my-2">
          <b-spinner class="align-middle"></b-spinner>
          <strong>Loading..</strong>
        </div>
      </template>

		</b-table>
		*/