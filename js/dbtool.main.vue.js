var router = new VueRouter({
	mode: 'history',
	routes: []
});

const EventBus = new Vue();
new Vue({
	el: '#app',
	router: router, 
	require: null,
	data: function() {
		return {
			datasources: [],
			dsn: (typeof this.getCookie('DSN') != 'undefined')? this.getCookie('DSN') : null, 
			tables: [],
			activeTable: null,
			table: null,
			totalRecords: 0
		};
	},
	methods: {
		fullScreen: function(selector, event){
				console.log('executed');
			   var full_screen_element = document.fullscreenElement;
			   // If no element is in full-screen
			   if(full_screen_element !== null) {
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
				   document.querySelector(selector).requestFullscreen({ navigationUI: "show" }).then(function() {
					$('#btn-toggle-fullscreen i.fa').removeClass('fa-arrows-alt');
					$('#btn-toggle-fullscreen i.fa').addClass('fa-compress');
				   }).catch(function(error) {
					   
				   });
			   }
		},
		getCookie: function(name) {
			return (document.cookie.match('(?:^|;)\\s*'+name.trim()+'\\s*=\\s*([^;]*?)\\s*(?:;|$)')||[])[1];
		},
		getDSNs: function() {
			axios.get('/cfcs/dbtool.cfc?method=serverDSNs&returnformat=json&queryformat=struct').then((r) => {
				this.datasources = r.data;
			});
		},
		setDSN: function(selected) {
			axios.post('/cfcs/dbtool.cfc?method=setDSN&returnformat=json&queryformat=struct&dsn=' + this.dsn);
			this.$root.$emit('refreshTables', this.dsn);
			this.activeTable = null;
		}
	},
	computed: {
		bows() {}
	},
	created: function() {
		// this.getItems();
		this.getDSNs();
		this.setDSN(this.dsn);
	},
	mounted: function() {
		if(this.$route.query.table != undefined) { 
			this.activeTable = this.$route.query.table;
			this.$root.$emit('tableDef', this.activeTable);
			this.$root.$emit('tableRecords', this.activeTable);
			this.$root.$emit('genWebform', this.activeTable);
			this.$root.$emit('genCFML', this.activeTable);
		}

		this.$root.$on('tableChange', (newtable) => {
			this.activeTable = newtable;
		});
	}
});
