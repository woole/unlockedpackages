@isTest
public class ExceptionEvent_TriggerHandler_Test {

    
    @isTest
    static void testPublish(){

        ExceptionEvent__e event = new ExceptionEvent__e();
        event.ClassName__c = 'MyTestClassX1';
        event.Correlation_Id__c = 'test-123-456-789';
        event.Record_Id__c = 'recordId';
        event.ErrorMessage__c = 'Test Error Message';
        
        ExceptionEvent_TriggerHandler handler = new ExceptionEvent_TriggerHandler();
        handler.setTriggerData(new List<SObject>{event},null,null);

        Test.startTest();
            try{
                handler.call('onAfterInsert', null);
            }catch(Exception e){
                // as this is testing the handler (not he bus) all we can assert is it didn't fail
                System.assertEquals(true, false,'Should not have thrown an error, force failure : ' + e.getStackTraceString());
            }
            
        Test.stopTest();
        List<Logger__c> logs = [Select Id,Name,Record_Name_Id__c From Logger__c];
        System.assertEquals(1, logs.size(),'expected 1 log entry');
        System.assertEquals('MyTestClassX1', logs[0].Name,'expected The class to be passed on');
    }
}
