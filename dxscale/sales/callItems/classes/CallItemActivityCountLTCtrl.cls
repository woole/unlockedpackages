public inherited sharing class CallItemActivityCountLTCtrl {
	static final String CLASSNAME = 'CallItemActivityCountLTCtrl';

	@AuraEnabled
	public static void callCounter(Id recordId) {
		LogControl.push('callCounter', CLASSNAME);

		try {
			Call_Item__c callItem = [
				SELECT Id, OwnerId, isOpenedByOwner__c, Attempted_Calls__c
				FROM Call_Item__c
				WHERE Id = :recordId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			if (
				UserInfo.getUserId() == callItem.OwnerId &&
				callItem.isOpenedByOwner__c != true &&
				Schema.sObjectType.Call_Item__c.fields.isOpenedByOwner__c.isupdateable()
			) {
				callItem.isOpenedByOwner__c = true;
				Database.update(callItem);
			}
		} catch (Exception e) {
			LogControl.debugException(e);
		} finally {
			LogControl.pop();
		}
	}
}
