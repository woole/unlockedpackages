@IsTest(SeeAllData = false)
public class LockOpportunityTriggerTest {

    @TestSetup static void createTestData() {
        List<SObject> listInsertObject = new List<SObject>();
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)) {
            SalesTestUtility.createUsersWithCustomPermission(1, 'isNcaPlusUser');
            insert new Global_Products__c(Name = 'GL - Sage - One');
        }
        SalesTestUtility.createLocalCrmCustomSetting();
        System.runAs([SELECT Id FROM User WHERE UserName LIKE 'nca.plus.cust.perm@%.com'].get(0)) {
            Id rtStandardAccountId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Standard_Account').getRecordTypeId();
            listInsertObject.addAll(SalesTestUtility.createSobject(1, false, new Map<String, Object>{
                        'Name' => 'Test Account Data'
                    ,   'Type' => 'Accountant Customer'
                    ,   'RecordTypeId' => rtStandardAccountId
                    ,   'Phone' => '1234567890'
                    ,   'BillingStreet' => 'Street'
                    ,   'BillingCity' => 'City'
                    ,   'BillingPostalCode' => 'NE323HL'
                    ,   'BillingCountryCode' => 'GB'
                    ,   'Local_CRM_Region__c' => 'EUR'
                    ,   'Local_CRM_Country__c' => 'GB - United Kingdom'
                    ,   'Local_CRM_Name__c' => 'INA - Intacct'
                    ,   'Global_Id__c' => '100098121'
            }, 'Account'));
            listInsertObject.addAll(SalesTestUtility.createSobject(1, false, new Map<String, Object>{
                        'Name' => 'Test Account Data'
                    ,   'Type' => 'Accountant Customer'
                    ,   'RecordTypeId' => rtStandardAccountId
                    ,   'Phone' => '1234567890'
                    ,   'BillingStreet' => 'Street'
                    ,   'BillingCity' => 'City'
                    ,   'BillingPostalCode' => 'NE323HL'
                    ,   'BillingCountryCode' => 'GB'
                    ,   'Local_CRM_Region__c' => 'EUR'
                    ,   'Local_CRM_Country__c' => 'GB - United Kingdom'
                    ,   'Local_CRM_Name__c' => 'INT - InTouch'
                    ,   'Global_Id__c' => '100098122'
            }, 'Account'));
            listInsertObject.addAll(SalesTestUtility.createSobject(1, false, new Map<String, Object>{
                        'Name' => 'Test Account Data'
                    ,   'Type' => 'Accountant Customer'
                    ,   'RecordTypeId' => rtStandardAccountId
                    ,   'Phone' => '1234567890'
                    ,   'BillingStreet' => 'Street'
                    ,   'BillingCity' => 'City'
                    ,   'BillingPostalCode' => '2127'
                    ,   'BillingCountryCode' => 'AU'
                    ,   'Local_CRM_Region__c' => 'AUS'
                    ,   'Local_CRM_Country__c' => 'AU - Australia'
                    ,   'Local_CRM_Name__c' => 'INA - Intacct'
                    ,   'Global_Id__c' => '100098123'
            }, 'Account'));
            listInsertObject.addAll(SalesTestUtility.createSobject(1, false, new Map<String, Object>{
                        'Name' => 'Test Account Data'
                    ,   'Type' => 'Accountant Customer'
                    ,   'RecordTypeId' => rtStandardAccountId
                    ,   'Phone' => '1234567890'
                    ,   'BillingStreet' => 'Street'
                    ,   'BillingCity' => 'City'
                    ,   'BillingPostalCode' => '2127'
                    ,   'BillingCountryCode' => 'AU'
                    ,   'Local_CRM_Region__c' => 'AUS'
                    ,   'Local_CRM_Country__c' => 'AU - Australia'
                    ,   'Local_CRM_Name__c' => 'AUS - None'
                    ,   'Global_Id__c' => '100098124'
            }, 'Account'));
            listInsertObject.addAll(SalesTestUtility.createSobject(1, false, new Map<String, Object>{
                        'Name' => 'Test Account Data'
                    ,   'Type' => 'Accountant Customer'
                    ,   'RecordTypeId' => rtStandardAccountId
                    ,   'Phone' => '1234567890'
                    ,   'BillingStreet' => 'Street'
                    ,   'BillingCity' => 'Manville'
                    ,   'BillingPostalCode' => '09909'
                    ,   'BillingCountryCode' => 'US'
                    ,   'Local_CRM_Region__c' => 'AMR'
                    ,   'Local_CRM_Country__c' => 'US - United States'
                    ,   'Local_CRM_Name__c' => 'FUS - Fusion'
                    ,   'Global_Id__c' => '100098125'
            }, 'Account'));
            Database.insert(listInsertObject);
        }
    }

    // CHANGES IN CURRENT TEST METHOD TO UTILIZE TEST SETUP METHOD
    @IsTest public static void runTest(){
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            Lead l = new Lead();
            l.FirstName = 'FirstName NCA'+system.now();
            l.lastName = 'LastName NCA AMP OPP'+system.now();
            l.Company = 'Test Comapny NCA AMP Test OPP'+system.now();
            l.Email = 'ncaLeadAmpOpp@amp.com';
            l.Status = 'New';
            l.Lead_Source__c = 'Marketing';
            l.Industry = 'Banking';
            //l.Lead_Source_Most_Recent__c = 'Other'; Commented out by Laxmi Bandaru on 11/15/2017 as the field is marked for deletion
            l.Country = 'United Kingdom';
            l.CountryCode = 'GB';
            l.Street = '123 Street';
            l.City = 'London';
            l.Product__C = 'Non Product Line Specific';
            l.Local_CRM_Country__c = 'GB - United Kingdom';
            l.Local_CRM_Name__c = 'INT - InTouch';
            insert l;

            Test.startTest();
            database.leadConvert lc = new database.leadConvert();
            lc.setLeadId(l.id);
            leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Test.stopTest();

            System.assert(lcr.isSuccess());

            LockOpportunityTriggerHelper.isFirstTimeRun = true;// Preparing for update
            Opportunity opp = [SELECT ID, Name FROM Opportunity LIMIT 1];
            opp.Integration_Record_Status__c = 'Pending - Send to Local (Self)';
            update opp;
        }
    }

    @IsTest static void localCRMFieldsIntAcctGbCRMProductTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                Name = 'Test Opportunity'
                ,   Product__c = 'Sage Intacct'
                ,   Product_Solution__c = 'Sage Intacct'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'INA - Intacct'
                                        AND BillingCountryCode = 'GB' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INA - Intacct', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctGbCRMWithoutProductTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Accounting'
                ,   Product_Solution__c = 'Accountants'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'INA - Intacct'
                                        AND BillingCountryCode = 'GB' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INA - Intacct', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctGbProductWithoutCRMTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Sage Intacct'
                ,   Product_Solution__c = 'Sage Intacct'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'INT - InTouch'
                                        AND BillingCountryCode = 'GB' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INA - Intacct', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctGbWithoutProductCRMTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Accounting'
                ,   Product_Solution__c = 'Accountants'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'INT - InTouch'
                                        AND BillingCountryCode = 'GB' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INT - InTouch', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctAusCRMProductTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Sage Intacct'
                ,   Product_Solution__c = 'Sage Intacct'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'INA - Intacct'
                                        AND BillingCountryCode = 'AU' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INA - Intacct', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctAusCRMWithoutProductTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Accounting'
                ,   Product_Solution__c = 'Accountants'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'INA - Intacct'
                                        AND BillingCountryCode = 'AU' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INA - Intacct', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctAusProductWithoutCRMTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Sage Intacct'
                ,   Product_Solution__c = 'Sage Intacct'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'AUS - None'
                                        AND BillingCountryCode = 'AU' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('INA - Intacct', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctAusWithoutProductCRMTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Accounting'
                ,   Product_Solution__c = 'Accountants'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'AUS - None'
                                        AND BillingCountryCode = 'AU' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('AUS - None', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctProductWithoutCountryCRMTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Sage Intacct'
                ,   Product_Solution__c = 'Sage Intacct'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'FUS - Fusion'
                                        AND BillingCountryCode = 'US' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('FUS - Fusion', listOpportunity.get(0).Local_CRM__c);
    }

    @IsTest static void localCRMFieldsIntAcctWithoutProductCountryCRMTest() {
        // GIVEN
        List<Opportunity> listOpportunity = new List<Opportunity> { new Opportunity(
                    Name = 'Test Opportunity'
                ,   Product__c = 'Accounting'
                ,   Product_Solution__c = 'Accountants'
                ,   AccountId = [   SELECT Id FROM Account
                                    WHERE Local_CRM_Name__c = 'FUS - Fusion'
                                        AND BillingCountryCode = 'US' LIMIT 1 ].get(0).Id
        ) };

        // WHEN
        Test.startTest();
        System.runAs([ SELECT Id FROM User WHERE Username LIKE 'nca.plus.cust.perm@%.com' LIMIT 1 ].get(0)) {
            new LockOpportunityTriggerHelper().populateLocalCRMFields(listOpportunity);
        }
        Test.stopTest();

        // THEN
        System.assertEquals('FUS - Fusion', listOpportunity.get(0).Local_CRM__c);
    }
}