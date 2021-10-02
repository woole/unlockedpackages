
/**
 * An integration test of sorts that shows the services in play that what would need to be stubbed
 * One test per type of request
 */
@isTest
 public class ZuoraServicesWithStubs_Test {
    @TestSetup
    static void makeData(){

       //Overrides the ZAPI Callout
       Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
       sio.Name = 'BillingServiceV1_updateContact';
       sio.Metadata_Invoker_Id__c = 'BillingServiceV1_updateContact';        
       sio.Stub_Class__c = 'UpdateContactRequest_Stub';
       sio.Invocation_Type__c = 'Stub';
       sio.Override_Default__c = true;
       sio.Input_Creation_Class__c = 'billing_ContactUpdateRequest';
       sio.Service_Name__c = 'BillingService';
       insert sio;

       

        Account account = new Account(Name='testAccount');
        insert account;    
             
    } 

    @isTest
    static void testUpdateBillingContact(){
        Account testAccount = [select id from Account where name = 'testAccount' limit 1];
        billing_IContactUpdateRequest request = new billing_ContactUpdateRequest('my.email@example.com','my-oldemail@example.com',testAccount.Id,null);
        GenericServiceInvoker invoker = new GenericServiceInvoker('BillingServiceV1_updateContact');
        IService_OUtput_Master response = invoker.call(request);
        System.assertEquals('SUCCESS', response.getState());
    }

   
}
