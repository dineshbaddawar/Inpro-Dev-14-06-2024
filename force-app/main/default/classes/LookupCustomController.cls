public without sharing class LookupCustomController {
    /**
* Returns JSON of list of ResultWrapper to Lex Components
* @objectName - Name of SObject
* @fld_API_Text - API name of field to display to user while searching
* @fld_API_Val - API name of field to be returned by Lookup COmponent
* @lim   - Total number of record to be returned
* @fld_API_Search - API name of field to be searched
* @searchText - text to be searched
* */
    @AuraEnabled(cacheable=true) 
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText ){
                                      
                                      searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                                      
                                      
                                      String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
                                          ' FROM '+objectName+
                                          ' WHERE '+fld_API_Search+' LIKE '+searchText+ 
                                          ' LIMIT '+lim;
                                      
                                      List<sObject> sobjList = Database.query(query);
                                      List<ResultWrapper> lstRet = new List<ResultWrapper>();
                                      
                                      for(SObject s : sobjList){
                                          ResultWrapper obj = new ResultWrapper();
                                          obj.objName = objectName;
                                          if(objectName == 'Account'){
                                               obj.text = String.valueOf(s.get('Name')) ;
                                          	 //  obj.detail = String.valueOf(s.get('AccountNumber')) ;
                                              obj.detail = (String.valueOf(s.get('Customer_Number__c')) == null ? '': String.valueOf(s.get('Customer_Number__c'))) ;
                                          }
                                           else if(objectName == 'Contact'){
                                               obj.text = String.valueOf(s.get('Name')) ;
                                               obj.text += ' - ' + (String.valueOf(s.get('Email')) == null ? '': String.valueOf(s.get('Email')));
                                               obj.detail = (String.valueOf(s.get('Account_Name__c')) == null ? '': String.valueOf(s.get('Account_Name__c')));
                                               obj.detail += ' - ' + (String.valueOf(s.getSObject('Account').get('Customer_number__c')) == null ? '': String.valueOf(s.getSObject('Account').get('Customer_number__c')));
                                             // obj.detail = =s.Account.Name;
                                             // Account.Name
                                          }
                                          else{
                                                obj.text = String.valueOf(s.get(fld_API_Text)) ;
                                          }
                                        
                                          obj.val = String.valueOf(s.get(fld_API_Val))  ;
                                          lstRet.add(obj);
                                      } 
                                      return JSON.serialize(lstRet) ;
                                  }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        public String detail{get;set;}
        
    }
}