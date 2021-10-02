@IsTest
public class ServiceMetadata_Test {

    @IsTest
    public static void serializeInvocationDetails() {
        ServiceInvocationImplementations.InvocationDetails sad = new ServiceInvocationImplementations.InvocationDetails();
        sad.setServiceName('Action_Definition_Test');
        String strInvocationDetails = ServiceSerialize.serializeObject(sad);

        IInvocation_Details sadAfter = Service.deserializeInvocationDetails(strInvocationDetails);
        System.assertEquals('Action_Definition_Test', sadAfter.getServiceName());
    }

    @IsTest
    public static void createTestMetadata() {
        String serviceName = 'MustNotBeRealCMTRecordName';
        Service__mdt serviceMDT = Service.createTestMetadata(serviceName);
        Service.cacheMetadataWrap(serviceMDT);

        Service svc = Service.initialize (serviceName);
        Service__mdt serviceMDTAfter = svc.getServiceMetadata();

        System.assertEquals(serviceName, serviceMDTAfter.DeveloperName);
    }


    @IsTest
    public static void testMetadataWraps () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // Test our fake Service Metadata
        Service svc = Service.initialize (baseSetup.serviceName);
        Service__mdt serviceMDT = svc.getServiceMetadata();


        System.assertEquals(baseSetup.serviceName, serviceMDT.DeveloperName,'Service.getMetadataWrap should return correct developer name');
        System.assertEquals('Active', serviceMDT.Status__c,'Test setup of Service.getMetadataWrap should have active status');

        // Test our fake Service Method Metadata
        ServiceMethod.ServiceMethodWrap smw = ServiceMethod.getMetadataWrap (baseSetup.serviceName, baseSetup.serviceIteration, baseSetup.serviceMethodName);
        System.assertEquals(baseSetup.serviceName, smw.serviceName,'ServiceMethod.getMetadataWrap should return correct service name');
        System.assertEquals(baseSetup.serviceMethodName, smw.serviceMethodName,'ServiceMethod.getMetadataWrap should return correct method name');
        System.assertEquals(baseSetup.serviceImplementationName, smw.serviceImplementationName,'ServiceMethod.getMetadataWrap should return correct implementation name');

