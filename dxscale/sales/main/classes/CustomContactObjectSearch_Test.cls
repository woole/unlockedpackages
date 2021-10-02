@isTest
public with sharing class CustomContactObjectSearch_Test {
   @TestSetup
    static void makeData() {
     Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    User adminUser  = new User(Alias = 'standt', Email='conselectortuser@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='conselectortuser@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);        
        System.runAs(adminUser){
            
            List<Account> lAccs = new List<Account>();
            Account acc1 = new Account(Name='testAccount1', Type='Customer', BillingCountry='United Kingdom',
                                       BillingCity='Blyth', BillingStreet='Salisbury Street', Locale_Billing_CC__c='US');
            Account acc2 = new Account(Name='testAccount2', Type='Customer', BillingCountry='United Kingdom',BillingCountryCode='GB',
                                       BillingCity='Cramlington', BillingStreet='Salisbury Street',
                                       Sales_Office__c='Dublin CBC', Locale_Billing_CC__c='GB');
           
            
            lAccs.add(acc1);
            lAccs.add(acc2);
            insert lAccs;
           
            List<Contact> lCons = new List<Contact>();
            Contact con1 = new Contact(FirstName='Test1', LastName='User', Email='test1@user.com',AccountId=acc1.Id);
            Contact con2 = new Contact(FirstName='Test2', LastName='User', Email='test2@user.com', AccountId=acc1.Id,
                                       MailingStreet='15a Credibility Street', MailingPostalCode='NE99 9XX', MailingCountry='Albania');
            Contact con3 = new Contact(FirstName='Test3', LastName='User', Email='test3@user.com',
                                       AccountId=acc2.Id, MailingStreet='16a Flicker Street', MailingPostalCode='10305', MailingCountry='United States');
            Contact con4 = new Contact(FirstName='Test4', LastName='User', Email='test4@user.com', 
                                       AccountId=acc2.Id, MailingStreet='16a Flicker Street', MailingPostalCode='NE67 9SP', MailingCountry='United Kingdom');
            Contact con5 = new Contact(FirstName='Test5', LastName='User', Email='test3@user.com',
                                       AccountId=acc2.Id, MailingStreet='16a Flicker Street', MailingPostalCode='10306', MailingCountry='United States');
            Contact con6 = new Contact(FirstName='Test6', LastName='User', Email='test4@user.com', 
                                       AccountId=acc2.Id, MailingStreet='16a Flicker Street', MailingPostalCode='NE67 9SQ', MailingCountry='United Kingdom');
            lCons.add(con1); 
            lCons.add(con2);
            lCons.add(con3);
            lCons.add(con4);
            lCons.add(con5);
            lCons.add(con6);
            insert lCons;

        }
    }


    @isTest 
    public static void CustomContactObjectSearch_Test1(){

        User u = [SELECT Id FROM User WHERE UserName='conselectortuser@testorg.com'];
        System.runAs(u){
           // List<Id> accContacts = [select id from contact where accountid=acc.id];

        Integer expectedNumberOfAcc1Contacts=2;
        Integer expectedNumberOfAcc2Contacts=0;
         Test.startTest();
          Account acc1 = [SELECT Id, Locale__r.Name, Sales_Office__c, BillingCountryCode FROM Account WHERE Name = 'testAccount1'];
          Account acc2 = [SELECT Id, Locale__r.Name, Sales_Office__c, BillingCountryCode FROM Account WHERE Name = 'testAccount2'];
          List<Contact> acc1Contacts= CustomContactObjectSearch.getContactList(acc1.Id, 'Test');
          List<Contact> acc1AllContacts=  CustomContactObjectSearch.getContactList(acc1.Id, 'All');
          List<Contact> acc2Contacts=  CustomContactObjectSearch.getContacts(acc2.Id);
          Integer acc2ContactsSize = acc2Contacts?.size()==null?0:4;
     Test.stopTest();
   System.assertEquals(expectedNumberOfAcc1Contacts, acc1Contacts.size(),'account contacts size');
   System.assertEquals(expectedNumberOfAcc1Contacts, acc1Contacts.size(),'account contacts size');
   System.assertEquals(expectedNumberOfAcc2Contacts, acc2ContactsSize,'account contacts size');

    }
}

}
