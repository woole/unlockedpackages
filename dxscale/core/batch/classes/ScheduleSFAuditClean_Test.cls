@isTest
public class ScheduleSFAuditClean_Test {

    @TestSetup
    static void setupLoggerData() {
        List <Service_Framework_Audit__c> testLogs = new List<Service_Framework_Audit__c>();
        Service_Framework_Audit__c log1 = new Service_Framework_Audit__c(Service_Name__c='Service1', Implementing_Class__c='ABC123',Input_Data__c='{value}');
        insert log1;
        Service_Framework_Audit__c log2 = new Service_Framework_Audit__c(Service_Name__c='Service2', Implementing_Class__c='ABC123',Input_Data__c='{value}');
        insert log2;
        Service_Framework_Audit__c log3 = new Service_Framework_Audit__c(Service_Name__c='Service3', Implementing_Class__c='ABC123',Input_Data__c='{value}');
        insert log3;
        Service_Framework_Audit__c log4 = new Service_Framework_Audit__c(Service_Name__c='Service4', Implementing_Class__c='ABC123',Input_Data__c='{value}');
        insert log4;
        Datetime twoDaysBack = Datetime.now().addDays(-2);
        Datetime fiveDaysBack = Datetime.now().addDays(-5);
        Datetime sevenDaysBack = Datetime.now().addDays(-7);
        Test.setCreatedDate(log1.Id, twoDaysBack);
        Test.setCreatedDate(log2.Id, fiveDaysBack);
        Test.setCreatedDate(log3.Id, sevenDaysBack);
        Test.setCreatedDate(log4.Id, sevenDaysBack);
        Service_Framework_Audit__c log5 = new Service_Framework_Audit__c(Service_Name__c='Service5', Implementing_Class__c='ABC123',Input_Data__c='{value}');
        insert log5;

    }

    @IsTest
    static void testScheduleAgain() {

        Test.startTest();
            ScheduleSFAuditClean scheduler = new ScheduleSFAuditClean();
            scheduler.testConfig.Archive_Before_Days__c = 1;
            scheduler.testConfig.DeveloperName = 'ScheduleSFAuditClean';            
            String jobId = scheduler.scheduleAgain();
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(0,ct.TimesTriggered, 'should be a cron entry but not fired yet');
        Test.stopTest();	
        
    }    
   
    /**
     * Test: running LoggerArchiveSchedulable gets scheduled
     */

     @isTest
     public static void testGetConfig(){
         //test scenario
         ScheduleSFAuditClean scheduler = new ScheduleSFAuditClean();
         scheduler.testConfig.Archive_Before_Days__c = 1;
         scheduler.testConfig.DeveloperName = 'ScheduleSFAuditClean';
         scheduler.testConfig.Empty_Recycle_Bin__c = true;
         
         System.assertEquals('ScheduleSFAuditClean', scheduler.getConfig().DeveloperName,'test confg should have been set and returned');
         System.assertEquals(true, scheduler.getConfig().Empty_Recycle_Bin__c,'test confg empty recycle bin should have been true');
     }

     @IsTest
     static void testLoggerSchedulable() {
        ScheduleSFAuditClean scheduler = new ScheduleSFAuditClean();
        scheduler.testConfig.Archive_Before_Days__c = 1;
        scheduler.testConfig.DeveloperName = 'ScheduleSFAuditClean';
         Test.startTest();
         // Schedule the test job
         String jobId = System.schedule('CleanUpTest.TestScheduleSFAuditClean', '0 30 0 1 12 ? 2099', scheduler);
         
         // Get the information from the CronTrigger API object
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
         
         // Verify the expressions are the same
         System.assertEquals('0 30 0 1 12 ? 2099', ct.CronExpression,'coron expression should match but was ' + ct.CronExpression);
         
         // Verify the job has not run
         System.assertEquals(0, ct.TimesTriggered,'cront task should not have triggered');
         
         // Verify the next time the job will run
         System.assert(String.valueOf(ct.NextFireTime).contains('00:30:00'),'Next fire time : ' + ct.NextFireTime + ' not as expected');
 
         // check here - batch has not run yet
         Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
         System.assertEquals(0, runningJobs,'Expected no Jobs to be returned');
 
         // force schedule to run
         Test.stopTest();
 
         // batch has started - but will complete after this test.
         runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
         System.assertEquals(1, runningJobs,'running jobs should have been 1');
     }
    
    @IsTest
    static void testAuditCleanupSixDays() {
        // The query used by the batch job.
        String query = 'SELECT Id FROM Service_Framework_Audit__c WHERE CreatedDate < LAST_N_DAYS:6';

        Test.startTest();

        RecordCleanerBatch c = new RecordCleanerBatch(query, 'Service_Framework_Audit__c', 'ScheduleSFAuditClean',false);
        Database.executeBatch(c);

        Test.stopTest();

        // all our logs are recent, so none should have been deleted
        Integer remainingLogs = [SELECT COUNT() FROM Service_Framework_Audit__c WHERE Implementing_Class__c = 'ABC123'];
        System.assertEquals(3, remainingLogs,'expect 3 records but was : ' + remainingLogs);
    }   

    @IsTest
    static void testAuditCleanupFourDays() {
        // The query used by the batch job.
        String query = 'SELECT Id FROM Service_Framework_Audit__c WHERE CreatedDate < LAST_N_DAYS:4';

        Test.startTest();

        RecordCleanerBatch c = new RecordCleanerBatch(query, 'Service_Framework_Audit__c', 'ScheduleSFAuditClean',false);
        Database.executeBatch(c);

        Test.stopTest();

        // all our logs are recent, so none should have been deleted
        Integer remainingLogs = [SELECT COUNT() FROM Service_Framework_Audit__c WHERE Implementing_Class__c = 'ABC123'];
        System.assertEquals(2, remainingLogs,'expect 2 records but was : ' + remainingLogs);
    }  


}
