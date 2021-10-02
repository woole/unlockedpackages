public with sharing class MakePrimaryPartner {
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityPartner> getAllSecondaryOpportunityPartners(String oppId) {
        Opportunity oppAcc = [SELECT Id, AccountId FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED LIMIT 1];
        String accId = oppAcc.AccountId;
        return [SELECT Id, OpportunityId, IsPrimary, AccountToId, AccountTo.Id, AccountTo.Name, Role FROM OpportunityPartner WHERE OpportunityId =: oppId AND (IsPrimary!=true AND AccountTo.Id !=: accId) WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityPartner> getPrimaryOpportunityPartner(String oppId) {
        Opportunity oppAcc = [SELECT Id, AccountId FROM Opportunity WHERE Id=:oppId WITH SECURITY_ENFORCED LIMIT 1];
        String accId = oppAcc.AccountId;
        return [SELECT Id, OpportunityId, IsPrimary, AccountToId, AccountTo.Id, AccountTo.Name, Role FROM OpportunityPartner WHERE OpportunityId =: oppId AND (IsPrimary =: true AND AccountTo.Id !=: accId) WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static void deletePartner(String PartnerId){
        
        if(OpportunityPartner.SObjectType.getDescribe().isDeletable()){
        OpportunityPartner oppDelete1 = [SELECT Id, OpportunityId FROM OpportunityPartner WHERE Id=: PartnerId WITH SECURITY_ENFORCED];
        delete oppDelete1;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
        }
    }

    @AuraEnabled
    public static void changePrimaryPartner(String PartnerId){
        
        if(OpportunityPartner.SObjectType.getDescribe().isDeletable() && OpportunityPartner.sObjectType.getDescribe().isCreateable()){
        OpportunityPartner oppDelete1 = [SELECT AccountToId, Role, OpportunityId FROM OpportunityPartner WHERE Id=: PartnerId WITH SECURITY_ENFORCED];
        String tempRole = oppDelete1.Role;
        String accId = oppDelete1.AccountToId;
        String oppId=oppDelete1.OpportunityId;
        delete oppDelete1;

        OpportunityPartner oppPartner = new OpportunityPartner();
        oppPartner.OpportunityId = oppId;
        oppPartner.AccountToId = accId;
        oppPartner.Role=tempRole;
        oppPartner.IsPrimary=true;
        insert oppPartner;
    	}
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
        }
    }
}