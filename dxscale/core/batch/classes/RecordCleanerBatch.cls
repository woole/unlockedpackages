global class RecordCleanerBatch implements Database.Batchable<SObject>, Database.Stateful {
    global String query;
    global String deleteObj;
    global String logReference;
    global Integer totalCount = 0;
    global Integer successCount = 0;
    global Boolean emptyRecycleBn = true;


global RecordCleanerBatch(String q, String delObj, String logRef,Boolean emptyRecycleBn) {
    this.query = q;
    this.deleteObj = delObj;
    this.logReference = logRef;
    this.emptyRecycleBn = emptyRecycleBn;
}


    global RecordCleanerBatch(String q, String delObj, String logRef) {
        this.query = q;
        this.deleteObj = delObj;
        this.logReference = logRef;
        
    }

   
   /**
    * start job
    * @param context
    * @return query locator
    */
   global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Start query: ' + this.query);
        return Database.getQueryLocator(query);
   }

   /**
    * execute a batch
    * @param context
    * @param scope - items to delete
    */
   global void execute(Database.BatchableContext BC, List<SObject> scope) {
       

           List<Logger__c> errorLogList = new List<Logger__c>();
           try {
               // maintain total number of records being processed
               totalCount += scope.size();

               // delete records
               Database.DeleteResult[] srList = Database.delete(scope, false);  // allOrNone = false
               for (Integer i = 0; i < scope.size(); i++) {
                   Database.DeleteResult sr = srList[i];
                   if (!sr.isSuccess()) {
                       errorLogList.add(processMessage(scope[i], 'execute', 'Unable to delete error log record: ' + sr.getErrors()[0].getMessage(), BC, null));
                   } else {
                       // update successful record count
                       successCount++;
                   }
               }
               if (emptyRecycleBn) {
                   Database.emptyRecycleBin(scope);
               }
           } catch (Exception e) {
               processMessage(null, 'execute', null, BC, e);
           }
           // flush any messages
           if (errorLogList.size() > 0) insertLoggerMessages(errorLogList);
   }

   /**
    * finish job - log any errors and on all stats of records processed
    * @param context
    */
   global void finish(Database.BatchableContext BC){
       
           List<Logger__c> logList = new List<Logger__c>();

           // compile any errors and log them.
           AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                             FROM AsyncApexJob
                             WHERE Id = :BC.getJobId()];
           if (a.NumberOfErrors > 0) {
               logList.add(processMessage(null, 'finish', 'Error in AsyncApexJob: Status:'+a.Status+' Number of errors:'+a.NumberOfErrors, BC, null));
           }
           // log stats
           logList.add(processStats(' Total:' + totalCount + ' Deleted:' + successCount, BC));
           // flush all messages
           insertLoggerMessages(logList);
       
   }
   /**
   * Processing of errors, returning stats log record. 
   * - Name will be '<logReference>|RecordCleanerBatch'.
   * - Exception method name will be 'STATISTICS'
   * @param messageDetail - message containing stats
   * @param context for job Id reference
   * @return logger record
   */
   global Logger__c processStats(String messageDetail, Database.BatchableContext BC) {
       // get job Id
       String jobId='<no jobId>';
       if (BC != null) { jobId=BC.getJobId(); }

       // Create logger record 
       Logger__c log = new Logger__c();
       log.Name = logReference + '|RecordCleanerBatch';
       log.Exception_Method_Name__c = 'STATISTICS'; 
       log.Record_Name_Id__c = deleteObj;
       log.Record_Details__c = 'JOB:' + jobId + '|MESSAGE:' + messageDetail;

       return log;
   }
   /**
   * Processing of errors, returning error log record.
   * - Name will be '<logReference>|RecordCleanerBatch'
   * @param recDetail - record to report (optional)
   * @param methodName - method where error occurred
   * @param resultErrorMessage - error message
   * @param context - for job Id reference
   * @param ex - exception (optional)
   * @return logger record (null if exception)
   */
   global Logger__c processMessage(SObject recDetail, String methodName, String resultErrorMessage, Database.BatchableContext BC, Exception ex) {

       Logger__c log = new Logger__c();    // return record
       // get job Id
       String jobId = '<no jobId>';
       if (BC != null) { jobId = BC.getJobId(); }
       if (ex != null) {
           // for exceptions, use ExceptionHandler method
           catchException(logReference + '|RecordCleanerBatch', methodName + '|JOB:' + jobId, ex);
       } else {
           // non-exceptions
           String traceMessage = resultErrorMessage;
           traceMessage = traceMessage.normalizeSpace().left(32768);
           //
           // create logger record
           log.Name = logReference + '|RecordCleanerBatch'; // Add Exception Name as ClassName
           log.Exception_Method_Name__c = methodName ; // Add MethodName from where exception was thrown
           log.Exception_Error_Message__c = traceMessage;
           if (recDetail != null) {
               // supplied record details
               log.Record_Name_Id__c = recDetail.Id;
               log.Record_Details__c = jobId + recDetail;
           }
       }
       return log;
   }
   /**
    * Insert Logger records
    * @param loggerRecords - records to insert
    */
   global void insertLoggerMessages(List<Logger__c> loggerRecords){
       if (loggerRecords.size() > 0) {
           try {
               insert loggerRecords;
           }
           catch (DmlException ex) {
               ex.setMessage('An error occurred while inserting records into the Error Log');
           }
       }
   }

   public static string catchException(String ClassName,String ModuleName,Exception ex){
       list<logger__c> loggerList = new list<Logger__c>();
       Logger__c log = new Logger__c();
       
       string message = ex.getMessage(); // Prepare the return value
       
       // Map the error to different fields in logger object
       log.Exception_Type__c = ex.getTypeName(); // Returns the type of exception such as DML Exception,listException,MathException and so on 
       log.Exception_Line_Number__c = string.valueOf(ex.getLineNumber()); // Returns the line number from where the exception was thrown
       log.Exception_Error_Message__c = ex.getMessage(); // Return the error message
       log.Exception_StackTrace__c = ex.getStackTraceString(); // Returns the stack trace
       log.Name = ClassName; // Add Exception Name as ClassName
       log.Exception_Method_Name__c = ModuleName ; // Add MethodName from where exception was thrown
       
       // Check for DML Exception
       if(ex.getTypeName().equalsIgnoreCase('System.DMLException')){
           message =  ((DMLException)ex).getDmlMessage(0); // Get the return Value 
           String dmlMessage = catchDMLException(ex); // Call to method to handle DML Exception
           if(dmlMessage != '') {
               log.Exception_DML_Message__c = dmlMessage; // Log the DML Message
           }
       }
       loggerlist.add(log);
       insertException(loggerList);
       return ex.getmessage();
   } 
   
   @TestVisible
   private static String catchDMLException(Exception ex){
       
       String dmlMessage = '';
       
       for (Integer i = 0; i < ex.getNumDml(); i++) {  
           //Returns the ID of the failed record that caused the error
           String dmlId = ((DMLException)ex).getDMLID(i);
           String dmlField = '';
           //Returns the names of the field or fields that caused the error
           String[] dmlFieldNames = ((DMLException)ex).getDmlFieldNames(i);
           
           for(String dmlFieldString:dmlFieldNames){ 
               dmlField += dmlFieldString + ',';
           }
           
           if (dmlField.length() > 2)
               dmlField = dmlField.substring(0,dmlField.length()-1); // Remove extra comma at the end
           
           //Returns the original row position
           Integer dmlIndex = ((DMLException)ex).getDmlIndex(i);
           
           //Returns the user message
           dmlMessage = ((DMLException)ex).getDmlMessage(i);

           //Returns the Apex failure code
           String dmlStatusCode = ((DMLException)ex).getDmlStatusCode(i);
           
           //Returns the number of failed rows for DML exceptions
           Integer numDml = ((DMLException)ex).getNumDml();
           dmlMessage += 'DMLException No. '+ (i+1)+' : ID of the failed Record : '+dmlId+', Names of the fields that caused the error : '+dmlField+', Original Row Position : '+dmlIndex+', User message : '+dmlMessage+', Apex failure code : '+dmlStatusCode+', Number of failed rows for DML exceptions : '+ numDml+'. ';
       }   
       return dmlMessage;  
   }    

   private static void insertException(list<Logger__c> loggerRecords){
       
       if(loggerRecords.size() > 0){
           try{
               insert loggerRecords;
           }
           catch(DMLException ex){
               ex.setMessage('Some error occured while inserting into the Error Log');
           }
       }
    }  

}
