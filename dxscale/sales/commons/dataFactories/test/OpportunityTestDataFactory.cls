@isTest
public class OpportunityTestDataFactory {
    
    
    public static Opportunity createOpportunity(String accountId, String stageName,String name){
        Opportunity opp = new Opportunity(
            AccountId = accountId, 
            name = name, 
            StageName = stageName
            );
        if(stageName.equalsIgnoreCase('closed won')){
            opp.CloseDate = Date.today();
        }else{
            Datetime stamp = System.now().addDays(30);
            opp.CloseDate = stamp.date();
        }
        insert opp;
        return opp;
    }

    public static OpportunityLineItem createOpportunityLineItems(String oppId, Decimal mrr,String priceBookEntryId){
        OpportunityLineItem oppProduct = new OpportunityLineItem(
            OpportunityId = oppId, 
            Quantity = 1, 
            PricebookEntryId = priceBookEntryId, 
            Product_Deployment__c = 'Sage Cloud',
            Commercialisation_Mode__c = 'Subscription',
            UnitPrice = 0);
            insert oppProduct;
        return oppProduct;
    }
}
