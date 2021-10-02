trigger opportunityTrigger on Opportunity (before insert, before update, after update, after insert) {
    TriggerFactory.executeTrigger(OpportunityControlSwitch__c.getInstance());
}