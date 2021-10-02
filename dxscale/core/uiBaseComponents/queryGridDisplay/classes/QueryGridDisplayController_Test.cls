@IsTest
public with sharing class QueryGridDisplayController_Test {

    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser  = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='primaryglobaliduser@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Core_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id); 
        System.runAs(adminUser){
            Account account = new Account(Name='Dummy Account');
            insert account;
        }
    }

    @IsTest
    public static void testDynamicQueryServiceV1_Stub () {
		Test.startTest();
        User adminUser =[select Id, Email from User where UserName = 'primaryglobaliduser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
            // this is the invokerId used by teh QueryGridDisplayController
            String invokerId = 'DynamicQueryService_Invocation_1';
            // setup the invocation to use a stub by tweaking the custom metadata
    
            Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
            sio.Name = invokerId;
            sio.Metadata_Invoker_Id__c = invokerId;        
            sio.Stub_Class__c = 'DynamicQueryV1_Stub';
            sio.Invocation_Type__c = 'Stub';
            sio.Override_Default__c = true;
            sio.Input_Creation_Class__c = 'DynamicQueryConfigData';
            sio.Service_Name__c = 'DynamicQueryService';
            insert sio;
    
            String masterConfig =  '{"whereClause":"id = ","enforceSecurity":true,"applyUserFLS":"READABLE","limitRows":500,"orderByClause":"Name","terminal":true,"fields":[{"api":"name","label":"Name","type":"String","display":true},{"api":"id","type":"id","display":true},{"api":"phone","type":"phone","display":true},{"api":"isActive","type":"boolean","display":true},{"api":"Latitude","type":"decimal","display":true},{"api":"lastvieweddate","type":"date","display":true},{"api":"NumberOfFailedLogins","type":"integer","display":true},{"api":"LanguageLocaleKey","type":"currency","display":true}],"objectType":"User"}';
    
            Account acc = [select id,Global_Id__c  from account where name = 'Dummy Account' limit 1];
            Id recordId = acc.Id;
            String globalId = 'Global_Id__c';
            String objectName = 'Account';
            QueryGridDisplayController.ScreenData sd = QueryGridDisplayController.fetchData(recordId, objectName, globalId, invokerId, masterConfig);
            System.assertEquals('SUCCESS',sd.state,'state should have been SUCCESS but was ' + sd.state);
            System.assertEquals(10,sd.items.size(),'should have had 10 items returned but was ' + sd.items.size()); // stub returns 10 rows by default
            System.assert(!sd.potentiallyMoreRows,'should not have had more rows set');
        }
        Test.stopTest();
    }

    @IsTest
    public static void testDynamicQueryServiceV1_NullIdParameter () {

        String invokerId = 'DynamicQueryService_Invocation_1';
        // setup the invocation to use the real implementation

        // we do not include a whereClause in our query, this will return all contacts (i.e. zero in this context)
        String masterConfig =  '{        "limitRows":500,          "orderByClause":"name",             "terminal":true,             "fields":[                 {                    "api":"name",                   "label":"Surname",                   "type":"String",                   "display":true                },                {                    "api":"department",                   "label":"Department",                   "type":"String",                   "display":true                },                {                    "api":"accountid",                   "type":"id",                   "display":false                }             ],             "objectType":"Contact"          }';

        Account acc = [select id,Global_Id__c  from account where name = 'Dummy Account' limit 1];
        Id recordId = null;
        String objectName = 'Account';
        String globalId = null;
        QueryGridDisplayController.ScreenData sd = QueryGridDisplayController.fetchData(recordId, objectName, globalId, invokerId, masterConfig);
        System.assertEquals('FAILURE: DynamicQueryService: Invalid Query Structure',sd.state,'state should be FAILURE: DynamicQueryService: Invalid Query Structure but was ' + sd.state);
        System.assert(sd.errorMessage.startsWith('Configuration Error'),'errorMessage should have started with Configuration Error');
    }

    @IsTest
    public static void testgetJSONConfig () {
        String masterConfig  = QueryGridDisplayController.getJSONConfig('ExampleQueryGridDisplay');
        System.assert(masterConfig != null,'ExampleQueryGridDisplay should be a valid config');
    } 
    @IsTest
    public static void testgetJSONConfig_NoConfig () {
        try{
            String masterConfig  = QueryGridDisplayController.getJSONConfig('DOESNOTEXIST');
            
            System.assertEquals(true,false,'force error as should not get here');
        }catch(Exception e){
            System.assert(e != null,'Exception should not be null');
        }
    }    

}