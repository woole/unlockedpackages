public with sharing class CustomContactObjectSearch{

    @auraEnabled
    public static List<Contact> getContactList(string accountId, string searchKey){
     List<Contact> conList;
        if(searchKey != null && String.isNotBlank(searchKey) && accountId != null && String.isNotBlank(accountId)){
            if(searchKey=='*' || searchKey.toLowerCase()=='all'){
                conList = [SELECT Id FROM Contact WHERE AccountId=:accountId AND
                                                        Inactive__c = false  AND 
                                                        IsIndirectCustomer__c = false  WITH SECURITY_ENFORCED 
                                                         Order by Primary__c  DESC LIMIT 200  ];
                                                        }
            else{
                String searchable = '%'+searchKey+'%';
                conList = [SELECT Id FROM Contact WHERE AccountId=:accountId AND 
                                                        Inactive__c = false AND 
                                                        IsIndirectCustomer__c = false AND
                                                        (Email LIKE:searchable OR 
                                                        Name LIKE:searchable OR 
                                                        Phone LIKE:searchable OR 
                                                        Job_Role__c LIKE:searchable ) WITH SECURITY_ENFORCED 
                                                        Order by Primary__c  DESC];
            }
        }
        return conList;
    }
    
     //function will return 3 or less then 3 contacts onload
    @auraEnabled
    public static List<Contact> getContacts(string accountId){
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId=:accountId AND
                                                              Inactive__c = false AND 
                                                              IsIndirectCustomer__c = false WITH SECURITY_ENFORCED 
                                                              Order by Primary__c  ];
        if(conList != null && conList.size() < 4){
            return conList;
        }
        return null;
    }

}