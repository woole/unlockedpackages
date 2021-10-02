public inherited sharing class Service {

    private String serviceName;
    private Service__mdt serviceMetadata;
    private String serviceType;
    private String serviceStatus;
    private String externalCredentialsLabel;
    private Id serviceMetadataId;

    public Service() {

    }

    public Service(String serviceName) {
        this.serviceName = serviceName;
    }

    public static Service initialize(String serviceName) {
        return getMetadataWrap(serviceName);
    }

    public String getServiceName() {
        return this.serviceName;
    }

    public Service__mdt getServiceMetadata() {
        return this.serviceMetadata;
    }

    public String getServiceType() {
        return this.serviceType;
    }

    public String getServiceMetadataId() {
        return this.serviceMetadataId;
    }

    public String getServiceStatus() {
        return this.serviceStatus;
    }

    public String getExternalCredentialsLabel() {
        return this.externalCredentialsLabel;
    }
        

    IService_Implementation serviceImplementation;

    /* Error Handling */

    public class ServiceFrameworkException extends Exception {}

    /* Async Processing */


    /* 
    Note there is no test coverage of this method in the generic package.
    This is deliberate as to test the method would require creating a Platform Event in the org which we should not do */

    public static List<ServiceSerialize.SerializedInvocationStructure> getSerializedInvocationList (List<SObject> sobjs) {
        List<ServiceSerialize.SerializedInvocationStructure> listInputs = new List<ServiceSerialize.SerializedInvocationStructure>();

        // A PE Trigger will read in more than one event if available and process in bulk
        for (SObject sobj : sobjs) {
            ServiceSerialize.SerializedInvocationStructure params = new ServiceSerialize.SerializedInvocationStructure();
            params.strInputData = (String) sobj.get(ServiceAsync.INPUT_DATA_FIELD); 
            params.strInvocationDetails = (String) sobj.get(ServiceAsync.INVOCATION_DETAILS_FIELD); 
            params.replayid = (String) sobj.get(ServiceAsync.REPLAYID_FIELD); 
            listInputs.add(params);
        }
        return listInputs;
    }


    // invoking a service asynchronously
    public static List<IService_Output_Master> asyncInvokeService (List<ServiceSerialize.SerializedInvocationStructure> listInputs) {
        // return value is for testing only
        List<IService_Output_Master> outputDatas = new List<IService_Output_Master>();

        // There is a danger of runaway governor limits being hit here within the for loop.
        // Recommend restricting the number of events to a manageable number prior to calling this method, for example in a PE trigger
        for (ServiceSerialize.SerializedInvocationStructure si : listInputs) {

            IInvocation_Details invocationDetails = (IInvocation_Details) deserializeInvocationDetails (si.strInvocationDetails);

            // deserializeInput method that returns an instance of the input interface for the service version.
            IService_Input_Master isi = deserializeInput(si.strInputData, invocationDetails);

            Service targetService = new Service(invocationDetails.getServiceName());
            IService_Output_Master isom = targetService.delegateImplementationEnhanced(invocationDetails, isi, si.replayid);
            outputDatas.add(isom);
        }
        return outputDatas;
    }

    // Note that we need to use the inputCreationClass as Apex will not allow deserialization to an abstract type like an interface
    public static IService_Input_Master deserializeInput (String strInputData, IInvocation_Details invocationDetails) {
        String inputCreationClass = invocationDetails.getInputCreationClass();
        return (IService_Input_Master) ServiceSerialize.deserializeByClassName(strInputData,inputCreationClass);
    }

    @TestVisible
    public static IInvocation_Details deserializeInvocationDetails (String strInvocationDetails) {
        IInvocation_Details iid = (IInvocation_Details) ServiceSerialize.deserializeByClassType(strInvocationDetails, ServiceInvocationImplementations.InvocationDetails.class);
        return iid;
    }

    /* Retrieving Processing Class */
    
    public static IService_Implementation instantiateServiceImplementation (String implementingClassName) {
        try {
            // to get if a class implements an interface we unfortunately have to create an instance of it and check that. Grr.
            Type classType = Type.forName(implementingClassName);
            Object iserviceImplmentation = classType.newInstance();

            if (iserviceImplmentation instanceOf IService_Implementation) {
                return (IService_Implementation) iserviceImplmentation;              
            }
            else {
                return null;
            }
        }
        catch (Exception e) {
            System.debug(e);
            // exception thrown means we can't create an instance of the implementing class. 
            // How to respond to this is handled in the caller, here we just set value to null which signifies that we can't serve up a Service Implementation
            return null;
        }
    }

    /* Service Processing */

    // Dispatch Service Version methods
    public IService_Output_Master delegateImplementation(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        return delegateImplementationEnhanced(invocationDetails, inputData, null);
    }

    private IService_Output_Master delegateImplementationEnhanced(IInvocation_Details invocationDetails, IService_Input_Master inputData, String replayId) {

        Datetime serviceStartTime = Datetime.now();

        IService_Output_Master outputData;

        // perform a validation check on the Service configuration as requested by the invocation
        ServiceValidator sv = new ServiceValidator(invocationDetails);
        IService_Output_Master serviceValidationOutput = sv.validateServiceSetup();

        // If the setup is good then we can proceed to execution
        if (serviceValidationOutput.getState() == 'SUCCESS') {

            // We build up a list of invocation that will follow this invocation
            // Ultimately we can built up dynamic lists of chained invocations

            List<String> subsequentInvocations = new List<String>();
            if (hasNextInvocation(invocationDetails)){
                subsequentInvocations.add(invocationDetails.getNextInvocation());
            }
            if (hasResponseInvocation(invocationDetails)){
                subsequentInvocations.add(invocationDetails.getResponseInvocation());
            }

            // check if pass through with a next invocation to chain onto it
            // passthrough is irrelevant now, if we can remove then this nextInput complication can go too.
            boolean isPassThrough = (invocationDetails.getImplementingType() == 'PassThrough');
            IService_Output_Master nextInput;
            if (isPassThrough) {
                nextInput = (IService_Output_Master) inputData;
            }
            // main line, service with an implementation
            if (!isPassThrough) {
                outputData = executeImplmentation (invocationDetails, inputData);
                nextInput = outputData;
            }

            // if we have been successful and there is a next and a response invocation configured we run the response invocation too
            if (nextInput.getState() == 'SUCCESS') {
                for (String subsequentInvocation : subsequentInvocations){
                    outputData = runSubsequentInvocation(subsequentInvocation, invocationDetails, nextInput);
                    if (outputData.getState() != 'SUCCESS') {
                        break;
                    }
                    nextInput = outputData;
                }
            }

            outputData.setTimingFields(serviceStartTime, invocationDetails.getInvocationTime());
        }
        else {
            outputData = serviceValidationOutput;
        }

        // publish outcome
        try {
            ServiceInvocation sinvAudit = ServiceAuditPublisher.getAuditServiceInvocation(invocationDetails,  outputData.getState(), 'Service');
            if (sinvAudit != null && sinvAudit.getInvocationDetails() != null) {
                IService_Output_Master auditData;
                // the invocation can be configured to always return raw output
                if (invocationDetails.getOutputAuditOverrideOption() != 'Raw') {
                    auditData = generateOutputAudit(outputData);
                }
                else {
                    auditData = outputData;
                }
                ServiceAuditPublisher.publishAudit (sinvAudit, invocationDetails, inputData, outputData, auditData);
            }
        }
        catch (Exception e) {   
            // error handing framework has failed, the transaction continues to be processed         
            System.debug(LoggingLevel.ERROR, 'Could not publish Audit Message. Check configuration. ' + e.getMessage());
        }

        return outputData;
    }

    public IService_Output_Master generateOutputAudit (IService_Output_Master outputData) {
        if (this.serviceImplementation instanceOf IService_Implementation_Audit_Override) {
            IService_Implementation_Audit_Override overrider = (IService_Implementation_Audit_Override) this.serviceImplementation;
            IService_Output_Master auditOutput = overrider.overrideAuditOutput(outputData);
            return auditOutput;
        }
        return null;
    }


    @TestVisible private IService_Output_Master executeImplmentation (IInvocation_Details invocationDetails, IService_Input_Master inputData) {        
        IService_Output_Master outputData;

        try { 
            this.serviceImplementation = instantiateServiceImplementation (invocationDetails.getImplementingClass() );
            if (serviceImplementation == null) {
                outputData = new ServiceOutputMaster();
                outputData.setState (ServiceErrorStrings.STATE_IMPLEMENTING_CLASS_INVALID);
                outputData.setErrorMessage (ServiceErrorStrings.ERRORMSG_IMPLEMENTING_CLASS_INVALID + invocationDetails.getServiceInvocationName());
                outputData.setCorrelationId(inputData.getCorrelationId());
                return outputData;
            }

            outputData = (IService_Output_Master) serviceImplementation.dispatch(invocationDetails, inputData);
            return outputData;
        }
        catch (Exception e) {
            // pass details of the error back to the invoker
            System.debug(LoggingLevel.ERROR, 'Exception caught: ' + e.getMessage());
            outputData = new ServiceOutputMaster();
            outputData.setState (ServiceErrorStrings.STATE_SERVICE_GENERIC_EXCEPTION);
            outputData.setErrorMessage (e.getMessage());
            return outputData;
        }
    }

    @TestVisible private boolean hasNextInvocation(IInvocation_Details invocationDetails) {
        return invocationDetails.getIsChained();
     }

    @TestVisible private boolean hasResponseInvocation(IInvocation_Details invocationDetails) {
        String responseInvocation = invocationDetails.getResponseInvocation();
        return (responseInvocation != null && responseInvocation.trim().length() > 0);
     }

    @TestVisible private IService_Output_Master runSubsequentInvocation(String subsequentInvocation, IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IService_Output_Master outputData;
        ServiceInvocation sinvBroker = ServiceInvocation.initialize(subsequentInvocation);
        outputData = sinvBroker.invokeService(inputData);
        return outputData;
    }

    /* Custom Metadata Retrieval and Cacheing for Test Classes */

    /* Required to hold custom metadata references for test classes where we create CMT records dynamically 
       These are required as CMT records can be created in Apex but cannot be saved */

    private static Map<String,Service> mapService = new Map<String,Service>(); 

    @TestVisible private static Service getMetadataWrap (String serviceName) {
        if (Service.mapService.containsKey(serviceName)) {
            Service svc = Service.mapService.get(serviceName);
            return svc;
        }
        else {
            List<Service__mdt> listServiceMDT = 
                [SELECT Id, DeveloperName,MasterLabel,Extensible__c, Private__c, Status__c, Service_Type__c, External_Credentials_Label__c 
                    from Service__mdt
                    where DeveloperName = :serviceName];
            
            if (listServiceMDT.size() > 0) {
                Service__mdt serviceMDT = listServiceMDT[0];
                Service svc = new Service(serviceName);
                svc.externalCredentialsLabel = serviceMDT.External_Credentials_Label__c;
                svc.serviceType = serviceMDT.Service_Type__c;
                svc.serviceStatus = serviceMDT.Status__c;
                svc.serviceMetadataId = serviceMDT.Id;
                svc.serviceMetadata = serviceMDT;
                Service.mapService.put(serviceName,svc);
                return svc;
            }
            else {
                return null;
            }
        }
    }

    @TestVisible private static void cacheMetadataWrap(Service__mdt serviceMDT) {
        String serviceName = serviceMDT.DeveloperName;
        Service svc = new Service(serviceName);
        svc.serviceMetadata = serviceMDT;
        svc.externalCredentialsLabel = serviceMDT.External_Credentials_Label__c;
        svc.serviceType = serviceMDT.Service_Type__c;
        svc.serviceMetadataId = serviceMDT.Id;
        Service.mapService.put(serviceName,svc);
    }


    // For test classes only, creates dummy custom metadata
    // instantiate a mininmal CMT record  
    // Add additional attributes to the variable returned and add to the CMT map.

    @TestVisible private static Service__mdt createTestMetadata(String serviceName) {
        Service__mdt serviceMDT = new Service__mdt();
        serviceMDT.DeveloperName = serviceName;
        return serviceMDT;
    }

}
