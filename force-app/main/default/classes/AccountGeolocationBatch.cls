global without sharing class AccountGeolocationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('Select Id from Account where Queue_Geolocation__c = true');
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		Set<Id> accountsToGeolocate = new Set<Id>();

		for(Account record : scope) {
			accountsToGeolocate.add(record.Id);
		}

		if(accountsToGeolocate.size()>0 && accountsToGeolocate.size()<=100) {
			GeoLocationUtilities.getLatLongAccount(accountsToGeolocate);
		} else if (accountsToGeolocate.size() > 100) {
			System.debug('Batch size greater than 100, could not run additional geolocation callout. Reduce batch size to 100 or fewer and try again.');
		}
	}

	global void finish(Database.BatchableContext BC) {
		System.debug('finish batch geolocation updates');
	}
}