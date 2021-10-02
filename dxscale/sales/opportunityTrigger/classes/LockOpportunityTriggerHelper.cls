/* *
 * Camp2Opp
 * Purpose of this class is to lock the Opportunity record for further updates, when the Opportunity is sent to Local CRM
 * Opportunity is allowed to be edited by Intformatica user 
 * */
public with sharing class LockOpportunityTriggerHelper {
    public static Boolean isFirstTimeRun = true;
    
    public boolean isNCAPlusUser(){
        Boolean isNCAplus = false;
        List<PermissionSetAssignment> permission = [select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where 
            Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = 'Sage_NCA_plus' LIMIT 1];
        if(permission != null && permission.size() > 0){
            isNCAplus = true;
        }
        return isNCAplus;
    }
    
    public void populateLocalCRMFields(List<Opportunity> opps){
        if(FeatureManagement.checkPermission('isNcaPlusUser')) {
            if(LockOpportunityTriggerHelper.isFirstTimeRun) {
                LockOpportunityTriggerHelper.isFirstTimeRun = false;
                Set<Id> accountIds = new Set<Id>();
                for(Opportunity opp :opps) {
                    accountIds.add(opp.AccountId); 
                    if(opp.StageName == 'Closed - Lost' || opp.StageName == '07 Closed - Won') {
                        opp.Integration_Record_Status__c = 'Do Not Send';
                    }
                }
                if(accountIds.size() > 0) {
                    // INTACCT RELATED CHANGES
                    Map<String, Map<String, String>> mCrmByCountryByProduct = ReferenceDataAccessHelper.getCrmMappingByProductByCountry();
                    Map<Id, Account> accountMap = new Map<Id, Account>([    SELECT  Id
                                                                                ,   Name
                                                                                ,   Local_CRM_Region__c
                                                                                ,   Local_CRM_Country__c
                                                                                ,   Local_CRM_Name__c
                                                                                ,   BillingCountryCode
                                                                            FROM Account
                                                                            WHERE Id IN :accountIds ]);
                    for(Opportunity opp :opps) {
                        if(accountMap.get( opp.AccountId) != null) {
                            opp.Local_CRM_Region__c = accountMap.get(opp.AccountId).Local_CRM_Region__c;
                            opp.Local_CRM_Country__c = accountMap.get(opp.AccountId).Local_CRM_Country__c;
                            if (String.isNotBlank(opp.Local_CRM_Country__c) && String.isNotBlank(opp.Product_Solution__c)
                                    && mCrmByCountryByProduct.get(accountMap.get(opp.AccountId).BillingCountryCode) != null
                                    && mCrmByCountryByProduct.get(accountMap.get(opp.AccountId).BillingCountryCode).get(opp.Product_Solution__c) != null) {
                                opp.Local_CRM__c = mCrmByCountryByProduct.get(accountMap.get(opp.AccountId).BillingCountryCode).get(opp.Product_Solution__c);
                            } else {
                                opp.Local_CRM__c = accountMap.get(opp.AccountId).Local_CRM_Name__c;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void checkOppoIntegrationStatus(List<Opportunity> opportunities, Map<Id, Opportunity> oldOppMap){
               
        OpportunityControlSwitch__c cs = OpportunityControlSwitch__c.getInstance(userinfo.getuserid());
        if(isFirstTimeRun){        
            isFirstTimeRun = false;
            for(Opportunity opp : opportunities){
                String oldStatus = oldOppMap.get(opp.Id).Integration_Record_Status__c;
                String newStatus = opp.Integration_Record_Status__c;
                if(cs.RunValidationRules__c){
                    if(Sales_Constants.OPP_IR_STATUS_PSTLS.equals(oldStatus) || Sales_Constants.OPP_IR_STATUS_PSTLRR.equals(oldStatus) || Sales_Constants.OPP_IR_STATUS_ETL.equals(oldStatus) || Sales_Constants.OPP_IR_STATUS_UFL.equals(oldStatus) || Sales_Constants.OPP_IR_STATUS_CAOC.equals(oldStatus) || Sales_Constants.OPP_IR_STATUS_LOL.equals(oldStatus)){
                        opp.adderror(System.Label.Opportunity_Can_Not_Be_Edited); 
                    }
                    else if((Sales_Constants.OPP_STAGE_CW.equals(opp.StageName) || Sales_Constants.OPP_STAGE_CL.equals(opp.StageName)) && (Sales_Constants.OPP_IR_STATUS_PSTLS.equals(newStatus) || Sales_Constants.OPP_IR_STATUS_PSTLRR.equals(newStatus))){
                        opp.adderror(System.Label.Closed_Opp_Can_Not_To_Local_CRM);
                    }
                    if(Sales_Constants.OPP_IR_STATUS_PSTLS.equals(newStatus) || Sales_Constants.OPP_IR_STATUS_PSTLRR.equals(newStatus) || Sales_Constants.OPP_IR_STATUS_ETL.equals(newStatus) || Sales_Constants.OPP_IR_STATUS_UFL.equals(newStatus) || Sales_Constants.OPP_IR_STATUS_CAOC.equals(newStatus) || Sales_Constants.OPP_IR_STATUS_LOL.equals(newStatus)){
                        opp.Error_Message__c = System.Label.Can_Not_Change_The_Opportunity_It_Is_Pushed_To_Local_CRM;
                    }
                }
            }
        }
    }
}