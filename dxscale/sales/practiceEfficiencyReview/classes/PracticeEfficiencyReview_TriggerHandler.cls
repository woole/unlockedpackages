/**
@description trigger handler class for PracticeEfficiencyReviewV trigger and responsible for invoking all business logic 
@author Betty Phan
@date 03/02/2021
*/
public class PracticeEfficiencyReview_TriggerHandler implements TriggerHandlerInterface{
    
    public void BeforeInsert(List<SObject> newItems) {
 		PracticeEfficiencyReview_Helper.PopulateFieldsFromAccount((List<PracticeEfficiencyReviewV2__c>) newItems);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
    }
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
}