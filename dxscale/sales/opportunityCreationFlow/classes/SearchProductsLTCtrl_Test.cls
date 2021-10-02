/**
* Test class for SearchProductsLTCtrl Lightning controller
*/
@isTest
public with sharing class SearchProductsLTCtrl_Test {
    
    @TestSetup
    static void makeData(){
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
	    update standardPricebook;
        Product2 prod1 = new Product2(Name='abc-100');
        insert prod1;
        Product2 prod2 = new Product2(Name='cde-200');
        insert prod2;
        Product2 prod3 = new Product2(Name='abc-300');
        insert prod3;        
        PricebookEntry gbpEntry = new PricebookEntry(Pricebook2Id=standardPricebook.Id,Product2id=prod1.Id,unitprice=100.0,isActive=true,CurrencyIsoCode='GBP');
        insert gbpEntry;
        /*PricebookEntry eurEntry = new PricebookEntry(Pricebook2Id=standardPricebook.Id,Product2id=prod1.Id,unitprice=120.0,isActive=true,CurrencyIsoCode='EUR');
        insert eurEntry;*/

        PricebookEntry gbpEntry2 = new PricebookEntry(Pricebook2Id=standardPricebook.Id,Product2id=prod2.Id,unitprice=100.0,isActive=true,CurrencyIsoCode='GBP');
        insert gbpEntry2;
        /*PricebookEntry eurEntry2 = new PricebookEntry(Pricebook2Id=standardPricebook.Id,Product2id=prod2.Id,unitprice=120.0,isActive=true,CurrencyIsoCode='EUR');
        insert eurEntry2;

        PricebookEntry eurEntry21 = new PricebookEntry(Pricebook2Id=standardPricebook.Id,Product2id=prod3.Id,unitprice=999.0,isActive=true,CurrencyIsoCode='EUR');
        insert eurEntry21;*/                  

    }
    
    /**
    * Tests that the price books are filtered by keywork and currency
    */
    @isTest 
    public static void testFetchLookUpValues_abcGBP(){
        Test.startTest();
            List<PriceBookEntry> results = SearchProductsLTCtrl.fetchLookUpValues('cde',Test.getStandardPricebookId(), new List<SObject>(), 'GBP');
        Test.stopTest();
        System.assertEquals(1,results.size(),'Should have matched 1 product for GBP cde');
        System.assertEquals('cde-200',results[0].Name,'Product Name should have been cde-200');
    }

    /**
    * Tests that the price books are filtered by currency and supplying no keyworks still returns results
    */
    @isTest 
    public static void testFetchLookUpValues_NoKeywordGBP(){
        Test.startTest();
            List<PriceBookEntry> results = SearchProductsLTCtrl.fetchLookUpValues('',Test.getStandardPricebookId(), new List<SObject>(), 'GBP');
        Test.stopTest();
        System.assertEquals(2,results.size(),'with no search params, should have returned 2 entries for GBP');
    }    

    /**
    * Tests that the price books are filtered by currency and results don't include those excluded
    */
   @isTest 
    public static void testFetchLookUpValues_FilteredKeywordEUR(){
        List<PriceBookEntry> entries = [SELECT Id from PricebookEntry where CurrencyIsoCode = 'EUR' and Name='abc-300'];
        Test.startTest();
            List<PriceBookEntry> results = SearchProductsLTCtrl.fetchLookUpValues('abc',Test.getStandardPricebookId(), entries, 'GBP');
        Test.stopTest();
        System.assertEquals(1,results.size(),'Should have retured one value instead of 2 ');
        System.assertEquals('abc-100',results[0].Name,'Product Name should have been abc-100');
        
    }      

}