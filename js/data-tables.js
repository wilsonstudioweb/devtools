
        var url = window.location.pathname;
        var filename = url.substring(url.lastIndexOf('/')+1);
        var start_row = 1;
        var max_rows = 40;







function scrollalert(){
    selector = $('table.data-table');  
    var scrolltop=selector.attr('scrollTop');  
    var scrollheight=selector.attr('scrollHeight');  
    var windowheight=selector.attr('clientHeight');  
    var scrolloffset=20;  
    if(scrolltop>=(scrollheight-(windowheight+scrolloffset))){  
       
    }  
    setTimeout('scrollalert();', 1500);  
} 


function getDocHeight() {
    var D = document;
    return Math.max(
        D.body.scrollHeight, D.documentElement.scrollHeight,
        D.body.offsetHeight, D.documentElement.offsetHeight,
        D.body.clientHeight, D.documentElement.clientHeight
    );
}


var didScroll = false;

$(window).scroll(function() {
    didScroll = true;
});

setInterval(function() {
    if ( didScroll ) {
        didScroll = false;
        scrollpos = Math.round(Math.round($(window).scrollTop()) + window.innerHeight);
        if(scrollpos >= $(document).height() - ($(window).height()/8)) {
            if(!$.active && typeof total_records !== 'undefined' && start_row <= total_records){
                loadTableData('#table-records',$('select[name=table] option:selected').val());
            }
        }
    }
}, 100);

        $(document)/*.ajaxStart(function () {
				$('<div id="ajaxspinner"><div id="ajaxspinner-container"><i class="fa fa-circle-o-notch fa-spin" style="font-size:32px;"></i></div></div>').prependTo('body');
				$("#ajaxspinner").show();
		}).ajaxStop(function () {
				$("#ajaxspinner").remove();
		})*/.on('change','select[name=table]',function(){
            // document.location = '?table=' + $(this).val();
            start_row = 1;
            setTimeout(function(){ loadDataGrid('#table-records',$('select[name=table] option:selected').val()) }, 500);
            setTimeout(function(){ tableReady(); }, 1000);
             

           //  if (history.pushState) { history.pushState(null, ', filename + '?table=' + $('select[name=table] option:selected').val()); }
        }).on('click','ul.nav-tabs a[data-toggle]',function(){
        
            //selector = '#table-records';
            console.log($(this).attr('href'));

          selector = $($(this).attr('href')).find('div.data-table-wrapper');

        if($(selector).attr('id') == 'table-records'){
		start_row = 1;
		setTimeout(function(){ loadDataGrid(selector,$('select[name=table] option:selected').val()),1 }, 500);
        } else {
            $(selector).load('dbtool.cfc?method=html_table_design&table=' +  $('select[name=table] option:selected').val());
        }

          
            
        }).on('dblclick','.data-table tbody tr td',function(){
                    toggleEdit($(this));
       }).on('input','thead :input',function(){

            loadTableData('#table-records',$('select[name=table] option:selected').val());

       }).on('click','li[data-toggle]',function(){

           $('li[data-toggle]').removeClass('active');
           if($(this).hasClass('collapsed')){
               $(this).removeClass('active');
           } else {
		$(this).addClass('active');
           }
           
       }).ready(function(){
            //loadDataGrid('#data-table-container','project_users');
            setTimeout(function(){ loadDataGrid('#table-records',$('select[name=table] option:selected').val()) }, 500);
           // if (history.pushState) { history.pushState(null, ', filename + '?table=' + $('select[name=table] option:selected').val()); }
       

           $('select#table').selectpicker({ container:'#content-container'  }); 


        });


        function loadDataGrid(selector,table_name,startrow){
		appendDataTable(selector,table_name);
		appendTableHeader(selector,table_name);
		appendTableBody(selector,table_name);   
          	loadTableData(selector,table_name,startrow);
         }


         function tableProperties(selector,table_name){
            appendDataTable(selector,table_name);
            appendTableHeader(selector,table_name);
            appendTableBody(selector,table_name);
            loadTableData(selector,table_name);
         }
         
         


        function appendDataTable(selector,table_name){ 
                //$('#table-design').load('dbtool.cfc?method=html_table_design&table=' +  table_name);
                $(selector).empty();
                var datatbl = $('<table />').attr({  id:'', class:'data-table table display table-striped table-bordered compact', 'table':table_name }).appendTo(selector);
            }
           
            function appendTableHeader(selector,table_name){
                datatbl = $(selector).find('table.data-table');
                $('<thead />').appendTo(datatbl); 
                $('<tr / >').appendTo(datatbl.find('thead'));
                $('<th />').attr({ 'column':'', 'class':'' }).text('#').appendTo(datatbl.find('thead tr'));

                $.ajax({
                    url: 'dbtool.cfc?method=table_design&returnformat=json&table=' +  table_name, 
                    type : "GET",
                    success : function(result) {
                        json = jQuery.parseJSON(result); D = json;
                        // console.log(D);
                        for (i = 0; i < D.length; i++) { 
                        th = $('<th />').attr({ 'column':D[i].column_name, 'class':'' }).text(D[i].column_name).appendTo(datatbl.find('thead tr'));
                        if(D[i].is_primarykey == 'YES' || D[i].is_primarykey == 'true' || D[i].is_primarykey == true){
                            primary_key_column = D[i].column_name;
                            th.addClass('primary-key');
                        }
                        }
                        tr = $('<tr / >').appendTo(datatbl.find('thead'));
                        td = $('<td />').attr({ 'column':'', 'class':'' }).appendTo(tr);
                        input = $('<input>').attr({ 'name':'', 'type':'text', placeholder:'Filter' }).appendTo(td);
                        for (i = 0; i < D.length; i++) { 
                            td = $('<td />').attr({ 'column':D[i].column_name, 'class':'' }).appendTo(tr);
                            input = $('<input>').attr({ 'name':D[i].column_name, 'type':'text', placeholder:'Filter' }).appendTo(td);
                            if(D[i].is_primarykey == 'YES' || D[i].is_primarykey == 'true' || D[i].is_primarykey == true){
                                primary_key_column = D[i].column_name;
                                input.attr('read-only','true');
                            }
                        }
                        if(typeof primary_key_column  != 'undefined'){
                            $(selector).find('table.data-table').attr({ 'pkey':primary_key_column });
                        }
                    }
                });
                tableReady();
            }


