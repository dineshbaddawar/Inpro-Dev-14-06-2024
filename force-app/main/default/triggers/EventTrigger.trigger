/*************************************************************
* Created by:   The Hunley Group
* Created on:   7/7/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:      This trigger fires on the Event object 
*               after update and after insert. 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/07/2020     THG - JP        Created
* 2/3/2022      EJL             Description Field Updates
************************************************************/
trigger EventTrigger on Event (after insert,after update, before insert) {
    if (trigger.isAfter) {
        if (trigger.isUpdate) {
            EventTriggerHandler handler = new EventTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterUpdate();
        }
    }
    if(trigger.isBefore)
    {
        if (trigger.isInsert) {
            for(Event e : Trigger.New) { 
                String descriptionAdditions = '\n\n';
                if(e.WhatId != null)
                {
                    String whatId = e.WhatId;
                    if(whatId.startsWith('001'))
                    {
                        List<Account> accountList = [SELECT Id, Name, AccountNumber, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Account  WHERE Id = :whatId];                    
                        if(accountList.size() > 0)
                        {
                            Account a = accountList[0];
                            descriptionAdditions += 'Account Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '\n';
                            if(a.Name != null)
                                descriptionAdditions += 'Account Name: ' + a.Name + '\n';
                            if(a.AccountNumber != null)
                                descriptionAdditions += 'Account Number: ' + a.AccountNumber + '\n';
                            if(a.Phone != null)
                                descriptionAdditions += 'Account Phone: ' + a.Phone + '\n';

                            descriptionAdditions += 'Account Address: ';
                            if(a.ShippingStreet != null)
                                descriptionAdditions += a.ShippingStreet + ' ';
                            if(a.ShippingCity != null)
                                descriptionAdditions += a.ShippingCity + ' ';
                            if(a.ShippingState != null)
                                descriptionAdditions += a.ShippingState + ' ';
                            if(a.ShippingPostalCode != null)
                                descriptionAdditions += a.ShippingPostalCode + ' ';
                            if(a.ShippingCountry != null)
                                descriptionAdditions += a.ShippingCountry;
                            descriptionAdditions += '\n';

                            descriptionAdditions += 'Account Address Link (Google Maps): https://www.google.com/maps?q=';
                            if(a.ShippingStreet != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingStreet + ' ', 'UTF-8');
                            if(a.ShippingCity != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingCity + ' ', 'UTF-8');
                            if(a.ShippingState != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingState + ' ', 'UTF-8');
                            if(a.ShippingPostalCode != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingPostalCode + ' ', 'UTF-8');
                            if(a.ShippingCountry != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingCountry, 'UTF-8');
                            descriptionAdditions += '\n';
                            descriptionAdditions += 'Account Address Link (Apple Maps): https://maps.apple.com/place?address=';
                            if(a.ShippingStreet != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingStreet + ' ', 'UTF-8');
                            if(a.ShippingCity != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingCity + ' ', 'UTF-8');
                            if(a.ShippingState != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingState + ' ', 'UTF-8');
                            if(a.ShippingPostalCode != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingPostalCode + ' ', 'UTF-8');
                            if(a.ShippingCountry != null)
                                descriptionAdditions += EncodingUtil.urlEncode(a.ShippingCountry, 'UTF-8');
                            descriptionAdditions += '\n';
                        }
                    }
                }
                if(e.WhoId != null)
                {
                    String whoId = e.WhoId;
                    if(whoId.startsWith('003'))
                    {
                        List<Contact> contactList = [SELECT Name, MobilePhone, Phone  FROM Contact  WHERE Id = :whoId];                    
                        if(contactList.size() > 0)
                        {
                            Contact c = contactList[0];
                            if(c.Name != null)
                                descriptionAdditions += 'Contact Name: ' + c.Name + '\n';
                            if(c.MobilePhone != null)
                                descriptionAdditions += 'Mobile Phone: ' + c.MobilePhone + '\n';
                            if(c.Phone != null)
                                descriptionAdditions += 'Phone: ' + c.Phone + '\n';
                        }
                    }
                }
                if(descriptionAdditions != '\n')
                {
                    if(e.Description != null)
                        e.Description = e.Description + descriptionAdditions;
                    else {
                        e.Description = descriptionAdditions;
                    }
                }                   
            }
        }
    }
}