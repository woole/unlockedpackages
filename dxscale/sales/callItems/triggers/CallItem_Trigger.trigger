/**
 @author    Veni Korapaty
 @date  10-Jun-2019
 @description   trigger for Call_Item__c object. There should only be one trigger per object.
 */
trigger CallItem_Trigger on Call_Item__c (before insert, after insert, before update, after update) {
  TriggerFactory.executeTrigger();
}