@IsTest
public with sharing class ServiceInvocation_Test {

    @IsTest
    public static void correctInvocationRunReturnsSuccess () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 

        IStringOutput outputData = (IStringOutput) sinv.invokeService(sinput);
        System.assertEquals('SUCCESS', outputData.getState(),'Correct Invocation of a synchronous service run should return state = SUCCESS');
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'Correct Invocation run should return populated output fields');
        System.assertEquals('Real', outputData.getDataReality(),'Services need to inform if data if data is from a real source or is stubbed');
    }

    @IsTest
    public static void invokingDownService () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        Service svc = Service.initialize (baseSetup.serviceName);
        Service__mdt serviceMDT = svc.getServiceMetadata();

        serviceMDT.status__c = 'Down';
        Service.cacheMetadataWrap(serviceMDT);

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('');

        IService_Output_Master outputData = sinv.invokeService(sinput);
        System.assertEquals(ServiceErrorStrings.STATE_SERVICE_IS_DOWN, outputData.getState(),'If a service is down this must be relayed back to invokers');
    }



    @IsTest
    public static void serviceReportsAFailure () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('FAILURE');

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals('FAILURE', outputData.getState(),'Service implementations that fail for business reasons should pass state back to invocations');
        System.assertEquals('Failure Message', outputData.getErrorMessage(),'Service implementations that fail for business reasons should pass a meaningful error message back to invocations');

    }

    @IsTest
    public static void serviceExceptionThrownCaughtAndPackaged () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('Throw');

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_SERVICE_GENERIC_EXCEPTION, outputData.getState(),'If a service fails unexpectedly and throws an exception then this should be caught and packaged back to the invocation as an IService_Output_Master structure. ');

    }


    @IsTest
    public static void correctAsyncInvocationRunReturnsSuccess () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        sinv.getInvocationDetails().setInvocationTime(DateTime.Now());            

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS');

        List<ServiceSerialize.SerializedInvocationStructure> listInputs = new List<ServiceSerialize.SerializedInvocationStructure>();
        ServiceSerialize.SerializedInvocationStructure params = new ServiceSerialize.SerializedInvocationStructure();
        params.strInputData = ServiceSerialize.serializeObject(sinput); 
        params.strInvocationDetails = ServiceSerialize.serializeObject(sinv.getInvocationDetails()); 
        listInputs.add(params);

        List<IService_Output_Master> outputDatas = Service.asyncInvokeService(listInputs);
        IService_Output_Master outputData = outputDatas[0];
        System.assertEquals('SUCCESS', outputData.getState(),'Correct Invocation of an asynchronous service run should return state = SUCCESS');

    }

    @IsTest
    public static void correctAsyncNoPublishReturnsSuccess () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'AsyncNoPublish';
        baseSetup.insertServiceInvocationOverride();

        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        IService_Output_Master outputData = sinv.invokeService(sinput);
        System.assertEquals('SUCCESS', outputData.getState(),'Correct Invocation type of AsyncNoPublish should return state = SUCCESS');
    }




    @IsTest
    public static void mismatchStubbedServiceSyncCall () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();
        Service svc = Service.initialize (baseSetup.serviceName);
        Service__mdt serviceMDT = svc.getServiceMetadata();

        serviceMDT.status__c = 'Stubbed';
        Service.cacheMetadataWrap(serviceMDT);

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('');

        IService_Output_Master outputData = sinv.invokeService(sinput);
        System.assertEquals(ServiceErrorStrings.STATE_STUB_SERVICE_REAL_CALL, outputData.getState(),'A sync invocation to a stubbed service should result in an error being passed back');
        System.assert(outputData.getErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_STUB_SERVICE_REAL_CALL),'A sync invocation to a stubbed service should result in an error being passed back');
    }


    @IsTest
    public static void errorWhenServiceIterationInvalid () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceIteration = 500;
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        // test requires the invocation having a non-existent iteration number so we change before creating the iteration metadata
        baseSetup.serviceIteration = 1;
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_NO_SERVICE_METHOD, outputData.getState(),'Graceful error handling should be in place when a Service Iteration is configured for a Service Invocation that does not exist ');
    }

    @IsTest
    public static void errorWhenServiceImplementationHasNoApexClassName () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        ServiceImplementation.ServiceImplementationWrap simpw = ServiceImplementation.getMetadataWrap (baseSetup.serviceImplementationName);
        simpw.serviceImplementationMDT.Implementing_Class__c = '';
        ServiceImplementation.updateCacheMetadata(simpw.serviceImplementationMDT);

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_NO_IMPLEMENTING_CLASS, outputData.getState(),'');
        System.assert(outputData.getErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_NO_IMPLEMENTING_CLASS),'');
    }

    @IsTest
    public static void errorWhenServiceImplementationHasNoFlowName () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        ServiceImplementation.ServiceImplementationWrap simpw = ServiceImplementation.getMetadataWrap (baseSetup.serviceImplementationName);
        simpw.serviceImplementationMDT.Implementation_Type__c = 'Flow';
        ServiceImplementation.updateCacheMetadata(simpw.serviceImplementationMDT);

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_NO_IMPLEMENTING_FlOW, outputData.getState(), 'Tests the setup of Service Implementation Flows, if the Implementation type is Flow then a flow name must be provided');
        System.assert(outputData.getErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_NO_IMPLEMENTING_FLOW), 'Tests the setup of Service Implementation Flows, if the Implementation type is Flow and a flow name is not provided then a meaningful error message should be provided');
    }

    @IsTest
    public static void errorWhenImplementingClassIsBad () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Sync';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        ServiceImplementation.ServiceImplementationWrap simpw = ServiceImplementation.getMetadataWrap (baseSetup.serviceImplementationName);
        simpw.serviceImplementationMDT.Implementing_Class__c = 'Dud';
        ServiceImplementation.updateCacheMetadata(simpw.serviceImplementationMDT);

        IService_Output_Master outputData = sinv.invokeService(sinput);        

        System.assertEquals(ServiceErrorStrings.STATE_IMPLEMENTING_CLASS_INVALID, outputData.getState(),'If an invalid Implementing Class name is derived then service invocation should error gracefully');
        System.assert(outputData.getErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_IMPLEMENTING_CLASS_INVALID ),'If an invalid Implementing Class name is derived then service invocation should error gracefully');
    }

    @IsTest
    public static void errorWhenBadPEIsProvided () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.invocationType = 'Async';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_EVENT_CREATION_FAILURE, outputData.getState(),'If an invalid Platform Event is provided then service invocation should error gracefully');
        System.assert(outputData.getErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_EVENT_CREATION_FAILURE ),'If an invalid Platform Event is provided then service invocation should error gracefully');
    }


    @IsTest
    public static void invalidInvocationTypeCausesError () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();

        baseSetup.invocationType = 'Dud';
        baseSetup.insertServiceInvocationOverride();

        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        IService_Output_Master outputData = sinv.invokeService(sinput);
        System.assertEquals(ServiceErrorStrings.STATE_INVOCATION_GENERIC_EXCEPTION, outputData.getState(),'If an invalid invocation is provided (probably in a custom setting override) then service invocation errors gracefully');
        System.assert(outputData.getErrorMessage().startsWith(ServiceErrorStrings.STATE_NO_INVOCATION_TYPE),'If an invalid invocation is provided (probably in a custom setting override) then service invocation errors gracefully');
    }

    @IsTest
    public static void testInvocationDetailsGettersAndSetters () {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        invocationDetails.setInvocationType('Async'); 
        invocationDetails.setImplementingType('myImplementingType'); 
        invocationDetails.setExternalProcessingId('myexternalProcessingId'); 

        System.assertEquals('Async',invocationDetails.getInvocationType(),'getInvocationType returns set value');
        System.assertEquals('myImplementingType',invocationDetails.getImplementingType(),'getImplementingType returns set value');
        System.assertEquals('myexternalProcessingId',invocationDetails.getExternalProcessingId(),'getExternalProcessingId returns set value');
    
    }


    @IsTest
    public static void InvocationWithoutPermissionFailsMethodsTest () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // make an external call reference an invalid Custom Permission
        baseSetup.invocationPermission = 'TnisIsNotARealPermission';
        baseSetup.invocationRestrictedByPermission = true;

        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        boolean isUserPermissioned = sinv.isUserPermissioned();
        IService_Output_Master outputData = sinv.isUserPermissionedFailsResponse();

        System.assert(!isUserPermissioned, 'Service should not be invocable without the correct custom permission'); 
        System.assertEquals(ServiceErrorStrings.STATE_UNPERMISSIONED_USER, outputData.getState(), 'Service should not be invocable without the correct custom permission'); 
        System.assertEquals(ServiceErrorStrings.ERRORMSG_UNPERMISSIONED_USER, outputData.getErrorMessage(), 'Service should not be invocable without the correct custom permission'); 

    }

    @IsTest
    public static void InvocationWithoutPermissionFails () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // make an external call reference an invalid Custom Permission
        baseSetup.invocationPermission = 'TnisIsNotARealPermission';
        baseSetup.invocationRestrictedByPermission = true;

        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('1');

        IService_Output_Master outputData = sinv.invokeService(sinput);

        System.assertEquals(ServiceErrorStrings.STATE_UNPERMISSIONED_USER, outputData.getState(), 'Service should not be invocable without the correct custom permission'); 
        System.assertEquals(ServiceErrorStrings.ERRORMSG_UNPERMISSIONED_USER, outputData.getErrorMessage(), 'Service should not be invocable without the correct custom permission'); 

    }


    @IsTest
    public static void ExternalInvocationWithoutPermission () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.externalInvocation = false;

        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IService_Output_Master outputData = sinv.allowExternalCallFail();

        System.assert(!sinv.allowExternalCall(), 'Service should not be invocable by an external with being configured to do so '); 
        System.assertEquals(ServiceErrorStrings.STATE_INVALID_EXTERNAL_USER, outputData.getState(), 'Service should not be invocable by an external with being configured to do so'); 
        System.assertEquals(ServiceErrorStrings.ERRORMSG_INVALID_EXTERNAL_USER, outputData.getErrorMessage(), 'Service should not be invocable by an external with being configured to do so'); 
    }
}
