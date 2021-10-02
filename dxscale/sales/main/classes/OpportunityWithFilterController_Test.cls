@isTest
public with sharing class OpportunityWithFilterController_Test {
    
    @TestSetup
    static void makeData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser  = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='opprealtedlistuser@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);        
        System.runAs(adminUser){
            Account ac = new Account(); 
            ac.Name='Test Account';
            ac.Type='Partner';
            ac.Phone='9876556789';
            insert ac;

            List<Opportunity> newOppList = new List<Opportunity>();
            
            Opportunity opp=new Opportunity();
            opp.Name='TestDiscovery';
            opp.AccountId=ac.Id;
            opp.Total_Contract_Value_TCV_forecast__c=4000;
            opp.StageName='Discovery';
            opp.Type='Upsell';
            opp.Product_Allocation_Group__c='Training';
            opp.Product__c='Accounting';
            opp.Roll_up_of_Opp_Products__c='test';
            opp.CloseDate=Date.newInstance(2022, 12, 31);
            newOppList.add(opp);
            
            Opportunity opp1=new Opportunity();
            opp1.Name='TestQualify';
            opp1.AccountId=ac.Id;
            opp1.Total_Contract_Value_TCV_forecast__c=4000;
            opp1.StageName='Qualify';
            opp1.Type='Upsell';
            opp1.Product_Allocation_Group__c='Training';
            opp1.Product__c='Accounting';
            opp1.Roll_up_of_Opp_Products__c='test';
            opp1.CloseDate=Date.newInstance(2022, 12, 31);
            newOppList.add(opp1);
            
            Opportunity opp2=new Opportunity();
            opp2.Name='TestClosedLost';
            opp2.AccountId=ac.Id;
            opp2.Total_Contract_Value_TCV_forecast__c=4000;
            opp2.StageName='Closed Lost';
            opp2.Type='Upsell';
            opp2.Product_Allocation_Group__c='Training';
            opp2.Product__c='Accounting';
            opp2.Roll_up_of_Opp_Products__c='test';
            opp2.CloseDate=Date.newInstance(2021, 06, 30);
            newOppList.add(opp2);
            
            Opportunity opp3=new Opportunity();
            opp3.Name='TestClosedWon';
            opp3.AccountId=ac.Id;
            opp3.Total_Contract_Value_TCV_forecast__c=4000;
            opp3.StageName='Closed Won';
            opp3.Type='Upsell';
            opp3.Product_Allocation_Group__c='Training';
            opp3.Product__c='Accounting';
            opp3.Roll_up_of_Opp_Products__c='test';
            opp3.CloseDate=Date.newInstance(2021, 06, 30);
            newOppList.add(opp3);

            insert newOppList;
        }
    }
    
    @isTest
    public static void testClosedWonOpportunities() {
        Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where UserName = 'opprealtedlistuser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){

        Account accountId = [Select Id from Account where Name=:'Test Account' Limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> closedWonOppList = [Select Id from Opportunity where StageName='Closed Won'];
        oppList=OpportunityWithFilterController.getClosedWonOpportunities(accountId.Id);
        System.assertEquals(oppList.size(), closedWonOppList.size());
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testClosedLostOpportunities() {
        Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where UserName = 'opprealtedlistuser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
        Account accountId = [Select Id from Account where Name=:'Test Account' Limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> closedLostOppList = [Select Id from Opportunity where StageName='Closed Lost'];
        oppList=OpportunityWithFilterController.getClosedLostOpportunities(accountId.Id);
        System.assertEquals(oppList.size(), closedLostOppList.size(),'Closed Lost Opp List');
        }
        Test.stopTest();
     }
    
    @isTest
    public static void testOpenOpportunities() {
        Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where UserName = 'opprealtedlistuser@testorg.com' Limit 1 ];
        
        System.runAs(adminUser){
        Account accountId = [Select Id from Account where Name=:'Test Account' Limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> openOppList = [Select Id from Opportunity where StageName=:'Qualify' or StageName=:'Discovery' or StageName=:'Confirming Value' or StageName=:'Selection'];
       oppList=OpportunityWithFilterController.getOpenOpportunities(accountId.Id);
        System.assertEquals(oppList.size(), openOppList.size(),'open opp list');  
        }
        Test.stopTest(); 
         
    }
    
    @isTest
    public static void testAllOpportunities() {
        Test.startTest();
        User adminUser =[select Id, Email, FederationIdentifier from User where UserName = 'opprealtedlistuser@testorg.com' Limit 1 ];
        System.runAs(adminUser){
        Account accountId = [Select Id from Account where Name=:'Test Account' Limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> allOppList = [Select Id from Opportunity];
        oppList=OpportunityWithFilterController.getAllOpportunities(accountId.Id);
        System.assertEquals(oppList.size(), allOppList.size(),'All Opp List'); 
        }
        Test.stopTest();
    }
}