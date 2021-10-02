trigger OpportunityLineItem_Trigger on OpportunityLineItem (after insert, after update, after delete) {
	TriggerFactory.executeTrigger(OpportunityControlSwitch__c.getInstance()); // uses Opportunity switch custom setting
}