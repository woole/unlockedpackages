/*
 * OpportunityAssignmentTrigger
 * 
 * Fires when an Opportunity Assignment record is created
 * and is used to update Opportunity OwnerId field
 */
trigger OpportunityAssignmentTrigger on Opportunity_Assignment__c (before insert, before update, before delete,
        														   after insert, after update, after delete, after undelete) {
    OpportunityAssignmentControlSwitch__c triggerSwitch = OpportunityAssignmentControlSwitch__c.getInstance();
    if (Test.isRunningTest() || triggerSwitch.RunTrigger__c) {
    	TriggerDispatcher.Run(new OpportunityAssignmentHandler());                                                                      
    }
}