@isTest
public with sharing class MakePrimaryPartner_Test {
    @TestSetup
    static void makeData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser  = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='primarypartneruser@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);        
        System.runAs(adminUser){
            List<Account> accList = new List<Account>();
            Account ac = new Account(); 
            ac.Name='Test Account';
            ac.Type='Partner';
            ac.Phone='9876556789';
            accList.add(ac);
            
            Account ac1 = new Account(); 
            ac1.Name='Account 1';
            ac1.Type='Partner';
            ac1.Phone='9876556789';
            accList.add(ac1);
            
            Account ac2 = new Account(); 
            ac2.Name='Account 2';
            ac2.Type='Partner';
            ac2.Phone='9876556789';
            accList.add(ac2);
            
            insert accList;

            Opportunity opp=new Opportunity();
            opp.Name='TestPrimePartner';
            opp.AccountId=accList[0].Id;
            opp.StageName='Discovery';
            opp.CloseDate=Date.newInstance(2022, 12, 31);
            insert opp;
            
            List<OpportunityPartner> oppPartner = new List<OpportunityPartner>();
            OpportunityPartner oppPart1 = new OpportunityPartner();
			oppPart1.OpportunityId = opp.Id;
			oppPart1.AccountToId = accList[1].Id;
			oppPart1.Role='Agent';
			oppPart1.IsPrimary=true;
			oppPartner.add(oppPart1);
            
            OpportunityPartner oppPart2 = new OpportunityPartner();
			oppPart2.OpportunityId = opp.Id;
			oppPart2.AccountToId = accList[2].Id;
			oppPart2.Role='Developer';
			oppPart2.IsPrimary=false;
			oppPartner.add(oppPart2);
            
            insert oppPartner;
        }
    }
    
    @isTest
    public static void testgetAllSecondaryOpportunityPartners() {
        Test.startTest();
        User adminUser =[select Id, Email from User where UserName = 'primarypartneruser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
        	Account account1 = [Select Id from Account where Name=:'Test Account' Limit 1];
            Id accId = account1.Id;
            Opportunity opp = [Select Id from Opportunity where Name=:'TestPrimePartner' Limit 1];
			Id oppId = opp.Id;
			            
        	List<OpportunityPartner> oppPartnerList = new List<OpportunityPartner>();
        	List<OpportunityPartner> allSecondaryPartners = [SELECT Id, OpportunityId FROM OpportunityPartner WHERE OpportunityId =: oppId AND (AccountTo.Id !=: accId AND IsPrimary !=: true)];
        	oppPartnerList=MakePrimaryPartner.getAllSecondaryOpportunityPartners(oppId);
        	System.assertEquals(oppPartnerList.size(), allSecondaryPartners.size());
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testgetPrimaryOpportunityPartner() {
        Test.startTest();
        User adminUser =[select Id, Email from User where UserName = 'primarypartneruser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
        	Account account1 = [Select Id from Account where Name=:'Test Account' Limit 1];
            Id accId = account1.Id;
            Opportunity opp = [Select Id from Opportunity where Name=:'TestPrimePartner' Limit 1];
			Id oppId = opp.Id;
			            
        	List<OpportunityPartner> oppPartnerList = new List<OpportunityPartner>();
        	List<OpportunityPartner> primayPartner = [SELECT Id, OpportunityId, IsPrimary, AccountToId, AccountTo.Id, AccountTo.Name, Role FROM OpportunityPartner WHERE OpportunityId =: oppId AND (IsPrimary =: true AND AccountTo.Id !=: accId)];
        	oppPartnerList=MakePrimaryPartner.getPrimaryOpportunityPartner(oppId);
        	System.assertEquals(oppPartnerList[0], primayPartner[0]);
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testChangePrimaryPartner() {
        Test.startTest();
        User adminUser =[select Id, Email from User where UserName = 'primarypartneruser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
            Opportunity opp = [Select Id from Opportunity where Name=:'TestPrimePartner' Limit 1];
			Id oppId = opp.Id;  
            OpportunityPartner oppPart = [Select Id, Role, IsPrimary from OpportunityPartner where OpportunityId=: oppId and (IsPrimary!=true and Role =:'Developer') LIMIT 1];
            Boolean afterfunction = true;
        	MakePrimaryPartner.changePrimaryPartner(oppPart.Id);
            OpportunityPartner newOppPart = [Select Id, Role, IsPrimary from OpportunityPartner where OpportunityId=: oppId and Role =:'Developer' LIMIT 1];
        	System.assertEquals(newOppPart.IsPrimary,afterfunction);
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testDeletePartner() {
        Test.startTest();
        User adminUser =[select Id, Email from User where UserName = 'primarypartneruser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
            Account account1 = [Select Id from Account where Name=:'Test Account' Limit 1];
            Id accId = account1.Id;
            Opportunity opp = [Select Id from Opportunity where Name=:'TestPrimePartner' Limit 1];
			Id oppId = opp.Id;  
            List<OpportunityPartner> beforeDeletion = [Select Id, Role, IsPrimary from OpportunityPartner where OpportunityId=: oppId and AccountToId !=: accId];
            OpportunityPartner oppPart = [Select Id, Role, IsPrimary from OpportunityPartner where OpportunityId=: oppId and Role =:'Developer' LIMIT 1];
        	MakePrimaryPartner.deletePartner(oppPart.Id);
            List<OpportunityPartner> afterDeletion = [Select Id, Role, IsPrimary from OpportunityPartner where OpportunityId=: oppId and AccountToId !=: accId];
        	System.assertEquals(beforeDeletion.size()-1,afterDeletion.size());
        }
        Test.stopTest();
        
    }
}