jQuery.fn.any = function(filter){ 
    for (i=0 ; i<this.length ; i++) {
     if (filter.call(this[i])) return true;
  }
  return false;
};

            function appendTableBody(selector,table_name){
                datatbl = $(selector).find('table.data-table');
                $('<tbody>').appendTo(datatbl);
            }

            function loadTableData(selector, table_name){

                table_name = $(selector).find('table.data-table').attr('table');
                datatbl = $(selector).find('table.data-table');
                pkey = $(selector).find('table.data-table').attr('pkey');

                parentform = $(selector).find('form:first');
                formdata =  parentform.find('thead :input').serializeArray();
                formdata.push({ 'name':'table', 'value':table_name });
                $.ajax({
                    url: 'dbtool.cfc?method=records&returnformat=json&start_row=' + start_row + '&max_rows=' + max_rows, 
                    type : "POST",
                    data: formdata, 
                    success : function(result) {
                        json = jQuery.parseJSON(result);           
                        total_records = json.total_records; 
                        end_row = json.end_row;
                        start_row = json.start_row;
                        D = json.records.DATA;
                        // console.log(json);
                        for (i = 0; i < D.length; i++) {                             
                            tr = $('<tr class="animated fadeIn" />');
                            jQuery.each(json.records.DATA[i], function(i, value){
                                td = $('<td />').attr({ 'class':'', 'name':json.records.COLUMNS[i] }).text(value).appendTo(tr);
                            });
                            addRow(i,tr,datatbl.find('tbody'));
                        }
                        $('ul.nav-tabs li:first span.badge').html(total_records);
                        start_row =  json.next_row;
                        tableReady();
                    },
                    error: function(xhr, resp, text) {
                        console.log(xhr, resp, text);
                    } 
                }); 

            }




