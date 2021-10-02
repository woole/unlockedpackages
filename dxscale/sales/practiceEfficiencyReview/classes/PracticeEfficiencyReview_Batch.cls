global inherited sharing class PracticeEfficiencyReview_Batch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([
              SELECT Id, Status__c, ClosedDate__c, CreatedDate FROM PracticeEfficiencyReviewV2__c 
               WHERE ClosedDate__c = null
                 AND Status__c = 'Open'
        ]        
        );
    }
 
    global void execute(Database.BatchableContext BC, List<PracticeEfficiencyReviewV2__c> scope)
    {
       for(PracticeEfficiencyReviewV2__c r : scope){                   
          IF ((date.valueOf(r.CreatedDate) > date.newInstance(r.CreatedDate.year(), 01, 01)) &&  
              (date.valueOf(r.CreatedDate) <= date.newInstance(r.CreatedDate.year(), 03, 31))) 
          {
             r.Status__c = 'Closed';
             r.ClosedDate__c = date.newInstance(r.CreatedDate.year(), 03, 31);
          }ELSE IF ((date.valueOf(r.CreatedDate) > date.newInstance(r.CreatedDate.year(), 03, 31)) &&  
                    (date.valueOf(r.CreatedDate) <= date.newInstance(r.CreatedDate.year(), 09, 30)))
          {
             r.Status__c = 'Closed';
             r.ClosedDate__c = date.newInstance(r.CreatedDate.year(), 09, 30);     
          }ELSE{
             r.Status__c = 'Closed';
             r.ClosedDate__c =  date.newInstance(r.CreatedDate.year() + 1, 03, 31);
          }
       } 
       update scope;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}