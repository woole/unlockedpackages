@IsTest
public class ServiceAlignment_Test {

    @IsTest
    public static void getInvocationStatic() {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();
        
        IInvocation_Details invocationDetails = ServiceValidator.getInvocationStatic(baseSetup.serviceInvocationName);
        System.assertEquals(baseSetup.serviceName, invocationDetails.getServiceName(),'Static should act on the same service as specified in input');
        System.assertEquals('SUCCESS', invocationDetails.getValidationState(),'Static should process correctly on valid input');
    }

    @IsTest
    public static void getInvocationStaticStub() {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        IInvocation_Details invocationDetails = ServiceValidator.getInvocationStatic(baseSetup.serviceInvocationName);
        System.assertEquals(baseSetup.serviceName, invocationDetails.getServiceName(),'Static should act on the same service as specified in stub input');
        System.assertEquals('SUCCESS', invocationDetails.getValidationState(),'Static should process correctly on valid stub input');

    }

    @IsTest
    public static void getInvocationStaticNoConfiguredServiceIterationMethod () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceIteration = 500;
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        // test requires the invocation having a non-existent iteration number so we change before creating the iteration metadata
        baseSetup.serviceIteration = 1;
        baseSetup.serviceSetup();

        IInvocation_Details invocationDetails = ServiceValidator.getInvocationStatic(baseSetup.serviceInvocationName);
        System.assertEquals(ServiceErrorStrings.STATE_NO_SERVICE_METHOD, invocationDetails.getValidationState(),'Static should error on a non-existent iteration');
    }

    @IsTest
    public static void getInvocationStaticImplementingClassNotAServiceImplementation () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.implementingClass = 'ServiceAlignment_Test'; // a real class but not a Service Implementation
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        IInvocation_Details invocationDetails = ServiceValidator.getInvocationStatic(baseSetup.serviceInvocationName);
        System.assertEquals(ServiceErrorStrings.STATE_IMPLEMENTING_CLASS_INVALID, invocationDetails.getValidationState(),'Static should error if the implementing class specific is not an instance of IService_Implementation');
        System.assert(invocationDetails.getValidationErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_IMPLEMENTING_CLASS_INVALID),'Static should return a meaningful error message if the implementing class specific is not an instance of IService_Implementation');
    }




}
