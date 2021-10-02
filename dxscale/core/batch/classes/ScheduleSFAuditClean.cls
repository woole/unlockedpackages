/**
 * @description Logger archive schedule job
 * Usage example: System.schedule('ScheduleSFAuditClean', '0 40 12 * * ?', new ScheduleSFAuditClean());
 * - Ensure custom metadata BatchSettings__mdt has an entry for this class name
 * - the field "Archive Before Days" indicates how many days of the most recent records should be preserved
 * - setting this to zero will empty the Logger__c table (though the cleanup job will create its own log)
 */
global class ScheduleSFAuditClean implements Schedulable {

    private static final String CLASSNAME = 'ScheduleSFAuditClean';
    
    //only for testing
    @TestVisible
    private BatchSettings__mdt testConfig = new BatchSettings__mdt();

    global static Integer RUNNING_BATCH_LIMIT = 4;
    global static Integer WAIT_MINUTES = 1;
    // clean-up setup values
    global static String CLEAN_UP_OBJECT = 'Service_Framework_Audit__c';
    global static String CLEAN_UP_REFERENCE = 'SFAudtiCleaner';

    /**
     * execute job batch. Schedule again logic if batch queue full.
     * @param context
     */
	global void execute(SchedulableContext sc) {
        LogControl.push('execute', CLASSNAME);
        try{
            Integer runningJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
            // if there are a few batch jobs already running then delay scheduling the batch for a minute
            if (runningJobs >= RUNNING_BATCH_LIMIT) {
                // Re-schedule to run again in WAIT_MINUTES time
                scheduleAgain();
            } else {
                BatchSettings__mdt cleanUpSetting = getConfig();
                // quit without purge if custom setting entry not found
                if (cleanUpSetting == null) {
                    System.debug('No BatchSettings__mdt records exists for class ScheduleSFAuditClean');
                    return;
                }
                Decimal beforeDays = (cleanUpSetting.Archive_Before_Days__c > 0 ? cleanUpSetting.Archive_Before_Days__c * -1 : cleanUpSetting.Archive_Before_Days__c);
                Boolean emptyRecycleBin = cleanUpSetting.Empty_Recycle_Bin__c;
                String query = 'SELECT Id FROM ' + CLEAN_UP_OBJECT;
                if (beforeDays != 0) {
                    query += ' WHERE CreatedDate != LAST_N_DAYS:' + (Integer)cleanUpSetting.Archive_Before_Days__c;
                }
                System.debug('Query records for deletion: ' + query);
                RecordCleanerBatch batch_obj = new RecordCleanerBatch(query, CLEAN_UP_OBJECT, CLEAN_UP_REFERENCE,emptyRecycleBin);
                Database.executeBatch(batch_obj, 25);
            }
        }catch (Exception e){
            ExceptionLogger.logException(CLASSNAME, 'execute', e, 'unable to execute Audit Cleanup');
        }finally{
            LogControl.pop(); 
        }
        
    }
    
    public BatchSettings__mdt getConfig(){
        return Test.isRunningTest()?testConfig:[select Archive_Before_Days__c,Empty_Recycle_Bin__c,Summariser_Class__c,DeveloperName from BatchSettings__mdt where DeveloperName = 'ScheduleSFAuditClean' LIMIT 1];
    }


    /**
     * Schedule again in a minute (WAIT_MINUTES) when batch queue full
     * All Cron parameters are specified without wildcards to ensure only a single additional run is scheduled
     */
    public String scheduleAgain() {
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(WAIT_MINUTES);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' '
                + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        String schedJobNameUnique = ScheduleSFAuditClean.class.getName()
                + '-' + nextRunTime.year() + nextRunTime.month() + nextRunTime.day() + nextRunTime.hour() + nextRunTime.minute() + nextRunTime.second();
        System.debug('cronString = ' + cronString + ' schedJobNameUnique = ' + schedJobNameUnique);
        return System.schedule(schedJobNameUnique, cronString, this);
    }

}
