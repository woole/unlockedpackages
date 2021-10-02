/*  Created as part of EAD-2161
*   Used as controller for Aura component "SuccessGoalInitialEngagement"
*   @Author: Dharani Chennupati
*/

public with sharing class OnboardingSuccessGoals {
    
    @AuraEnabled
    public static List <String> getAllSuccessGoals() {
        List<String> plValues = new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Success_Goals__c').getDescribe();
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        //plValues.sort();
        return plValues;
    }
    //Himanshu
    @AuraEnabled
    public static List <String> getAllOnboardingScores() {
        List<String> plValues = new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Onboarding_Score__c').getDescribe();
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        return plValues;
    }
    
    @AuraEnabled
    public static void updateRecord(Id recId,String onboardingScore, List<String> FinalValues,List<String> Initialvalues, String otherGoals) {
        String InitialEngagements = '';
        String FinalEngagements = '';
        
        if(!Initialvalues.isEmpty()){
            InitialEngagements = string.Join(Initialvalues,';');
        }  
        if(!FinalValues.isEmpty()){
            FinalEngagements = string.Join(FinalValues,';');
        }   
        if(recId!=null &&
           Schema.SObjectType.Opportunity.fields.Success_Goals__c.isupdateable() &&
           Schema.SObjectType.Opportunity.fields.Final_Success_Goals__c.isupdateable() &&
           Schema.SObjectType.Opportunity.fields.Onboarding_Score__c.isupdateable() &&
           Schema.SObjectType.Opportunity.fields.Other_Success_Goals__c.isupdateable() ){
               Opportunity opp = new Opportunity(Id=recId);
               opp.Success_Goals__c = InitialEngagements;
               opp.Final_Success_Goals__c = FinalEngagements;
               opp.Onboarding_Score__c = onboardingScore;
               opp.Other_Success_Goals__c=otherGoals;
               update opp;                  
           }
    }
    
    @AuraEnabled
    public static List<String> getStoredEngagements(String recId) { 
        List<String> initialEngagement=new List<String>(); 
        if(recId!=null){   
               List<Opportunity> oppList = [SELECT Id,Success_Goals__c FROM Opportunity WHERE Id=:recId WITH SECURITY_ENFORCED LIMIT 1];
               if(oppList != null && !oppList.isEmpty() && oppList[0].Success_Goals__c != null){
                   initialEngagement.addAll(oppList[0].Success_Goals__c.split(';'));
               }
           }  
        return initialEngagement;
    }
    
    @AuraEnabled
    public static List<String> getStoredFinalEngagements(String recId) { 
        List<String> finalEngagement=new List<String>();
        if(recId!=null){
               List<Opportunity> oppList = [SELECT Id,Final_Success_Goals__c FROM Opportunity WHERE Id=:recId WITH SECURITY_ENFORCED LIMIT 1];
               if(oppList != null && !oppList.isEmpty() && oppList[0].Final_Success_Goals__c != null){
                   finalEngagement.addAll(oppList[0].Final_Success_Goals__c.split(';'));
               }
           }
        return finalEngagement;
    }
    
    @AuraEnabled
    public static String getStoredOtherGoals(String recId) { 
        String otherGoals; 
        if(recId!=null){   
               List<Opportunity> oppList = [SELECT Id,Other_Success_Goals__c FROM Opportunity WHERE Id=:recId WITH SECURITY_ENFORCED LIMIT 1];
               if(oppList != null && !oppList.isEmpty() && oppList[0].Other_Success_Goals__c != null){
                   otherGoals=oppList[0].Other_Success_Goals__c;
               }
           }  
        return otherGoals;
    }
    
    @AuraEnabled
    public static String getStoredOnboardingScore(String recId) { 
        String onboardingScore=''; 
        if(recId!=null){   
               List<Opportunity> oppList = [SELECT Id,Onboarding_Score__c  FROM Opportunity WHERE Id=:recId WITH SECURITY_ENFORCED LIMIT 1];
               if(oppList != null && !oppList.isEmpty() && oppList[0].Onboarding_Score__c != null){
                   onboardingScore+=oppList[0].Onboarding_Score__c;
               }
           }  
        return onboardingScore;
    }
}