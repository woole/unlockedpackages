/**
* Lightning controller class that searches against PricebookEntry for products.
*/
public with sharing class SearchProductsLTCtrl {
 

    /**
     * @description  Fetch all the Matching 'Products' (PriceBookEntry) the the supplied
     * @param searchKeyWord String to match
     * @param pricebookId the Proce Book
     * @param excludeItemsList ensures the results don't return something already selected
     * @param currencyISOCode the currency code to filter the pricebook
     * @returns List<PricebookEntry>
     */
    @AuraEnabled
    public static List <PricebookEntry> fetchLookUpValues(String searchKeyWord,String pricebookId, List<SObject> excludeItemsList, String currencyISOCode) {
        String searchKey = '%' + searchKeyWord + '%';
        //these are the list of already selected products. no need to return
        List<String> excludedSearchItems = new List<String>();
        if(excludeItemsList != null && !excludeItemsList.isEmpty()){
            for(SObject item : ExcludeitemsList ){
                excludedSearchItems.add(item.id);
            }

        }

        List<PricebookEntry> priceBookEntryList = [SELECT Id, Name,Product2Id,Product2.Name from 
                    PricebookEntry where Pricebook2Id =:pricebookId AND Name LIKE: searchKey AND Id NOT IN : excludedSearchItems 
                    AND CurrencyIsoCode = :currencyISOCode AND IsActive = true order by createdDate DESC limit 10];
               
        return priceBookEntryList;
    }
    

}