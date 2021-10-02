@isTest
public class Service_Invoke_Event_TriggerHandler_Test {
    


    @isTest
    static void testPublish(){

        Service_Invoke_Event__e event = new Service_Invoke_Event__e();
        event.InputData__c = 'some input load';
        event.InvocationDetails__c = 'some invocation JSON';
        Service_Invoke_Event_TriggerHandler handler = new Service_Invoke_Event_TriggerHandler();
        handler.setTriggerData(new List<SObject>{event},null,null);

        Test.startTest();
            try{
                handler.call('onAfterInsert', null);
            }catch(Exception e){
                // as this is testing the handler (not he bus) all we can assert is it didn't fail
                System.assertEquals(true, false,'Should not have thrown an error, force failure');
            }
            
        Test.stopTest();
    }


}
