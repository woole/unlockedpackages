/**
 * Created by veni korapaty on 10/06/2019.
 */


public inherited sharing class CallItem_DAC {


    /**
     * @description retrieving leads with campaign members for the given lead ids
     *
     * @param leadIds   set of lead ids
     *
     * @return      list of Accounts associated LOcal CRM Names
     */

    public static List<Account> getLocalAccounts(Set<String> localAccountIds) {

        List<Account> salesforceAccounts = [
                select id,
                        Name,
                        (select id from contacts)
   			     from Account
			    where Id IN :localAccountIds
            	WITH SECURITY_ENFORCED
        ];
        
	 return salesforceAccounts;
    }

    public static List<Contact> getAccountContacts(Id callItemId) {

        List<Call_Item__c> listci = [select Account__c from Call_Item__c where id = :callItemId Limit 1];
        Id accountId = listci[0].Account__c;

        List<Contact> salesforceContacts = [
                SELECT Id, Name, MailingStreet, Phone, Email, LeadSource, Job_Role__c, DoNotCall, Description, Phone_Call_Options__c
                FROM Contact
                WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
                ORDER BY DoNotCall
            
        ];

        return salesforceContacts;
    }

    public static List<Call_Item__c> getCallItemContacts(Id callItemId) {

        List<Call_Item__c> callItemContactlist = [select id, Contact__c from Call_Item__c where id = :callItemId WITH SECURITY_ENFORCED];

        return callItemContactlist;
    }


    public static List<User> getUserIds(Set<String> localUserIds) {

        List<User> salesforceUsers = [
                select id, FederationIdentifier
                from User
                where IsActive = true AND
                FederationIdentifier IN :localUserIds 
            WITH SECURITY_ENFORCED
        ];


        return salesforceUsers;
    }
}