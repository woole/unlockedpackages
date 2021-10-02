@isTest
public class ContactSelectorLTCtrl_Test {

    /** Create CallItem and Select Contact **/

    @testSetup static void setup() {

        Account Acc = AccountTestDataFactory.createAccount('Test1');
        Contact firstContact = ContactTestDataFactory.createContact('tets','user',Acc.Id,'200098121');
        Contact secondContact = new Contact();
        secondContact.firstName = 'john';
        secondContact.lastName = 'smith';
        secondContact.accountId = Acc.Id;
        secondContact.MailingCity = 'Atlanta';
        secondContact.MailingCountry = 'United States';
        secondContact.MailingStreet = '17 North West St';
        secondContact.MailingPostalCode = '30005';
        secondContact.MailingState = 'Georgia';
        secondContact.Global_Id__c='200098122';
        insert secondContact;
        
        Contact indirectContact = new Contact();
        indirectContact.firstName = 'john-Indirect';
        indirectContact.lastName = 'smith';
        indirectContact.accountId = Acc.Id;
        indirectContact.MailingCity = 'Atlanta';
        indirectContact.MailingCountry = 'United States';
        indirectContact.MailingStreet = '17 South West St';
        indirectContact.MailingPostalCode = '30002';
        indirectContact.MailingState = 'Georgia';
        indirectContact.Global_Id__c='200098123';
        indirectContact.IsIndirectCustomer__c=true;

        insert indirectContact;
        User adminUser = SalesTestUtility.setUpUserWithPermissions('myOrg','System Administrator',new String[]{'Sage_Global_Sales_Admin','Sage_Global_Core_Data_Model_Admin'});
        User userNoPerms = SalesTestUtility.setUpUserWithPermissions('myExampleOrg','Standard User',new List<String>());
        
        //assign admin FLS perms
        SalesTestUtility.assignPermissionSet(adminUser.id,new String[]{'Sage_Global_Sales_Admin','Sage_Global_Core_Data_Model_Admin'});         
        System.runAs(adminUser){
            Call_Item__c callItem= new  Call_Item__c();
            callItem.Account__c=Acc.id;
            callItem.Contact__c=firstContact.id;
            callItem.Active_Start_Date__c=System.today();
            callItem.Target_Finish_Date__c=System.today()+30;
            callItem.FederationUserID__c=adminUser.Email;
            insert callItem;
        }
    }

    /** select the contact and check callitem has the selected contact using the setContact Method**/
    @isTest
    public static void testSetContact() {
        Test.startTest();
        String expectedbeforeUpdateMailingState='New York';
        String expectedafterUpdateMailingState='Georgia';


        Call_Item__c beforeUpdateCallItem = [select id, ownerid, Contact__c,Contact__r.MailingState, Account__c from Call_Item__c  Limit 1];
        Contact secondContact = [select id from Contact where MailingState='Georgia' Limit 1];
        System.AssertEquals(beforeUpdateCallItem.Contact__r.MailingState, expectedbeforeUpdateMailingState);
        ContactSelectorLTCtrl.setContact(secondContact.id,beforeUpdateCallItem.id);


        Call_Item__c afterUpdateContactCallItem = [select id, ownerid, Contact__c,Contact__r.MailingState, Account__c from Call_Item__c  where id=: beforeUpdateCallItem.id Limit 1];
        System.AssertEquals(afterUpdateContactCallItem.Contact__r.MailingState, expectedafterUpdateMailingState);
        Test.stopTest();
    }

    @isTest
    public static void testGetContacts() {
        Test.startTest();
        Integer expectedContacts=2;// Indirect Contact won't be considered
        Integer actualContacts=0;
        User adminUser = [select Id from user where email like '%@myOrg.com' limit 1];
        Call_Item__c callItem = [select id, ownerid, Contact__c, Account__c from Call_Item__c  Limit 1];
        List<Contact> callItemAccountContacts;
        System.runAs(adminUser){
            try{
                callItemAccountContacts=ContactSelectorLTCtrl.getContacts(callItem.id);
            }catch(AuraHandledException e){
                System.debug(e);
            }
        }

        
        if(callItemAccountContacts!=null)
        {
            actualContacts=callItemAccountContacts.size();
        }

        System.AssertEquals(expectedContacts, actualContacts);
        Test.stopTest();
    }

    @isTest
    public static void testGetContacts_NoPermission() {
        Test.startTest();
        Integer expectedContacts=2;
        Integer actualContacts=0;
        User stdUser = [select Id from user where email like '%@myExampleOrg.com' limit 1];
        
        Call_Item__c callItem = [select id, ownerid, Contact__c, Account__c from Call_Item__c  Limit 1];
        List<Contact> callItemAccountContacts;
        System.runAs(stdUser){
            try{
                callItemAccountContacts=ContactSelectorLTCtrl.getContacts(callItem.id);
                System.assert(false,'should have thrown and exception but did not');
            }catch(AuraHandledException e){
                System.assert(e.getMessage().contains('unable to  query contacts'), 'Exception message is not as expected');
            }
        }
        Test.stopTest();
    }    

