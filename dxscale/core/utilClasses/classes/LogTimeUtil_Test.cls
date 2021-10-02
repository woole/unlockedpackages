@isTest
public class LogTimeUtil_Test {
    
    @isTest
    static void testLog_OK(){
        LogTimeUtil timer = LogTimeUtil.getInstance('Test');
        timer.start();
        String logEntry = timer.end();
        System.assert(logEntry != null,'expected a debug log entry back');
        System.debug(LoggingLevel.DEBUG, logEntry);
        System.assert(logEntry.contains('STATS : Test'),'expected to contain STATS : Test but was ' + logEntry);
    }

    /**
     * Tests that an entry isn't produced if you don't call start
     */
    @isTest
    static void testLog_NoEntry(){
        LogTimeUtil timer = LogTimeUtil.getInstance('Test');
        
        String logEntry = timer.end();
        System.assert(logEntry == null,'expected NO debug log entry back');

    }

}
