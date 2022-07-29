
<cfset request.title="Code Snippet">
<cfsavecontent variable="request.head">

    <style>
    h1, .btn-container { display:inline-block;  }
    h1 {  position:relative; top:4px; left:14px;  color:#fff; font-size:1.75em;}
    .btn-container { position:absolute; top:14px; right:14px;  }

#codeplayer {
	font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif; 
	font-weight: 300;
	background-color: #252525;
    position:relative;
    min-height:86vh
}    

.grid-container {
    display: grid;
    grid-template-columns: auto auto auto;
    padding: 10px;
}
.grid-item {
    background: rgba(0, 0, 0, 0.8);
    background-color: rgba(0, 0, 0, 0.8);
  border:0;
  padding: 0px;
  font-size: 1em;
  text-align: center;
  position:relative;
  min-height:25vh;
 
}
.grid-item label { 	
    position: absolute;
    z-index:2;
	right: 10px;
	bottom: 10px;
	border-radius: 5px;
	background-color: rgba(255, 255, 255, .4);
	color: #252525;
	padding: 5px; 
} 
#ResultsContainer label{
    color: #252525;
    background-color: rgba(0, 0, 0, .4);
}

.grid-item textarea {
    outline:0;
	width: 100%;
	height:100%; 
    position:relative;
    top:0; bottom:0; left:0; right:0;
	border: none;
	
	font-family: Consolas, "Andale Mono", "Lucida Console", "Lucida Sans Typewriter", Monaco, "Courier New", monospace;
	font-size: 90%;
	box-sizing: border-box;
	padding: 5px;
	color: #00EBFF;
	background-color: #111;
	overflow-wrap: unset;
}
.grid-item:nth-child(1) textarea , .grid-item:nth-child(2) textarea { border-right: 1px solid grey; }

iframe {
	height: 100%;
	position: absolute;
	width: 100%;
	border: none;
    background:#fff;
    height:100%; min-height:100%;
    left:0; right:0; top:0; bottom:0; 
}

.dropdown {
    min-width:400px;
  position: relative;
  display: inline-block;
}
.dropdown > input { min-width:100%; }
.dropdown:hover .dropdown-content {
  display: block;
}
.dropdown-content { display:none; position:absolute; background:#eee;  width:100%; min-width: 150%; box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2); padding: 12px 16px; z-index: 3; }

    </style>

</cfsavecontent>

<nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="/">Home</a></li>
        <li class="breadcrumb-item active" aria-current="page">Snippet Code Editor</li>
    </ol>
</nav>


<snippet-builder></snippet-builder>


<cfsavecontent variable="request.foot">
    <script src="codesnippet.js?<cfoutput>#CreateUUID()#</cfoutput>" type="text/javascript"></script>
</cfsavecontent>
