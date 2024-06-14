@isTest
public with sharing class OrderRequestRouteHelperTest {
    // @isTest static void testOrderRequestRouting() {
	// 	string userId = '';
    //     string groupIdFinance = '';
    //     string groupIdCCS = '';
        
    //     string oQueryCCS =  'SELECT Id FROM Group WHERE Name = \'Customer Care Queue\'';
    //     List<Group> cssGroup = Database.query(oQueryCCS);
    //     if(cssGroup.size() > 0)
    //         groupIdCCS = cssGroup[0].Id;
    //     else {
    //         Group g = new Group();
    //         g.Name = 'Customer Care Queue';
    //         insert g;
    //         groupIdCCS = g.Id;

    //         QueueSobject qobj = new QueueSobject();
    //         qobj.QueueId = g.Id;
    //         qobj.SobjectType = 'Order_Request__c';
    //         insert qobj;
    //     }

    //     string oQueryFinance =  'SELECT Id FROM Group WHERE Name = \'Finance Queue\'';
    //     List<Group> financeGroup = Database.query(oQueryFinance);
    //     if(financeGroup.size() > 0)
    //         groupIdFinance = financeGroup[0].Id;
    //     else {
    //         Group g2 = new Group();
    //         g2.Name = 'Finance Queue';
    //         insert g2;
    //         groupIdFinance = g2.Id;

    //         QueueSobject qobj2 = new QueueSobject();
    //         qobj2.QueueId = g2.Id;
    //         qobj2.SobjectType = 'Order_Request__c';
    //         insert qobj2;
    //     }

    //     string oQuery =  'SELECT Id FROM User WHERE FirstName = \'Everett Leptich\'';
    //     List<User> users = Database.query(oQuery);
    //     if(users.size() > 0)
    //         userId = users[0].Id;
    //     else {
    //         User u = new User();
    //         u.IsActive = true;
    //         u.Username = 'elep@kshdfksfh.com';
    //         u.LastName = 'Lep';
    //         u.Email = 'elep@kshdfksfh.com';
    //         u.Alias = 'ELEP';
    //         u.TimeZoneSidKey = 'America/Chicago';
    //         u.LocaleSidKey = 'en_US';
    //         u.EmailEncodingKey = 'UTF-8';
    //         u.ProfileId = '00e4V000002KjxAQAS';
    //         u.LanguageLocaleKey = 'en_US';
    //         insert u;
    //         userId = u.Id;
    //     }

    //     Order_Request__c orderRequest = new Order_Request__c();
    //     //orderRequest.OwnerId = g.Id;
    //     orderRequest.Description__c = '';
    //     orderRequest.Same_Day__c = false;
    //     orderRequest.No_Charge__c =  false;
    //     orderRequest.PO_Number__c = '1027465';
    //     orderRequest.Sales_Rep_Number__c = '1234';
    //     //orderRequest.ContactId__c = orderRequest.ContactId;
    //     orderRequest.Invoice_Report_Type__c = 'LumpSum';
    //     orderRequest.Shipping_Instructions__c = 'Instructions';
    //     orderRequest.Installer_Email__c = 'totallycoolemail@lskdjfls.com';
    //     //orderRequest.QuoteId__c = recordId;       
    //     //orderRequest.Account__c = orderRequest.Bidder;
    //     orderRequest.Order_Amount__c = 150;
    //     orderRequest.Ship_To_Address_1__c = 'asdad';
    //     orderRequest.Ship_To_City__c = 'Muskego';
    //     orderRequest.Ship_To_Contact_Name__c = 'Everett';
    //     orderRequest.Ship_To_Contact_Phone_Number__c = '2624758377';
    //     orderRequest.Ship_To_Country__c = 'United States';
    //     orderRequest.Ship_To_Name__c = 'Ship To Name';
    //     orderRequest.Ship_To_State_Province__c = 'Wisconsin';
    //     orderRequest.Ship_To_Zip_Postal_Code__c = '53150';
    //     orderRequest.Order_Request_Comments__c = '';
    //     orderRequest.Job_Number__c = ''; 
    //     insert orderRequest;

        

    //     List<User> usersResult = OrderRequestRouteHelper.RetrieveUserInfo(userId);
    //     List<Order_Request__c> requests = OrderRequestRouteHelper.RetrieveRecordInfo(orderRequest.Id);
    //     string routeTest1Result = OrderRequestRouteHelper.RouteOrderRequest(orderRequest.Id,'Approve','eleptich',userId,'OR Comments','User Comments');
    //     //string routeTest2Result = OrderRequestRouteHelper.RouteOrderRequest(orderRequest.Id,'Reject','eleptich',userId,'OR Comments','User Comments');
    //     string routeTest3Result = OrderRequestRouteHelper.RouteOrderRequest(orderRequest.Id,'Resubmit For Approval','eleptich',userId,'OR Comments','User Comments');
	// }
}