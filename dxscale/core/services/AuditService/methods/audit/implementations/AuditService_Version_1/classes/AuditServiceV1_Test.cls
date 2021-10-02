@IsTest
public class AuditServiceV1_Test {


    @IsTest
    public static void testAuditServiceV1ImplementationBody () {
        AuditServiceV1 asv1 = new AuditServiceV1();

        IService_Audit inputData = new ServiceAudit();

        IInvocation_Details originalInvocationDetails = new ServiceInvocationImplementations.InvocationDetails();
        originalInvocationDetails.setServiceName('service');
        originalInvocationDetails.setImplementingClass('implementingClass');
        originalInvocationDetails.setIteration(1);
        originalInvocationDetails.setMethod('method');

        inputData.setInputData('originalInputData');
        inputData.setOutputData('originalOutputData');
        String serializedInvocationDetails = ServiceSerialize.serializeObject(originalInvocationDetails);
        inputData.setInvocationDetails( serializedInvocationDetails);

        Test.startTest();
        IStringOutput outputData = asv1.implementationBody( originalInvocationDetails,  inputData);      
        Test.stopTest();

        System.assertEquals('SUCCESS', outputData.getState(),'Exepcted the response to be SUCCESS');
        System.assertEquals('Audit Message Posted', outputData.getOutputMessage(),'Exepcted the Audit message to be posted');

        list<Service_Framework_Audit__c> listsfa = [
            select id, createddate, Input_Data__c,Output_Data__c ,Invocation_Details__c, Service_Name__c, Method__c, Iteration__c from Service_Framework_Audit__c];

        System.assertEquals(1, listsfa.size(),'Should have returned 1 records from Service_Framework_Audit__c');
        Service_Framework_Audit__c sfa = listsfa[0];
        System.assertEquals('originalInputData', sfa.Input_Data__c,'Input_Data__c should have been originalInputData but was ' + sfa.Input_Data__c);
        System.assertEquals('originalOutputData', sfa.Output_Data__c,'Output_Data__c should have been originalOutputData but was ' + sfa.Output_Data__c);
        System.assertEquals(serializedInvocationDetails, sfa.Invocation_Details__c,'the Invocation_Details__c should haev matched');

        System.assertEquals('service', sfa.Service_Name__c,'Service_Name__c should have been service but was ' + sfa.Service_Name__c);
        System.assertEquals('method', sfa.Method__c,'Method__c should have been method but was ' + sfa.Method__c);
        System.assertEquals(1, sfa.Iteration__c,'Iteration__c should have been 1 but was ' + sfa.Iteration__c);

    }

    @IsTest private static void extractState() {
        Test.startTest();
        String extracted = AuditServiceV1.extractState('SUCCESS');      
        Test.stopTest();
        System.assertEquals('SUCCESS', extracted,'var extracted should have been SUCCESS');
    }

    @IsTest private static void extractStateFailure() {
        Test.startTest();
        String extracted = AuditServiceV1.extractState('FAILURE: this is a really long failure message that should be');      
        Test.stopTest();
        System.assertEquals('FAILURE', extracted,'var extracted should have been FAILURE');
    }


}


