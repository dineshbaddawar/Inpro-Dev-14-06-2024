/*************************************************************
* Created by:	The Hunley Group
* Created on:	8/8/2018
* ===========================================================
* Test Class: 	TBD
* ===========================================================
* Purpose:		This class provides a wrapper for the response from the Google Maps Geocoding API.
*
* ===========================================================
* Change History
* Date 			Author			Purpose
* ----------	-------------	-----------------------------
* 8/8/2018		THG - PS 		Created
*
************************************************************/
public class GoogleGeoWrapper {

	public class Address_components {
		public String long_name;
		public String short_name;
		public List<String> types;
	}

	public class Geometry {
		public Bounds bounds;
		public Location location;
		public String location_type;
		public Bounds viewport;
	}

	public List<Results> results;
	public String status;

	public class Results {
		public List<Address_components> address_components;
		public String formatted_address;
		public Geometry geometry;
		public String place_id;
		public List<String> postcode_localities;
		public List<String> types;
	}

	public class Viewport {
		public Location northeast;
		public Location southwest;
	}

	public class Location {
		public Double lat;
		public Double lng;
	}

	public class Bounds {
		public Location northeast;
		public Location southwest;
	}

	
	public static GoogleGeoWrapper parse(String json) {
		return (GoogleGeoWrapper) System.JSON.deserialize(json, GoogleGeoWrapper.class);
	}
}