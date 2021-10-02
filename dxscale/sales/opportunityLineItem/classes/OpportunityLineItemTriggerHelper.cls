public inherited sharing class OpportunityLineItemTriggerHelper {

    static String CLASSNAME = 'OpportunityLineItemTriggerHelper';

    /**
     * @description     EAD-2102 Populate product names on the parent Opportunity
     * @param newOpps   list of trigger OLI (Product) records to update parent Opportunities for
     */
	public static void populateProductNamesOnOpportunity(List<OpportunityLineItem> lineItems) {  
		LogControl.push('populateProductNamesOnOpportunity', CLASSNAME);
        
        Set<Id> opportunityIds = new Set<Id>{};
        List<Opportunity> parents = new List<Opportunity>{};
        List<Opportunity> optyUpdateList = new List<Opportunity>();
        List<String> names = new List<String>();
        
        for (OpportunityLineItem oli : lineItems) {
            opportunityIds.add(oli.OpportunityId);       
        }
        
        if (!opportunityIds.isEmpty()) {

            try {
                parents = [SELECT Id, Name, Roll_up_of_Opp_Products__c, (SELECT Product2.name FROM OpportunityLineItems) 
                           FROM Opportunity
                           WHERE Id IN :opportunityIds];

                for (Opportunity opp : parents) {
                    
                    if (opp.OpportunityLineItems.size() > 0) {
                    	
                        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                            
                            if (oli.Product2.name != null){
                                // add name to list 
                                names.add(oli.Product2.name);
                            }
                        }
                        
                        // update name-separating ', '  
                        opp.Roll_up_of_Opp_Products__c = String.join(names, ', ');
                        // clear list to add new account contact names 
                        names.clear();
                    } else {
                        opp.Roll_up_of_Opp_Products__c = '';
                    } 
                    
                    optyUpdateList.add(opp);
                } 
                
                if (!optyUpdateList.isEmpty()){
                	update optyUpdateList;
                }
                
            } catch (Exception e) {
            	ExceptionLogger.logException(CLASSNAME,null,e,'populateProductNamesOnOpportunity',true);
            } finally {
            	LogControl.pop();
            }
    	}
    }
}