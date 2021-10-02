trigger PracticeEfficiencyReview_Trigger on PracticeEfficiencyReviewV2__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   PracticeEfficiencyReviewControlSwitch__c triggerSwitch = PracticeEfficiencyReviewControlSwitch__c.getInstance();
    if (Test.isRunningTest() || triggerSwitch.RunTrigger__c) {
    
        TriggerDispatcher.Run(new PracticeEfficiencyReview_TriggerHandler());   
                                                                           
    }
}