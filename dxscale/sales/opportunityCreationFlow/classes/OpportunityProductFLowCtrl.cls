/**
* This class is used by the Call List functionality to create Opportunity Line Items selected in a FLow
* The Flow calls this classes InvocableMethod passing in a JSON string:
*   format:        [{"id":"01u1o00000Sc8kCAAR","productName":"Handisoft Online","quantity":"2","amount":40000}]  
* which is then hydrated into a Product wrapper
* @author craig.bradshaw@sage.com
* @date June 2019
*/

global inherited sharing class OpportunityProductFLowCtrl {

    /**
    * Transient Mapper Object to rehydrate the JSON string from the Call Item Flow
    */
    public class Product {
        //this is actually the procebook id but we can't change the format passed form the component
        public String id;
        public String productName;
        public String commercialisationMode;
        public String productDeployment;
        public Integer quantity;
       //x public Decimal amount;     
        public String nonRecurringRevenue;
        public String monthlyRecurringRevenue;
    }
        
    /**
    * Transient Input mapping from the flow
    */
    public class FlowInputs{    
        @InvocableVariable
        public String opportunityId;
        
        @InvocableVariable
        public String jsonString;        
    }

    /**
    * called by the Call Item Opportunity FLow. RE-hydrates the JSON payload and maps to
    * the opportunity line items
    */
   @InvocableMethod
   public static void createOpportunityLineItems(List<FlowInputs> listFlowInputs) {
       FlowInputs flowInputs = listFlowInputs[0];
       System.debug(LoggingLevel.ERROR, flowInputs);
       String jsonString = flowInputs.jsonString;
       String opportunityId = flowInputs.opportunityId;

       List<OpportunityProductFLowCtrl.Product> products = 
        (List<OpportunityProductFLowCtrl.Product>)JSON.deserialize(
               jsonString, List<OpportunityProductFLowCtrl.Product>.class);

        List<OpportunityLineItem> listOLI = new List<OpportunityLineItem>();       

        for (OpportunityProductFLowCtrl.Product product : products ) {
           System.debug(LoggingLevel.ERROR, product);

            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opportunityId;
            oli.PricebookEntryId= product.Id;
            oli.Quantity = product.quantity;
            //oli.UnitPrice = 1;
            oli.Commercialisation_Mode__c = product.commercialisationMode;
            oli.Product_Deployment__c = product.productDeployment;
           // oli.TotalPrice = product.amount;
           
            oli.UnitPrice = 0;
            oli.Monthly_Recurring_Revenue__c=0;
            
            if(product.nonRecurringRevenue!='' && product.nonRecurringRevenue!=null){  
                oli.UnitPrice = decimal.valueOf(product.nonRecurringRevenue);}
            if(product.monthlyRecurringRevenue!='' && product.monthlyRecurringRevenue!=null){ 
                oli.Monthly_Recurring_Revenue__c=decimal.valueOf(product.monthlyRecurringRevenue);                
            }
           

            listOLI.add(oli);
        }
       
       system.debug('listOLI.....'+listOLI);
        insert listOLI;
   }
}