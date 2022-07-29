
// Vue.use(VSwitch);
// Vue.config.ignoredElements = ['iframe'];

Vue.component('snippet-builder', {
	require: null,
	template:`
		<div>

		<div class="container">
			<p>Use the below online editor to build reference code, entire projects, and/or isolating code to test features and animations.</p>
			<p>
			<div class="dropdown">
				<input type="text" placeholder="Frameworks">
				<div class="dropdown-content" style="">
					<div v-for="(row, key) in frameworks">
						<label data-toggle="collapse" :data-target="'#' + key.replace(/[^a-z0-9]/gi, '')" aria-expanded="false" aria-controls="collapseExample" style="display:inline-block;">
							<input type="checkbox" name="framework"> {{key}}
						</label>
						<span class="collapse" :id="key.replace(/[^a-z0-9]/gi, '')" style="padding-left:1em;">
							<label v-for="item in frameworks[key]" style="min-width:100px;"><input type="radio" :name="key.replace(/[^a-z0-9]/gi, '')" @click="toggleCDN(key.replace(/[^a-z0-9]/gi, ''),item)"> v{{item.version}}</label>
						</span>
					</div>
				</div>
			</div>
			</p>
		</div>


		<div id="codeplayer" class="codeplayer" style="padding-bottom:10px;">

			<header class="codeplayer__nav">
				<h1>Code Snippet</h1>
				<div class="btn-container">
					<button class="btn btn-success btn-sm" id="runButton" @click="run()">Run</button> or
					<code>Shift + Enter</code>
				</div>
			</header>
			<div class="grid-container">
				<div class="grid-item" id="HTMLContainer">
					<label for="" class="codeplayer__label">HTML</label>
					<textarea id="htmlCode" placeholder="HTML" v-model="source.html"  @keydown.tab="forbidBlur($event)" @keyup.tab="replaceBlur($event)"></textarea>
				</div>
				<div class="grid-item" id="CSSContainer">
					<label for="" class="codeplayer__label">CSS</label>
					<textarea id="cssCode" placeholder="CSS" v-model="source.css" @change="run()" @keydown.tab="forbidBlur($event)" @keyup.tab="replaceBlur($event)"></textarea>
				</div>
				<div class="grid-item" id="JSContainer">
					<label for="" class="codeplayer__label">JavaScript</label>
					<textarea id="jsCode" placeholder="JavaScript" v-model="source.js" @keydown.tab="forbidBlur($event)" @keyup.tab="replaceBlur($event)"></textarea>
				</div>
			</div>
			<div class="grid-item" id="ResultsContainer" style="margin:0 10px 10px 10px; min-height:55vh">
				<label for="" class="codeplayer__label">Results</label>
				<iframe class="codeplayer__results-frame" :srcdoc="iframedoc"></iframe>
			</div>
		</div>
		</div>
	`,
	data: function() {
		return {
			source:{
				frameworks: {}, 
				html:'', 
				css:'', 
				js:''
			},
			iframedoc: '',
			frameworks: {
				'animate.css': [ 
					{
						version: '4.1.1',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css' ]
					},
					{
						version: '4.1.0',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.0/animate.min.css' ]
					},
					{
						version: '4.0.0',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.0.0/animate.min.css' ]
					},
					{
						version: '3.7.2',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.2/animate.min.css' ]
					}
				],
				'uikit': [ 
					{
						version: '3.15.1',
						css: [ 'https://cdn.jsdelivr.net/npm/uikit@3.15.1/dist/css/uikit.min.css' ],
						js: [
							'https://cdn.jsdelivr.net/npm/uikit@3.15.1/dist/js/uikit.min.js',
							'https://cdn.jsdelivr.net/npm/uikit@3.15.1/dist/js/uikit-icons.min.js'
						]
					}
				],
				'Bootstrap': [ 
					{
						version: '5.1.3',
						css: [ 'https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css', ],
						js: [ 'https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js' ]
					},
					{
						version: '4.6.1',
						css: [ 'https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css' ],
						js: [ 'https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js' ]
					}
				],
				'Bootstrap Icons': [ 
					{
						version: '1.8.3',
						css: [ 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css' ]
					},
				],
				'Angular': [ 
					{
						version: '1.8.3',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.8.3/angular-csp.min.css', ],
						js: [ 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.8.3/angular.min.js' ]
					},
					{
						version: '1.8.2',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.8.2/angular-csp.min.css', ],
						js: [ 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.8.2/angular.min.js' ]
					},
					{
						version: '1.7.9',
						js: [ 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.7.9/angular.min.js' ]
					},
				],
				'Bulma': [ 
					{
						version: '0.9.4',
						css: [ 'https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.4/css/bulma.min.css' ]
					},
				],
				
				'jQuery': [ 
					{
						version: '3.6.0',
						js: [ 'https://code.jquery.com/jquery-3.6.0.min.js' ]
					},
					{
						version: '2.2.4',
						js: [ 'https://code.jquery.com/jquery-2.2.4.min.js' ]
					},
					{
						version: '1.12.4',
						js: [ 'https://code.jquery.com/jquery-1.12.4.min.js' ]
					}
				],
				'jQuery migrate': [ 
					{
						version: '3.4.0',
						js: [ 'https://code.jquery.com/jquery-migrate-3.4.0.min.js' ]
					}
				],
				'jQuery UI': [ 
					{
						version: '1.13.2',
						js: [ 'https://code.jquery.com/ui/1.13.2/jquery-ui.min.js' ]
					},
					{
						version: '1.12.1',
						js: [ 'https://code.jquery.com/ui/1.12.1/jquery-ui.min.js' ]
					}
				],
				'jQuery Mobile': [ 
					{
						version: '1.4.5',
						js: [ 'https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js' ]
					}
				]
			}
		};
	},
	methods: {
		toggleCDN: function(lib,row){
			this.source.frameworks[lib] = row;
			this.run();
			// console.log(this.source.frameworks);
		},
		run: function(props){
			this.iframedoc = this.injectCDNs() +  this.source.html + '<style>' + this.source.css +'</style>' + '<script>' + this.source.js + '</script>';
			document.getElementsByTagName('iframe')[0].contentWindow.location.reload();
		},
		injectCDNs: function(){
			jsCodeArr = [];
			for (const [framework, cdns] of Object.entries(this.source.frameworks)) {
				for (const [type, srcArray] of Object.entries(cdns)) {
					if(type == 'js') {
						srcArray.forEach(function (src, index) {
							jsCodeArr.push('<script src="' + src + '"></script>');
						});
					} else if(type == 'css'){
						srcArray.forEach(function (src, index) {
							jsCodeArr.push('<link rel="stylesheet" href="' + src + '" crossorigin="anonymous"></link>');
						});
					}		
				}
			}
			return jsCodeArr.toString().replace(',','');
		},
		forbidBlur(e){ e.preventDefault() },
		replaceBlur(e){ return e.target.value += "\t" }
	},
	created: function() {

	},
	mounted: function() {
		let self = this;
		window.addEventListener("keypress", function(event) {
			if (event.shiftKey===true && event.key === "Enter") {
			  self.run(); event.preventDefault();
			}
		});

	}
});
