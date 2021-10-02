@IsTest
public class ServiceMethod_Test {


    @IsTest
    public static void testGetNextInvocation () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.nextInvocationName = 'SalesforceOutboundBrokerInvocation';
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        ServiceValidator sv = new ServiceValidator(invocationDetails);
        IService_Output_Master serviceValidationOutput = sv.validateServiceSetup();

        System.assertEquals('SUCCESS', serviceValidationOutput.getState(),'Setting up next invocation should not break Service Validator');
        System.assertEquals(baseSetup.nextInvocationName, invocationDetails.getNextInvocation(),'Configured next invocation names must be represented in invocation details');
        System.assert(invocationDetails.getIsChained(),'Setting up next invocation should set isChained to true in Service Validator');

    }


}
