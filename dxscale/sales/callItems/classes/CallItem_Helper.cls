/**
@author Veni Korapaty (veni.korapaty@sage.com)
@date 10-Jun-2019
@description helper class for CallItem object. This class should hold all the business logic that needs to be
performed on the CallItem record. The method signatures should be as generic as possible.
Implemented as part of Call Item  JIRA-CCORE-1653
*/
public inherited sharing class CallItem_Helper {
	static string CLASSNAME = 'CallItem_Helper';
	public static Boolean runTriggerMethod = false;

	/**
	 * @description  Get all the Valid Accounts
	 * @param callitem list of new trigger callitems
	 */

	public static Map<ID, Account> getSalesforceAccountIDs(
		List<Call_Item__c> callItems
	) {
		LogControl.push('getSalesforceAccountIDs', CLASSNAME);

		Set<String> sfAccountIds = new Set<String>();
		for (Call_Item__c callItem : callItems) {
			if (CallItem.Account__c != null)
				sfAccountIds.add(CallItem.Account__c);
		}
		List<Account> salesforceAccounts = null;
		Map<ID, Account> localAccountIdsMap = new Map<ID, Account>();
		salesforceAccounts = CallItem_DAC.getLocalAccounts(sfAccountIds);

		for (Account account : salesforceAccounts) {
			localAccountIdsMap.put(account.id, account);
		}
		LogControl.pop();
		return localAccountIdsMap;
	}

	/**
	 * @description  Get all the Active Salesfore Users with Valid Fedeartion IDs
	 * @param callitem list of new trigger callitems
	 */

	public static Map<String, User> getSalesforceUserIDs(
		List<Call_Item__c> callItems
	) {
		LogControl.push('getSalesforceUserIDs', CLASSNAME);
		Set<String> sfFederationUserEmails = new Set<String>();
		for (Call_Item__c callItem : callItems) {
			if (CallItem.FederationUserID__c != null)
				sfFederationUserEmails.add(CallItem.FederationUserID__c);
		}

		List<User> salesforceUsers = null;
		Map<String, User> lowerCaseFederationIDs = new Map<String, User>();
		salesforceUsers = CallItem_DAC.getUserIds(sfFederationUserEmails);
		for (User user : salesforceUsers) {
			if (String.isNotBlank(user.FederationIdentifier)) {
				lowerCaseFederationIDs.put(
					user.FederationIdentifier.toLowerCase(),
					user
				);
			}
		}
		LogControl.pop();

		return lowerCaseFederationIDs;
	}

	/**
	 * @description  Populate the callItemData based on the salesforce Account ID
	 * @param callitem list of new trigger callitems
	 * @param oldCallItems list of old callitems
	 */
	public static void autoPopulateCallItemData(
		List<Call_Item__c> callItems,
		Map<Id, Call_Item__c> oldCallItems
	) {
		LogControl.push('autoPopulateCallItemData', CLASSNAME);

		Map<ID, Account> localAccountIdsMap = new Map<ID, Account>();
		Map<String, Sobject> lowerCaseFederationIDs = new Map<String, User>();
		localAccountIdsMap = getSalesforceAccountIDs(callItems);
		lowerCaseFederationIDs = getSalesforceUserIDs(callItems);

		for (Call_Item__c callItem : callItems) {
			String federationUserID = callItem.FederationUserID__c?.toLowerCase();
			String OwnerId = null;
			DateTime nowDT = System.now();
			String formatted = nowDT.format('dd-MM-yyyy');
			OwnerId = lowerCaseFederationIDs?.get(federationUserID)?.Id;
			if (!String.isBlank(OwnerId)) {
			callItem.ownerid = lowerCaseFederationIDs?.get(federationUserID)?.Id;
			} else {
				callItem.AddError(
					'Federation ID doesnt exist, Please provide the valid email.'
				);
			}

			callItem.Name =
				localAccountIdsMap?.get(callItem.Account__c)?.Name +
				':' +
				formatted +
				'(Call Item)';
			callItem.Number_of_Account_Contacts__c = localAccountIdsMap
				?.get(callItem.Account__c)
				?.Contacts
				?.size();
			callItem.Status__c = 'Missing Contact';

		LogControl.pop();
	}
	}

    /**
	 * @description  UpdateOwner when Federation Email Changes
	 * @param callitem list of new trigger callitems
	 * @param oldCallItems list of old callitems
	 */
	public static void updateOwnerOnChangeOfFederationEmail(
		list<Call_Item__c> CallItems,
		Map<id, Call_Item__c> oldCallItemMap
	) {
		LogControl.push('updateOwnerOnChangeOFFederationEmail', CLASSNAME);
		Map<String, User> lowerCaseFederationIDs = new Map<String, User>();
		String OwnerId = null;
		lowerCaseFederationIDs = getSalesforceUserIDs(CallItems);

		for (Call_Item__c callItem : CallItems) {
			String federationUserID = callItem.FederationUserID__c?.toLowerCase();
			Call_Item__c oldCallItem = oldCallItemMap.get(callItem.Id);
          	if (callItem.FederationUserID__c != oldCallItem.FederationUserID__c) {
				OwnerId = lowerCaseFederationIDs?.get(federationUserID)?.Id;
				if (!String.isBlank(OwnerId)) {
				callItem.ownerid = lowerCaseFederationIDs?.get(federationUserID)?.Id;
				} else {
					callItem.AddError(
						'Federation ID doesnt exist, Please provide the valid email.'
					);
				}
			}
		}
		LogControl.pop();
	}

	/**
	 * @description method to set setVisbilityStatusManually Field to True
	 * When CallItem VisibillityStatus is changed to Inactive and Active Start Date is in Future,
	 * then  set isVisibilityStatusSetManually__c =True
	 * @param callitem list of new trigger callitems
	 * @param oldcallitems map of old trigger callitem
	 * JIRA - CCORE-1912
	 */
	public static void setVisbilityStatusManually(
		list<Call_Item__c> newCallItems,
		map<id, Call_Item__c> oldCallItemMap
	) {
		LogControl.push('setVisbilityStatusManually', CLASSNAME);
		for (Call_Item__c callItem : newCallItems) {
			Call_Item__c oldCallItem = oldCallItemMap.get(callItem.Id);
			if (
				callItem.Active_Start_Date__c != null &&
				callItem.Visibility_Status__c == 'Inactive' &&
				callItem.Active_Start_Date__c >= Date.Today() &&
				callItem.Visibility_Status__c != oldCallItem.Visibility_Status__c
			) {
				callItem.isVisibilityStatusSetManually__c = true;
			}
		}
		LogControl.pop();
	}

	/**
	 * @description method - Setting the status when the contact is updated
	 * @param callitem list of new trigger callitems
	 * @param oldcallitems map of old trigger callitem
	 * JIRA - CCORE-1912
	 */
	public static void updateStatusWhenContactFound(
		list<Call_Item__c> newCallItems,
		map<id, Call_Item__c> oldCallItemMap
	) {
		LogControl.push('updateStatusWhenContactFound', CLASSNAME);
		for (Call_Item__c callItem : newCallItems) {
			//Id callItemId = callItem.Id;
			Call_Item__c oldCallItem = oldCallItemMap.get(callItem.Id);
			if (
				oldCallItem.Status__c == 'Missing Contact' &&
				oldCallItem.Contact__c == null &&
				callItem.Contact__c != null
			) {
				callItem.Status__c = 'To Be Actioned';
			}
		}

		LogControl.pop();
	}

	public static void setActiveInactive(
		list<Call_Item__c> newCallItems,
		map<id, Call_Item__c> oldCallItemMap
	) {
		LogControl.push('setActiveInactive', CLASSNAME);
		if (!runTriggerMethod) {
			for (Call_Item__c callItem : newCallItems) {
				//  Id callItemId = callItem.Id;
				Call_Item__c oldCallItem = oldCallItemMap.get(callItem.Id);
				Boolean flag = false;

				if (
					flag == false &&
					callItem.Active_Start_Date__c != null &&
					callItem.Target_Finish_Date__c != null &&
					callItem.Active_Start_Date__c == callItem.Target_Finish_Date__c &&
					callItem.Active_Start_Date__c == Date.Today() &&
					callItem.Visibility_Status__c != 'Inactive'
				) {
					callItem.Visibility_Status__c = 'Inactive';
					flag = true;
				}

				if (
					flag == false &&
					callItem.Target_Finish_Date__c != null &&
					callItem.Visibility_Status__c != 'Inactive' &&
					callItem.Target_Finish_Date__c == Date.Today()
				) {
					callItem.Visibility_Status__c = 'Inactive';
					flag = true;
				}
				if (
					flag == false &&
					callItem.Active_Start_Date__c != null &&
					callItem.Visibility_Status__c != 'Active' &&
					callItem.Active_Start_Date__c == Date.Today()
				) {
					callItem.Visibility_Status__c = 'Active';
					flag = true;
				}
			}
		}
		LogControl.pop();
	}
}