    @isTest
    public static void testGetContactsFromAccountId() {
        Test.startTest();
        Integer expectedContacts=2;
        Integer actualContacts=0;

        Account  acc = [select id from Account  Limit 1];
        User adminUser = [select Id from user where email like '%@myOrg.com' limit 1];
        List<Contact> AccountContacts;
        System.runAs(adminUser){
            AccountContacts=ContactSelectorLTCtrl.getContactsFromAccountId(acc.id);
        }
        
        if(AccountContacts!=null)
        {
            actualContacts=AccountContacts.size();
        }

        System.AssertEquals(expectedContacts, actualContacts);
        Test.stopTest();
    }


    @isTest
    public static void testGetAccounts() {
        Test.startTest();


        Call_Item__c callItem = [select id, ownerid, Contact__c, Account__c from Call_Item__c  Limit 1];
        ID expectedCallItemAccountID = callItem.Account__c;
        ID actualCallItemAccountID=ContactSelectorLTCtrl.getAccountId(callItem.id);

        System.AssertEquals(expectedCallItemAccountID, actualCallItemAccountID);
        Test.stopTest();
    }

    @isTest
    public static void testCreateSaveContact() {
        Test.startTest();
        Call_Item__c callItem = [select id, ownerid, Contact__c, Account__c from Call_Item__c  Limit 1];
        String firstName = 'john';
        String lastName = 'smith';
        String phone = '1234567891';
        String email = 'testcallItem@example.com';
        Id accountId = callItem.Account__c;
        String MailingCity = 'Atlanta';
        String MailingCountry = 'United States';
        String MailingStreet = '17 North West St';
        String MailingPostalCode = '30005';
        String MailingState = 'Georgia';
        String JobRole ='CEO';


        Contact createContact= ContactSelectorLTCtrl.saveNewContactApex(callItem.id,firstName,lastName, phone,email, JobRole,
                MailingCountry, MailingState,MailingCity, MailingPostalCode,callItem.Account__c);

        createContact = [select id, firstName,lastName,phone,email,MailingState,MailingPostalCode from contact where id =:createContact.id LIMIT 1];

        System.AssertEquals(firstName, createContact.firstName);
        System.AssertEquals(lastName, createContact.lastName);
        Test.stopTest();

    }

    @isTest
    public static void testGetMaillingCountry() {
        Test.startTest();
        String maillingCountry='MailingCountryCode';
        List<String> mailingCountryLst =ContactSelectorLTCtrl.getMailingCountry(maillingCountry);
        Test.stopTest();
    }

    @IsTest
    public static void testC2dParamsWithCallItem() {
        // GIVEN
        String strRetJson;
        Call_Item__c callItemData = [ SELECT Id, Name FROM Call_Item__c LIMIT 1 ].get(0);

        // WHEN
        Test.startTest();
        strRetJson = ContactSelectorLTCtrl.getPureCloudClickToDialParams(callItemData.Id);
        Test.stopTest();

        //THEN
        Map<String, Object> mMainData = (Map<String, Object>) JSON.deserializeUntyped(strRetJson);
        System.assert((Boolean) mMainData.get('autoPlace'));
        Map<String, Object> mAssociationsData = (Map<String, Object>) ((List<Object>) JSON.deserializeUntyped((String) mMainData.get('associations'))).get(0);
        Map<String, Object> mAttributesData = (Map<String, Object>) mAssociationsData.get('attributes');
        System.assertEquals(callItemData.Id, (String) mAssociationsData.get('Id'));
        System.assertEquals(callItemData.Name, (String) mAssociationsData.get('Name'));
        System.assertEquals('Call_Item__c', (String) mAttributesData.get('type'));
        System.assert(((String) mAttributesData.get('url')).contains(callItemData.Id));
    }

    @IsTest
    public static void testC2dParamsWithAccount() {
        // GIVEN
        String strRetJson;
        Account accountData = [ SELECT Id, Name FROM Account LIMIT 1 ].get(0);

        // WHEN
        Test.startTest();
        strRetJson = ContactSelectorLTCtrl.getPureCloudClickToDialParams(accountData.Id);
        Test.stopTest();

        //THEN
        System.assert(strRetJson != null);
        Map<String, Object> mMainData = (Map<String, Object>) JSON.deserializeUntyped(strRetJson);
        System.assert((Boolean) mMainData.get('autoPlace'));
        Map<String, Object> mAssociationsData = (Map<String, Object>) ((List<Object>) JSON.deserializeUntyped((String) mMainData.get('associations'))).get(0);
        Map<String, Object> mAttributesData = (Map<String, Object>) mAssociationsData.get('attributes');
        System.assertEquals(accountData.Id, (String) mAssociationsData.get('Id'));
        System.assertEquals(accountData.Name, (String) mAssociationsData.get('Name'));
        System.assertEquals('Account', (String) mAttributesData.get('type'));
        System.assert(((String) mAttributesData.get('url')).contains(accountData.Id));
    }

    @IsTest
    public static void testC2dParamsWithoutAccountOrCallItem() {
        // GIVEN
        String strRetJson;
        Contact contactData = [ SELECT Id, Name FROM Contact LIMIT 1 ].get(0);

        // WHEN
        Test.startTest();
        strRetJson = ContactSelectorLTCtrl.getPureCloudClickToDialParams(contactData.Id);
        Test.stopTest();

        //THEN
        System.assert(strRetJson == null);
    }
}