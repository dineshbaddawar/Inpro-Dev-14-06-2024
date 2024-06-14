/*************************************************************
* Created by:   The Hunley Group
* Created on:   7/20/2018
* ===========================================================
* Purpose:      This is the mock class for the callout in the GeolocationUtilities class.
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/20/2018     THG - PS        Created
* 8/8/2018 		THG - PS 		Updated with Google API structure
************************************************************/
@isTest
global class GeolocationUtilitiesCalloutMock implements HttpCalloutMock{

	global static final String testCity = 'Village of Clarkston';
	global static final String testCountry = 'United States';
	global static final String testState = 'Michigan';
	global static final String testStateAbr = 'MI';
	global static final String testStreet = '2 S Main St';
	global static final String testZip = '48346';
	global static final Decimal testLatitude = 42.735836500000000;
	global static final Decimal testLongitude = -83.418846300000000;
	global static final String  jsonResponse = '{ "results" : [ { "address_components" : [ { "long_name" : "2", "short_name" : "2", "types" : [ "street_number" ] }, { "long_name" : "South Main Street", "short_name" : "S Main St", "types" : [ "route" ] }, { "long_name" : "Clarkston", "short_name" : "Village of Clarkston", "types" : [ "locality", "political" ] }, { "long_name" : "Oakland County", "short_name" : "Oakland County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Michigan", "short_name" : "MI", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] }, { "long_name" : "48346", "short_name" : "48346", "types" : [ "postal_code" ] }, { "long_name" : "1524", "short_name" : "1524", "types" : [ "postal_code_suffix" ] } ], "formatted_address" : "2 S Main St, Village of Clarkston, MI 48346, USA", "geometry" : { "location" : { "lat" : 42.7358365, "lng" : -83.4188463 }, "location_type" : "ROOFTOP", "viewport" : { "northeast" : { "lat" : 42.7371854802915, "lng" : -83.41749731970849 }, "southwest" : { "lat" : 42.7344875197085, "lng" : -83.42019528029151 } } }, "place_id" : "ChIJ92Fn_16XJIgRRPToz_-CdlQ", "plus_code" : { "compound_code" : "PHPJ+8F Clarkston, Michigan, United States", "global_code" : "86JRPHPJ+8F" }, "types" : [ "street_address" ] } ], "status" : "OK" }';

	global HttpResponse respond(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type','text/plain; charset=utf-8');
		res.setBody(jsonResponse);
		res.setStatusCode(200);
		return res;
	}
}