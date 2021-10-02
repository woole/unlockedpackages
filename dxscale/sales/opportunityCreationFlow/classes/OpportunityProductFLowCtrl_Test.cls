@isTest
public with sharing class OpportunityProductFLowCtrl_Test {
	@testsetup static void setup() {
	
        	 Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser  = new User(Alias = 'standt', Email='callitemtst@testorg.com',
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                                  LocaleSidKey='en_US', ProfileId = p.Id, FederationIdentifier ='callitemtst@testorg.com',
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='callitemtst@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);  
		
	}

	@IsTest
	static void createOpportunityLineItems() {
        
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
            
        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street');
		insert acc;

		//Insert Opportunity
		//1084 Added Why We Lost for Validation
		Opportunity opp = new Opportunity(AccountId = acc.Id, name = 'SelectPriceBookLTCtrl_Test',
										StageName = Label.Opportunity_Sales_Stages_Closed_Won,
										Why_We_Lost__c = 'Won from Competitor',
										CloseDate = Date.today());
		insert opp;

		Product2 product = new Product2(name='test');
		insert product;
        
		List<Opportunity> oppList = [select id,closedate from Opportunity where name = 'SelectPriceBookLTCtrl_Test'];
		Opportunity opp1 = oppList[0];
		List<Product2> productList = [select id, Name from Product2 where name = 'Test'];
		Product2 product1 = productList[0];

		PricebookEntry pbe = new PricebookEntry();
		pbe.Pricebook2Id = Test.getStandardPricebookId();
		pbe.Product2Id = product.id;
		pbe.UnitPrice = 1020;
		
		pbe.IsActive = true;
		insert pbe;

		OpportunityProductFLowCtrl.Product fip = new OpportunityProductFLowCtrl.Product();
		fip.id = pbe.id;
		fip.productName = product.name;
		fip.commercialisationMode = 'Perpetual';
		//fip.productDeployment = 'Cloud';
		fip.quantity = 100;
		fip.nonRecurringRevenue = '100';
		fip.monthlyRecurringRevenue = '200';

		List<OpportunityProductFLowCtrl.Product> listfip = new List<OpportunityProductFLowCtrl.Product>();
		listfip.add(fip);

		OpportunityProductFLowCtrl.FlowInputs fis = new OpportunityProductFLowCtrl.FlowInputs ();
		fis.opportunityId = opp.id;
		fis.jsonString = JSON.serialize(listfip);
		List<OpportunityProductFLowCtrl.FlowInputs> listFlowInputs = new List<OpportunityProductFLowCtrl.FlowInputs>();
		listFlowInputs.add(fis);

		Test.startTest();
			OpportunityProductFLowCtrl.createOpportunityLineItems(listFlowInputs);
		Test.stopTest();

		List<OpportunityLineItem> listoli = [select id from OpportunityLineItem where opportunityId = :opp.id];
		System.assertEquals(1, listoli.size());
        }
	}

	@IsTest
	static void createOpportunityLineItemsWithEmptyValues() {
        
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){

        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street');
		insert acc;

		//Insert Opportunity
		//1084 Added Why We Lost for Validation
		Opportunity opp = new Opportunity(AccountId = acc.Id, name = 'SelectPriceBookLTCtrl_Test',
										StageName = Label.Opportunity_Sales_Stages_Closed_Won,
										Why_We_Lost__c = 'Won from Competitor',
										CloseDate = Date.today());
		insert opp;

		Product2 product = new Product2(name='test');
		insert product;
        
		List<Opportunity> oppList = [select id,closedate from Opportunity where name = 'SelectPriceBookLTCtrl_Test'];
		Opportunity opp2 = oppList[0];
		List<Product2> productList = [select id, Name from Product2 where name = 'Test'];
		Product2 product2 = productList[0];

		PricebookEntry pbe = new PricebookEntry();
		pbe.Pricebook2Id = Test.getStandardPricebookId();
		pbe.Product2Id = product.id;
		pbe.UnitPrice = 1020;
		
		pbe.IsActive = true;
		insert pbe;

		OpportunityProductFLowCtrl.Product fip = new OpportunityProductFLowCtrl.Product();
		fip.id = pbe.id;
		fip.productName = product.name;
		fip.commercialisationMode = 'Perpetual';
		//fip.productDeployment = 'Cloud';
		fip.quantity = 100;
		fip.nonRecurringRevenue = '';
		fip.monthlyRecurringRevenue = '';

		List<OpportunityProductFLowCtrl.Product> listfip = new List<OpportunityProductFLowCtrl.Product>();
		listfip.add(fip);

		OpportunityProductFLowCtrl.FlowInputs fis = new OpportunityProductFLowCtrl.FlowInputs ();
		fis.opportunityId = opp.id;
		fis.jsonString = JSON.serialize(listfip);
		List<OpportunityProductFLowCtrl.FlowInputs> listFlowInputs = new List<OpportunityProductFLowCtrl.FlowInputs>();
		listFlowInputs.add(fis);

		Test.startTest();
			OpportunityProductFLowCtrl.createOpportunityLineItems(listFlowInputs);
		Test.stopTest();

		List<OpportunityLineItem> listoli = [select id,UnitPrice,Monthly_Recurring_Revenue__c from OpportunityLineItem where opportunityId = :opp.id];
		System.assertEquals(1, listoli.size());
		System.assertEquals(0, listoli[0].UnitPrice);
		System.assertEquals(0, listoli[0].Monthly_Recurring_Revenue__c);
        }
	}

	@IsTest
	static void createOpportunityLineItemsWithNulls() {
	
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
            
        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street');
		insert acc;

		//Insert Opportunity
		//1084 Added Why We Lost for Validation
		Opportunity opp = new Opportunity(AccountId = acc.Id, name = 'SelectPriceBookLTCtrl_Test',
										StageName = Label.Opportunity_Sales_Stages_Closed_Won,
										Why_We_Lost__c = 'Won from Competitor',
										CloseDate = Date.today());
		insert opp;

		Product2 product = new Product2(name='test');
		insert product;
        
		List<Opportunity> oppList = [select id,closedate from Opportunity where name = 'SelectPriceBookLTCtrl_Test'];
		Opportunity opp3 = oppList[0];
		List<Product2> productList = [select id, Name from Product2 where name = 'Test'];
		Product2 product3 = productList[0];

		PricebookEntry pbe = new PricebookEntry();
		pbe.Pricebook2Id = Test.getStandardPricebookId();
		pbe.Product2Id = product.id;
		pbe.UnitPrice = 1020;
		
		pbe.IsActive = true;
		insert pbe;

		OpportunityProductFLowCtrl.Product fip = new OpportunityProductFLowCtrl.Product();
		fip.id = pbe.id;
		fip.productName = product.name;
		fip.commercialisationMode = 'Perpetual';
		//fip.productDeployment = 'Cloud';
		fip.quantity = 100;
		fip.nonRecurringRevenue = null;
		fip.monthlyRecurringRevenue =null;

		List<OpportunityProductFLowCtrl.Product> listfip = new List<OpportunityProductFLowCtrl.Product>();
		listfip.add(fip);

		OpportunityProductFLowCtrl.FlowInputs fis = new OpportunityProductFLowCtrl.FlowInputs ();
		fis.opportunityId = opp.id;
		fis.jsonString = JSON.serialize(listfip);
		List<OpportunityProductFLowCtrl.FlowInputs> listFlowInputs = new List<OpportunityProductFLowCtrl.FlowInputs>();
		listFlowInputs.add(fis);

		Test.startTest();
			OpportunityProductFLowCtrl.createOpportunityLineItems(listFlowInputs);
		Test.stopTest();

		List<OpportunityLineItem> listoli = [select id,Monthly_Recurring_Revenue__c,UnitPrice from OpportunityLineItem where opportunityId = :opp.id];
		System.assertEquals(1, listoli.size());
		System.assertEquals(0, listoli[0].UnitPrice);
		System.assertEquals(0, listoli[0].Monthly_Recurring_Revenue__c);
	}
    }
}