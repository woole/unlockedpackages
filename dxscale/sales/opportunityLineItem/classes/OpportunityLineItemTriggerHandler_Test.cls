@isTest
public without sharing class OpportunityLineItemTriggerHandler_Test{
    
    @TestSetup 
    static void makeData() {
        Account acc = new Account(Name='test account', Sales_Office__c='Dublin CBC', Type='Customer', Industry='Automotive', 
                                  BillingCountry='United Kingdom', BillingCity='Blyth', BillingStreet='101 Salisbury Street');
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(AccountId=acc.Id, name='test Opp 1', StageName=Label.Opportunity_Sales_Stages_Stage1,
                                           CloseDate=Date.today(), Lead_Source__c='Marketing');
        oppList.add(opp1);
        Opportunity opp2 = new Opportunity(AccountId=acc.Id, name='test Opp 2', StageName=Label.Opportunity_Sales_Stages_Stage1,
                                           CloseDate=Date.today(), Lead_Source__c='Marketing');
        oppList.add(opp2);
        insert oppList;

        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2(Name='Product X', ProductCode='Pro-X', isActive=true);
        prodList.add(prod1);
        Product2 prod2 = new Product2(Name='Product Y', ProductCode='Pro-Y', isActive=true);
        prodList.add(prod2);
        insert prodList;

        List<PriceBookEntry> entries = new List<PriceBookEntry>();
        Id pricebookId = Test.getStandardPricebookId();
        PriceBookEntry pbEntry1 = new PriceBookEntry(Pricebook2Id=pricebookId, Product2Id=prod1.Id, UnitPrice=100.00, IsActive=true);
        entries.add(pbEntry1);
        PriceBookEntry pbEntry2 = new PriceBookEntry(Pricebook2Id=pricebookId, Product2Id=prod2.Id, UnitPrice=99.00, IsActive=true);
        entries.add(pbEntry2);
        insert entries;        
    }
    
    // Test method to cover test cases for EAD-1311
    static testMethod void testPopulateProductNamesOnOpportunity() {
        Opportunity op1 = [SELECT Id FROM Opportunity WHERE Name = 'test Opp 1' LIMIT 1];
        Opportunity op2 = [SELECT Id FROM Opportunity WHERE Name = 'test Opp 2' LIMIT 1];
        Product2 p1 = [SELECT Id FROM Product2 WHERE Name = 'Product X' LIMIT 1];
        Product2 p2 = [SELECT Id FROM Product2 WHERE Name = 'Product Y' LIMIT 1];
        PricebookEntry pbe1 = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id = :p1.Id LIMIT 1];
        PricebookEntry pbe2 = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id = :p2.Id LIMIT 1];
        
    	Test.startTest();
		// INSERTIONS
		List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
		OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=op1.Id, Quantity=5, PricebookEntryId=pbe1.Id, 
                                                       	   TotalPrice=5*pbe1.UnitPrice, Product2Id=p1.Id, 
                                                           Commercialisation_Mode__c='Subscription');
        lineItems.add(oli1);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=op1.Id, Quantity=10, PricebookEntryId=pbe2.Id, 
                                                       	   TotalPrice=10*pbe1.UnitPrice, Product2Id=p2.Id, 
                                                           Commercialisation_Mode__c='Subscription');
        lineItems.add(oli2);
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId=op2.Id, Quantity=100, PricebookEntryId=pbe2.Id, 
                                                       	   TotalPrice=100*pbe1.UnitPrice, Product2Id=p2.Id, 
                                                           Commercialisation_Mode__c='Subscription');
        lineItems.add(oli3);
        insert lineItems;
		// CHECK PRODUCT NAME ROLL UPS
        Opportunity retOpp1 = [SELECT Id, Roll_up_of_Opp_Products__c FROM Opportunity WHERE Id = :op1.Id LIMIT 1];
        Opportunity retOpp2 = [SELECT Id, Roll_up_of_Opp_Products__c FROM Opportunity WHERE Id = :op2.Id LIMIT 1];
        System.assert(retOpp1.Roll_up_of_Opp_Products__c.contains('Product X'), 'Product X not found in Opportunity Product roll-up');
        System.assert(retOpp1.Roll_up_of_Opp_Products__c.contains('Product Y'), 'Product Y not found in Opportunity Product roll-up');
        System.assert(retOpp1.Roll_up_of_Opp_Products__c.contains(','), 'Comma not found in Opportunity Product roll-up');
        System.assert(retOpp2.Roll_up_of_Opp_Products__c == 'Product Y', 'Opportunity Product roll-up should be Product Y');
        // UPDATES
        lineItems = new List<OpportunityLineItem>();
        oli2.Commercialisation_Mode__c='Perpetual';
        lineItems.add(oli2);
        oli3.Commercialisation_Mode__c='Perpetual';
        lineItems.add(oli3);
        update lineItems;
        // CHECK PRODUCT NAME ROLL UPS
        retOpp2 = [SELECT Id, Roll_up_of_Opp_Products__c FROM Opportunity WHERE Id = :op2.Id LIMIT 1];
        System.assert(retOpp2.Roll_up_of_Opp_Products__c == 'Product Y', 'Opportunity Product roll-up should still be Product Y');
        // DELETIONS
        lineItems = new List<OpportunityLineItem>();
        lineItems.add(oli2);
        lineItems.add(oli3);
        delete lineItems;
        // CHECK PRODUCT NAME ROLL UPS
        retOpp1 = [SELECT Id, Roll_up_of_Opp_Products__c FROM Opportunity WHERE Id = :op1.Id LIMIT 1];
        retOpp2 = [SELECT Id, Roll_up_of_Opp_Products__c FROM Opportunity WHERE Id = :op2.Id LIMIT 1];
        System.assert(retOpp1.Roll_up_of_Opp_Products__c == 'Product X', 'Opportunity Product roll-up should be Product X after deletion');
        System.assert(retOpp2.Roll_up_of_Opp_Products__c == null, 'Opp. Product roll-up should be null after deletion, but is ' + retOpp2.Roll_up_of_Opp_Products__c);
        Test.stopTest();
        
        System.debug('Number of SOQL Queries run during test: ' + Limits.getQueries());
    }
}