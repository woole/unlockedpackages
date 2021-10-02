@isTest
public with sharing class KeyAccountInfoCtrl_Test {

    static final String INVOKER_ID = 'KeyAccountInfo_Invocation_1';

    @TestSetup
    static void makeData(){
        Account account = AccountTestDataFactory.createAccount('Dummy Account');
        Account migrationAccount = AccountTestDataFactory.createAccountWithMigrationInfo('MigrationOriginInfo Account', 'SBC UK/I to Global Migration Customer');

        ContactTestDataFactory.createContact('Dummy','Contact',account.Id);
        
        ContactTestDataFactory.createContact('No','Account');
        Profile noAccesProfile = [select Id from profile where name = 'Chatter Free User' LIMIT 1];
        
        User noAccess = UserTestDataFactory.createUser(noAccesProfile.id);
        noAccess.FirstName='KeyAccountInfoCtrlTest';
        update noAccess;
        ServiceInvocationDataFactory.InvokerParams params = new ServiceInvocationDataFactory.InvokerParams();
        params.inputClassName = 'DynamicQueryConfigData';
        params.invokerName = INVOKER_ID;
        params.serviceName = 'DynamicQueryService';
        params.stubClassName = 'DynamicQueryV1_Stub';
        Service_Invocation_Override__c sio = ServiceInvocationDataFactory.createStubOverride(params);
    }

    @IsTest
    public static void testRecordIdNullAndAccount () {
        Account acc = [select id,Global_Id__c from account where name = 'Dummy Account' limit 1];
        String accountId = KeyAccountInfoCtrl.getRecordId(acc.Id,'Account','Global_Id__c');
        System.assert(acc.Global_Id__c == accountId, 'should return the accountId for Account object');
    }   
    @IsTest
    public static void testRecordIdContact () {
        Contact record = [select id,accountId,Global_Id__c from contact where firstname = 'Dummy' limit 1];
        String accountId = KeyAccountInfoCtrl.getRecordId(record.Id,'Contact','Global_Id__c');
        System.assert(record.id == accountId, 'should Have looked up the account records for the contact');

    }   
    
    @IsTest
    public static void testRecordIdContactNoAccess () {
        User user = [select Id from User where FirstName = 'KeyAccountInfoCtrlTest' LIMIT 1];
        
        Contact record = [select id,accountId from contact where firstname = 'Dummy' limit 1];
        Test.startTest();
        System.runAs(user){
            try{
                String accountId = KeyAccountInfoCtrl.getRecordId(record.Id,'Contact','Global_Id__c');
                System.assertEquals(true,false,'should not have got here, force failure');
            }catch(Exception e){
                System.assert(e instanceof AuraHandledException,'SHould have thrown an AuraHandleExpetion but was : ' + e.getTypeName());
                
            }
            
        }
        Test.stopTest();
        

    }      
    
    @IsTest
    public static void testRecordIdContactInvalidRecord () {
        Contact record = [select id,accountId from contact where firstname = 'Dummy' limit 1];
        try{
            KeyAccountInfoCtrl.getRecordId(record.Id,'Account','Global_Id__c');
        }catch(Exception e){
            System.assert(e != null,'An Exception should have been thrown');
        }
    } 

    @IsTest
    public static void testRecordIdNoAccountRecord() {
        Contact contactNoAccount = [select id,accountId from contact where firstname = 'No' limit 1];
        try{
            KeyAccountInfoCtrl.getRecordId(contactNoAccount.Id,'Contact','Global_Id__c');
        }catch(Exception e){
            System.assert(e instanceof AuraHandledException,'should have thrown an AuraHandledException');
        }
    } 

    @isTest
    public static void testGetFieldName(){
        System.assertEquals('Global_Id__c', KeyAccountInfoCtrl.getFieldName('Account','Global_Id__c'),'Standard Objects should return accountId');
        System.assertEquals('Account__r.Global_Id__c', KeyAccountInfoCtrl.getFieldName('Call_Item__c','Account_r.Global_Id__c'),'Custom Objects should return Account__c');
    }

    
    @IsTest
    public static void testGetAccountExtra () {

        List<KeyAccountInfo_d> results = KeyAccountInfoCtrl.getAccountExtra(null,INVOKER_ID);
        
        System.assertEquals(30,results.size(),'should have had 30 records');
        System.assert(results[0].id != null,'id should not have been null');
        System.assert(results[0].priority == 1,'priority should have been 1 but was ' + results[0].priority);
        System.assert(results[0].message != null,'message should not have been null');
    }   

    @IsTest
    public static void testGetAccountOriginInfo () {
        Account acc = [select id,Migration_Information__c,Global_Id__c from account where name = 'MigrationOriginInfo Account' limit 1];
        List<KeyAccountInfo_d> results = KeyAccountInfoCtrl.getAccountOriginInfo(acc.id,acc.Global_Id__c);  
        System.assert(results[0].id != null,'id should not have been null');
        System.assert(results[0].priority == 1,'priority should have been 1 but was ' + results[0].priority);
        System.assert(results[0].message != null,'message should not have been null');
    } 
    
    @IsTest
    public static void testGetAccountPartner() {

        List<KeyAccountInfo_d> results = KeyAccountInfoCtrl.getAcccountPartner(null,INVOKER_ID);
        System.debug(results);
        System.assertEquals(1,results.size(),'should have had 1 records');
        System.assert(results[0].id != null,'id should not have been null');
        System.assert(results[0].priority == 1,'priority should have been 1 but was ' + results[0].priority);
        System.assert(results[0].message != null,'message should not have been null');
    }
    
    @IsTest
    public static void testGetAccountPrompt() {

        List<KeyAccountInfo_d> results = KeyAccountInfoCtrl.getAccountPrompt(null,INVOKER_ID);
        System.debug(results);
        System.assertEquals(1,results.size(),'should have had 1 records');
    }     
    
    @IsTest
    public static void testGetCustomerInteraction() {

        List<KeyAccountInfo_d> results = KeyAccountInfoCtrl.getCustomerInteraction(null,INVOKER_ID);
        System.debug(results);
        System.assertEquals(1,results.size(),'should have had 1 records');
    }   
    
    
    @IsTest
    public static void testException() {
        try{
            List<KeyAccountInfo_d> results = KeyAccountInfoCtrl.getAccountPrompt(null,'DoesNotExit1');
            System.assertEquals(true, false, 'Should not reach here, should fail..');
        }catch(Exception e){
            System.assert(e instanceof AuraHandledException,'should have been an AuraHandledException');
            
        }
    } 

    @isTest
    public static void testGetConfig(){
        try{
            KeyAccountInfoCtrl.getConfig('SomeMadeUpConfigNameThatDoesNotExist');
            System.assertEquals(true, false, 'Should not reach here, should fail..');
        }catch(Exception e){
            System.assert(e instanceof AuraHandledException,'should have been an AuraHandledException');
        }
        
    }
    
   
}