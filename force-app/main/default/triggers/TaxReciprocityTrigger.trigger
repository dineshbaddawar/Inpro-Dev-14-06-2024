trigger TaxReciprocityTrigger on Tax_Reciprocity__c (before update) {
    for(Tax_Reciprocity__c tr :Trigger.new){
        String[] states = tr.Valid_States__c.split(';');
        String value = '';
        for(String s : states){
            value += s + ';';
        }
        value = value.substring(0,value.length()-1);
        tr.States_Where_Valid__c = value;
    }
}