        // Test our fake Service Version Metadata
        ServiceImplementation.ServiceImplementationWrap simpw = ServiceImplementation.getMetadataWrap (baseSetup.serviceImplementationName);
        System.assertEquals(baseSetup.serviceImplementationName, simpw.serviceImplementationName,'ServiceImplementation.getMetadataWrap should return correct implementation name');

    }


    @IsTest
    public static void testServiceWithOutboundBrokerFieldsSetup () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceType = 'External Outbound';
        baseSetup.externalCredentialsLabel = '01MobileDev';

        // this should cache the overwritten values so that the initialized service references the next values
        baseSetup.serviceSetup();

        Service svc = Service.initialize (baseSetup.serviceName);

        System.assertEquals(baseSetup.serviceType, svc.getServiceType(),'Service.getServiceType returns configured value');
        System.assertEquals(baseSetup.externalCredentialsLabel, svc.getExternalCredentialsLabel(),'Service.getExternalCredentialsLabel returns configured value');
    }


    @IsTest
    public static void invocationReferenceBadService () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.serviceSetup();
        // test requires the invocation to try to call a service which is not named
        Service svc = Service.initialize (baseSetup.serviceName);
        Service__mdt serviceMDT = svc.getServiceMetadata();
        serviceMDT.status__c = 'Dud';
        Service.cacheMetadataWrap(serviceMDT);

        ServiceInvocation sinv;
        try {
            sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        }
        catch (Service.ServiceFrameworkException sfe) {
            System.assert(sfe.getMessage().startsWith(ServiceErrorStrings.STATE_NO_INVOCATION_FOUND + baseSetup.serviceInvocationName),'Attempting to invoke a service which does not have a Service metadata record should result in a meaningful error message');
        }
    }

    @IsTest
    public static void serviceInvocationUsesOverrideDefault () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.overrideDefault = true;
        baseSetup.insertServiceInvocationOverride();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IInvocation_Details isi = sinv.getOverride ();
        System.assert(isi.getOverrideDefault(),'invocations should use custom setting override default when one is set');
    }

    @IsTest
    public static void serviceInvocationNotOverridenNoDefaultNoPerm () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.overrideDefault = false;
        baseSetup.insertServiceInvocationOverride();
        ServiceInvocation sinv = new ServiceInvocation(baseSetup.serviceInvocationName);

        IInvocation_Details invocationDetails = sinv.getOverride ();
        // The user does not have the Custom Permiision so the override is null
        System.assert(invocationDetails == null, 'No override should be returned for a user who does not have a custom permission for any record when no record is set as the default');
    }

    @IsTest
    public static void testIsPassThroughWithoutNextInvocation () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.howImplemented = 'PassThrough';
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();        

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 
        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_PASS_THROUGH_WO_NEXT_INV, outputData.getState(),ServiceErrorStrings.STATE_PASS_THROUGH_WO_NEXT_INV);
    }

    @IsTest
    public static void chainInvocationRunReturnsSuccess () {

        // Set up two services, iterations, methods and invocations.
        String nextInvocationServiceName = 'nextInvocationServiceName';
        String nextInvocationServiceInvocationName = 'nextInvocationServiceInvocationName';

        ServiceFrameworkBaseTestSetup baseSetup2 = new ServiceFrameworkBaseTestSetup();
        baseSetup2.serviceName = nextInvocationServiceName;
        baseSetup2.serviceInvocationName = nextInvocationServiceInvocationName;

        baseSetup2.howImplemented = 'Implementation';
        baseSetup2.invocationType = 'Sync';
        baseSetup2.outputInterfaceVersion = 'IStringOutput';
        baseSetup2.outputCreationClass = 'StringIO';
        baseSetup2.insertServiceInvocationOverride();
        baseSetup2.serviceSetup();


        String passThroughInvocationServiceName = 'ptInvocationServiceName';
        String passThroughInvocationServiceInvocationName = 'ptInvocationServiceInvocationName';    

        ServiceFrameworkBaseTestSetup baseSetup1 = new ServiceFrameworkBaseTestSetup();
        baseSetup1.serviceName = passThroughInvocationServiceName;
        baseSetup1.serviceInvocationName = passThroughInvocationServiceInvocationName;

        baseSetup1.nextInvocationName = nextInvocationServiceInvocationName;
        baseSetup1.howImplemented = 'PassThrough';
        baseSetup1.outputInterfaceVersion = 'IStringOutput';
        baseSetup1.invocationType = 'Sync';
        baseSetup1.insertServiceInvocationOverride();
        baseSetup1.serviceSetup();     

        // // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup1.serviceInvocationName);


        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 


        IService_Output_Master rawOutput = sinv.invokeService(sinput);
        System.assertEquals('SUCCESS', rawOutput.getState(),'Correct Invocation of a chained service run should return state = SUCCESS');

        IStringOutput outputData = (IStringOutput) rawOutput;
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'Correct Invocation of a chained service run should return populated output fields');

    }

    @IsTest
    public static void chainInvocationPTWithoutNextInvFails () {

        String passThroughInvocationServiceName = 'ptInvocationServiceName';
        String passThroughInvocationServiceInvocationName = 'ptInvocationServiceInvocationName';    

        ServiceFrameworkBaseTestSetup baseSetup1 = new ServiceFrameworkBaseTestSetup();
        baseSetup1.serviceName = passThroughInvocationServiceName;
        baseSetup1.serviceInvocationName = passThroughInvocationServiceInvocationName;

        baseSetup1.howImplemented = 'PassThrough';
        baseSetup1.outputInterfaceVersion = 'IStringOutput';
        baseSetup1.invocationType = 'Sync';
        baseSetup1.insertServiceInvocationOverride();
        baseSetup1.serviceSetup();     

        // // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup1.serviceInvocationName);


        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 

        IService_Output_Master outputData = sinv.invokeService(sinput);
        System.assertEquals(ServiceErrorStrings.STATE_PASS_THROUGH_WO_NEXT_INV, outputData.getState(),ServiceErrorStrings.ERRORMSG_PASS_THROUGH_WO_NEXT_INV);

    }



}
