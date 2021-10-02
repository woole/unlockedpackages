public inherited sharing class ServiceValidator {

    IInvocation_Details invocationDetails;
    Service svc;
    Service__mdt serviceCMT;
    ChainedStatic chainedStatic = new ChainedStatic();
    IInvocation_Static invocationStatic;

    public ServiceValidator(IInvocation_Details invocationDetails) {
        this.invocationDetails = invocationDetails;
        this.svc = Service.initialize (invocationDetails.getServiceName());
        this.serviceCMT = this.svc.getServiceMetadata();
        storeChainedStaticFromPrevious();

        this.invocationStatic = new ServiceInvocationImplementations.InvocationStatic();
        this.invocationStatic.setIsValidateSetup(true);
        this.invocationStatic.setValidationState('SUCCESS');
    
    }

    /* 
        Validating services is driven by the invocationDetails that are stored in Salesforce.
        However when invocations are chained we may have inherited some static from earlier in the chain which we store here
    */

    class ChainedStatic {
        String externalProcessingId;
    }

    private void storeChainedStaticFromPrevious () {
        chainedStatic.externalProcessingId  = this.invocationDetails.getExternalProcessingId();
    }
    
    /* Converts the output of validate and returns ISOM so can be interpreted by Service Invoctions */

    public IService_Output_Master validateServiceSetup() {
        IService_Output_Master outputData = new ServiceOutputMaster();

        validate();

        if (this.invocationStatic.getIsValidateSetup()) {
            outputData.setState ('SUCCESS');
        }
        else {
            outputData.setState (this.invocationStatic.getValidationState());
            outputData.setErrorMessage (this.invocationStatic.getValidationErrorMessage());    
        }
        return outputData;
    }


    /* 
        This is called during every Service Invocation to validate the setup of the service
        We need to check that the implementing artifacts can be derived and our valid

        This same method can also be used for health check tooling.

        It takes stored metadata and derives processing static from it which can then be cached.    
        Methods within use invocationDetails.iStored and enriches invocationDetails.iStatic

        Steps:
            storeChained static - done in constructor. free to overwrite static at this point.
            check if the service is live
            check if there's a hash
            retrieve from hash
            derive config if there is none in cache and store the new values if appropriate

    */


    private void validate() {
        Datetime start = Datetime.now();

        IInvocation_Stored invocationStored = (IInvocation_Stored) this.invocationDetails;

        checkLiveService(invocationStored);

        if (this.invocationStatic.getIsValidateSetup()) {
            getCacheOrDerive();
        }

        this.invocationDetails.setStatic(this.invocationStatic);

        long metric = Datetime.now().getTime() - start.getTime();
        System.debug('Validation METRIC: ' + metric);

    }

    private void checkLiveService(IInvocation_Stored invocationStored) {

        if (this.serviceCMT == null) {
            String errorMsg = ServiceErrorStrings.ERRORMSG_NO_SERVICE_DEFINED_PT1 + invocationStored.getServiceName() + ServiceErrorStrings.ERRORMSG_NO_SERVICE_DEFINED_PT2 + invocationStored.getServiceInvocationName();
            this.invocationStatic.setIsValidateSetup(false);
            this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_NO_SERVICE_DEFINED);
            this.invocationStatic.setValidationErrorMessage(errorMsg);
            return;
        }

        String serviceState = this.serviceCMT.Status__c;

        // Service can be set to "Down" in unexpected circumstances, in which case we return an error
        if (serviceState == 'Down') {
            this.invocationStatic.setIsValidateSetup(false);
            this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_SERVICE_IS_DOWN);
            this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_SERVICE_IS_DOWN  + invocationStored.getServiceInvocationName());
            return;
        }
    }

    private void deriveConfig(IInvocation_Stored invocationStored) {
        String invocationType = invocationStored.getInvocationType();    
        String serviceState = this.serviceCMT.Status__c;

        if (serviceState == 'Stubbed' && invocationType != 'Stub') {
            this.invocationStatic.setIsValidateSetup(false);
            this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_STUB_SERVICE_REAL_CALL);
            this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_STUB_SERVICE_REAL_CALL  + invocationStored.getServiceInvocationName());
            return;
        }

        this.invocationStatic.setServiceStatus(this.svc.getServiceStatus());
        this.invocationStatic.setServiceType(this.svc.getServiceType());
        this.invocationStatic.setServiceMetadataId(this.svc.getServiceMetadataId());

        if (this.invocationStatic.getIsValidateSetup()) {

            if (invocationType == 'Stub') {
                // at the moment only use apex for stubs
                String implementingClassName = invocationStored.getStubClass(); 
                this.invocationStatic.setImplementingClass(implementingClassName);
                this.invocationStatic.setImplementingType('ApexClass');
            }    

            if (invocationType == 'Sync' || invocationType == 'Async' || invocationType == 'Queueable' || invocationType == 'Audit' || invocationType == 'OutboundBroker') {

                ServiceMethod.ServiceMethodWrap smw = ServiceMethod.getMetadataWrap(invocationStored.getServiceName(), invocationStored.getIteration(), invocationStored.getMethod());
                String serviceImplementationName;
                if (smw == null) {
                    this.invocationStatic.setIsValidateSetup(false);
                    this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_NO_SERVICE_METHOD);
                    this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_NO_SERVICE_METHOD  + invocationStored.getServiceInvocationName());
                    return;        
                }

                if (smw.serviceMethodMDT.How_Implemented__c == 'PassThrough') {
                    this.invocationStatic.setImplementingType('PassThrough');
                    // for PassThrough we must have a next invocation
                    if (smw.getNextInvocationName() == null || smw.getNextInvocationName().trim() == '') {
                        this.invocationStatic.setIsValidateSetup(false);
                        this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_PASS_THROUGH_WO_NEXT_INV);
                        this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_PASS_THROUGH_WO_NEXT_INV  + invocationStored.getServiceInvocationName());
                        return;            
                    }
                }
                else {
                    serviceImplementationName = smw.getServiceImplementationName();
                    this.invocationStatic.setServiceMethodMetadataId(smw.getServiceMethodMetadataId());

                    if (serviceImplementationName == null || serviceImplementationName.trim() == '') {
                        this.invocationStatic.setIsValidateSetup(false);
                        this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_NO_IMPLEMENTING_CLASS);
                        this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_NO_IMPLEMENTING_CLASS  + invocationStored.getServiceInvocationName());
                        return;            
                    }
        
                    ServiceImplementation.ServiceImplementationWrap siw = ServiceImplementation.getMetadataWrap(serviceImplementationName);                

                    this.invocationStatic.setServiceImplementationMetadataId(siw.getServiceImplementationMetadataId());
                    String implementingType = siw.serviceImplementationMDT.Implementation_Type__c;
                    String implementingClass = siw.serviceImplementationMDT.Implementing_Class__c;
                    String implementingFlow = siw.serviceImplementationMDT.Implementing_Flow__c;
                    String outputCreationClass = siw.serviceImplementationMDT.Output_Creation_Class__c;

                    if (implementingType == null ) { // legacy, assume that anything without an implementing type is Apex Class
                        implementingType = 'ApexClass';
                    }
                    this.invocationStatic.setImplementingType(implementingType);

                    if (implementingType == 'Flow' ){
                        implementingClass = 'ServiceFlow';
                        this.invocationStatic.setImplementingFlow(implementingFlow);
                    }

                    this.invocationStatic.setImplementingClass(implementingClass);
                    this.invocationStatic.setConfiguredOutputCreationClass(outputCreationClass);

                    // Check that there is a configured class
                    if (implementingType == 'ApexClass' && (implementingClass == null || implementingClass.trim() == '')){
                        this.invocationStatic.setIsValidateSetup(false);
                        this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_NO_IMPLEMENTING_CLASS);
                        this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_NO_IMPLEMENTING_CLASS  + invocationStored.getServiceInvocationName());
                        return;            
                    }    

                    // Check that any configured class implements the correct interfaces
                    if (implementingType == 'ApexClass' && (implementingClass != null && implementingClass.trim() != '')){
                        IService_Implementation serviceImplementation = Service.instantiateServiceImplementation (implementingClass);
                        if (serviceImplementation == null) {
                            this.invocationStatic.setIsValidateSetup(false);
                            this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_IMPLEMENTING_CLASS_INVALID);
                            this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_IMPLEMENTING_CLASS_INVALID  + invocationStored.getServiceInvocationName());
                            return;            
                        }
                    }

                    // This duplicates a Validation Rule on Service Implementation but keep in case this can be enhanced.
                    if (implementingType == 'Flow' && (implementingFlow == null || implementingFlow.trim() == '')) {
                        this.invocationStatic.setIsValidateSetup(false);
                        this.invocationStatic.setValidationState(ServiceErrorStrings.STATE_NO_IMPLEMENTING_FLOW);
                        this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_NO_IMPLEMENTING_FLOW  + invocationStored.getServiceInvocationName());
                        return;            
                    }
                }

                // check if this invocation is chained
                if (smw.getNextInvocationName() != null && smw.getNextInvocationName().trim() != '') {
                    this.invocationStatic.setNextInvocation(smw.getNextInvocationName());
                    this.invocationStatic.setResponseInvocation(smw.getResponseInvocationName());
                    this.invocationStatic.setIsChained(true);
                    // if its a remote proxy then we can set the external identifier
                    String externalProcessingId = smw.serviceMethodMDT.External_Processing_Id__c;
                    if (externalProcessingId != null && externalProcessingId.trim() != '') {
                        this.invocationStatic.setExternalProcessingId(externalProcessingId);
                    }
                }
                else {
                    this.invocationStatic.setIsChained(false);
                }

                if (this.svc.getServiceType() == 'External Outbound') {
                    // for an external service an identifier for an external system maybe have been created by a proxy
                    this.invocationStatic.setExternalProcessingId(chainedStatic.externalProcessingId);
                }
            

            }    
        }
    }    

    private void getCacheOrDerive () {
        String invocationHash = this.invocationDetails.getInvocationHash();

        if (invocationHash != null) {
            // the invocation has provided a hash
            ServiceCacheHandler sch = new ServiceCacheHandler(this.invocationDetails.getUseCachePartition());
            boolean cachePartitionExists = sch.getCachePartitionExists();       
            if (!cachePartitionExists) {
                // the configured partition does not exist in this org
                System.debug('Configured Partition does not exist: ' + this.invocationDetails.getUseCachePartition());
                deriveConfig((IInvocation_Stored) this.invocationDetails);

                if (this.invocationStatic.getIsValidateSetup()) {
                    this.invocationStatic.setHasValidateWarning (true);
                    this.invocationStatic.setValidationState (ServiceErrorStrings.STATE_BAD_CACHE_PARTITION_NAME  + this.invocationDetails.getUseCachePartition());
                    this.invocationStatic.setValidationErrorMessage (ServiceErrorStrings.ERRORMSG_BAD_CACHE_PARTITION_NAME  + this.invocationDetails.getUseCachePartition());
                }
                                
                return;
            } 

            System.debug('Using Cache Partition: ' + this.invocationDetails.getUseCachePartition());

            IInvocation_Static staticCache = (IInvocation_Static) sch.retrieveInvocationStatic(invocationHash);
            if (staticCache != null) {
                // reuse stored invocation static metadata
                System.debug('reuse stored invocation static metadata');
                this.invocationStatic = (IInvocation_Static) staticCache;                
            }
            else {
                // the invocation details are not currenty hashed but cache is requested. Create new cache
                deriveConfig((IInvocation_Stored) this.invocationDetails);
                System.debug('lay down new stored invocation static metadata');
                sch.saveInvocationStatic( invocationHash, this.invocationStatic);    
            }
        }
        else {
            // the invocation has not provided a hash so we derive the config and return
            deriveConfig((IInvocation_Stored) this.invocationDetails);
        }
    }

    /* Methods Health Check tooling, not used at runtime */

    public static IInvocation_Details getInvocationStatic(String serviceInvocationName){
        ServiceInvocation sinv = ServiceInvocation.initialize(serviceInvocationName);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();

        ServiceValidator serviceValidator = new ServiceValidator(invocationDetails);
        serviceValidator.validate();
        return invocationDetails;
    } 

    
}
