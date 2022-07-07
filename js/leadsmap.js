var fenway = { lat: 42.345573, lng: -71.098326 }, sv;
let time = 0;

const svgIcon = L.divIcon({
    html: `<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 495.398 495.398" width="32px" height="32px"><g><g><g><path d="M487.083,225.514l-75.08-75.08V63.704c0-15.682-12.708-28.391-28.413-28.391c-15.669,0-28.377,12.709-28.377,28.391v29.941L299.31,37.74c-27.639-27.624-75.694-27.575-103.27,0.05L8.312,225.514c-11.082,11.104-11.082,29.071,0,40.158c11.087,11.101,29.089,11.101,40.172,0l187.71-187.729c6.115-6.083,16.893-6.083,22.976-0.018l187.742,187.747c5.567,5.551,12.825,8.312,20.081,8.312c7.271,0,14.541-2.764,20.091-8.312C498.17,254.586,498.17,236.619,487.083,225.514z"/><path d="M257.561,131.836c-5.454-5.451-14.285-5.451-19.723,0L72.712,296.913c-2.607,2.606-4.085,6.164-4.085,9.877v120.401c0,28.253,22.908,51.16,51.16,51.16h81.754v-126.61h92.299v126.61h81.755c28.251,0,51.159-22.907,51.159-51.159V306.79c0-3.713-1.465-7.271-4.085-9.877L257.561,131.836z"/></g></g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg>`,
    className: "svg-icon probate",
    iconSize: [40, 40],
    iconAnchor: [16, 0],
  });

$(document).on('input',':input[name=strSearch]',function(){
    clearTimeout(time);
    time = setTimeout(function() {
         if($('#strSearch').val().length >= 3) { suggestLoc($('#strSearch').val()); } else {  $('#ul_strSearch').hide(); }
    }, 350);
}).on('click','#ul_strSearch li',function(){
    $('#ul_strSearch').hide();
    $('#strSearch').val($(this).text());
    map.closePopup();
    latlon = $(this).data('coordinates').split(',');
    $('#right-pane').empty();
    $('<h3 />').html('Leads near ' + $(this).html() + ' <span class="badge rounded-pill bg-dark">0</span>' ).appendTo('#right-pane');
    switch ($(this).data('matchtype')) {
        case 'citystate': setzoom = 12;  break;
        case 'county': setzoom = 11; break;
        case 'state': setzoom = 7;  break;
        default: setzoom = currentViewport.currentzoom;
    }
    map.setView(latlon, setzoom);
    bounds = map.getBounds();
    var zoom = map.getZoom();
    getData(JSON.stringify(currentViewport.mapbounds));
}).on('click','.fa-location-arrow',function(){
    console.log(getLocation());
});

$(document).on('click','#btn-toggle-fullscreen',function(){
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
       document.querySelector("#fullscreen-container").requestFullscreen({ navigationUI: "show" }).then(function() {
        $('#btn-toggle-fullscreen i.fa').removeClass('fa-arrows-alt');
        $('#btn-toggle-fullscreen i.fa').addClass('fa-compress');
       }).catch(function(error) {
           
       });
   }

});

var currentViewport = {};    
currentViewport.currentzoom = 3;
currentViewport.mapcenter = L.latLng(39.5, -98.35);

var tiles = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: '<a href="https://www.alltheleads.com">AllTheLeads.com</a>'
}), latlng = currentViewport.mapcenter;

var map = L.map('map', { center: currentViewport.mapcenter, zoom: currentViewport.currentzoom, minzoom:12, layers: [tiles]});
var markers = L.markerClusterGroup({ chunkedLoading: true });
// console.log(markers);

for (var i = 0; i < addressPoints.length; i++) {
    var a = addressPoints[i];
    var title =  a[3] + '<br><a href="/admin/subscribers/detail.cfm?id=' + a[2] + '" target="_new">Details</a><br>';

    var marker = L.marker(L.latLng(a[0], a[1]), {  icon: svgIcon, title: title, id:a[2] });
    marker.bindPopup(title, {autoClose: true, autoPan: true});

    markers.addLayer(marker);
    markers.on("click", markerOnClick);
}

map.addLayer(markers);

/*
async function addGeoJson() {
    const response = await fetch("json/GEOJSON_USCOUNTIES.json");
    const data = await response.json();
    L.geoJson(data).addTo(map);
}
*/
// addGeoJson();


map.on('moveend', function() { 
    currentViewport = { mapbounds:map.getBounds(), mapcenter: map.getCenter(), currentzoom: map.getZoom() };
    if(currentViewport.currentzoom >= 8) { 
        getData(JSON.stringify(currentViewport.mapbounds)); $('#right-pane').show(); 
        $("#left-pane").addClass("sizable");
    } else {  
        $("#left-pane").removeClass("sizable");
        $('#right-pane').hide(); 
    }
    (currentViewport.currentzoom >=13)? markers.disableClustering() : markers.enableClustering() ;
});

map.on('zoomend', function() { 
    if( map.getZoom() <= 3) { map.setView(L.latLng(39.5, -98.35),3); $('#right-pane').show(); return false; } else {  $('#right-pane').hide(); }
    window.dispatchEvent(new Event('resize')); 
    currentViewport.currentzoom = map.getZoom();
});

