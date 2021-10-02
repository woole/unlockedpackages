/**
 * This only tests the flow of the messages in the LogControl and not the platform events
 */
@isTest
public with sharing class LogControlTest {
    

    @isTest
    public static void testLogPush(){
        Test.startTest();
        LogControl.push('testLog', 'LogControlTest');
        Test.stopTest();
        System.assert(LogControl.stack.size() == 1,'Log should have had 1 message added'+ LogControl.stack.size() );
    }

    @isTest
    public static void testLogDebug(){
        
        LogControl.push('testLog1', 'LogControlTest');
        System.assert(LogControl.stack.size() == 1,'Log should have had 1 message added'+ LogControl.stack.size() );
        Exception e = new AuraException('error');
        LogControl.debugException(e);
        System.assert(LogControl.exceptionEvents.size() == 1,'Log should have had 1 exceptionEvents added'+ LogControl.exceptionEvents.size() );
        LogControl.pop();
        System.assert(LogControl.stack.isEmpty(),'stack should have emptied'+ LogControl.stack.size() );
    }

    @isTest
    public static void testLogPop(){
        Test.startTest();
        LogControl.push('testLog', 'LogControlTest');
        LogControl.pop();
        Test.stopTest();
        System.assert(LogControl.exceptionEvents.size() == 0,'exception map should have been emptied'+ LogControl.exceptionEvents.size() );
        System.assert(LogControl.stack.size() == 0,'stack should have been emptied'+ LogControl.stack.size() );

    }    


}
