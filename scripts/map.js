/**
 * Created by Akshay on 2/11/2017.
 */
var geocoder;
var map;
var markers = Array();
var infos = Array();
function initialize() {
// prepare Geocoder
    geocoder = new google.maps.Geocoder();
// set initial position (Boston)
    var myLatlng = new google.maps.LatLng(42.3601,-71.0589);
    var myOptions = { // default map options
        zoom: 14,
        center: myLatlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById('map'), myOptions);
    var infoWindow = new google.maps.InfoWindow({map: map});

    // Try HTML5 geolocation.
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            var pos = {
                lat: position.coords.latitude,
                lng: position.coords.longitude
            };
            document.getElementById('lat').value = pos.lat;
            document.getElementById('lng').value = pos.lng;

            infoWindow.setPosition(pos);
            infoWindow.setContent('Location found.');
            map.setCenter(pos);
        }, function() {
            handleLocationError(true, infoWindow, map.getCenter());
        });
    } else {
        // Browser doesn't support Geolocation
        handleLocationError(false, infoWindow, map.getCenter());
    }
}

function handleLocationError(browserHasGeolocation, infoWindow, pos) {
    infoWindow.setPosition(pos);
    infoWindow.setContent(browserHasGeolocation ?
        'Error: The Geolocation service failed.' :
        'Error: Your browser doesn\'t support geolocation.');
}


// clear overlays function
function clearOverlays() {
    if (markers) {
        for (i in markers) {
            markers[i].setMap(null);
        }
        markers = [];
        infos = [];
    }
}
// clear infos function
function clearInfos() {
    if (infos) {
        for (i in infos) {
            if (infos[i].getMap()) {
                infos[i].close();
            }
        }
    }
}


// find address function
function findAddress() {
    var address = document.getElementById("gmap_where").value;
// script uses our 'geocoder' in order to find location by address name
    geocoder.geocode( { 'address': address}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) { // and, if everything is ok
// we will center map
            var addrLocation = results[0].geometry.location;
            map.setCenter(addrLocation);
// store current coordinates into hidden variables
            document.getElementById('lat').value = results[0].geometry.location.lat();
            document.getElementById('lng').value = results[0].geometry.location.lng();
// and then - add new custom marker
            var addrMarker = new google.maps.Marker({
                position: addrLocation,
                map: map,
                title: results[0].formatted_address,
                icon: 'marker.png'
            });
        } else {
            alert('Geocode was not successful for the following reason: ' + status);
        }
    });
}
// find custom places function
function findPlaces() {
// prepare variables (filter)
    var type = document.getElementById('gmap_type').value;
    var radius = document.getElementById('gmap_radius').value;
    var keyword = document.getElementById('gmap_keyword').value;
    var lat = document.getElementById('lat').value;
    var lng = document.getElementById('lng').value;
    var cur_location = new google.maps.LatLng(lat, lng);
// prepare request to Places
    var request = {
        location: cur_location,
        radius: radius,
        types: [type]
    };
    if (keyword) {
        request.keyword = [keyword];
    }
// send request
    service = new google.maps.places.PlacesService(map);
    service.search(request, createMarkers);
}

function scraped_data_URL_builder() {
    var URL_REQ = "https://raw.githubusercontent.com/aksh4y/Eventor/master/data_source.json";
    $.ajax({
        type: "GET",
        url: URL_REQ,
        data: {limit: 3},
        dataType: "json",
        success: function(data) {
            // Do some awesome stuff.
        }
    });
}


function build_URL(lat, lng, radius, type, keyword) {

    var URL_REQ = "https://www.eventbriteapi.com/v3/events/search/?location.lattitude=" +
    lat + "&location.longitude=" + lng + "&categories=" + type + "&location.within=" + radius + "km"
        + "&q=" + keyword
        + "&token=DX43YVUK5EDWAE357ROL";

    var xhReq = new XMLHttpRequest();
    xhReq.open("GET", URL_REQ, false);
    xhReq.send(null);
    var cwData = JSON.parse(xhReq.responseText)

    $.each(cwData.events, function (i, events) {

        var option_cate = '<li class="item"><a href="#">' + events.name.text + '</a></li>';
        $('#product_list').append(option_cate);

    });
}
// create markers (from 'findPlaces' function)
function createMarkers(results, status) {
    if (status == google.maps.places.PlacesServiceStatus.OK) {
// if we have found something - clear map (overlays)
        clearOverlays();
// and create new markers by search result
        for (var i = 0; i < results.length; i++) {
            createMarker(results[i]);
        }
    } else if (status == google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
        alert('Sorry, no such event in your area!');
    }
}
// creare single marker function
function createMarker(obj) {
// prepare new Marker object
    var mark = new google.maps.Marker({
        position: obj.geometry.location,
        map: map,
        title: obj.name
    });
    markers.push(mark);
// prepare info window
    var infowindow = new google.maps.InfoWindow({
        content: '<img src="' + obj.icon + '" /><font style="color:#000;">' + obj.name +
        '<br />Rating: ' + obj.rating + '<br />Vicinity: ' + obj.vicinity + '</font>'
    });
// add event handler to current marker
    google.maps.event.addListener(mark, 'click', function() {
        clearInfos();
        infowindow.open(map,mark);
    });
    infos.push(infowindow);
}
// initialization
google.maps.event.addDomListener(window, 'load', initialize);
