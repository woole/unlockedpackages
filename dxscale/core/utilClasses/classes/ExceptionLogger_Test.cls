@isTest
public class ExceptionLogger_Test {
    private final static String CLASSNAME = 'ExceptionLogger_Test';

    @isTest static void testlogInfo() {
        Test.startTest();
            ExceptionLogger.logInfo(CLASSNAME, 'test-123455', '123456789', 'validation failure', ExceptionLogger.ERROR_TYPE.VALIDATION);
        Test.stopTest(); 
        Logger__c log = [select Name, Exception_Error_Message__c,Exception_Type__c,Correlation_Id__c,Record_Name_Id__c from Logger__c LIMIT 1];
        System.assertEquals(CLASSNAME, log.Name);
        System.assertEquals('123456789', log.Record_Name_Id__c);
        System.assertEquals(ExceptionLogger.ERROR_TYPE.VALIDATION.name(), log.Exception_Type__c);
        System.assertEquals('test-123455',log.Correlation_Id__c);
    }

   /**
     *  Test Class handling standard exception
     */
    @isTest static void testStandard_additionalInfo() {
        Exception e;
        //force exception
        try{
            String s;
            s.toLowerCase();
        }catch(NullPointerException npe){
            e = npe;
        }
        Test.startTest();
            ExceptionLogger.logException(CLASSNAME,'testStandard',e,'TEST MESSAGE');
        Test.stopTest();
        Logger__c log = [select Name, Exception_Type__c,Exception_Line_Number__c,Exception_Error_Message__c,Exception_StackTrace__c,Exception_Method_Name__c from Logger__c LIMIT 1];
        System.assertEquals(log.Name, CLASSNAME,'Log Name should have been the classname');
        System.assertEquals(log.Exception_Type__c, 'System.NullPointerException','Excepted NullPointerException Type but was : ' +log.Exception_Type__c );
        System.assert(log.Exception_Error_Message__c != null,'Excepted Exception_Error_Message__c but was : ' + log.Exception_Error_Message__c );
        System.assertEquals(log.Exception_Method_Name__c,'testStandard','Excepted testStandard Type but was : ' +log.Exception_Method_Name__c );
    }

    @isTest static void testPE_additionalIfo() {
        Exception e;
        //force exception
        try{
            String s;
            s.toLowerCase();
        }catch(NullPointerException npe){
            e = npe;
        }
        Test.startTest();
            ExceptionLogger.logException(CLASSNAME,e,'ADDITIONAL INFO');
        Test.stopTest();
        Logger__c log = [select Name, Correlation_Id__c,Exception_Error_Message__c from Logger__c LIMIT 1];
        System.assert(log != null);
        System.assert(log.Exception_Error_Message__c.contains('ADDITIONAL INFO'));
    }    

    @isTest static void testPE_withCorrelationId() {
        Exception e;
        //force exception
        try{
            String s;
            s.toLowerCase();
        }catch(NullPointerException npe){
            e = npe;
        }
        Test.startTest();
            ExceptionLogger.logException(CLASSNAME,'cid-12345-765',e,'ADDITIONAL INFO',true);
        Test.stopTest();
        Logger__c log = [select Name, Correlation_Id__c from Logger__c LIMIT 1];
        System.assert(log != null);
        System.assertEquals(log.Correlation_Id__c, 'cid-12345-765');
    }

      /**
     *  Test Class handling standard exception
     */
    @isTest static void testStandard() {
        Exception e;
        //force exception
        try{
            String s;
            s.toLowerCase();
        }catch(NullPointerException npe){
            e = npe;
        }
        Test.startTest();
            ExceptionLogger.logException(CLASSNAME,'testStandard',e,null);
            
        Test.stopTest();
        Logger__c log = [select Name, Exception_Type__c,Exception_Line_Number__c,Exception_Error_Message__c,Exception_StackTrace__c,Exception_Method_Name__c from Logger__c LIMIT 1];
        System.assertEquals(log.Name, CLASSNAME,'Log Name should have been the classname');
        System.assertEquals(log.Exception_Type__c, 'System.NullPointerException','Excepted NullPointerException Type but was : ' +log.Exception_Type__c );
        System.assert(log.Exception_Error_Message__c != null,'Excepted Exception_Error_Message__c but was : ' + log.Exception_Error_Message__c );
        System.assertEquals(log.Exception_Method_Name__c,'testStandard','Excepted testStandard Type but was : ' +log.Exception_Method_Name__c );
    }



   /**
     *  Test Class handling standard exception
     */
    @isTest static void testDML() {
        Exception e;
        //force exception
        try{
            Account a = new Account();
            insert a;
        }catch(Exception dmle){
            e = dmle;
        }
        Test.startTest();
            ExceptionLogger.logException(CLASSNAME,'testDML',e,'TEST MESSAGE');
        Test.stopTest();
        Logger__c log = [select Name, Exception_Type__c,Exception_DML_Message__c,Exception_Line_Number__c,Exception_Error_Message__c,Exception_StackTrace__c,Exception_Method_Name__c from Logger__c LIMIT 1];
        System.assertEquals(log.Name, CLASSNAME,'Log Name should have been the classname');
        System.assertEquals(log.Exception_Type__c, 'System.DmlException','Excepted DmlException Type but was : ' +log.Exception_Type__c );
        System.assert(log.Exception_Error_Message__c != null,'Excepted Exception_Error_Message__c but was : ' + log.Exception_Error_Message__c );
        System.assert(log.Exception_DML_Message__c != null,'Excepted Exception_DML_Message__c but was : ' + log.Exception_DML_Message__c );
        System.assertEquals(log.Exception_Method_Name__c,'testDML','Excepted testDML Type but was : ' +log.Exception_Method_Name__c );
    }    

}
