@IsTest
public class OpportunityTriggerTest {
    
    public static testmethod void testTrigger () {

        Opportunity o = new Opportunity ();
        
        o.Name      = 'Test Opportunity';
        o.CloseDate = Date.today();
        o.StageName = 'New';

        insert o;
        update o;

    }

}