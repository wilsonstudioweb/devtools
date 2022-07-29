
Vue.use(VSwitch);

Vue.component('form-builder', {
	require: null,
	template:`
		<div class="row">
                <div class="col-md-3" id="leftcol">
                    <label><i calss="fa fa-table"></i> Database Tables</label>
                    <select class="select-table form-control" id="select-table"  @change="getTableDef(table_name)" v-model="table_name" multiple>
					<option v-for="item in tables" :value="item.TABLE_NAME">{{ item.TABLE_NAME }}  ({{item.RECORD_COUNT}})</option>
                    </select>
                    <label> Columns <!---({{ this.table_name[0] }}) ---></label>
                    <select class="form-control" id="table-def"  @dblclick="addField(column_name)" v-model="column_name" multiple>
                        <option v-for="r in table_columns"  v-bind:value="r.COLUMN_NAME"  v-bind:column_props="JSON.stringify(r)"> {{ r.COLUMN_NAME }}</option>
                    </select>
                </div>
                <div class="col-md-9">
					<div id="form_canvas">
						<draggable  v-model="form_canvas" ghost-class="ghost" :sort="true" @end="onEnd" class="row">
						
							<div v-for="(field, index) in formFields" class="form-group col-md-6 "  @dblclick="showEditForm(index)">
								<label v-if="field.label" :for="formFields[index].label.for" :class="formFields[index].label.class">{{ formFields[index].label.labelText }}</label>
								<input v-if="field.input" :type="field.input.type" :v-model="field.input.name" :id="field.input.id" :field="field" :value="field.input.value" :placeholder="field.input.placeholder" :minLength="field.input.minLength" :maxLength="field.input.maxLength" :pattern="field.input.pattern" :class="field.input.class" :readonly="field.input.readOnly" :required="field.input.required">
								<textarea v-if="field.textarea" :v-model="field.textarea.name" :id="field.textarea.id" :placeholder="field.textarea.placeholder" :class="field.textarea.class" :readonly="field.textarea.readOnly" :required="field.textarea.required"></textarea>
								
								<select v-if="field.select" :v-model="field.select.name" :id="field.select.id" :class="field.select.class" :readonly="field.select.readOnly" :required="field.select.required" @click="genSelectOptions(field.select)">
									<option v-for="option in field.select.options" :value="option.value">{{ option.text }}</option>
								</select>
							
							</div>

						</draggable>
					</div>
                </div>
				

				<div v-show="this.editorVisible" class="modal" tabindex="-1" role="dialog" style="z-index:99999;">
				<div class="modal-dialog modal-xl" role="document">
				  <div class="modal-content">
					<div class="modal-header">
					  <h5 class="modal-title">Edit Properties</h5>
					  <button type="button" class="btn btn-sm" data-dismiss="modal" aria-label="Close" @click="closeProp"><i class="fa fa-times"></i></button>
					</div>
					<div class="modal-body">
					  
						<div v-for="(obj, objkey, objindex) in formFields[editRow]">
						
							<h6 style="margin-top:.5em;">{{objkey.toUpperCase()}}</h6>
							<div class="row">
								<div v-for="(value, key, index) in obj"  v-if="key !== 'for'" class="form-group col-md-6 row">
									<label class="col-sm-4 col-form-label col-form-label-sm">{{ spaceCamelCase(key) }}</label>
									<div v-switch="key.toLowerCase()" class="col-sm-8">
										<select v-case="'type'" class="form-control form-control-sm" v-model="formFields[editRow][objkey][key]">
											<option>Choose</option>
										</select>
										<label class="switch" v-case="'readonly'">
											<input type="checkbox" v-model="formFields[editRow][objkey][key]">
											<span class="slider round"></span>
										</label>
										<label class="switch" v-case="'required'">
											<input type="checkbox" v-model="formFields[editRow][objkey][key]" @click="requiredLabel(formFields[editRow]['label'])">
											<span class="slider round"></span>
										</label>
										<input v-case="'minlength'" type="number" class="form-control form-control-sm" v-model="formFields[editRow][objkey][key]" >
										<input v-case="'maxlength'" type="number" class="form-control form-control-sm" v-model="formFields[editRow][objkey][key]" >
										<input v-default type="text" class="form-control form-control-sm" v-model="formFields[editRow][objkey][key]" >
									</div>
								</div>
							</div>
						</div>

					</div>
				  </div>
				</div>
			  </div>


            </div>
	`,
	data: function() {
		return {
			form_type:'vue', 
            form_canvas:[],
            form_items:[], 
			datasources: [],
			tables:[], 
            table_name:[],
			table_columns:[],
            column_name:[], 
            column_def:[], 
			dsn: 'leadsdb_new',
			tables: [],
			activeTable: null,
			table: null,
			totalRecords: 0,
            oldIndex: "",
            newIndex: "",
			editAttributes: { 
				text:	['alt', 'autocomplete', 'name', 'pattern', 'placeholder', 'step', 'defaultValue', 'value', 'validationMessage', 'title', 'id', 'class' ], 
				select: ['alt', 'autocomplete', 'name', 'pattern', 'placeholder', 'step', 'defaultValue', 'value', 'validationMessage', 'title', 'id', 'class' ],
				label: 	['alt', 'class' ]
		  	},
			formFields:[],
			editorVisible:false,
			editRow:null,
			editor:{
				input_types: ['button','checkbox','color','date','datetime-local','email','file','hidden','image','month','number','password','radio','range','reset','search','submit','tel','text','time','url','week']
			}
		};
	},
	methods: {
		labelProps: function(props){
			console.log(props);
		},
		requiredLabel: function(obj){
			if(obj.class !== null){
				classArray = obj.class.split(" "); index = classArray.indexOf("required");

				if(index > -1){
					classArray.splice(index, 1);
				} else {
					classArray.push("required");
				}
				obj.class = classArray.join(" ").trim();
			} else {
				obj.class = 'required';
			}
		},
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
				this.tables = r.data;
			});
		},
		closeProp(){
			this.editorVisible = false;
		},
		showEditForm(index){
			this.editorVisible = true;
			this.editRow = index;

			
			/*
			console.log(item.querySelector('input:first-of-type').attributes.name.value);
			field = item.querySelector('input:first-of-type').attributes;

			newInput = document.createElement('input');
			newInput.setAttribute('type', 'text').setAttribute('name', field.name).name(field.name);
			document.body.appendChild(inpt);

			for(let i = field.length - 1; i >= 0; i--) {
				console.log(field[i].name);
			}
*/

		},
		onChange(event) {
			//console.log(event.target.value);
		},
		getTableDef: function(table_name) {
			axios.get('cfcs/formbuilder.cfc?table=' + table_name + '&method=tabledef&returnformat=json&queryformat=struct').then((r) => {
				this.table_columns = r.data;
			});
		},
        spaceCamelCase(s) {
			s = s
				.replaceAll('name', 'Name')
				.replaceAll('_', ' ')
				.replace(/([a-z])([A-Z])/g, '$1 $2')
				.replaceAll(/&.*;/g, ' ').replace(/(^\w{1})|(\s+\w{1})/g, (letter) => letter.toUpperCase())
				.replaceAll(' Id', ' ID')
				.replaceAll(' Dt', ' Date');
			return s;
		},
		initHandlers:function(){
			labels = document.getElementById('form_canvas').getElementsByTagName('label');
			for (let label of labels) {
				label.addEventListener("dblclick", function() {
					console.log(this);
				});	
			}
		},
        addField: function(column_name){

			var prop = { for:null, value:null, class:null };

            axios.get('cfcs/formbuilder.cfc?table=' + this.table_name + '&column=' + column_name + '&method=columndef&returnformat=json&queryformat=struct').then((r) => {
				this.column_def = r.data[0];
				objStruct = {}
                // console.log(this.column_def);
                var div = document.createElement('div');
                div.className = 'form-group col-md-6 draggable';
				objStruct.label = this.genLabel(this.column_def);
				if(this.column_def.IS_FOREIGNKEY == 'YES') {
					objStruct.select = this.genSelect(this.column_def);
				} else if( ['varchar(max)','nvarchar(max)'].indexOf(this.column_def.TYPE_NAME.toString()) >= 0 ) {
					objStruct.textarea = this.genTextArea(this.column_def);
				} else {
                	objStruct.input = this.genInput(this.column_def);
				}
				this.formFields.push(objStruct);
				console.log(this.formFields);
				// this.initHandlers();
			});
        },
		genLabel: function(field) {
            return { 
				labelText: this.spaceCamelCase(field.COLUMN_NAME),
				for: field.COLUMN_NAME.toLowerCase(),
				class: (field.IS_PRIMARYKEY == 'YES')? 'primary-key': (field.IS_NULLABLE !== 'YES')? 'required' :  null
			};
		},
		genTextArea: function(field){
			return { 
					name: field.COLUMN_NAME.toLowerCase(),
					'v-model': field.COLUMN_NAME.toLowerCase(),
					id: field.COLUMN_NAME.toLowerCase(),
					placeholder: this.spaceCamelCase(field.COLUMN_NAME),
					minLength:null,
					maxLength: field.COLUMN_SIZE,
					pattern:null,
					class:'form-control',				
					readOnly:null,
					required: (field.IS_NULLABLE == 'YES')? false:true
				/*
					table:null,
					bindto:null
				*/

			}
		},
		genSelectOptions: function(field){
			params = {
				method: 'records',
				filters: field.bind.filters,
				returnformat: 'json',
				queryformat: 'struct',
				table: field.bind.table,
				currentPage: field.bind.currentPage,
				perPage: field.bind.perPage,
				sort_by: field.bind.sortBy,
				sort_dir: field.bind.sortDesc ? 'DESC' : 'ASC',
				spaceCamelCase: 0
			};
			var queryString = Object.keys(params).map((key) => key + '=' + params[key]).join('&');
			axios
			.post('/cfcs/dbtool.cfc?' + queryString, JSON.stringify(params),{
				headers: {
					'Content-Type': 'application/json;charset=UTF-8',
					'Access-Control-Allow-Origin': '*'
				}
			})
			.then((r) => {
				this.field.options = r.data;
				console.log(this.field.options);			
			});
		},
		genSelect: function(field){




			return {
				name: field.COLUMN_NAME.toLowerCase(),
				'v-model': field.COLUMN_NAME.toLowerCase(),
				id: field.COLUMN_NAME.toLowerCase(),
				class:'form-control',				
				readOnly: null,
				required: (field.IS_NULLABLE == 'YES')? false:true,
				bind: {
					table: field.REFERENCED_PRIMARYKEY_TABLE, 
					key: field.REFERENCED_PRIMARYKEY,
						filters: null,
						currentPage: 1,
						perPage: 100, 
						sortBy: null, 
						sortDesc: null
				},
				options:[]
			}

			var input = document.createElement('select');
			var option = document.createElement('option');
			option.text = 'Choose ' + this.spaceCamelCase(field.COLUMN_NAME).toLowerCase();
			input.add(option, -1);

			if(this.form_type == 'vue') { 
				input.setAttribute('v-model','form.' + field.COLUMN_NAME);
			} else {
				input.name = field.COLUMN_NAME;
			}
			input.id = field.COLUMN_NAME;
            input.required = (field.IS_NULLABLE == 'YES')? false:true;
			input.className = 'form-control';
			input.setAttribute('data-pkey', field.REFERENCED_PRIMARYKEY_TABLE + '.' + field.REFERENCED_PRIMARYKEY);
			return input;
		}, 
		genInput: function(field) {
			input = {
					type: null,
					name: field.COLUMN_NAME.toLowerCase(),
					'v-model': field.COLUMN_NAME.toLowerCase(), 
					id: field.COLUMN_NAME.toLowerCase(),
					value: null, 
					placeholder: this.spaceCamelCase(field.COLUMN_NAME),
					minLength:null,
					maxLength: field.COLUMN_SIZE,
					pattern:null,
					class:'form-control',				
					readOnly:null,
					required: (field.IS_NULLABLE == 'YES')? false:true,

					/*
					table:null,
					bindto:null
					*/
				}

			inst = this;
			switch (field.TYPE_NAME) {
				case 'BIT':
					input.type = 'select';
					// var input = document.createElement('select');
					break;
					case 'nvarchar(max)': case 'varchar(max)':
					input.type = 'textarea';
				default:
					input.type = 'input';
					// var input = document.createElement('input');
					break;
			}
			switch (field.COLUMN_NAME.toUpperCase()) {
                case String(field.COLUMN_NAME.match(/.*DATE.*/i)): 
                    input.type = 'date';
                    break;
				case 'PASSWORD':
				case 'PASS':
					input.type = 'password';
					break;
                case String(field.COLUMN_NAME.match(/.*PHONE.*/i)): 
				case 'PHONE':
				case 'PHONE2':
					input.type = 'tel';
					input.pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}';
					break;
                case String(field.COLUMN_NAME.match(/.*EMAIL.*/i)): 
				case 'EMAIL':
				case 'EMAIL2':
					input.type = 'email';
					input.pattern = '^(?![.-_])((?![-._][-._])[a-z0-9-._]){0,63}[a-z0-9]@(?![-])((?!--)[a-z0-9-]){0,63}[a-z0-9].(|((?![-])((?!--)[a-z0-9-]){0,63}[a-z0-9].))(|([a-z]{2,14}.))[a-z]{2,14}$';
					input.autocapitalize = 'off';
					input.spellcheck = false;
					input.autocorrect = 'off';
					input.spellcheck = 'off';
					break;
				default:
					switch (field.TYPE_NAME.toUpperCase()) {
						case 'INT IDENTITY':
							input.type = 'number';
							input.readOnly = true;
							break;
						case 'DATE': 
							input.type = 'date';
							break;
						case 'TIMESTAMP': case 'DATETIME': case 'DATETIME2':
							input.type = 'datetime-local';
							break;
						case 'INTEGER': case 'NUMERIC':
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
			input.id = field.COLUMN_NAME;
            input.maxLength = field.COLUMN_SIZE;
            input.required = (field.IS_NULLABLE == 'YES')? false:true;
			input.placeholder = this.spaceCamelCase(field.COLUMN_NAME);
			input.class = 'form-control';
			//input.setAttribute('v-on:click', "this.showEditForm(this)");
			// input.addEventListener('click', this.$root.showEditForm('wtf'));
            // input.value = '#this.' & field.COLUMN_NAME & '#';
            
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
			// console.log(prop);
			//return input;
		},
        onEnd(e) {
            this.oldIndex = e.oldIndex;
            this.newIndex = e.newIndex;
        },
	},
	computed: {
        myList: {
            get() {
                return this.$store.state.form_canvas
            },
            set(value) {
                this.$store.commit('updateList', value)
            }
        }
	},
	created: function() {
		// this.getItems();
		// this.getDSNs();
		// this.setDSN(this.dsn);
		this.getTables();
	},
	mounted: function() {
		this.$root.$on('setDataVars', (d) => {
			this.totalRecords = d.totalRecords;
			this.activeTable = d.activeTable;
		});
		this.$root.$on('refreshTables', (dsn) => {
			this.getTables(dsn);
		});
	}
});
