@isTest
public class RecordCleanerBatch_Test {

    @isTest
    static void testCleanUp() {
        // The query used by the batch job.
        String query = 'SELECT Id, CreatedDate FROM Account';
        
        // Create some test items to be deleted by the batch job.
        List<Account> accList = new List<Account>();
        for (Integer i=0;i<10;i++) {
            Account acc = new Account(Name = 'Test Account'+i, Type = 'Customer', 
                                      Industry = 'Finance', Phone = '12345678',BillingCity='Test City',
                                      BillingCountry='Belgium', BillingStreet ='Sample Street');
            accList.add(acc);
        }
        insert accList;
        // Verify items
        System.assertEquals(10, [SELECT COUNT() FROM Account],'expected 10 but was not');
        
        Test.startTest();
        RecordCleanerBatch c = new RecordCleanerBatch(query, 'Account','testExecution',false);
        Database.executeBatch(c);
        
        Test.stopTest();
        
        // Verify items got deleted 
        Integer i = [SELECT COUNT() FROM Account];
        System.assertEquals(0, i,'expect all records cleaned');
        for(Logger__c log : [select id, Name, Record_Name_Id__c, Record_Details__c, Exception_StackTrace__c, 
                             Exception_Method_Name__c, Exception_Error_Message__c From Logger__c]){
                                 system.debug('***log:'+log);
                             }
    }
        /**
    * Test: Successful CleanUpBatch
    */
    @isTest
    static void testNoRecords() {
        // The query used by the batch job.
        String query = 'SELECT Id, CreatedDate FROM Account';

        Test.startTest();
        RecordCleanerBatch c = new RecordCleanerBatch(query, 'Account','testExecution');
        Database.executeBatch(c);
        Test.stopTest();
        
        // Verify items got deleted 
        Integer i = [SELECT COUNT() FROM Account];
        System.assertEquals(0, i,'expect all records cleaned');
        for(Logger__c log : [select id, Name, Record_Name_Id__c, Record_Details__c, Exception_StackTrace__c, 
                             Exception_Method_Name__c, Exception_Error_Message__c From Logger__c]){
                                 system.debug('***log:'+log);
                             }
    }
  

    /**
    * Test: execution of processMessage method
    */
    @isTest
    static void testProcessMessage(){
        // initialise batch class
        RecordCleanerBatch cleanup = new RecordCleanerBatch('query','Account','testExecution');
        // setup any test record
        Account acc = new Account(Name = 'Test Account', Type = 'Customer', 
                                  Industry = 'Finance', Phone = '12345678',BillingCity='Test City',
                                  BillingCountry='Belgium', BillingStreet ='Sample Street');
        // setup batch context
        Database.BatchableContext dbc;
        //
        // Test - processMessage method with parameters
        Logger__c messageLogger=cleanup.processMessage(acc, 'methodName', 'errMsg', dbc, null);//Exception ex)
        //
        // check results
        system.assertEquals('errMsg',messageLogger.Exception_Error_Message__c,'expected errMsg but was ' +messageLogger.Exception_Error_Message__c);
        system.assertEquals('testExecution|RecordCleanerBatch',messageLogger.Name,'expected testExecution|RecordCleanerBatch but was ' + messageLogger.Name);
        String recDetails=messageLogger.Record_Details__c;
        system.assert(recDetails.contains('Test Account'),'should have contained Test Account');
        //
        // Test - exception logging
        boolean errorFound=false;
        try {
            throw new TestException('test exception');
        } catch(Exception e) {
            errorFound=true;
            cleanup.processMessage(null, 'testMethod', null, dbc, e);
        }
        // check exception thrown
        system.assert(errorFound,'should throw exception');
        // check logger record inserted
        List<Logger__c> logList=[select id, Name, Exception_Error_Message__c from Logger__c];
        system.assert(logList[0].Exception_Error_Message__c!=null,'Error message should not be null');
    }

    @isTest
    static void testDMLException(){
        
        //force a DML to test it
        Test.startTest();
        try{
            insert new Lead();
        }catch(DmlException dme){
            String message = RecordCleanerBatch.catchDMLException(dme);
            System.assert(message != null, 'should have converted to string');
        } 
        

    }

    public class TestException extends Exception {}     



}
