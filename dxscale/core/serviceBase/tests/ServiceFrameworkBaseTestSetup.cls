@IsTest
public with sharing class ServiceFrameworkBaseTestSetup {
    public ServiceFrameworkBaseTestSetup() {

    }

    // We can overwrite these members in each test as required.

    // service MDT values
    public String serviceName = 'UnrealService';
    public String serviceStatus = 'Active';
    public String serviceType = 'Internal Processing';
    public String externalCredentialsLabel = '';
    // service iteration MDT values
    public Integer serviceIteration = 1;
    // service method MDT values
    public String serviceMethodName = 'UnrealMethod';
    public String nextInvocationName = '';    
    public String responseInvocationName = '';    
    public String howImplemented = 'Implementation';    
    // service implementatation MDT values
    public String serviceImplementationName = 'UnrealServiceVersion';
    public String outputCreationClass = 'StringOutputV1';
    // service invocation MDT values
    public String serviceInvocationName = 'UnrealServiceInvocation';
    public String implementingClass = 'SampleServiceImplementation_Test';
    public String implementingFlow = '';
    public String externalProcessingId = '';
    public String implementationType = 'ApexClass';
    public String stubClass = 'SampleServiceImplementation_Test';
    public String inputInterfaceVersion = 'IStringInput';
    public String outputInterfaceVersion = 'IStringOutput';
    public String invocationType = 'Sync';
    public String inputCreationClass = 'StringIO';
    public boolean logRequests = true;
    public boolean asyncOnlyLogService = false;    
    public String userPermission = 'UserPermission';
    public boolean overrideDefault = true;
    public boolean externalInvocation = true;
    public String invocationPermission = 'InvocationPermission';
    public boolean invocationRestrictedByPermission = false;
    public String externalRestrictedUser = UserInfo.getUserName();
    public boolean useCache = false;
    public String useCachePartition;


    public Service__mdt serviceMDT;
    public Service_Implementation__mdt serviceImplementationMDT;
    public Service_Method__mdt serviceMethodMDT;

    public ServiceImplementation.ServiceImplementationWrap simpw;
    public ServiceMethod.ServiceMethodWrap smw;

    public void insertServiceInvocationOverride() {
        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = serviceInvocationName;
        sio.Metadata_Invoker_Id__c = serviceInvocationName;        
        sio.Service_Name__c = serviceName;
        sio.Override_Default__c = overrideDefault;
        sio.User_Permission__c = userPermission;
        sio.Stub_Class__c = stubClass;
        sio.Invocation_Type__c = invocationType;
        sio.Input_Interface_Version__c = inputInterfaceVersion;
        sio.Output_Interface_Version__c = outputInterfaceVersion;
        sio.Input_Creation_Class__c = inputCreationClass;
        sio.Log_Requests__c = logRequests; 
        sio.Async_Only_Log_Service__c = asyncOnlyLogService; 
        sio.Iteration__c = serviceIteration;
        sio.Method__c = serviceMethodName;
        sio.External_Invocation__c = externalInvocation;
        sio.Invocation_Permission__c = invocationPermission;
        sio.Invocation_Restricted_By_Permission__c = invocationRestrictedByPermission;
        sio.Use_Cache__c = useCache;
        sio.Use_Cache_Partition__c = useCachePartition;
        insert sio;
    }


    public void serviceSetup(){
        // Note that we can't use @testSetup for CMT records as we can't save them.

        // Set up our fake Service Metadata
        serviceMDT = Service.createTestMetadata(serviceName);
        serviceMDT.Status__c = serviceStatus;
        serviceMDT.Service_Type__c = serviceType;
        serviceMDT.External_Credentials_Label__c = externalCredentialsLabel;

        Service.cacheMetadataWrap(serviceMDT);

        // Set up our fake Service Implementation Metadata
        serviceImplementationMDT = ServiceImplementation.createTestMetadata(serviceImplementationName);
        serviceImplementationMDT.Implementing_Class__c = implementingClass;
        serviceImplementationMDT.Implementing_Flow__c = implementingFlow;
        if (outputCreationClass != '') {
            serviceImplementationMDT.Output_Creation_Class__c = outputCreationClass;
        }
        
        serviceImplementationMDT.Implementation_Type__c = implementationType;

        simpw = ServiceImplementation.cacheMetadata(serviceImplementationName, serviceImplementationMDT);

        // Set up our fake Service Method Metadata
        serviceMethodMDT = ServiceMethod.createTestMetadata(serviceName, serviceIteration, serviceMethodName);
        serviceMethodMDT.Method__c = serviceMethodName;
        serviceMethodMDT.Iteration__c = serviceIteration;
        serviceMethodMDT.How_Implemented__c = howImplemented;
        smw = ServiceMethod.cacheMetadata(serviceName, serviceIteration, serviceMethodName, serviceMethodMDT);
        smw.serviceImplementationName = serviceImplementationName;
        if (nextInvocationName != null) {
            smw.nextInvocationName = nextInvocationName;
            serviceMethodMDT.External_Processing_Id__c = externalProcessingId;
        }
        smw.responseInvocationName = responseInvocationName;
    }


}
