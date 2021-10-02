@isTest
public class AssistedSalesController_Test {
     
    @TestSetup
    static void makeSetupData() {
        Group grp = new Group(Name='Assisted Sales Agent', Type='Regular');
        insert grp;
        Group grpman = new Group(Name='Assisted Sales Manager', Type='Regular');
        insert grpman;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile psa = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> lUsers = new List<User>();
        User u = new User(Alias = 'nogroup', Email='expectedemail@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = psa.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='nogroup@anywhere.com', FederationIdentifier='nogroup');
        
        User ug = new User(Alias = 'inagroup', Email='expectedanotheremail@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey='America/Los_Angeles',
                           UserName='inagroup@anywhere.com', FederationIdentifier='inagroup');
        User uf = new User(Alias = 'nofedid', Email='nofedid@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey='America/Los_Angeles',
                           UserName='nofedid@anywhere.com');
        User usa = new User(Alias = 'sadgroup', Email='sysadminingroup@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=psa.Id, TimeZoneSidKey='America/Los_Angeles',
                           UserName='sysadminingroup@anywhere.com', FederationIdentifier='sysadminingroup');
        lUsers.add(u);
        lUsers.add(ug);
        lUsers.add(uf);
        lUsers.add(usa);
        insert lUsers;
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
		insert new PermissionSetAssignment(AssigneeId = lUsers[0].id, PermissionSetId = ps1.Id);
        List<GroupMember> lGMs = new List<GroupMember>();
        GroupMember grpmem1 = new GroupMember(UserOrGroupId=ug.Id, GroupId=grp.Id);
        GroupMember grpmem2 = new GroupMember(UserOrGroupId=ug.Id, GroupId=grpman.Id);
        GroupMember grpmem3 = new GroupMember(UserOrGroupId=uf.Id, GroupId=grp.Id);
        GroupMember grpmem4 = new GroupMember(UserOrGroupId=usa.Id, GroupId=grp.Id);
        lGMs.add(grpmem1);
        lGMs.add(grpmem2);
        lGMs.add(grpmem3);
        lGMs.add(grpmem4);
        insert lGMs;
        // Non-system user will require read permissions on the custom field Locale__c on Account (sigh)
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE PermissionSet.Profile.Name = 'Standard User'];
        FieldPermissions[] fps = [SELECT Id, Field, SobjectType, PermissionsRead, PermissionsEdit, ParentId
                                  FROM FieldPermissions
                                  WHERE Field='Account.Locale__c'
                                  AND SobjectType='Account'
                                  AND ParentId=:ps.Id];
        FieldPermissions fp;
        if (fps.size() == 0) {
            fp = new FieldPermissions(Field='Account.Locale__c', SobjectType='Account',
                                      PermissionsRead=true, PermissionsEdit=false, ParentId=ps.Id);
            insert fp;
        } else {
            fp = new FieldPermissions(Id=fps[0].Id, PermissionsRead=true, PermissionsEdit=false, ParentId=ps.Id);
            update fp;
        }
        // repeat for Sys Admin with Edit access on Locale field
        PermissionSet pssa = [SELECT Id FROM PermissionSet WHERE PermissionSet.Profile.Name = 'System Administrator'];
        FieldPermissions[] fpsa = [SELECT Id, Field, SobjectType, PermissionsRead, PermissionsEdit, ParentId
                                   FROM FieldPermissions
                                   WHERE Field='Account.Locale__c'
                                   AND SobjectType='Account'
                                   AND ParentId=:pssa.Id];
        FieldPermissions fpa;
        if (fpsa.size() == 0) {
            fpa = new FieldPermissions(Field='Account.Locale__c', SobjectType='Account',
                                       PermissionsRead=true, PermissionsEdit=true, ParentId=pssa.Id);
            insert fpa;
        } else {
            fpa = new FieldPermissions(Id=fpsa[0].Id, PermissionsRead=true, PermissionsEdit=true, ParentId=pssa.Id);
            update fpa;
        }
        // Non-setup object records are created in a new context (block) to avoid Mixed DML errors
        System.runAs(u) {
            makeNonSetupData();
        }
    }

