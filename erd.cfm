<cfscript>

  list.relationiships = '';

    /* Function to prevent CF from UPPERCASING column names returned from the query being passed through to the SerializeJSON() function */
    function QueryToJSONStruct(query,columnlist){
        json = SerializeJSON(query,'struct').toString();
        for(col in listToArray(columnlist)) json = REReplaceNoCase(json,'"#UCASE(col)#":','"#col#":','all');
        return json;
    }
 
    sql = {
      mysql: " SELECT i.TABLE_NAME AS `from`,  k.REFERENCED_TABLE_NAME AS `to`, k.COLUMN_NAME AS 'text', k.REFERENCED_COLUMN_NAME AS toText, CONCAT(i.TABLE_NAME,'.',k.COLUMN_NAME,' = ',k.REFERENCED_TABLE_NAME,'.',k.REFERENCED_COLUMN_NAME) AS 'join'
        FROM information_schema.TABLE_CONSTRAINTS i 
        LEFT JOIN information_schema.KEY_COLUMN_USAGE k 
            ON i.CONSTRAINT_NAME = k.CONSTRAINT_NAME 
        WHERE i.TABLE_SCHEMA = 'db1091448_probateleads' AND i.CONSTRAINT_TYPE = 'FOREIGN KEY' 
        ORDER BY i.TABLE_NAME ",
      mssql: " SELECT fk.name 'FK Name', tp.name 'from', cp.name 'text',  tr.name 'to', cr.name 'toText', CONCAT(tp.name,'.',cp.name,' = ',tr.name,'.',cr.name) AS 'join'
        FROM sys.foreign_keys fk
        INNER JOIN  sys.tables tp ON fk.parent_object_id = tp.object_id
        INNER JOIN  sys.tables tr ON fk.referenced_object_id = tr.object_id
        INNER JOIN  sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
        INNER JOIN   sys.columns cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
        INNER JOIN   sys.columns cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
        ORDER BY  tp.name, cp.column_id "
    }

    
    q.linkData = queryExecute("SELECT fk.name 'FK Name', tp.name 'from', cp.name 'text',  tr.name 'to', cr.name 'toText', CONCAT(tp.name,'.',cp.name,' = ',tr.name,'.',cr.name) AS 'join'
    FROM sys.foreign_keys fk
    INNER JOIN  sys.tables tp ON fk.parent_object_id = tp.object_id
    INNER JOIN  sys.tables tr ON fk.referenced_object_id = tr.object_id
    INNER JOIN  sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
    INNER JOIN   sys.columns cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
    INNER JOIN   sys.columns cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
    ORDER BY  tp.name, cp.column_id", {});

      for(r in listToArray(list.relationiships)){
        r1 = trim(listFirst(r,'=')); r2 = trim(listLast(r,'='));
        QueryAddRow(q.linkData, { FROM:trim(listFirst(r1,'.')), JOIN:r, TEXT:trim(listLast(r1,'.')), TO:trim(listFirst(r2,'.')), TOTEXT:trim(listLast(r2,'.'))  });
      }
      q.addTables = queryExecute( "SELECT DISTINCT [from] AS TABLE_NAME FROM q.linkData UNION SELECT DISTINCT [to] AS TABLE_NAME FROM q.linkData", {}, { dbtype="query" } );
      q.addTables = queryExecute( "SELECT DISTINCT TABLE_NAME FROM q.addTables", {}, { dbtype="query" } );


      sql = {
        mysql: "SELECT DISTINCT TABLE_NAME 
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE  
        WHERE (REFERENCED_TABLE_NAME IS NOT NULL) OR (TABLE_NAME IN (#QuotedValueList(q.addTables.Table_NAME)#) )
        UNION 
        DISTINCT SELECT DISTINCT REFERENCED_TABLE_NAME AS TABLE_NAME 
        FROM INFORMATION_SCHEMA. KEY_COLUMN_USAGE  
        WHERE REFERENCED_TABLE_NAME IS NOT NULL",
        mssql: "SELECT t.name as TABLE_NAME FROM sys.tables t WHERE t.name != 'sysdiagrams'"
      }
    q.tables = queryExecute("SELECT t.name as TABLE_NAME FROM sys.tables t WHERE t.name != 'sysdiagrams'", {}, { datasource = session.datasourcename});
    
    nodeDataArray = [];
    session.dbService = (isDefined('session.datasourcename')? new dbinfo(datasource=session.datasourcename):new dbinfo() ); 
     for(r in q.tables){
        q.props = session.dbService.Columns(table=r.TABLE_NAME);
        items = [];
        for(p in q.props) arrayAppend(items, { name: p.COLUMN_NAME, iskey: (p.IS_PRIMARYKEY)? true:false, figure: (p.IS_PRIMARYKEY OR p.IS_FOREIGNKEY)? "Key":"Decision", color: (p.IS_PRIMARYKEY)?'rgba(0, 0, 128, .75)':(p.IS_FOREIGNKEY)?'rgba(175, 212, 254, 1)':'rgba(0,0,0,.1)' });
        arrayAppend(nodeDataArray, { key: r.TABLE_NAME, items: items });        
     }


    </cfscript>

  <nav aria-label="breadcrumb">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="/">Home</a></li>
        <li class="breadcrumb-item active" aria-current="page">Database ER Diagram</li>
    </ol>
  </nav>

<section class="page-header" style="margin-bottom:5px !important;">
    <div class="container">
          <h1>DATABASE ENTITY RELATIONSHIP DIAGRAM</h1>
    </div>
</section>

<div class="container">
    <br>
    <p>
    An Entity-relationship model (ER model) describes the structure of a database with the help of a diagram, which is known as Entity Relationship Diagram (ER Diagram). 
    An ER diagram shows the relationships among table sets. 
    </p>
    <p>The backend programatically retrieves <b>all defined relationships</b> from the current database information schema to auto-generate the below ERD. Any new relationships defined in the database will automatically appear here.</p>

  ER Diagram is best viewed <button id="btn-toggle-fullscreen" class="btn btn-success btn-sm"><i class="fa fa-expand"></i> Fullscreen</button><br><br>
 </div>


  

  <div id="myDiagramDiv" style="background-color: #efefef; border: solid 1px #efefef; width: 100%; height:100vh; min-height: 700px"></div>


<cfsavecontent variable="htmlhead">

  <script src="https://gojs.net/latest/release/go.js"></script>
  <script src="https://gojs.net/latest/extensions/Figures.js"></script>
  <script id="code">
      function init() {
        var $ = go.GraphObject.make;  // for conciseness in defining templates
  
        myDiagram = $(go.Diagram, "myDiagramDiv",  // must name or refer to the DIV HTML element
            {
              allowDelete: false,
              allowCopy: false,
              layout: $(go.ForceDirectedLayout),
              "undoManager.isEnabled": true
            });
  
        // the template for each attribute in a node's array of item data
        var itemTempl = $(go.Panel, "Horizontal",
            $(go.Shape,
              { desiredSize: new go.Size(15, 15), strokeJoin: "round", strokeWidth: 3, stroke: null, margin: 2 },
              new go.Binding("figure", "figure"),
              new go.Binding("fill", "color"),
              new go.Binding("stroke", "color")),
            $(go.TextBlock,
              {
                stroke: "#333333",
                font: "bold 14px sans-serif"
              },
              new go.Binding("text", "name"))
          );
  
        // define the Node template, representing an entity
        myDiagram.nodeTemplate = $(go.Node, "Auto",  // the whole node panel
            {
              selectionAdorned: true,
              resizable: true,
              layoutConditions: go.Part.LayoutStandard & ~go.Part.LayoutNodeSized,
              fromSpot: go.Spot.AllSides,
              toSpot: go.Spot.AllSides,
              isShadowed: true,
              shadowOffset: new go.Point(3, 3),
              shadowColor: "#C5C1AA"
            },
            new go.Binding("location", "location").makeTwoWay(),
            // whenever the PanelExpanderButton changes the visible property of the "LIST" panel,
            // clear out any desiredSize set by the ResizingTool.
            new go.Binding("desiredSize", "visible", function(v) { return new go.Size(NaN, NaN); }).ofObject("LIST"),
            // define the node's outer shape, which will surround the Table
            $(go.Shape, "RoundedRectangle",
              { fill: 'white', stroke: "#eeeeee", strokeWidth: 3 }),
            $(go.Panel, "Table", { margin: 8, stretch: go.GraphObject.Fill },
              $(go.RowColumnDefinition, { row: 0, sizing: go.RowColumnDefinition.None }),
              // the table header
              $(go.TextBlock, {
                  row: 0, alignment: go.Spot.Center,
                  margin: new go.Margin(0, 24, 0, 2),  // leave room for Button
                  font: "bold 16px sans-serif"
                },
                new go.Binding("text", "key")),
              // the collapse/expand button
              $("PanelExpanderButton", "LIST",  // the name of the element whose visibility this button toggles
                { row: 0, alignment: go.Spot.TopRight }),
              // the list of Panels, each showing an attribute
              $(go.Panel, "Vertical", {
                  name: "LIST",
                  row: 1,
                  padding: 3,
                  alignment: go.Spot.TopLeft,
                  defaultAlignment: go.Spot.Left,
                  stretch: go.GraphObject.Horizontal,
                  itemTemplate: itemTempl
                },
                new go.Binding("itemArray", "items"))
            )  // end Table Panel
          );  // end Node
  
        // define the Link template, representing a relationship
        myDiagram.linkTemplate = $(go.Link,  // the whole link panel
            {
              selectionAdorned: true,
              layerName: "Foreground",
              reshapable: true,
              routing: go.Link.AvoidsNodes,
              corner: 5,
              curve: go.Link.JumpOver
            },
            $(go.Shape,  // the link shape
              { stroke: "#303B45", strokeWidth: 2.5 }),
            $(go.TextBlock,  // the "from" label
              {
                textAlign: "center",
                font: "bold 14px sans-serif",
                stroke: "#1967B3",
                segmentIndex: 0,
                segmentOffset: new go.Point(NaN, NaN),
                segmentOrientation: go.Link.OrientUpright
              },
              new go.Binding("text", "text")),
            $(go.TextBlock,  // the "to" label
              {
                textAlign: "center",
                font: "bold 14px sans-serif",
                stroke: "#1967B3",
                segmentIndex: -1,
                segmentOffset: new go.Point(NaN, NaN),
                segmentOrientation: go.Link.OrientUpright
              },
              new go.Binding("text", "toText"))
          );
  
  
        // create the model for the E-R diagram
        var nodeDataArray = <cfoutput>#serializeJSON(nodeDataArray)#</cfoutput>;
        var linkDataArray = <cfoutput>#QueryToJSONStruct(q.linkData,ArrayToList(q.linkData.getMeta().getcolumnlabels()))#</cfoutput>;
        
           myDiagram.model = $(go.GraphLinksModel, {
            copiesArrays: true,
            copiesArrayObjects: true,
            nodeDataArray: nodeDataArray,
            linkDataArray: linkDataArray
          });
      }
      window.addEventListener('DOMContentLoaded', init);
     
     
     </script>

  </cfsavecontent>
  
  <cfhtmlhead  text = "#htmlhead#">

  <cfsavecontent variable="request.foot">

<script>

$(document).on('click','#btn-toggle-fullscreen',function(){
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
         document.querySelector("#myDiagramDiv").requestFullscreen({ navigationUI: "show" }).then(function() {
          $('#btn-toggle-fullscreen i.fa').removeClass('fa-arrows-alt');
          $('#btn-toggle-fullscreen i.fa').addClass('fa-compress');
         }).catch(function(error) {
             
         });
     }
    
    });

    </script>
  </cfsavecontent>

 
  