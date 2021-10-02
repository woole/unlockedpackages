/**
 @author Veni Korapaty (veni.korapaty@sage.com)
 @date 10-Jun-2019
 @description trigger handler class for CallItem trigger. This class should be responsible for invoking all business logic
 involved on CallItem

 */

public without sharing class CallItem_TriggerHandler extends TriggerService {
	public override void onBeforeInsert(){
		CallItem_Helper.autoPopulateCallItemData((List<Call_Item__c>) this.listNewSObject, new Map<Id, Call_Item__c>());
		CallItem_Helper.setActiveInactive((List<Call_Item__c>) this.listNewSObject, new Map<Id, Call_Item__c>());
	}

	public override void onBeforeUpdate(){
		CallItem_Helper.setActiveInactive((List<Call_Item__c>) this.listNewSObject, (Map<Id, Call_Item__c>) this.mapOldSObject);         
		CallItem_Helper.updateStatusWhenContactFound ((List<Call_Item__c>) this.listNewSObject, (Map<Id, Call_Item__c>) this.mapOldSObject);
        CallItem_Helper.updateOwnerOnChangeOfFederationEmail ((List<Call_Item__c>) this.listNewSObject, (Map<Id, Call_Item__c>) this.mapOldSObject);
		CallItem_Helper.setVisbilityStatusManually((List<Call_Item__c>) this.listNewSObject, (Map<Id, Call_Item__c>) this.mapOldSObject);
    }
    
}