    static void makeNonSetupData() {
        List<Locale__c> lLocs = new List<Locale__c>();
        Locale__c locGB = new Locale__c(Name='en_GB', Country__c='GB - United Kingdom', LanguageLocaleKey__c='en_GB', 
                                        Default_Locale__c='Yes',Language__c='English');
        Locale__c locUS = new Locale__c(Name='en_US', Country__c='US - United States', LanguageLocaleKey__c='en_US', 
                                        Default_Locale__c='Yes',Language__c='English');
        lLocs.add(locGB);
        lLocs.add(locUS);
        insert lLocs;
        List<Account> lAccs = new List<Account>();
        Account acc1 = new Account(Name='testAccount1', Type='Customer', BillingCountry='United Kingdom',
                                   BillingCity='Blyth', BillingStreet='Salisbury Street', Locale_Billing_CC__c='US',VAT_Number__c='GB123456789');
        Account acc2 = new Account(Name='testAccount2', Type='Customer', BillingCountry='United Kingdom',BillingCountryCode='GB',
                                   BillingCity='Cramlington', BillingStreet='Salisbury Street', Locale__c=locGB.Id,
                                   Sales_Office__c='Dublin CBC', Locale_Billing_CC__c='GB',VAT_Number__c='GB123499999');
        Account acc3 = new Account(Name='testAccount3', Type='Customer', BillingCountry='United States', Locale__c=locUS.Id,
                                   Sales_Office__c='Atlanta CBC', BillingCity='Atlanta', BillingStreet='Sesame Street', Locale_Billing_CC__c='US',VAT_Number__c='GB987654321');
        Account acc4 = new Account(Name='testAccount4', Type='Customer', BillingCountry='United Kingdom',
                                   BillingCity='Blyth', BillingStreet='Salisbury Street', Locale_Billing_CC__c='US',VAT_Number__c='GB123456778');
        
        lAccs.add(acc1);
        lAccs.add(acc2);
        lAccs.add(acc3);
        lAccs.add(acc4);
        insert lAccs;
        // To evaluate the cross reference values and derive the formula... apparently. Does not remain populated by insertion alone.
        acc2.Locale__c = locGB.Id;
        upsert acc2;
        acc3.Locale__c = locUS.Id;
        upsert acc3;
        List<Contact> lCons = new List<Contact>();
        Contact con1 = new Contact(FirstName='Test1', LastName='User', Email='test1@user.com', Locale__c=locGB.Id);
        Contact con2 = new Contact(FirstName='Test2', LastName='User', Email='test2@user.com', AccountId=acc2.Id,
                                   MailingStreet='15a Credibility Street', MailingPostalCode='NE99 9XX', MailingCountry='Albania');
        Contact con3 = new Contact(FirstName='Test3', LastName='User', Email='test3@user.com', Locale__c=locGB.Id,
                                   AccountId=acc3.Id, MailingStreet='16a Flicker Street', MailingPostalCode='10305', MailingCountry='United States');
        Contact con4 = new Contact(FirstName='Test4', LastName='User', Email='test4@user.com', Locale__c=locGB.Id,
                                   AccountId=acc4.Id, MailingStreet='16a Flicker Street', MailingPostalCode='NE67 9SP', MailingCountry='United Kingdom');
        lCons.add(con1); 
        lCons.add(con2);
        lCons.add(con3);
        lCons.add(con4);
        insert lCons;
        List<Opportunity> lOpps = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(Name='testOpp1', AccountId=acc1.Id, StageName='Qualify',
                                           CloseDate=System.today() + 20, Lead_Source__c='Marketing');
        Opportunity opp2 = new Opportunity(Name='testOpp2', AccountId=acc1.Id, StageName='Qualify',
                                           CloseDate=System.today() + 20, Lead_Source__c='Marketing');
        Opportunity opp3 = new Opportunity(Name='testOpp3', AccountId=acc1.Id, StageName='Qualify',
                                           CloseDate=System.today() + 20, Lead_Source__c='Marketing');
        Opportunity opp4 = new Opportunity(Name='testOpp4', AccountId=acc4.Id, StageName='Qualify',
                                           CloseDate=System.today() + 20, Lead_Source__c='Marketing');
        lOpps.add(opp1); 
        lOpps.add(opp2);
        lOpps.add(opp3);
        lOpps.add(opp4);
        insert lOpps;
        List<OpportunityContactRole> lOCRs = new List<OpportunityContactRole>();
        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId=opp2.Id, ContactId=con1.Id, Role='Bill To');
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId=opp2.Id, ContactId=con1.Id, Role='Sell To');
        OpportunityContactRole ocr3 = new OpportunityContactRole(OpportunityId=opp3.Id, ContactId=con2.Id, Role='Bill To');
        OpportunityContactRole ocr4 = new OpportunityContactRole(OpportunityId=opp3.Id, ContactId=con3.Id, Role='Sell To');
        OpportunityContactRole ocr5 = new OpportunityContactRole(OpportunityId=opp4.Id, ContactId=con4.Id, Role='Other');
        lOCRs.add(ocr1);
        lOCRs.add(ocr2);
        lOCRs.add(ocr3);
        lOCRs.add(ocr4);
        lOCRs.add(ocr5);
        insert lOCRs;
    }

    @isTest
    static void testCheckRequest() {
        User u = [SELECT Id FROM User WHERE UserName='nogroup@anywhere.com'];
        User ug = [SELECT Id FROM User WHERE UserName='inagroup@anywhere.com'];
        User uf = [SELECT Id FROM User WHERE UserName='nofedid@anywhere.com'];
        Opportunity badOpp1 = [SELECT Id FROM Opportunity WHERE Name = 'testOpp1'];
        Opportunity badOpp2 = [SELECT Id FROM Opportunity WHERE Name = 'testOpp2'];
        Opportunity goodOpp = [SELECT Id FROM Opportunity WHERE Name = 'testOpp3'];
        
        test.startTest();
        AssistedSalesController.AssistedSalesController_d ascon0 = AssistedSalesController.checkRequest(badOpp1.Id);
        System.assert(ascon0.qlv == null, 'Request was populated despite missing ON switch');
        Assisted_Sales_Control__c ascs = new Assisted_Sales_Control__c(Active__c=true, Destination_URL__c='/testURL/wherever?');
        insert ascs;
        AssistedSalesController.AssistedSalesController_d ascon1 = AssistedSalesController.checkRequest(badOpp1.Id);
        System.assert(hasError('Please supply a Bill To Contact Role on your Opportunity',
                               ascon1.errorList), 'Error not found for Opportunity testOpp1');
        System.assert(hasError('Please supply a Sell To Contact Role on your Opportunity',
                               ascon1.errorList), 'Error not found for Opportunity testOpp1');
        AssistedSalesController.AssistedSalesController_d ascon2 = AssistedSalesController.checkRequest(badOpp2.Id);
        System.assert(hasError('Bill To Contact needs to reference an Account Id',
                               ascon2.errorList), 'Error not found for Opportunity testOpp2');
        System.assert(hasError('Sell To Contact needs to reference an Account Id',
                               ascon2.errorList), 'Error not found for Opportunity testOpp2'); 
        AssistedSalesController.AssistedSalesController_d ascon3;
        System.runAs(u) {
            ascon3 = AssistedSalesController.checkRequest(goodOpp.Id);
        }
        System.assert(hasError('You are not currently a member of any Assisted Sales public group (Manager or Agent)',
                               ascon3.errorList), 'Error not found for Opportunity testOpp3');
        AssistedSalesController.AssistedSalesController_d ascon4;
        System.runAs(ug) {
            ascon4 = AssistedSalesController.checkRequest(goodOpp.Id);
        }
        System.assert(hasError('You need permission to update Contact locale field value to continue',
                               ascon4.errorList), 'Error not found for Opportunity testOpp4');
        AssistedSalesController.AssistedSalesController_d ascon5;
        System.runAs(uf) {
            ascon5 = AssistedSalesController.checkRequest(goodOpp.Id);
        }
        System.assert(hasError('Your user record should contain your name, email address and Federation Id',
                               ascon5.errorList), 'Error not found for Opportunity testOpp5');       
        test.stopTest();
        
        // check locale not set on Contact(s) - which it would have been if validation had been passed and an update performed
        Contact retCon = [SELECT Locale__c, AccountId FROM Contact WHERE Email = 'test2@user.com' LIMIT 1];
        Account retAcc = [SELECT Locale__c FROM Account WHERE Id = :retCon.AccountId LIMIT 1];
        System.assert(retAcc.Locale__c != retCon.Locale__c,'test2 Contact Locale somehow matches Account Locale');
        retCon = [SELECT Locale__c, AccountId FROM Contact WHERE Email = 'test3@user.com' LIMIT 1];
        retAcc = [SELECT Locale__c FROM Account WHERE Id = :retCon.AccountId LIMIT 1];
        System.assert(retAcc.Locale__c != retCon.Locale__c,'test3 Contact Locale somehow matches Account Locale');
    }

    @isTest
    static void testCheckSwitch() {
        // run with switch on and off
        AssistedSalesController.AssistedSalesController_d retAsc = AssistedSalesController.checkSwitch();
        System.assert(retAsc.errorList != null, 'No errors returned from checkSwitch despite missing switch setting');
        System.assert(retAsc.destination == null, 'Destination url returned from checkSwitch despite missing switch setting');
        Assisted_Sales_Control__c ascon = new Assisted_Sales_Control__c(Active__c = true);
        insert ascon;
        retAsc = AssistedSalesController.checkSwitch();
        System.assert(retAsc.errorList != null, 'Errors returned from checkSwitch despite switch setting being incomplete: ' + retAsc.errorList);
        System.assert(retAsc.destination == null, 'Destination url returned from checkSwitch despite incomplete switch setting');
        ascon.Destination_URL__c = '/testURL/wherever?';
        update ascon;
        retAsc = AssistedSalesController.checkSwitch();
        System.assert(retAsc.errorList.isEmpty(), 'Errors returned from checkSwitch despite switch setting being present and complete: ' + retAsc.errorList);
        System.assert(retAsc.destination != null, 'Destination url not returned from checkSwitch despite switch setting being present'); 
    }

    @isTest
    static void testFetchUser() {
        User u = [SELECT Id, Email, Name, FederationIdentifier FROM User WHERE UserName='nogroup@anywhere.com'];
        QuoteLoginRequestV1 request = new QuoteLoginRequestV1();
        QuoteLoginRequestV1 response;
        System.runAs(u) {
            response = AssistedSalesController.fetchUser(request);
        }
        System.assert(response.user.id == u.Id, 'Id of user not passed into response');
        System.assert(response.user.name == u.Name, 'Name of user not passed into response');
        System.assert(response.user.email == u.Email, 'Email of user not passed into response');
        System.assert(response.user.federatedid == u.FederationIdentifier, 'Federation Id of user not passed into response');
    }

    @isTest
    static void testFetchGroupMembers() {
        User u = [SELECT Id FROM User WHERE UserName='nogroup@anywhere.com'];
        User ug = [SELECT Id FROM User WHERE UserName='inagroup@anywhere.com'];
        QuoteLoginRequestV1 request = new QuoteLoginRequestV1();
        request.user = new QuoteLoginRequestV1.User_d();
        QuoteLoginRequestV1 response;
        System.runAs(u) {
            response = AssistedSalesController.fetchGroupMembers(request);
        }
        System.assert(response.user.groups == null, 'User groups returned but not expected');
        System.runAs(ug) {
            response = AssistedSalesController.fetchGroupMembers(request);
        }
        System.assert(response.user.groups.contains('Assisted Sales Agent'), 'Assisted Sales Agent group not retrieved');
        System.assert(response.user.groups.contains('Assisted Sales Manager'), 'Assisted Sales Manager group not retrieved');
        System.assert(response.user.groups.size() == 2, '>2 user groups returned');              
    }

    @isTest
    static void testFetchOpportunityContactRoles() {
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name='testOpp3'];
        Contact cb = [SELECT Id, Name FROM Contact WHERE FirstName='Test2'];
        Contact cs = [SELECT Id, Name FROM Contact WHERE FirstName='Test3'];
        QuoteLoginRequestV1 request = new QuoteLoginRequestV1();
        QuoteLoginRequestV1.Opportunity_d oppd = new QuoteLoginRequestV1.Opportunity_d();
        request.opportunity = oppd;
        request.opportunity.id = o.Id;
        QuoteLoginRequestV1 response = AssistedSalesController.fetchOpportunityContactRoles(request);
        System.assert(cb.Id != null, 'Bill To Contact Role not retrieved');
        System.assert(cs.Id != null, 'Sell To Contact Role not retrieved');
        System.assert(response.opportunity.billToContact.Id == cb.Id, 'Bill To Contact Role not as expected');
        System.assert(response.opportunity.sellToContact.Id == cs.Id, 'Sell To Contact Role not as expected');
        System.assert(response.opportunity.name == o.Name, 'Opportunity Name not as expected');
    }

    @isTest
    static void testFetchOpportunityContacts() {
        User ug = [SELECT Id FROM User WHERE UserName='inagroup@anywhere.com'];
        // this contact is connected to an Account with a null Locale__c
        Contact cb = [SELECT Id, Name FROM Contact WHERE FirstName='Test2'];
        // this one's account is connected to the US locale 'en_US'
        Contact cs = [SELECT Id, Name FROM Contact WHERE FirstName='Test3']; 
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name='testOpp3'];
        List<Id> opportunityContacts = new List<Id>();
        opportunityContacts.add(cb.Id);
        opportunityContacts.add(cs.Id);
        QuoteLoginRequestV1 request = new QuoteLoginRequestV1();
        QuoteLoginRequestV1.Opportunity_d oppd = new QuoteLoginRequestV1.Opportunity_d();
        QuoteLoginRequestV1.Contact_d s2c = new QuoteLoginRequestV1.Contact_d();
        s2c.id = cs.Id;
        QuoteLoginRequestV1.Contact_d b2c = new QuoteLoginRequestV1.Contact_d();
        b2c.id = cb.id;
        oppd.sellToContact = s2c;
        oppd.billToContact = b2c;
        request.opportunity = oppd;
        AssistedSalesController.AssistedSalesController_d response = 
            AssistedSalesController.fetchOpportunityContacts(request, opportunityContacts);
        System.assert(response.contactToLocale.size() == 2, 'Expecting both contacts to need locale change, map size is ' + response.contactToLocale.size());
        System.assert(response.qlv.opportunity.billToContact.account.address.country == 'Albania', 'Bill To Country not as expected');
        System.assert(response.qlv.opportunity.sellToContact.account.address.country == 'United States', 'Sell To Country not as expected');
        System.assertEquals('GB987654321',response.qlv.opportunity.sellToContact.account.vatRegistrationNumber,'Vat Number should have been set');
        System.assertEquals('GB123499999',response.qlv.opportunity.billToContact.account.vatRegistrationNumber,'Vat Number should have been set');        
    }

    @isTest
    static void testUpdateContactLocales() {
        User ug = [SELECT Id FROM User WHERE UserName='inagroup@anywhere.com'];
        Locale__c gbloc = [SELECT Id, Name, Country__c FROM Locale__c WHERE Name='en_GB'];
        Locale__c usloc = [SELECT Id, Name, Country__c FROM Locale__c WHERE Name='en_US'];
        Contact cb = [SELECT Id, Locale__c, Name FROM Contact WHERE FirstName='Test2'];
        Contact cs = [SELECT Id, Locale__c, Name FROM Contact WHERE FirstName='Test3'];
        System.assert(cb.Locale__c == null, 'Unexpected value for Bill To Contact Locale ' + cb.Locale__c);
        System.assert(cs.Locale__c == gbloc.Id, 'Unexpected value for Sell To Contact Locale ' + cs.Locale__c);
        Map<Id,Id> input = new Map<Id,Id>();
        input.put(cb.Id,gbloc.Id);
        input.put(cs.Id,usLoc.Id);
        Boolean wasProblemUpdating;
        System.runAs(ug) {
            wasProblemUpdating = AssistedSalesController.updateContactLocales(input);
        }
        System.assert(wasProblemUpdating == true, 'Problem not encountered updating locales, was expected though');
        System.assert(cb.Locale__c == null, 'Bill To Contact Locale changed to ' + cb.Locale__c);
        System.assert(cs.Locale__c == gbloc.Id, 'Sell To Contact Locale changed to ' + cs.Locale__c);
        wasProblemUpdating = AssistedSalesController.updateContactLocales(input);
        System.assert(wasProblemUpdating == false, 'Problem encountered updating locales');
        cb = [SELECT Id, Locale__c, Name FROM Contact WHERE FirstName='Test2'];
        cs = [SELECT Id, Locale__c, Name FROM Contact WHERE FirstName='Test3'];
        System.assert(cb.Locale__c == gbloc.Id, 'Unexpected value returned for Bill To Contact Locale ' + cb.Locale__c);
        System.assert(cs.Locale__c == usloc.Id, 'Unexpected value returned for Sell To Contact Locale ' + cs.Locale__c);
    }

    @isTest
    static void testCheckContactData() {
        Account a3 = [SELECT Id, Locale__r.Name, Sales_Office__c, BillingCountryCode FROM Account WHERE Name = 'testAccount3'];
        List<String> badNews = new List<String>();
        QuoteLoginRequestV1.Contact_d con = new QuoteLoginRequestV1.Contact_d();
        badNews = AssistedSalesController.checkContactData('Sell To', con);
        System.assert(badNews != null, 'Contact somehow passed validation');
        con.email = 'blah@blah.com';
        QuoteLoginRequestV1.Address_d add = new QuoteLoginRequestV1.Address_d();
        add.line1 = '15 Credibility Street';
        add.country = 'Togo';
        add.postalCode = 'NNN 000';
        QuoteLoginRequestV1.Account_d acc = new QuoteLoginRequestV1.Account_d();
        acc.address = add;
        acc.id = a3.Id;
        acc.locale = a3.Locale__r.Name;
        acc.salesOffice = a3.Sales_Office__c;
        acc.countryCode = a3.BillingCountryCode;
        con.account = acc;
        badNews = AssistedSalesController.checkContactData('Sell To', con);
        System.assert(badNews.isEmpty(), 'Contact failed validation with errors ' + badNews);
    }

    @isTest
    static void testUpdateMissedAccountInfo() {
        Opportunity op = [SELECT Id, Name,AccountId FROM Opportunity WHERE Name='testOpp4'];
        String locGB = [SELECT Id, Name, Country__c FROM Locale__c WHERE Name='en_GB'].Name;
        String salOfc = 'Dublin CBC';               
        List<SObject> objLst = AssistedSalesController.updateMissedAccountInfo(op.Id,locGB,salOfc);
        Account acc = [select id,sales_office__c, Locale__r.Name,Locale_Billing_CC__c from account where id =:objLst[0].id];
        System.assertEquals('en_GB',acc.Locale__r.Name);
        System.assertEquals('Dublin CBC',acc.Sales_Office__c);
        System.assertEquals(Account.sObjectType,objLst[0].getsObjectType());
        System.assertEquals('GB', acc.Locale_Billing_CC__c,'expected the account Locale_Billing_CC__c to be updated too');
    }

    @isTest
    static void testUpdateMissedContactRoleInfo() {
        Opportunity op = [SELECT Id, Name,AccountId FROM Opportunity WHERE Name='testOpp4'];              
        List<SObject> objLst = AssistedSalesController.updateMissedContactRoleInfo(op.Id);
        List<OpportunityContactRole> ocrLst = [SELECT ContactId, Role, Opportunity.Name FROM OpportunityContactRole WHERE OpportunityId = :op.Id AND Role IN ('Sell To','Bill To')];
        System.assertEquals('Sell To',ocrLst[0].Role);
        System.assertEquals('Bill To',ocrLst[1].Role);
        System.assertEquals(OpportunityContactRole.sObjectType,objLst[0].getsObjectType());
        System.assertEquals(2, ocrLst.size(),'expected that two contact roles will get created');
    }
    
    @isTest
    static void testGetTokenOK() {
        TestGenericServiceInvoker testInvoker = new TestGenericServiceInvoker();
        testInvoker.responseJSON = '{    "quoteToken": "quote-abcdefghijk1234567",    "refreshToken": "refreh-abcdefghijk1234567"}';
        QuoteLoginRequestor.invoker = testInvoker;
        String request = JSON.serialize(new QuoteLoginRequestV1());
        // AssistedSalesController.getTokens(null,'wherever',false); this will cause exception
        AssistedSalesController.getTokens(request,'wherever',false);
    }

    @isTest
    static void testGetTokenNotOK() {
        TestGenericServiceInvoker testInvoker = new TestGenericServiceInvoker();
        testInvoker.responseJSON = 'mayday';
        QuoteLoginRequestor.invoker = testInvoker;
        String request = JSON.serialize(new QuoteLoginRequestV1());
        
        try {
            AssistedSalesController.getTokens(request,'wherever',true);
            System.assert(false,'This code should not be reached after bad tokens request');
        } catch (AuraHandledException ae) {
            System.debug('Exception as expected in tokens request ' + ae.getMessage());
        }
    }

    private static Boolean hasError (String errorOfInterest, List<String> errorList) {
        for (String s : errorList) {
            if (s.equals(errorOfInterest)) {
                return true;
            }
        }
        return false;
    }
    
    public class TestGenericServiceInvoker extends GenericServiceInvoker {
        public Boolean isErroring = false;
        public String responseJSON;
        
        public override IService_Output_Master call(String jsonPayload){
            IService_Output_Master output;
            
            if (!isErroring) {
                QuoteLogin quoteLogin = (QuoteLogin)JSON.deserialize(responseJSON, QuoteLogin.class);
                quoteLogin.setState('SUCCESS');
                output = quoteLogin;
            } else {
                output = new StringOutputV1();
                output.setState('FAIL');
                output.setErrorMessage('failed to login');
            }
            
            return output;
        }
    }
}