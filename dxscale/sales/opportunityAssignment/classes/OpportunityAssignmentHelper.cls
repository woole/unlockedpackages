/*
 * OpportunityAssignmentHelper
 * ----------------------------
 * Invoked by the OpportunityAssignmentTrigger and OpportunityAssignmentHandler class when an Opportunity Assignment record is inserted
 * Updates the specified Opportunity's owner with the user identified in the Assignee__c field
 * via a batched job - a simple update was resulting in Apex CPU limits exceeded on >50 Opportunity updates
 */
public inherited sharing class OpportunityAssignmentHelper {
    static String CLASSNAME = 'OpportunityAssignmentHelper';
  
     /**
     * @description CCORE-2152 Mass reassign Opportunities via the Data Import Wizard
     * @param newOAs list of new trigger records
     */
    public static void presetStatusOpportunityAssignments(List<Opportunity_Assignment__c> newOAs) {
      try{  
         LogControl.push('presetStatusOpportunityAssignments', CLASSNAME);
         List<Opportunity_Assignment__c> lstOAs = new List<Opportunity_Assignment__c>();
         // Unique set of Opportunities to prevent duplicate updates to same Opportunity
         Set<Id> uniqueOpportunities = new Set<Id>();        
         for (Opportunity_Assignment__c oa : newOAs) {    
            Opportunity opp = new Opportunity();
            opp.Id = oa.Opportunity__c;           
            if (uniqueOpportunities.contains(oa.Opportunity__c)) {
                // duplicate Opportunity spotted
                oa.Status__c = 'Duplicate';
                oa.Outcome__c = '';
            } else {
                oa.Status__c = 'Request';
                oa.Outcome__c = '';
                uniqueOpportunities.add(opp.Id);
            }    
         }    
         } catch (Exception e) { 
           LogControl.debugException(e); 
         } finally { 
           LogControl.pop(); 
       }
    }    

    /**
     * @description CCORE-2152 Mass reassign Opportunities via the Data Import Wizard
     * @param newOAs list of new trigger records
     */
    public static void assignOpportunities(List<Opportunity_Assignment__c> newOAs) {
        LogControl.push('assignOpportunities', CLASSNAME);
        List<Opportunity_Assignment__c> assignmentsForUpdate = new List<Opportunity_Assignment__c>();
        // Map to allow recording of updates in the original Opportunity Assignment records and the Opportunities themselves
        Map<Opportunity_Assignment__c, Opportunity> mapAssignmentsToOpportunities = new Map<Opportunity_Assignment__c, Opportunity>();
        // Unique set of Opportunities to prevent duplicate updates to same Opportunity
        Set<Id> uniqueOpportunities = new Set<Id>();
        // "Create" Opportunities for update
        for (Opportunity_Assignment__c oa : newOAs) {
            if (uniqueOpportunities.contains(oa.Opportunity__c)) {
                // duplicate Opportunity spotted
                Opportunity_Assignment__c assignmentForUpdate = new Opportunity_Assignment__c();
                assignmentForUpdate.Id = oa.Id;
                assignmentForUpdate.Status__c = 'Duplicate';
                assignmentForUpdate.Outcome__c = '';
                assignmentsForUpdate.add(assignmentForUpdate);
            } else {
                Opportunity opp = new Opportunity();
                opp.Id = oa.Opportunity__c;
                
                if (!String.isBlank(oa.Assignee__c)){
                   opp.OwnerId = oa.Assignee__c;
                }    
                // 2020/06/11 bphan EAD 1539
                if (!String.isBlank(oa.Assignee__c)){
                   opp.Amount_ACV__c = oa.Amount_ACV__c;
                }
                if ((oa.Annual_Sales_Booking_ASB__c <> NULL) && (oa.Annual_Sales_Booking_ASB__c <> 0)) {
                   opp.Annual_Sales_Booking_ASB__c = oa.Annual_Sales_Booking_ASB__c;
                }
                if (!String.isBlank(oa.Channel_Type__c)){
                   opp.Channel_Type__c = oa.Channel_Type__c;
                }
                if (!String.isBlank(oa.CurrencyIsoCode)){
                   opp.CurrencyIsoCode = oa.CurrencyIsoCode;
                }
                if (!String.isBlank(oa.Opportunity_Name__c)){
                     opp.Name = oa.Opportunity_Name__c;
                }
                if (!String.isBlank(oa.Pain_Points_w_Current_Solution__c)){
                  opp.Pain_Points_w_Current_Solution__c = oa.Pain_Points_w_Current_Solution__c;
                }
                if (!String.isBlank(oa.Discovery_Notes__c)){
                     opp.Discovery_Notes__c = oa.Discovery_Notes__c;                
                }
                if ((oa.Total_Contract_Value_TCV_forecast__c <> NULL) && (oa.Total_Contract_Value_TCV_forecast__c <> 0)) {
                     opp.Total_Contract_Value_TCV_forecast__c = oa.Total_Contract_Value_TCV_forecast__c;
                }
                if (!String.isBlank(oa.Win_Loss_Other_Reason__c)){
                     opp.Win_Loss_Other_Reason__c = oa.Win_Loss_Other_Reason__c;
                }
                if (oa.CloseDate__c <> NULL){
                     opp.CloseDate = oa.CloseDate__c;
                }
                if (oa.Contract_Due_Date_For_Renewal__c <> NULL){
                     opp.Contract_Due_Date_For_Renewal__c = oa.Contract_Due_Date_For_Renewal__c;  
                }
                if (!String.isBlank(oa.Why_We_Lost__c)){
                     opp.Why_We_Lost__c = oa.Why_We_Lost__c;
                }                
                if (!String.isBlank(oa.Win_Loss_Reject_Reasons_Level1__c)){
                     opp.Win_Loss_Reject_Reasons_Level1__c = oa.Win_Loss_Reject_Reasons_Level1__c;
                }
                if (!String.isBlank(oa.Win_Loss_Reject_Reasons_Level2__c)){
                     opp.Win_Loss_Reject_Reasons_Level2__c = oa.Win_Loss_Reject_Reasons_Level2__c;
                }
                if (!String.isBlank(oa.Win_Loss_Reject_Reasons_Level3__c)){
                   opp.Win_Loss_Reject_Reasons_Level3__c = oa.Win_Loss_Reject_Reasons_Level3__c;
                }
                if (!String.isBlank(oa.Stage__c)){
                   opp.StageName = oa.Stage__c;
                }
                if (!String.isBlank(oa.Lead_Source__c)){
                   opp.Lead_Source__c = oa.Lead_Source__c;             
                }
                
                // Adding all new renewal fields as per the request on EAD-1991
                // Date 10-11-2020
                if (!String.isBlank(oa.Renewal_BillingPeriod__c)){
                   opp.Renewal_BillingPeriod__c = oa.Renewal_BillingPeriod__c;             
                }
                if (!String.isBlank(oa.Renewal_Yearlyvaluebeingrenewed__c)){
                   opp.Renewal_Yearlyvaluebeingrenewed__c = oa.Renewal_Yearlyvaluebeingrenewed__c;             
                }
                if (!String.isBlank(oa.Renewal_Status__c)){
                   opp.Renewal_Status__c = oa.Renewal_Status__c;             
                }
                if (oa.Renewal_PromisePaiddate__c <> NULL){
                     opp.Renewal_PromisePaiddate__c = oa.Renewal_PromisePaiddate__c;
                }
                if (oa.Renewal_InterventionDate__c <> NULL){
                     opp.Renewal_InterventionDate__c = oa.Renewal_InterventionDate__c;
                }
                if (oa.Renewal_FirstBillingDate__c <> NULL){
                     opp.Renewal_FirstBillingDate__c = oa.Renewal_FirstBillingDate__c;
                }
                if (oa.Renewal_Billingfilefullvalue__c <> NULL){
                     opp.Renewal_Billingfilefullvalue__c = oa.Renewal_Billingfilefullvalue__c;
                }
               
                

                Opportunity_Assignment__c oaReq = new Opportunity_Assignment__c();
                oaReq.Id = oa.Id;
                oaReq.Status__c = 'Request';
                oaReq.Outcome__c = '';
                assignmentsForUpdate.add(oaReq);
                
                                            
                mapAssignmentsToOpportunities.put(oa, opp);
                uniqueOpportunities.add(opp.Id);
            }
        }
        // Kick off the batch to update Opportunities (and Opportunity Assignment status)
        // Update the Opportunity Assignments which attempted to update Opportunities already being reassigned
        Database.update(assignmentsForUpdate, false);
        if (!system.isBatch() && mapAssignmentsToOpportunities.size() > 0){
             Database.executeBatch(new OpportunityAssignmentBatch(mapAssignmentsToOpportunities), 200);
        }    

    }
}