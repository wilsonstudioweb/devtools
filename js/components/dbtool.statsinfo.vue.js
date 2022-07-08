Vue.component('db-statsinfo', {
	props: {},
	template: ` 
	<div id="table-list-container" class="row" style="font-size:14px">
        <div class="col-md-7">
            <div class="card" >
                <div class="card-body row">
                    <div class="col-md-12"><h3 class="card-title">{{ serverinfo.CURRENTDATABASE }}</h3></div>
                    <label class="col-md-3">Database System:</label> <div class="col-md-9">{{ serverinfo.SQLVERSIONBUILD }}   {{ serverinfo.SQLSERVICEPACK }} {{ serverinfo.SQLEDITION }}  {{ serverinfo.SQLPRODUCTVERSION }}</div>
                    <label class="col-md-3">Server Name:</label>  <div class="col-md-9">{{ serverinfo.SQLSERVERNAME }}</div>
                    <label class="col-md-3">Server Local Address:</label> <div class="col-md-9">{{ serverinfo.LOCAL_NET_ADDRESS }}</div>
                    <label class="col-md-3">Active Database:</label> <div class="col-md-9">{{ serverinfo.CURRENTDATABASE }}</div>
                    <label class="col-md-3">DB File Paths</label> <div class="col-md-9"> <div v-for="file in serverinfo.FILES">  {{ file.physical_name}} - {{ file.size * 8/1024 }} mb </div></div>
                </div>
            </div>
        </div>
        <div class="col-md-1"></div>
        <div class="col-md-4"><canvas id="myChart" style="max-width:300px; max-height:300px;"></canvas></div>
    </div>
    `,
	data: function() {
		return {
			chart_props: {
				labels: [],
				data: [],
                pjArray: [],
				backgroundColor: []
			},
            serverinfo: {
                CURRENTDATABASE: null,
                FILES: null, 
                FULL_VER: null,
                PRODUCTBUILD: null,
                PRODUCTMAJORVERSION: null,
                PRODUCTMINORVERSION: null,
                SQLEDITION: null,
                SQLPRODUCTVERSION: null,
                SQLSERVERNAME: null,
                SQLSERVICEPACK: null,
                SQLVERSIONBUILD: null
            }
		};
	},
	methods: {
		updateChart: function(data){

			// JS - Destroy exiting Chart Instance to reuse <canvas> element
			let chartStatus = Chart.getChart("myChart"); // <canvas> id
			if (chartStatus != undefined) {
			    chartStatus.destroy();
			}
			
			this.chart_props.labels = [], this.chart_props.data=[], this.chart_props.backgroundColor=[];

			for (let i = 0; i < data.length; i++) {
				this.chart_props.labels.push(data[i].TABLE_NAME); 
				this.chart_props.data.push(data[i].TOTAL_SPACE);
				this.chart_props.backgroundColor.push(this.getRandomRGB());
			}

		  myChart = new Chart(
			document.getElementById('myChart'), {
				type: 'doughnut',
				data: {
					labels: this.chart_props.labels,
					datasets: [{
						label: 'Used Drive Space (mb)',
						backgroundColor: this.chart_props.backgroundColor,
						// borderColor: 'rgb(255, 99, 132)',
						data: this.chart_props.data
					}]
				},
				options: {
					plugins: {
						title: {
							display: true,
							text: 'Drive Space by Table (mb)'
						},
						legend: {
							display: false,
							labels: {
								color: 'rgb(255, 99, 132)'
							}
						}
					}
				}
			});

		},
		getRandomRGB: function() {
			var num = Math.round(0xffffff * Math.random());
			var r = num >> 16;
			var g = num >> 8 & 255;
			var b = num & 255;
			return 'rgb(' + r + ', ' + g + ', ' + b + ')';
		},
        dbServerInfo: function(){
            axios.get('/cfcs/dbtool.cfc', {
                params: {
                    method: 'mssqlserverInfo',
                    returnformat: 'json',
                    queryformat: 'struct'
                }
			}).then((r) => {
                this.serverinfo = r.data;
			});
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
				this.items = r.data;
				this.pjArray = this.filterAlpha(r.data);
				this.updateChart(r.data);
			});
		},
        filterAlpha(results) {
			return results
				.map((item) => item.TABLE_NAME.substring(0, 1).toUpperCase())
				.filter((value, index, self) => self.indexOf(value) === index);
		}
	},
	computed: {

	},
	created: function() {
		this.getTables();
        this.dbServerInfo();
	},
	mounted: function() {
		this.$root.$on('refreshTables', (dsn) => {
			this.getTables(dsn);
            this.dbServerInfo();
		});
	}
});
