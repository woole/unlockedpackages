@IsTest
public class ServiceAuditPublisher_Test {

    @IsTest
    public static void createAuditMessage () {

        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setServiceInvocationName('invocation');
        invocationDetails.setServiceName('service');
        invocationDetails.setImplementingClass('implementingClass');
        invocationDetails.setIteration(1);
        invocationDetails.setMethod('method');

        IStringInput inputData = new StringInputV1();
        inputData.setInputMessage ('input');

        IStringOutput outputData = new StringOutputV1();
        outputData.setOutputMessage ('output');

        IStringOutput auditData = null;

        Test.startTest();
        IService_Audit auditInput = ServiceAuditPublisher.createAuditMessage (invocationDetails, inputData, outputData, auditData);
        Test.stopTest();

        auditInput.parseInvocationDetails();

        System.assertEquals('invocation',auditInput.getInvocationName());
        System.assertEquals('method',auditInput.getMethod());
        System.assertEquals(1,auditInput.getIteration());
        System.assertEquals('service',auditInput.getServiceName());
        System.assertEquals('implementingClass',auditInput.getImplementingClass());

    }

    @IsTest
    public static void createBigAuditMessage () {

        String loopString = '12345678';

        while (loopString.length() < ServiceAuditPublisher.MAX_AUDIT_SIZE) {
            loopString = loopString + loopString;
        }

        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();

        IStringInput inputData = new StringInputV1();
        inputData.setInputMessage (loopString);

        IStringOutput outputData = new StringOutputV1();
        outputData.setOutputMessage (loopString);

        IStringOutput auditData = null;

        Test.startTest();
        IService_Audit auditInput = ServiceAuditPublisher.createAuditMessage (invocationDetails, inputData, outputData, auditData);
        Test.stopTest();

        System.assert(auditInput.getInputData().startsWith(ServiceConfigStrings.AUDIT_MESSAGE_TOO_LONG), 'Big Audit Messages should be truncated and have a meaningful piece of text prepended to signify this');


    }

    @IsTest
    public static void invocationWithNoAuditSetup () {

        // Runs a simple invocation but with a non-existent Audit method

        ServiceConfigStrings.AUDIT_SERVICE_INVOCATION = 'Fake';

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 

        IStringOutput outputData = (IStringOutput) sinv.invokeService(sinput);
        System.assertEquals('SUCCESS', outputData.getState(),'Correct Invocation of a synchronous service run should return state = SUCCESS even if there is no Audit invocation record present');
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'Correct Invocation run should return populated output fields even if there is no Audit invocation record present');
    }

    @IsTest
    public static void invocationWithLoggingOff () {

        // Runs a simple invocation with logging switched off
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.logRequests = false;
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 

        IStringOutput outputData = (IStringOutput) sinv.invokeService(sinput);
        System.assertEquals('SUCCESS', outputData.getState(),'Correct Invocation of a synchronous service run should return state = SUCCESS even if there is no Audit invocation record present');
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'Correct Invocation run should return populated output fields even if there is no Audit invocation record present');
    }


    /* getAuditPoint returns true tests */

    @IsTest
    public static void getAuditPoint () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Sync');

        String state = 'SUCCESS';
        String callPoint = 'Invoker';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(doAudit, 'Sync service should have an audit point in the invoking code');
    }

    @IsTest
    public static void getAuditPoint_ErrorAudits () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Sync');

        String state = 'FAILURE';
        String callPoint = 'Service';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(doAudit, 'Any error response should audit');
    }

    @IsTest
    public static void getAuditPoint_setAsyncOnlyLogServiceFalse () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Async');
        invocationDetails.setLogRequests(true);
        invocationDetails.setAsyncOnlyLogService(false);

        String state = 'SUCCESS';
        String callPoint = 'Invoker';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(doAudit, 'Async service should have an invoker audit point if log requests is true but only log service is false');
    }

    @IsTest
    public static void getAuditPoint_setAsyncOnlyLogServiceFalse_Queueable () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Queueable');
        invocationDetails.setLogRequests(true);
        invocationDetails.setAsyncOnlyLogService(false);

        String state = 'SUCCESS';
        String callPoint = 'Invoker';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(doAudit, 'Queueable service should have an invoker audit point if log requests is true but only log service is false');
    }

    /* getAuditPoint returns false tests */

    @IsTest
    public static void getAuditPoint_NoAuditIfLogRequestsFalse () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Sync');
        invocationDetails.setLogRequests(false);

        String state = 'SUCCESS';
        String callPoint = 'Invoker';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(!doAudit, 'Sync service should not have an audit point if log requests is false');

    }

    @IsTest
    public static void getAuditPoint_setAsyncOnlyLogService () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Async');
        invocationDetails.setLogRequests(true);
        invocationDetails.setAsyncOnlyLogService(true);

        String state = 'SUCCESS';
        String callPoint = 'Invoker';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(!doAudit, 'Async service should not have an invoker audit point if log requests is true but only log service is also true');

    }



    @IsTest
    public static void getAuditPoint_AuditDoesNotAudit () {
        IInvocation_Details invocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        invocationDetails.setInvocationType('Audit');

        String state = 'SUCCESS';
        String callPoint = 'Invoker';        

        Test.startTest();
        boolean doAudit = ServiceAuditPublisher.getAuditPoint (invocationDetails, state, callPoint);
        Test.stopTest();

        System.assert(!doAudit, 'Audit service should not have an audit point in the invoking code');

    }

}
