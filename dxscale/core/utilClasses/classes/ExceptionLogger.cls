/**
 * Needs reworking with wider Logger updates
 * Taken from Tetris ExceptionHandler approach
 * Makes a more meaningful log message for low volume entries
 */
public without sharing class ExceptionLogger {
    
    public enum ERROR_TYPE {
        VALIDATION,ERROR,INFO,DEBUG
    }

    //for logging specific errors to the Logger__c (i.e. not excpetions but validation error or other operational )
    public static void logInfo(String className,String correlationId,String recordId,String message,ERROR_TYPE type){
        List<ExceptionEvent__e> exceptionEvents = new List<ExceptionEvent__e>(); 
        ExceptionEvent__e eve = new ExceptionEvent__e();
        eve.ClassName__c = className;
        eve.Correlation_Id__c = correlationId;
        eve.ErrorMessage__c = message;
        eve.Record_Id__c = recordId;
        eve.ExceptionType__c = type.name();
        exceptionEvents.add(eve);
        writeLogsToDatabase(exceptionEvents);

    }


    /**
     * Log error with correlationId
     */
    public static void logException(String className,String correlationId,Exception ex,String additionalInfo,boolean debug){
        List<ExceptionEvent__e> exceptionEvents = new List<ExceptionEvent__e>(); 
        String lineNumber = string.valueOf(ex.getLineNumber());
        ExceptionEvent__e eve = populateExceptionEvent(className,ex,additionalInfo);
        if(String.isNotBlank(correlationId)){
            eve.Correlation_Id__c = correlationId;
        }
        exceptionEvents.add(eve);
        if(debug){
            System.debug(LoggingLevel.DEBUG, 'logging Error : ' + eve);
        }
        writeLogsToDatabase(exceptionEvents);
    }
    
    public static void logException(String className,Exception ex,String additionalInfo){
        List<ExceptionEvent__e> exceptionEvents = new List<ExceptionEvent__e>();        
        
        ExceptionEvent__e eve = populateExceptionEvent(className,ex,additionalInfo);
        exceptionEvents.add(eve);
        writeLogsToDatabase(exceptionEvents);
    }

    
	static private void writeLogsToDatabase(List<ExceptionEvent__e> exEvents) {
		EventBus.publish(exEvents);
    }    


    

    private static ExceptionEvent__e populateExceptionEvent(String className,Exception ex,String additionalInfo){
        ExceptionEvent__e eve = new ExceptionEvent__e();
        String lineNumber = string.valueOf(ex.getLineNumber());
        if(additionalInfo != null){
            eve.ErrorMessage__c = ex.getMessage() +'\r\n'+additionalInfo; // Return the error message    
        }else{
            eve.ErrorMessage__c = ex.getMessage();
        }
        if(String.isNotBlank(lineNumber)){
            eve.ErrorMessage__c += +'\r\n line : '+lineNumber; 
        }
		eve.ClassName__c = className;
		eve.StackTrace__c = ex.getStackTraceString();
		eve.ExceptionType__c = ex.getTypeName();
		eve.ExceptionCause__c = String.valueOf(ex.getCause());
        return eve;
    }

    public static void logException(String className,String methodName,Exception ex,String additionalInfo){
        list<logger__c> loggerList = new list<Logger__c>();
        Logger__c log = new Logger__c();
        
        string message = ex.getMessage(); // Prepare the return value
        
        // Map the error to different fields in logger object
        log.Exception_Type__c = ex.getTypeName(); // Returns the type of exception such as DML Exception,listException,MathException and so on 
        log.Exception_Line_Number__c = string.valueOf(ex.getLineNumber()); // Returns the line number from where the exception was thrown
        if(additionalInfo != null){
            log.Exception_Error_Message__c = ex.getMessage() +'\r\n'+additionalInfo; // Return the error message    
        }else{
            log.Exception_Error_Message__c = ex.getMessage();
        }
        log.Exception_StackTrace__c = ex.getStackTraceString(); // Returns the stack trace
        log.Name = ClassName; // Add Exception Name as ClassName
        log.Exception_Method_Name__c = methodName ; // Add MethodName from where exception was thrown
        
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
     }
     
    
    /**
     *  @desc Method to handle the DML Exceptions and set the values of Intgeration_Log__c
     */
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
    /*
     * @desc Method to insert log
     */
    private static void insertException(list<Logger__c> loggerRecords){
        if(loggerRecords.size() > 0){
            insert loggerRecords;
        }
     }      
}
