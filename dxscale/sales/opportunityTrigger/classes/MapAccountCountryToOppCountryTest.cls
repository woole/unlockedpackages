/*Created By: Adam Annony*/
@isTest
public class MapAccountCountryToOppCountryTest {
    
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class   
    private static String zuoraId2 = '2c92c0f84dfff49f014e021c79b82bb7';
    
    @testsetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User adminUser  = new User(Alias = 'standt', Email='callitemtst@testorg.com',
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                                  LocaleSidKey='en_US', ProfileId = p.Id, FederationIdentifier ='callitemtst@testorg.com',
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='callitemtst@testorg.com');
        insert adminUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);       
          
    }
    
    Static testmethod void MapAccountCountryToOppCountryTest(){
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
        
        //Testing if Billing Address is the only thing populated
        Account a = new Account(Name = 'TestAccount', Type = 'Customer',
                                Phone = '1111111222', BillingCountry = 'Albania', BillingStreet = '123 abc', 
                                BillingCity = 'testCity', BillingPostalCode = '12345');
        
        insert a;
        Contact con = new Contact(FirstName='firstname', LastName='lastName', email='testcaon@testcon.com', 
                                  AccountId = a.Id, HasOptedOutOfEmail = false);
        insert con;
        
        Opportunity o = new Opportunity(AccountId = a.Id, Name = 'TestOpportunity', 
                                        StageName = Label.Opportunity_Sales_Stages_Stage1, CloseDate = Date.today());
        
        insert o;
        o = [select id, Country__c,Sage_Region__c from opportunity where id =: o.Id limit 1];

        //Testing if Shipping Address is the only thing populated
        Account a2 = new Account(Name = 'TestAccount2', Type = 'Customer',
                                Phone = '1111111222', ShippingCountry = 'Albania', ShippingStreet = '123 abc', 
                                ShippingCity = 'testCity', ShippingPostalCode = '12345');
        
        insert a2;
        
        Opportunity o2 = new Opportunity(AccountId = a2.Id, Name = 'TestOpportunity2', 
                                        StageName = Label.Opportunity_Sales_Stages_Stage1, CloseDate = Date.today());
         
        insert o2;
        o2 = [select id, Country__c,Sage_Region__c from opportunity where id =: o2.Id limit 1];

        //updateRegionOnOpportunity test 
        Account a3 = new Account(Name = 'SampleAccount', Type = 'Customer',
                                Phone = '1111111222', BillingCountry = 'Venezuela, Bolivarian Republic of', BillingStreet = '123 abc', 
                                BillingCity = 'testCity', BillingPostalCode = '12345', Sales_Office__c = 'none');
        
        insert a3;

        Opportunity o3 = new Opportunity(AccountId = a3.Id, Name = 'TestOpportunity3', 
                                        StageName = Label.Opportunity_Sales_Stages_Stage1, CloseDate = Date.today());
        
        insert o3;
        Opportunity o4 = [select id, Country__c,Sage_Region__c from opportunity where id =: o3.Id limit 1];
        }
    }
    
    static testMethod void accountChangeonOppTest(){
        User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        System.runAs(adminUser){
        
        
        Locale__c loc = 
        SalesTestUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        Account acc = SalesTestUtility.createAccount(loc.Id);
        Account acc1 = SalesTestUtility.createAccount(loc.Id);
        Contact con = SalesTestUtility.createContact(acc.Id);
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'ZuoraQuoteOpportunity', 
                                        StageName = Label.Opportunity_Sales_Stages_Stage1, CloseDate = Date.today());
        insert opp;
        
        opp.AccountID = acc1.Id;
        try{
            update opp;
        } catch(Exception e){
            System.debug('Exception' +e.getMessage());
        }
    }
}
    static testMethod void oppsWithQuotesTest(){
            User adminUser =[select Id, Email, FederationIdentifier from User where Email='callitemtst@testorg.com' Limit 1 ];
        	System.runAs(adminUser){
            
            MapAccountCountryToOppCountry ob=new MapAccountCountryToOppCountry();
            Map<ID,Opportunity> m1=new Map<ID,Opportunity>();
            List<Opportunity> newOppList=new List<Opportunity>();
            Map<ID,Opportunity> newOppMap=new Map<ID,Opportunity>();
            
            Account a3 = new Account(Name = 'SampleAccount', Type = 'Customer',
                                Phone = '1111111222', BillingCountry = 'Venezuela, Bolivarian Republic of', BillingStreet = '123 abc', 
                                BillingCity = 'testCity', BillingPostalCode = '12345', Sales_Office__c = 'none');
        
        	insert a3;
            
            Opportunity opp = new Opportunity(AccountId = a3.Id, Name = 'TestOpportunity3', 
                                        StageName = Label.Opportunity_Sales_Stages_Stage1, CloseDate = Date.today());
        
        	insert opp;
                
            m1.put(opp.Id,opp);
            newOpplist.add(opp);
            newOppMap.put(opp.Id,opp);
            
			ob.oppsWithQuotes(m1,newOpplist,newOppMap);
            } 
}
}