@isTest
public class BillingServiceQueryAccountV1_Test {

    @TestSetup
    static void makeData(){

        //SET UP a stub for the Zuora Data call.
        Service_Invocation_Override__c sio3 = new Service_Invocation_Override__c();
        sio3.Name = 'ZuoraBillingAccount_Invocation_1';
        sio3.Metadata_Invoker_Id__c = 'ZuoraBillingAccount_Invocation_1';        
        sio3.Stub_Class__c = 'ZuoraBillingQueryV1_Stub';
        sio3.Invocation_Type__c = 'Stub';
        sio3.Override_Default__c = true;
        sio3.Input_Creation_Class__c = 'DynamicQueryConfigData';
        sio3.Service_Name__c = 'DynamicQueryService';
        insert sio3;              
                
        Account account = new Account(Name='testAccount');
        insert account;      
        
    }

    @isTest
    static void testGetBillingAccountInfo(){
        Account account = [select id from account where name = 'testAccount' limit 1];
        String correlationId = 'test12345';
        billing_IRequest request = new billing_Request(account.Id);
        GenericServiceInvoker invoker = new GenericServiceInvoker('BillingServiceV1_query');
        IService_Output_Master output = invoker.call(request);
        billing_QueryResponse reponse = (billing_QueryResponse)output;
        List<billing_BillingAccount> billingAccounts = reponse.getAccounts();
        System.assertEquals(1,billingAccounts.size(),'expected 1 records');
    }    


}
