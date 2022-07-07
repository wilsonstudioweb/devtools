Vue.component('form-builder', {
	props: {},
	template: ` 

        <b-container id="webform-container">{{ this.webform }}</b-container>

    `,
	data: function() {
		return {
			webform: null,
			table: null
		};
	},
	methods: {
		genWebform: function(table) {
			if(this.table != undefined){			
				axios
				.get('/cfcs/dbtool.cfc', {
					params: {
						method: 'webform',
						table: table
					}
				})
				.then((r) => {
					document.getElementById('webform-container').innerHTML = r.data.toString();
				});
			}
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
	mounted: function() {
		this.$root.$on('tableChange', (newtable) => {
			this.table=newtable;
		});
		this.$root.$on('genWebform', (table) => {
			this.genWebform(table);
		});

	}
});
