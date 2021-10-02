/*
 * OpportunityAssignmentHandler
 * ----------------------------
 */
public class OpportunityAssignmentHandler implements TriggerHandlerInterface {
    
    public void beforeInsert(List<SObject> newItems) {
         OpportunityAssignmentHelper.presetStatusOpportunityAssignments((List<Opportunity_Assignment__c>)newItems);
    }
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void afterDelete(Map<Id, SObject> oldItems) {}
    
    public void afterInsert(Map<Id, SObject> newItems) {
        OpportunityAssignmentHelper.assignOpportunities((List<Opportunity_Assignment__c>)newItems.values());
    }
    
    public void afterUndelete(Map<Id, SObject> oldItems) {}
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
   //     OpportunityAssignmentHelper.assignOpportunities((List<Opportunity_Assignment__c>)newItems.values());
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems) {}
}