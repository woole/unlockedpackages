public inherited sharing class ExceptionEvent_Helper {
   
    public static void processEventToLogger(List<ExceptionEvent__e> exceptionEvents) {
        //list of hold the log records that needs to be inserted from the platform events
        List<Logger__c> logsToInsert = new List<Logger__c>();

        //looping through each platform event that gets published and inserting log records
        for (ExceptionEvent__e eve : exceptionEvents){
            Logger__c log = new Logger__c();
            log.Exception_StackTrace__c = eve.StackTrace__c;
            log.Record_Name_Id__c = eve.Record_Id__c;
            log.Name = eve.ClassName__c;
            log.Exception_Error_Message__c = eve.ErrorMessage__c;
            log.Exception_Type__c = eve.ExceptionType__c;
            log.Exception_DML_Message__c = eve.ExceptionCause__c;
            if(!Test.isRunningTest()){
                log.OwnerId = eve.CreatedById;
            }
            log.Correlation_Id__c = eve.Correlation_Id__c;
            logsToInsert.add(log);
        }
        insert logsToInsert;
        
    }

}