$(document).on('click','.property, .card',function(){
    map.closePopup();
    propertyid = $(this).data('id');
    latlon = $(this).data('coordinates').split(',');
    map.setView(latlon, (currentViewport.currentzoom <= 17)?17:currentViewport.currentzoom);
    bounds = map.getBounds();
    var zoom = map.getZoom();
    markers.eachLayer(function(layer) {
        if(layer.options.id.toString() == propertyid.toString() ){
            layer.openPopup(); layer.openPopup(); return false;
        } else { 
           layer.closePopup(); 
        }
    });
});

$("#left-pane").resizable({

  handleSelector: ".splitter",
  resizeHeight: false,
  resize: function() {
    $("#right-pane").outerWidth($("#map-ui-container").innerWidth() - $("#left-pane").outerWidth());
    window.dispatchEvent(new Event('resize')); 
  }
});

function initMap() {
    var sv = new google.maps.StreetViewService();
    panorama = new google.maps.StreetViewPanorama(document.getElementById('pano'));
    sv.getPanorama({location: fenway, radius: 50}, processSVData);
}

function processSVData(data, status) {
  if (status === google.maps.StreetViewStatus.OK) {
	$('#pano').show();
	panorama.setPano(data.location.pano);
	panorama.setPov({ heading: 270, pitch: 0 });
	panorama.setVisible(true);
  } else {
	$('#pano').hide(); // console.error('Street View data not found for this location.');
  }
}


async function getLocation() {
    let lat = 0
    let long = 0
    if(navigator.geolocation) {
        await navigator.geolocation.getCurrentPosition( function(position) {
            console.log(position.coords.latitude + ',' + position.coords.longitude);
            map.setView([position.coords.latitude , position.coords.longitude], 12);
            lat = position.coords.latitude
            long = position.coords.longitude
      
            //console.log("LATLONG1: ", lat, long) //test..
        })
    }
  
    return [lat,long]
}

function suggestLoc(q){
    $('#ul_strSearch').empty();
    $.ajax({
        type: "GET",
        url: '/cfcs/leadsMap.cfc',
        data: {
            method: 'suggest',
            returnformat: 'json', 
            queryformat: 'struct', 
            q: q
        }, 
        success: function(result) {
            r = jQuery.parseJSON(result); 
            if(r.length > 0){
                $('#ul_strSearch').show();
                for (var i = 0; i < r.length; i++){
                    $('<li />').attr({ 'data-coordinates':r[i]['COORD'], 'data-matchtype':r[i]['MATCHTYPE'] }).html(r[i]['PLACE']).appendTo('#ul_strSearch');
                }
            } else {
                $('#ul_strSearch').hide();
            }
        }
    });
}

function markerOnClick(e) {
    var attributes = e.layer.properties;
    map.setView(e.layer._latlng, currentViewport.currentzoom);
}

function clientCoordinates(){
    navigator.geolocation.getCurrentPosition(function(position) {
        let lat = position.coords.latitude;
        let long = position.coords.longitude;
       
    });
     return lat.toFixed(2) + ',' + long.toFixed(2);
}

function getData(LatLngBounds){
    $.ajax({
        type: "GET",
        url: '/cfcs/leadsMap.cfc',
        data: {
            method: 'lookup',
            returnformat: 'json', 
            queryformat: 'struct', 
            LatLngBounds: LatLngBounds.toString().trim(),
            centerlat: currentViewport.mapcenter.lat,
            centerlon: currentViewport.mapcenter.lng 
        }, 
        success: function(result) {
            r = jQuery.parseJSON(result); 
            if(r.length > 0){
                $('#right-pane').empty();
                $('<h3 />').html('Leads near ' +  r[0]['PRCITY'] + ', ' + r[0]['PRSTATE'] + ' <span class="badge rounded-pill bg-dark">' + r.length + '</span>' ).appendTo('#right-pane');
                $('<div id="pano" style="width:100%; height:320px;"></div>').appendTo('#right-pane');
                leadsContainer = $('<div />').attr({ id:'leads' }).appendTo('#right-pane');
                for (var i = 0; i < r.length; i++){
                    $('<div />').attr({ class:'card', 'data-id':r[i]['ID'], lat: r[i]['LAT'], lon: r[i]['LON'],  'data-coordinates': r[i]['LAT'] + ',' + r[i]['LON'] }).html('<div class="card-header">' + r[i]['LEADTYPE'] + '</div>  <div class="card-body"><h5 class="card-title"><i class="fa fa-map-marker"></i>' + r[i]['FULLADDRESS'] + '</h5>    <p class="card-text">' + r[i]['COUNTY'] + ' County<br>PR Date: ' + r[i]['PROBATEDATE'] + '<span class="daysold badge rounded-pill badge-light">' + r[i]['DAYSOLD'] + ' days old</span></p>    <a href="#!" class="btn btn-primary btn-sm">Details</a> <a href="#!" class="btn btn-sm" style="border:1px solid #efefef"><i class="fa fa-bookmark"></i> Favorite</a>  </div>').appendTo('#leads');
                }
                $('#right-pane').scrollTop(0);

                fenway = { lat:parseFloat(r[0]['LAT']), lng:parseFloat(r[0]['LON']) };  initMap();
            }
        }
    });
}