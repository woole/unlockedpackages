@isTest
public  class ZuoraBillingAccountHelper_Test {

    @TestSetup
    static void makeData(){
        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = 'ZuoraBillingAccount_Invocation_1';
        sio.Metadata_Invoker_Id__c = 'ZuoraBillingAccount_Invocation_1';        
        sio.Stub_Class__c = 'ZuoraBillingQueryV1_Stub';
        sio.Invocation_Type__c = 'Stub';
        sio.Override_Default__c = true;
        sio.Input_Creation_Class__c = 'DynamicQueryConfigData';
        sio.Service_Name__c = 'DynamicQueryService';
        insert sio;        
    }
    
    @isTest
    static void testGetBillingAccount(){

        Id recordId = UserInfo.getUserId();
        String correlationId = 'test12345';
        String billingAccount = ZuoraBillingAccountHelper.getBillingAccount(recordId,correlationId);
        System.assert(billingAccount != null,'should have returned the stub response');
        System.assertEquals('C00012345',billingAccount, 'Mismatching billing account');

    }

    @isTest
    static void testGetBillingAccountInfo(){
        Id recordId = UserInfo.getUserId();
        String correlationId = 'test12345';
        List<billing_BillingAccount> billingAccounts = ZuoraBillingAccountHelper.getBillingAccountInfo(recordId,correlationId);
        System.assert(billingAccounts != null,'should have returned the stub response');
        System.assertEquals(1,billingAccounts.size(), 'Billing account should be returned');
    }
}
