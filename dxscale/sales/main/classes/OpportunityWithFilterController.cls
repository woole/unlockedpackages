public with sharing class OpportunityWithFilterController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getAllOpportunities(String recordAccId) {
        return [Select Id, AccountId, Name, CloseDate, StageName, Total_Contract_Value_TCV_forecast__c, 
        Type, Product_Allocation_Group__c,Product__c, Roll_up_of_Opp_Products__c	,
        CreatedBy.Name, Owner.Name from Opportunity where AccountId =: recordAccId WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpenOpportunities(String recordAccId) {
        return [Select Id, AccountId, Name, CloseDate, StageName, Total_Contract_Value_TCV_forecast__c, 
        Type, Product_Allocation_Group__c,Product__c, Roll_up_of_Opp_Products__c	,
        CreatedBy.Name, Owner.Name from Opportunity where AccountId =: recordAccId and 
        (StageName=:'Qualify' or StageName=:'Discovery' or StageName=:'Confirming Value' or StageName=:'Selection') 
        WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getClosedWonOpportunities(String recordAccId) {
        return [Select Id, AccountId, Name, CloseDate, StageName, Total_Contract_Value_TCV_forecast__c, 
        Type, Product_Allocation_Group__c,Product__c, Roll_up_of_Opp_Products__c	,
        CreatedBy.Name, Owner.Name from Opportunity 
        where AccountId =: recordAccId and StageName =: 'Closed Won' WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getClosedLostOpportunities(String recordAccId) {
        return [Select Id, AccountId, Name, CloseDate, StageName, Total_Contract_Value_TCV_forecast__c, 
        Type, Product_Allocation_Group__c,Product__c, Roll_up_of_Opp_Products__c	,
        CreatedBy.Name, Owner.Name from Opportunity 
        where AccountId =: recordAccId and StageName =: 'Closed Lost' WITH SECURITY_ENFORCED];
    }
}
