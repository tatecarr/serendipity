// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require jquery.purr
//= require best_in_place
//= require_tree .


var places_result_set = [];


function get_nearby_places(latitude, longitude, radius_meters, keyword)
{
	var places_url = 'google_gnp.json';

	var location = latitude+','+longitude;

	url_params = {
		'location' : location,
		'radius' : radius_meters,
		'sensor' : false,
		'keyword' : keyword
	}

	$.getJSON(places_url, url_params, function(data) {
		console.debug(data);
		drop_places_on_map(data);
	});

	return true;
}

// @param - data - result set from places query
function drop_places_on_map(data)
{
	places_string = '';

	$.each(data['results'], function(index,value) {

		places_string += value['name'] 

		$.each(value['types'], function(t_ind, t_val) {

			places_string += "\n=> " + t_val;

		});

		places_string += "\n\n";


	});
	alert(places_string);
	// iterate over and drop on map
	// alert(JSON.stringify(data));
}


$(function(){ $(document).foundation(); });