function tableReady(){
    $('table.data-table th').each(function(col) {

        $(this).hover(function() { $(this).addClass('focus'); },function() { $(this).removeClass('focus'); });

        $(this).click(function() {

            if ($(this).is('.asc')) {
                $(this).addClass('desc selected').removeClass('asc');
                sortOrder = -1;
            } else {
                $(this).addClass('asc selected').removeClass('desc');
                sortOrder = 1;
            }

            $(this).siblings().removeClass('asc selected');
            $(this).siblings().removeClass('desc selected');

            var arrData = $('table').find('tbody >tr:has(td)').get();

            arrData.sort(function(a, b) {
                var val1 = $(a).children('td').eq(col).text().toUpperCase();
                var val2 = $(b).children('td').eq(col).text().toUpperCase();
                if($.isNumeric(val1) && $.isNumeric(val2))
                    return sortOrder == 1 ? val1-val2 : val2-val1;
                else
                    return (val1 < val2) ? -sortOrder : (val1 > val2) ? sortOrder : 0;
            });

            $.each(arrData, function(index, row) {
                $('tbody').append(row);
            });
        });

    });
}


            function addRow(i, content, selector){ 
                setTimeout(function(){
                    content.appendTo(selector);
                }, i*50);
                            
            }

        function toggleEdit(thistd){
            parenttbody = thistd.parents('tbody:first');
            parenttr = thistd.parent('tr');
            selector = thistd.parents('table.data-table:first');
            pkey = selector.attr('pkey');
            table_name = selector.attr('table');

            if(parenttr.hasClass('editable')){
                $(selector).unwrap('form'); $('#dg-btnbar').remove();
                parenttr.find('td').each(function(){
                    $(this).html($(this).find(':input').val());
                });
                parenttr.removeClass('editable');
            } else {
                
                $(selector).wrap($('<form />').attr({ 'class':'inline-editable' }));
                parenttr.find('td').each(function(){
                    inputfield = $('<input>').attr({ 'type':'text','name':$(this).attr('name') , 'value':$(this).text() });
                    $(this).empty();
                    inputfield.appendTo($(this));
                    if($(this).attr('name').toUpperCase() == pkey.toUpperCase()){
                        inputfield.attr({ 'readonly':'true' });
                    }

                });
                $(this).find(':input').focus();
                parenttr.addClass('editable');

                btnbar = $('<div />').attr({ 'id':'dg-btnbar', 'class':'btnbar' });
                    $('<button/>').attr({ type:'cancel', name:'cancel', value:'cancel', 'class':'btn btn-default' }).html('<i class="fa fa-times"></i> Cancel').appendTo(btnbar);
                    $('<button/>').attr({ type:'reset', name:'reset', value:'reset', 'class':'btn btn-warning' }).html('Reset').appendTo(btnbar);
                    $('<button/>').attr({ type:'submit', name:'submit', value:'save', 'class':'btn btn-primary' }).html('<i class="fa fa-save"></i> Save').appendTo(btnbar);
                btnbar.appendTo($(selector));

                $(document).on('click','#dg-btnbar [type=cancel]',function(){
                    toggleEdit(thistd);
                }).on('click','#dg-btnbar [type=submit]',function(e){
                    e.preventDefault();
                    parentform = $(this).parents('form:first');
                    formdata =  parentform.find('tbody :input').serializeArray();
                    formdata.push({ 'name':'table', 'value':table_name });
                    //console.log(formdata);

                    $.ajax({
                        type:'post',
                        url:'dbTool.cfc?method=update',
                        data: formdata,
                        beforeSend:function(){
                            $('<div><span></span></div>')
                        },
                        complete:function(){
                        
                        },
                        success:function(result){
                            //console.log(result);
                            toggleEdit(thistd);
                        }
                    });

                });
                
            }
        }




        function hideEmptyCols(table) {
           table.find('th').each(function(idx, el) {
                /* check every td in the same column, see if they contain any text */
                var check = !! table.find('tr').find('td:eq(' + idx + ')').filter(function() {
                   return $.trim( $(this).text() ).length; 
                }).length;
                /* toggle the display of each th and td in this column, based on the check above */
               table.find('tr').find('td:eq(' + idx + '), th:eq(' + idx + ')').toggle( check );
            });
        }