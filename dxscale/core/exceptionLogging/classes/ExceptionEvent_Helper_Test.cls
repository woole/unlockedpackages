@isTest
public class  ExceptionEvent_Helper_Test {

    @isTest
    static void testProcessEventToLogger(){
        List<ExceptionEvent__e> events = new List<ExceptionEvent__e>();
        ExceptionEvent__e event = new ExceptionEvent__e();
        event.ClassName__c = 'MyTestClassX1';
        event.Correlation_Id__c = 'test-123-456-789';
        event.Record_Id__c = 'recordId';
        event.ErrorMessage__c = 'Test Error Message';
        events.add(event);

        ExceptionEvent__e event2 = new ExceptionEvent__e();
        event2.ClassName__c = 'MyTestClassX2';
        event2.Correlation_Id__c = 'test-123-456-00';
        event2.Record_Id__c = 'recordId2';
        event2.ErrorMessage__c = 'Another test Error Message';
        events.add(event2);
    

        Test.startTest();
            try{
                ExceptionEvent_Helper.processEventToLogger(events);
            }catch(Exception e){
                // as this is testing the handler (not he bus) all we can assert is it didn't fail
                System.assertEquals(true, false,'Should not have thrown an error, force failure : ' + e.getStackTraceString());
            }
            
        Test.stopTest();
        List<Logger__c> logs = [Select Id,Name,Record_Name_Id__c From Logger__c];
        System.assertEquals(2, logs.size(),'expected 2 log entry');
        System.assertEquals('MyTestClassX1', logs[0].Name,'expected The class to be passed on');        
    }    
}
