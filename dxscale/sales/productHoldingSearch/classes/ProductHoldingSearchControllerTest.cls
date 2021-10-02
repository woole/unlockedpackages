/*
 * ProductHoldingSearchControllerTest
 * ----------------------------------
 * Tests the ProductHoldingSearchController which retrieves external object records for a given serial number
 */
@IsTest
public class ProductHoldingSearchControllerTest {
    @IsTest
    static void testProductHoldingSearch() {       
        System.debug('ProductHoldingSearchControllerTest: testProductHoldingSearch START');
		// Run search before data mocked up (to increase test coverage)        
        List<ProductHoldingSearchController.ProductHoldingAccount> pHsDoh = ProductHoldingSearchController.searchForXProductHoldings('E123', 20);
        // Set up test data
        Account acc = AccountTestDataFactory.createAccountWithBillingAddressUK('testAccount','Blyth','104A the street');
        
        VW_Connect_ProductHoldings__x ph1 = new VW_Connect_ProductHoldings__x(SerialNumber__c='E123456',
                                                                              SalesforceAccountId__c=acc.Id);
        VW_Connect_ProductHoldings__x ph2 = new VW_Connect_ProductHoldings__x(SerialNumber__c='E123789',
                                                                              SalesforceAccountId__c=acc.Id);
        ProductHoldingSearchController.mockProdHoldingResponse.add(ph1);
        ProductHoldingSearchController.mockProdHoldingResponse.add(ph2); 
        Test.startTest();
        // Make the call with our incomplete search term
        List<ProductHoldingSearchController.ProductHoldingAccount> pHs = ProductHoldingSearchController.searchForXProductHoldings('E123', 5);
        // Check retrieved records
        Test.stopTest();
        System.assertEquals(2,pHs.size(),'expected 2 results');            
        for (ProductHoldingSearchController.ProductHoldingAccount ph : pHs) {
        	System.assertEquals('E123', ph.SerialNumber.substring(0,4),'Should have matched SerialNumber');
            System.assertEquals(acc.Id, ph.AccountId,'Should have matched the account');
            System.assertEquals('Blyth', ph.AccountCity,'Should have matched the account city');
        }                      
        System.debug('ProductHoldingSearchControllerTest: testProductHoldingSearch FINISH');
    }
}