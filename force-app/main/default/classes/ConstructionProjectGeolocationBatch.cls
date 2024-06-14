global without sharing class ConstructionProjectGeolocationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('Select Id from Construction_Project__c where Queue_Geolocation__c = true');
	}

	global void execute(Database.BatchableContext BC, List<Construction_Project__c> scope) {
		Set<Id> projectsToGeolocate = new Set<Id>();

		for(Construction_Project__c record : scope) {
			projectsToGeolocate.add(record.Id);
		}

		if(projectsToGeolocate.size()>0 && projectsToGeolocate.size()<=100) {
			GeoLocationUtilities.getLatLongConstructionProject(projectsToGeolocate);
		} else if (projectsToGeolocate.size() > 100) {
			System.debug('Batch size greater than 100, could not run additional geolocation callout. Reduce batch size to 100 or fewer and try again.');
		}
	}

	global void finish(Database.BatchableContext BC) {
		System.debug('finish batch geolocation updates');
	}
}