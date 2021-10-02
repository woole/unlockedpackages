@isTest
public class UpdateBillingContactV1_Test {
    
    @TestSetup
    static void makeData(){
        Account account = new Account(Name='testAccount');
        insert account;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=account.id,
                        Email='my.email@test.com',MailingCity='Atlanta',MailingCountry='United States',
                        MailingStreet='123 Street');
        insert contact;

        //Overrides the ZAPI Callout
        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = 'BillingServiceV1_updateZuora';
        sio.Metadata_Invoker_Id__c = 'BillingServiceV1_updateZuora';        
        sio.Stub_Class__c = 'ZuoraUpdateRequest_Stub';
        sio.Invocation_Type__c = 'Stub';
        sio.Override_Default__c = true;
        sio.Input_Creation_Class__c = 'billing_UpdateRequest';
        sio.Service_Name__c = 'BillingService';
        insert sio;

        //Overrides the Zuora SObject Updates
        Service_Invocation_Override__c sio2 = new Service_Invocation_Override__c();
        sio2.Name = 'BillingServiceV1_sObjectUpdate';
        sio2.Metadata_Invoker_Id__c = 'BillingServiceV1_sObjectUpdate';        
        sio2.Stub_Class__c = 'SObjectUpdateRequest_Stub';
        sio2.Invocation_Type__c = 'Stub';
        sio2.Override_Default__c = true;
        sio2.Input_Creation_Class__c = 'billing_UpdateSObjectRequest';
        sio2.Service_Name__c = 'BillingService';
        insert sio2;        

        //SET UP a stub for the Zuora Data call.
        Service_Invocation_Override__c sio3 = new Service_Invocation_Override__c();
        sio3.Name = 'ZuoraBillingAccount_Invocation_1';
        sio3.Metadata_Invoker_Id__c = 'ZuoraBillingAccount_Invocation_1';        
        sio3.Stub_Class__c = 'UpdateBillingContactV1_Test.ZuoraQueryStubOK';
        sio3.Invocation_Type__c = 'Stub';
        sio3.Override_Default__c = true;
        sio3.Input_Creation_Class__c = 'DynamicQueryConfigData';
        sio3.Service_Name__c = 'DynamicQueryService';
        insert sio3;              
    } 

    @isTest
    static void testUpdateContactRequest(){
        String newEmailAddress = 'my.newemail-update@test.com';
        Account testAccount = [SELECT id FROM Account WHERE name = 'testAccount' LIMIT 1];
        Contact testContact = [SELECT id, Email FROM Contact WHERE Email = 'my.email@test.com'];
        
        Test.startTest();
            billing_IContactUpdateRequest request = new billing_ContactUpdateRequest(newEmailAddress,testContact.Email,testAccount.id,testContact.Id);
            GenericServiceInvoker invoker = new GenericServiceInvoker('BillingServiceV1_updateContact');
            IService_OUtput_Master response = invoker.call(request);
        Test.stopTest();

        System.assertEquals('SUCCESS', response.getState(), 'Service request should be successful');
        // refetch the contact to validate
        testContact = [SELECT id, Email FROM Contact WHERE id =:testContact.id];
        System.assertEquals(newEmailAddress, testContact.Email, 'expected the contact email to be updated');  
    }

    @isTest
    static void testUpdateContact_ZuoraObjectError(){
        Service_Invocation_Override__c sio = [SELECT Id, Stub_Class__c FROM Service_Invocation_Override__c WHERE Name = 'BillingServiceV1_sObjectUpdate'];
        sio.Stub_Class__c = 'UpdateBillingContactV1_Test.SObjectUpdateStubError';
        update sio;
        String newEmailAddress = 'my.newemail-update@test.com';
        Account testAccount = [SELECT id FROM Account WHERE name = 'testAccount' LIMIT 1];
        Contact testContact = [SELECT id, Email FROM Contact WHERE Email = 'my.email@test.com'];
        
        Test.startTest();
            billing_IContactUpdateRequest request = new billing_ContactUpdateRequest(newEmailAddress,testContact.Email,testAccount.id,testContact.Id);
            GenericServiceInvoker invoker = new GenericServiceInvoker('BillingServiceV1_updateContact');
            IService_OUtput_Master response = invoker.call(request);
        Test.stopTest();

        System.assertEquals('FAIL', response.getState(), 'Service request should fail');
        // refetch the contact to validate
        testContact = [SELECT id, Email FROM Contact WHERE id =:testContact.id];
        System.assertEquals('my.newemail-update@test.com', testContact.Email, 'Contact email should still have updated');  
    }    

    //stub with error in SObjectUpdate
    public class SObjectUpdateStubError implements IService_Implementation {
        public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
            billing_Response reponse = new billing_Response();
            reponse.setState('FAIL');
            reponse.setErrorMessage('Error updating SObject');
            return reponse;
        }
    }

    //stub specific for this test
    public class ZuoraQueryStubOK implements IService_Implementation {

        public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
            IDynamicQueryConfigData isi = (IDynamicQueryConfigData) inputData;
            return stubBody(isi);
        }

        IQueryListMap stubBody (IDynamicQueryConfigData isi) {
            IQueryListMap iso = new QueryListMap();
            
            Map<String,Object> mapper = putToMap(isi.getFields(),isi.getQueryId());
            iso.add(mapper);   
            
            iso.setState('SUCCESS');
            iso.setCorrelationId(isi.getCorrelationId());
            System.debug('exiting stubBody with state:' + iso.getState());
            return iso;
        }

        private  Map<String,Object> putToMap (List<IDynamicQueryConfigItem> fields, String recordId) {
            Map<String,Object> mapper = new Map<String,Object>();
            for (IDynamicQueryConfigItem configItem : fields) {
                
                    if(configItem.getApi().equals('Zuora__Zuora_Id__c')){
                        mapper.put(configItem.getApi(),'stub-id-2c92c0f8749ff0ed0174a0cb29926c46');
                    }
                    if(configItem.getApi().equals('Zuora__AccountNumber__c')){
                        mapper.put(configItem.getApi(),'C00012345');
                    }
                    if(configItem.getApi().equals('Zuora__Account__c')){
                        mapper.put(configItem.getApi(),recordId);
                    }
                    if(configItem.getApi().equals('Zuora__BillToId__c')){
                        mapper.put(configItem.getApi(),'2c92a0ff64d60ab30164db947844445e');
                    }
                    if(configItem.getApi().equals('Zuora__BillToWorkEmail__c')){
                        mapper.put(configItem.getApi(),'my.email@test.com');
                    }
                    if(configItem.getApi().equals('Zuora__SoldToId__c')){
                        mapper.put(configItem.getApi(),'2c92a0ff64d60ab30164db947844445e');
                    }
                    if(configItem.getApi().equals('Zuora__SoldToWorkEmail__c')){
                        mapper.put(configItem.getApi(),'my.email@test.com');
                    } 
                    if(configItem.getApi().equals('Zuora__Zuora_Id__c')){
                        mapper.put(configItem.getApi(),'2c92a0ff64d60ab30164db947844445e');
                    }                 
                                                     
            }
            return mapper;
        }        
    }
}
