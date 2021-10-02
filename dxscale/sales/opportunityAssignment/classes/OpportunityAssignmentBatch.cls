/*
 * OpportunityAssignmentBatch
 * ----------------------------
 * Invoked by the OpportunityAssignmentHandler 
 * For a given list of Opportunity Ids and OwnerIds
 * updates the specified Opportunity's owner with the user identified
 * in batches
 */
public class OpportunityAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful {
    static String CLASSNAME = 'OpportunityAssignmentBatch';
    public List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
    public List<Opportunity_Assignment__c> oaForUpdate = new List<Opportunity_Assignment__c>();
    public List<Opportunity_Assignment__c> oaList = new List<Opportunity_Assignment__c>();    
    public Map<Id, Id> opportunityToAssignment = new Map<Id, Id>();

    // constructor
    public OpportunityAssignmentBatch(Map<Opportunity_Assignment__c, Opportunity> assToOpp) {
        // Opportunity update will be attempted for all Opps
        for (Opportunity_Assignment__c oa : assToOpp.keySet()) {
            opportunitiesForUpdate.add(assToOpp.get(oa));
            opportunityToAssignment.put(oa.Opportunity__c, oa.Id);
            oaList.add(oa);
        }
    }

    public List<Opportunity> start(Database.BatchableContext bc) {
        LogControl.push('start', CLASSNAME);
        return opportunitiesForUpdate;
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> uOpps) {
        try{
        LogControl.push('execute', CLASSNAME);

        // Update the Opportunities
        Database.SaveResult[] srList = Database.update(uOpps, false);

        // Iterate through returned results using the Opps list
        // as ids can be picked up for failed records here - the SaveResult list corresponds in order
        for (Integer i = 0; i < uOpps.size(); i++) {			            
            Opportunity_Assignment__c oaStatus = new Opportunity_Assignment__c();
            Database.SaveResult sr = srList[i];            
           
               oaStatus.Id = opportunityToAssignment.get(uOpps[i].Id);
               if (sr.isSuccess()) {
                  oaStatus.Status__c = 'Success';
                  oaStatus.Outcome__c = '';
               } else {                  
                   oaStatus.Status__c = 'Fail';
                   Database.Error err = sr.getErrors()[0];
				   string msg = err.getStatusCode() + ': ' + err.getMessage();
                   Integer maxSize = 200;
				   if(msg.length() >= maxSize ){
    			 		msg = msg.substring(0, maxSize); 
                   }    
                   oaStatus.Outcome__c = msg;
               }
                oaForUpdate.add(oaStatus);
 			}
            
        // Update status and error message the Opportunity Assignment records too
            Database.update(oaForUpdate, false);
      		} catch (Exception e) {} 
            
    }

    public void finish(Database.BatchableContext bc) {
        LogControl.push('finish', CLASSNAME);
        AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
        System.debug(job);
    }
}