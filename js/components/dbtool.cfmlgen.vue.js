

Vue.component('gencfml-builder', {
	props: {},
	template: ` 
        <b-container id="gencfml-container" >
			<h5>CFQuery INSERT Statement</h5>
			<pre id="cfquery_insert" class="prettyprint" style="max-height:420px; overflow:auto; position:relative;"><div class="btn-bar" style="top:10px; right:10px; float:right; position:sticky;"><button class="btn btn-sm btn-dark btn-copy"  @click="copyToClipboard('#cfquery_insert code')"><i class="fa fa-copy"></i> Copy to clipboard</button> <button @click="fullScreen('#cfquery_insert')" class="btn btn-sm btn-dark"><i class="fa-solid fa-maximize"></i></button></div><code style="color:##efefef;" id="code">{{ sqlFormat(sourcecode.cfquery_insert) }}</code></pre>
			
			<h5>CFSCRIPT INSERT Statement</h5>
			<pre id="cfscript_insert" class="prettyprint" style="max-height:420px; overflow:auto; position:relative;"><div class="btn-bar" style="top:10px; right:10px; float:right; position:sticky;"><button class="btn btn-sm btn-dark btn-copy"  @click="copyToClipboard('#cfscript_insert code')"><i class="fa fa-copy"></i> Copy to clipboard</button> <button @click="fullScreen('#cfscript_insert')" class="btn btn-sm btn-dark"><i class="fa-solid fa-maximize"></i></button></div><code style="color:##efefef;" id="code">{{ sourcecode.cfscript_insert }}</code></pre>

			<h5>CFSCRIPT UPDATE Statement</h5>
			<pre id="cfscript_update" class="prettyprint" style="max-height:420px; overflow:auto; position:relative;"><div class="btn-bar" style="top:10px; right:10px; float:right; position:sticky;"><button class="btn btn-sm btn-dark btn-copy"  @click="copyToClipboard('#cfscript_update code')"><i class="fa fa-copy"></i> Copy to clipboard</button> <button @click="fullScreen('#cfscript_update')" class="btn btn-sm btn-dark"><i class="fa-solid fa-maximize"></i></button></div><code style="color:##efefef;" id="code">{{ sourcecode.cfscript_update }}</code></pre>

			<h5>CFSCRIPT Function Params</h5>
			<pre id="cfscript_funct" class="prettyprint" style="max-height:420px; overflow:auto; position:relative;"><div class="btn-bar" style="top:10px; right:10px; float:right; position:sticky;"><button class="btn btn-sm btn-dark btn-copy"  @click="copyToClipboard('#cfscript_funct code')"><i class="fa fa-copy"></i> Copy to clipboard</button> <button @click="fullScreen('#cfscript_funct')" class="btn btn-sm btn-dark"><i class="fa-solid fa-maximize"></i></button></div><code style="color:##efefef;" id="code">{{ sourcecode.cfscript_function }}</code></pre>

		</b-container>
    `,
	data: function() {
		return {
			sourcecode:{
				cfquery_insert: null,
				cfscript_function: null, 
				cfscript_insert: null, 
				cfscript_update: null
			},
			cfml: null,
			table: null,
			fsElem:document.fullscreenElement
		};
	},
	methods: {
		sqlFormat: function(code){
			return (code)? window.sqlFormatter.format(code) : '';

		}, 
		copyToClipboard: function(elem){
			var textArea = document.createElement("textarea");
			textArea.value = document.querySelector(elem).innerHTML;
			textArea.style.position = 'fixed';
			textArea.style.bottom = 0;
			textArea.style.right = 0;
			textArea.style.width = '2em';
			textArea.style.height = '2em';		  
			textArea.style.padding = 0;			
			textArea.style.border = 'none';
			textArea.style.outline = 'none';
			textArea.style.boxShadow = 'none';			
			textArea.style.background = 'transparent';
			textArea.style.opacity = 0;
			
			document.body.appendChild(textArea);
			textArea.focus();
			textArea.select();
			textArea.remove();
		  
			try {
			  var successful = document.execCommand('copy');
			  var msg = successful ? 'successful' : 'unsuccessful';
			  alert('Copying source code to clipboard was ' + msg);
			} catch (err) {
			  alert('Oops, unable to copy');
			}
		},
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
		genCFML: function(table) {
			axios
				.get('/cfcs/dbtool.cfc', {
					params: {
						method: 'codegen',
						returnformat: 'json',
						queryformat: 'struct',
						table: table
					}
				})
				.then((r) => {
					this.sourcecode = r.data;
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
	mounted: function() {


		this.$root.$on('genCFML', (table) => {
			this.genCFML(table);
		});
	}
});
