/*************************************************************
* Created by:   The Hunley Group
* Created on:   6/27/2019
* ===========================================================
* Test Class:   NONE (yet)
* ===========================================================
* Purpose:  A common set of utility methods that can be useful in unit tests
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 6/27/2019     THG - TyS        Created
*
************************************************************/
@isTest
public without sharing class HunleyTestUtils {


    /*
       Allows code to load the valid values in a specified dependant picklist  -- this is valuable in a UnitTest scenario
       where a given picklist valueset can change and you don't want to hardcode values


       Ex Usage:
        // where Product_Family__c is master picklist and Product_Sub_Family__c is dependent

        Schema.DescribeFieldResult fieldResult = Substitution_Line_Item__c.Product_Family__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String family = ple.get(0);  // simply grab first value in master picklist
        Map<Object, List<String>> result =
            getDependentPicklistValues(Substitution_Line_Item__c.Product_Sub_Family__c);
        String subfamily = result.get(family).get(0);  // get the first item in the list of dependent values

     */
    public static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken )  {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
                (   control.getType() == Schema.DisplayType.Boolean
                        ?   null
                        :   control.getPicklistValues()
                );

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                    String.valueOf
                            (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                            ).split( '' );
            //System.debug(base64chars);
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                        (   controlEntries == null
                                ?   (Object) (index == 1)
                                :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                        );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null || base64chars.size() <= bitIndex
                        ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                        ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                //system.debug(entry.getLabel() );
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
        }
        return dependentPicklistValues;
    }
}