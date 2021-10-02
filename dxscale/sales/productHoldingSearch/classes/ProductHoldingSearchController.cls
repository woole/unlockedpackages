/*
 * ProductHoldingSearchController
 * ------------------------------
 * Used by the ProductHoldingSearch component which retrieves external Product Holding records 
 * and associated Account data for a given serial number
 */
public with sharing class ProductHoldingSearchController {
	@AuraEnabled
    public static List<ProductHoldingAccount> searchForXProductHoldings(String searchText, Integer rowsToLoad) {
        String searchTextWild = searchText + '%';
        Set<Id> accountsToRetrieve = new Set<Id>();
        List<VW_Connect_ProductHoldings__x> holdings = new List<VW_Connect_ProductHoldings__x>();
        
        if (!mockProdHoldingResponse.isEmpty()) {
            // We are running in test mode, external objects can't be retrieved easily during test so use mock list
            holdings = mockProdHoldingResponse;
        } else {
        	holdings = [SELECT SerialNumber__c, SalesforceAccountId__c
                        FROM VW_Connect_ProductHoldings__x
                        WHERE SerialNumber__c LIKE :searchTextWild
                        AND SalesforceAccountId__c != null
                        LIMIT :Integer.valueOf(rowsToLoad)];
        }
        for (VW_Connect_ProductHoldings__x ph : holdings) {
            accountsToRetrieve.add(ph.SalesforceAccountId__c);
        }
        Map<Id,Account> accounts = new Map<Id,Account>();
        if (!accountsToRetrieve.isEmpty()) {
        	accounts = new Map<Id,Account>([SELECT Id, Name, Customer_Type__c, BillingStreet, BillingCity, BillingPostalCode
                                            FROM Account
                                            WHERE Id IN :accountsToRetrieve]);
        }
        List<ProductHoldingAccount> phas = new List<ProductHoldingAccount>();
        for (VW_Connect_ProductHoldings__x ph : holdings) {
        	ProductHoldingAccount pha = new ProductHoldingAccount();
            pha.SerialNumber = ph.SerialNumber__c;
            pha.AccountId = ph.SalesforceAccountId__c;
            Account temp = new Account();
            temp = accounts.get(pha.AccountId);
            // check Salesforce Account Id is good - it may be present on the Product Holding record but out of date
            if (temp != null) { 
                pha.AccountName = temp.Name;
                pha.AccountCustomerType = temp.Customer_Type__c;
                pha.AccountStreet = temp.BillingStreet;
                pha.AccountCity = temp.BillingCity;
                pha.AccountPostCode = temp.BillingPostalCode;
                phas.add(pha);
            }
        }
        return phas;
    } 
    
    /**
     * For supporting Testing of external objects - we need to mock out the response
     */
    @TestVisible 
    private static List<VW_Connect_ProductHoldings__x> mockProdHoldingResponse = new List<VW_Connect_ProductHoldings__x>();
    
    /**
     * Class used to represent search results from Product Holdings and associated Account objects
     */
    public class ProductHoldingAccount {
        @AuraEnabled public String SerialNumber { get; set; }
        @AuraEnabled public Id AccountId { get; set; }
        @AuraEnabled public String AccountName { get; set; }
        @AuraEnabled public String AccountCustomerType { get; set; }
        @AuraEnabled public String AccountStreet { get; set; }
        @AuraEnabled public String AccountCity { get; set; }
        @AuraEnabled public String AccountPostCode { get; set; }
    }
}