@isTest
private class QuoteActionRequestHelperTest{

	@testSetup static void setup(){
		String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;


		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today()
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id,
			Status = 'Draft',
            Pricebook2Id = pricebookId
		);
		insert quoteObj;

		 Task taskObj = new Task (
			WhatId = quoteObj.Id, 
			Subject = 'AddShortDescriptionHere'
		);
		insert taskObj;
		List<User> users = [select id from User LIMIT 2];
		

		Quote_action__c quoteactioncObj = new Quote_action__c (
			QuoteId__c = quoteObj.Id, 
			Status__c ='Pending', 
			Subject__c = 'test value', 
			Comments__c = 'Test Value', 
			Type__c ='Custom Part Number Request', 
			OwnerId = users.get(0).Id,
			TaskId__c = taskObj.Id,
			ApproverId__c = users.get(1).Id
		);
		insert quoteactioncObj;

		Alternate__c alt1 = new Alternate__c(
            Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate 1',
            QuoteId__c = quoteObj.Id
        );
        insert alt1;

        Quotelineitem quotelineitemObj = new Quotelineitem (
            Description = 'test value', 
            Alternate__c = alt1.Id, 
            Custom_Pricing_Requested__c = false, 
            Customer_Priced_On__c = 'test value', 
            Description_2__c = 'Test Value', 
            Document_Name__c = 'test value', 
            Is_Custom_Product__c = true, 
            Quantity = 1.1, 
            UnitPrice = 1.1,
            Item_Number__c = '123',
            ParentID__c = '123',
            QuoteId = quoteObj.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id,
            LineNumber__c = 1,
            Sequence_Number__c = 1,
            Alternate_Number__c = 1,
            Unit_Weight__c = 1
        );
        insert quotelineitemObj;
	}

	@isTest 
	static void testGetQuoteAction_success() {
		String query = 'SELECT Id, TaskId__c FROM Quote_action__c LIMIT 1';
		Quote_action__c quoteAction = (Quote_action__c)Database.query(query);

		String jsonResults = QuoteActionRequestHelper.getQuoteAction(quoteAction.TaskId__c);
		Quote_action__c results = (Quote_action__c)JSON.deserialize(jsonResults, Quote_action__c.class);

		System.assert(results != null);
	}

	@isTest 
	static void testGetQuoteAction_exception() {
		try{
			String jsonResults = QuoteActionRequestHelper.getQuoteAction('');
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest
	static void testGetQuoteLineItemsWithSignSchedules_success()
	{
		Quote quote = [SELECT Id FROM Quote LIMIT 1];

		String jsonResults = QuoteActionRequestHelper.getQuoteLineItemsWithSignSchedules(quote.Id);

		List<QuoteLineItem> results = (List<QuoteLineItem>)JSON.deserialize(jsonResults, List<QuoteLineItem>.class);

		System.assertEquals(0, results.size());
	}

	@isTest
	static void testGetQuoteStatus()
	{
		Quote quote = [SELECT Id FROM Quote LIMIT 1];

		string results = QuoteActionRequestHelper.getQuoteStatus(quote.Id);

		System.assertEquals('Draft', results);
	}

	@isTest 
	static void testGetQuoteName_success() {
		String query = 'SELECT Id FROM Quote LIMIT 1';
		Quote quote = (Quote)Database.query(query);

		String results = QuoteActionRequestHelper.getQuoteName(quote.Id);

		System.assert(results.indexOf('This is my Quote') != -1);
	}

	@isTest 
	static void testGetQuoteName_exception() {
		try{
			String results = QuoteActionRequestHelper.getQuoteName('');
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest 
	static void testGetUsers_success() {
		String jsonResults = QuoteActionRequestHelper.getUsers();
		List<User> results = (List<User>)JSON.deserialize(jsonResults, List<User>.class);

		System.assert(results.size() >= 2);
	}

	@isTest 
	static void testUserSearch_success() {
		String query = 'SELECT Id, Name FROM User LIMIT 1';
		User user = (User)Database.query(query);

		List<LookupSearchResult> results = QuoteActionRequestHelper.userSearch(user.Name,'', new List<String>());

		System.assert(results.get(0).getTitle() == user.Name);
	}

	@isTest
	static void testCreateQuoteAction_noApprover_success(){
		String query = 'SELECT Id, Name FROM Quote LIMIT 1';
		Quote quote = (Quote)Database.query(query);

		String query2 = 'SELECT Id, Name FROM User LIMIT 1';
		User user = (User)Database.query(query2);

		String jsonResults = QuoteActionRequestHelper.createQuoteAction(quote.Id, 'Custom Part Number Request', '', '','','',user.Id);

		Task results = (Task)JSON.deserialize(jsonResults, Task.class);

		System.assertEquals(results.Subject,'Custom Part Number Request - ' + quote.Name + ' - null');
	}

	@isTest
	static void testCreateQuoteAction_withApprover_success(){
		String query = 'SELECT Id, Name FROM Quote LIMIT 1';
		Quote quote = (Quote)Database.query(query);

		String query2 = 'SELECT Id, Name FROM User LIMIT 1';
		User user = (User)Database.query(query2);

		String jsonResults = QuoteActionRequestHelper.createQuoteAction(quote.Id, 'Custom Part Number Request', '', '',user.Id,'',user.Id);

		Task results = (Task)JSON.deserialize(jsonResults, Task.class);

		System.assertEquals(results.Subject,'Custom Part Number Request - ' + quote.Name + ' - null');
	}

	@isTest
	static void testCreateQuoteAction_noType(){
		String query = 'SELECT Id, Name FROM Quote LIMIT 1';
		Quote quote = (Quote)Database.query(query);

		String query2 = 'SELECT Id, Name FROM User LIMIT 1';
		User user = (User)Database.query(query2);

		String results = QuoteActionRequestHelper.createQuoteAction(quote.Id, '', '', '','','',user.Id);

		System.assertEquals(results,'Quote Action type not provided!');
	}

	@isTest
	static void testCreateQuoteAction_noUser(){
		String query = 'SELECT Id, Name FROM Quote LIMIT 1';
		Quote quote = (Quote)Database.query(query);

		String results = QuoteActionRequestHelper.createQuoteAction(quote.Id, 'Custom Part Number Request', '', '','','','');

		System.assertEquals(results,'Assignee not provided!');
	}

	@isTest
	static void testCompleteQuoteAction_success()
	{
		Quote_Action__c quoteAction = [SELECT Id, Status__c,TaskId__c, QuoteId__c FROM Quote_Action__c LIMIT 1];

		QuoteActionRequestHelper.completeQuoteAction(quoteAction.TaskId__c);

		Quote_Action__c quoteActionAfter = [SELECT Id, Status__c,TaskId__c, QuoteId__c FROM Quote_Action__c LIMIT 1];
		String query2 = 'Select Id, Status FROM Task WHERE WhatId = \'' + quoteAction.QuoteId__c + '\' LIMIT 1';
		Task task = (Task)Database.query(query2);

		System.assert(quoteActionAfter.Status__c == 'Complete');
		System.assert(task.Status == 'Completed');
	}

	@isTest
	static void testRejectQuoteAction_success()
	{
		Quote_Action__c qa = [SELECT Id,Comments__c, Status__c, TaskId__c, QuoteId__c FROM Quote_Action__c LIMIT 1];
		QuoteActionRequestHelper.rejectQuoteAction(qa.TaskId__c, 'Reject test');

		Quote_Action__c quoteActionAfter = [SELECT Id,Comments__c, Status__c, TaskId__c, QuoteId__c FROM Quote_Action__c LIMIT 1];
		
		System.assert(quoteActionAfter.Comments__c.indexOf('REJECTION NOTES') != -1);
		System.assert(quoteActionAfter.Status__c == 'Rejected');
	}

	@isTest
	static void testRejectQuoteAction_exception()
	{
		try {
			QuoteActionRequestHelper.rejectQuoteAction('', '');
			System.assert(false);
		} catch (Exception e) {
			System.assert(true);
		}
	}

	@isTest
	static void testUpdateQuoteActionPending_success()
	{
		Quote_Action__c qa = [SELECT Id,Comments__c, Status__c, TaskId__c, QuoteId__c FROM Quote_Action__c LIMIT 1];
		
		QuoteActionRequestHelper.updateQuoteActionPending(qa.TaskId__c);

		Quote_Action__c quoteActionAfter = [SELECT Id,Comments__c, Status__c, TaskId__c, QuoteId__c FROM Quote_Action__c LIMIT 1];
		
		System.assert(quoteActionAfter.Comments__c.indexOf('Approver Notified') != -1);
		System.assert(quoteActionAfter.Status__c == 'Pending');
	}

	@isTest
	static void testUpdateQuoteActionPending_exception()
	{
		try {
			QuoteActionRequestHelper.updateQuoteActionPending(null);
			System.assert(false);
		} catch (Exception e) {
			System.assert(true);
		}
	}

	/*@isTest
	static void testCreateIllustrationChangeRequest()
	{
		Quote quote = [SELECT Id FROM Quote LIMIT 1];

		QuoteActionRequestHelper.createIllustrationChangeRequest(quote.Id,'ordNo','comments', 'selectedIds,selectedIds');

		Task task = [SELECT WhatId,Type FROM Task WHERE WhatId = :quote.Id AND Subject != 'AddShortDescriptionHere'];
		Quote_Action__c quoteAction = [SELECT QuoteId__c, TaskId__c,Type__c FROM Quote_Action__c WHERE QuoteId__c = :quote.Id AND TaskId__c = :task.Id];

		System.assertEquals(task.Id, quoteAction.TaskId__c);
		System.assertEquals(quote.Id, task.WhatId);
		System.assertEquals('Illustration Change Request', quoteAction.Type__c);
		System.assertEquals('Illustration Change Request',task.Type);
	}

	@isTest
	static void testCreateSignScheduleChangeRequest()
	{
		Quote quote = [SELECT Id FROM Quote LIMIT 1];

		QuoteActionRequestHelper.createSignScheduleChangeRequest(quote.Id, 'ordNo','comments');

		Task task = [SELECT WhatId,Type FROM Task WHERE WhatId = :quote.Id AND Subject != 'AddShortDescriptionHere'];
		Quote_Action__c quoteAction = [SELECT QuoteId__c, TaskId__c,Type__c FROM Quote_Action__c WHERE QuoteId__c = :quote.Id AND TaskId__c = :task.Id];

		System.assertEquals(task.Id, quoteAction.TaskId__c);
		System.assertEquals(quote.Id, task.WhatId);
		System.assertEquals('Sign Schedule Change Request', quoteAction.Type__c);
		System.assertEquals('Sign Schedule Change Request',task.Type);
	}*/
}