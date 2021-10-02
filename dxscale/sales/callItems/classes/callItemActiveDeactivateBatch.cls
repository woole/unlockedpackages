global class callItemActiveDeactivateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // callItemsProcessed to retain state across transactions
    global Integer CallItemsList4Updatesize = 0;
    global Integer CallItemsupdateSucess = 0;
    global Integer CallItemsupdateFailure = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, Visibility_Status__c, Active_Start_Date__c, Target_Finish_Date__c ' +
            ' FROM Call_Item__c ' + 
            'Where (Active_Start_Date__c <= TODAY AND Visibility_Status__c = \'Inactive\')'+
            ' OR (Target_Finish_Date__c <= TODAY AND Visibility_Status__c = \'Active\')'
            
        );
    }
    global void execute(Database.BatchableContext bc, List<Call_Item__c> ci){
        // process each batch of records
        
        List<Call_Item__c> CallItemsList4Update = new List<Call_Item__c>();
        Boolean Flag;
        for(Call_Item__c c : ci){
            
            Flag =false;            
          
            if(flag ==false && c.Active_Start_Date__c == c.Target_Finish_Date__c && c.Active_Start_Date__c == date.TODAY() && (c.Visibility_Status__c != 'Inactive'||c.Visibility_Status__c != ''||c.Visibility_Status__c != NULL)) {
                c.Visibility_Status__c = 'Inactive';
                CallItemsList4Update.add(c);
                flag =true;                
            }
            
            if(flag ==false && c.Active_Start_Date__c <= date.TODAY()&& c.Target_Finish_Date__c > date.TODAY() && c.Visibility_Status__c != 'Active') {
                c.Visibility_Status__c = 'Active';
                CallItemsList4Update.add(c);
                flag =true;
            }
            if(flag ==false && c.Target_Finish_Date__c <= date.TODAY() && c.Visibility_Status__c != 'Inactive') {
                c.Visibility_Status__c = 'Inactive';
                CallItemsList4Update.add(c);
                flag =true;
            }
           
            //update CallItemsList4Update;
            
      
        }  
        Database.SaveResult[] srList = Database.update(CallItemsList4Update, false);
              System.debug(CallItemsList4Update + ' CallItemsList4Update');
        CallItemsList4Updatesize = CallItemsList4Update.size();
            
            // Iterate through each returned result
    for (Database.SaveResult sr : srList) {
       if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
              CallItemsupdateSucess++;
              System.debug('Successfully updated Call item. Call item ID: ' + sr.getId());
                               }
      else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
               CallItemsupdateFailure++; 
               System.debug('The following error has occurred.');                    
               System.debug(err.getStatusCode() + ': ' + err.getMessage());
               System.debug('Call item fields that affected this error: ' + err.getFields());
                                }
           }
           
        }
    }
    
    global void finish(Database.BatchableContext bc){
           
        CallitemBatchJobSettings__mdt Emaildata =[select Emails__c from CallitemBatchJobSettings__mdt where DeveloperName='Email_details'];
        
        String status = 'Success';
        if (CallItemsupdateFailure!=0)
        {Status = 'Failure';}        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = Emaildata.Emails__c.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('Call Item Batch '+ Status);
        mail.setPlainTextBody('Total callItems Processed -> '+ CallItemsList4Updatesize+ ' with '+
                               CallItemsupdateSucess+ ' -> Updated Successfully '+
                               CallItemsupdateFailure+' -> with failures.');
       if(!Test.isRunningTest()){
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}
        
    }    
}
