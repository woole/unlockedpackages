@isTest
public class PriceBookTestDataFactory {
    
    
  
    public static PriceBook2 createPriceBook2(String name, String currencyCode){
        PriceBook2 customPriceBookId = new PriceBook2(
            Name = name,
            IsActive = true,
            CurrencyIsoCode = currencyCode
        );
        insert customPriceBookId;
        return customPriceBookId;
    }

    public static Product2 createProduct(String name, String code){
        Product2 product = new Product2(
                Name = name, 
                ProductCode = code, 
                isActive = true);
        insert product;
        return product;
    }    

    public static PricebookEntry createPriceBookEntry(String pricebookId,String product2Id, Decimal price){
        
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = product2Id, UnitPrice = price, IsActive = true);
        insert pbEntry;
        return pbEntry;
    }

}
