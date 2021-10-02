/**
 * Created by craigb on 2019-02-26.
 */
trigger Account_Trigger on Account (before insert, before update, before delete,after insert, after update, after delete, after undelete) {
	TriggerFactory.executeTrigger(AccountControlSwitch__c.getInstance());
}