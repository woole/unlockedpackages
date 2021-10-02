public inherited sharing class ServiceInvocationImplementations {

// stored
// static
// details

    public inherited sharing virtual class InvocationStored implements IInvocation_Stored { 
        private String serviceInvocationName;
        private String serviceName;
        private String invocationType;
        private Id metadataId;
        private boolean logRequests;
        private boolean asyncOnlyLogService;
        private String stubClass;
        private String asyncPlatformEvent;
        private String inputInterfaceVersion;
        private String outputInterfaceVersion;
        private String inputCreationClass;
        private Integer iteration;
        private String method;
        private boolean externalInvocation;
        private String externalRestrictedUser; 
        private String invocationPermission; 
        private boolean invocationRestrictedByPermission; 
        private String outputAuditOverrideOption; 
        private boolean useCache;
        private String useCachePartition;
        private String invocationHash;
                
        // custom setting additional fields
        private boolean overrideDefault;
        private String userPermission;

    
        public String serialize () {
            return ServiceSerialize.serializeObject(this);
        }

        public String getInputInterfaceVersion() {
            return this.inputInterfaceVersion;
        }

        public String getOutputInterfaceVersion() {
            return this.outputInterfaceVersion;
        }

        public String getInputCreationClass() {
            return this.inputCreationClass;
        }

        public String getServiceInvocationName() {
            return this.serviceInvocationName;
        }

        public String getServiceName() {
            return this.serviceName;
        }

        public String getInvocationType() {
            return this.invocationType;
        }

        public Id getMetadataId() {
            return this.metadataId;
        }

        public boolean getLogRequests() {
            return this.logRequests;
        }

        public boolean getAsyncOnlyLogService() {
            return this.asyncOnlyLogService;
        }

        public boolean getUseCache() {
            return this.useCache;
        }

        public String getUseCachePartition() {
            return this.useCachePartition;
        }

        public String getInvocationHash() {
            return this.invocationHash;
        }

        public String getStubClass() {
            return this.stubClass;
        }

        public String getAsyncPlatformEvent() {
            return this.asyncPlatformEvent;
        }

        public Integer getIteration() {
            return this.iteration;
        }

        public String getMethod() {
            return this.method;
        }

        public boolean getOverrideDefault() {
            return this.overrideDefault;
        }

        public String getUserPermission() {
            return this.userPermission;
        }

        public boolean getExternalInvocation() {
            return this.externalInvocation;
        }

        public String getExternalRestrictedUser() {
            return this.externalRestrictedUser;
        }

        public String getInvocationPermission() {
            return this.invocationPermission;
        }

        public boolean getInvocationRestrictedByPermission() {
            return this.invocationRestrictedByPermission;
        }

        public String getOutputAuditOverrideOption() {
            return this.outputAuditOverrideOption;
        }

        public void setInvocationType(String value) {
            this.invocationType = value;
        }

        public void setMetadataId(Id value) {
            this.metadataId = value;
        }
        
        public void setLogRequests(boolean value) {
            this.logRequests = value;
        }

        public void setAsyncOnlyLogService(Boolean value) {
            this.asyncOnlyLogService = value;
        }

        public void setUseCache(boolean value) {
            this.useCache = value;
        }        

        public void setUseCachePartition(String value) {
            this.useCachePartition = value;
        }        

        public void setInvocationHash(String value) {
            this.invocationHash = value;
        }        

        public void setInputInterfaceVersion(String value) {
             this.inputInterfaceVersion = value;
        }

        public void setOutputInterfaceVersion(String value) {
            this.outputInterfaceVersion = value;
        }

        public void setInputCreationClass(String value) {
            this.inputCreationClass = value;
        }    

        public void setStubClass(String value) {
            this.stubClass = value;
        }
        
        public void setServiceName(String value) {
            this.serviceName = value;
        }

        public void setIteration(Integer value) {
            this.iteration = value;
        }

        public void setMethod(String value) {
            this.method = value;
        }

        public void setServiceInvocationName(String value) {
            this.serviceInvocationName = value;
        }

        public void setUserPermission(String value) {
            this.userPermission = value;
        }

        public void setOverrideDefault(boolean value) {
            this.overrideDefault = value;
        }

        public void setExternalInvocation(boolean value) {
            this.externalInvocation = value;
        }

        public void setExternalRestrictedUser(String value){
            this.externalRestrictedUser = value;
        }

        public void setInvocationPermission(String value){
            this.invocationPermission = value;
        }
        public void setInvocationRestrictedByPermission(boolean value){
            this.invocationRestrictedByPermission = value;
        }
        public void setOutputAuditOverrideOption(String value){
            this.outputAuditOverrideOption = value;
        }
        public void setAsyncPlatformEvent(String value){
            this.asyncPlatformEvent = value;
        }
    }

    public inherited sharing virtual class InvocationStatic implements IInvocation_Static { 

        // not part of configuration but added during processing
        private String implementingClassName;
        private String implementingType;
        private String implementingFlow;
        private String externalProcessingId;
        private String nextInvocation;
        private String responseInvocation;
        private boolean isChained = false;
        private String outputCreationClass;
        private String serviceStatus;
        private String serviceType;
        private String configurationType = 'Metadata Record';
        private Id serviceMetadataId;
        private Id serviceIterationMetadataId;
        private Id serviceMethodMetadataId;
        private Id serviceImplementationMetadataId;

        boolean isValidateSetup = true;
        boolean hasValidateWarning = false;        
        String validationState;
        String validationErrorMessage;

        public Id getServiceMetadataId(){
            return this.serviceMetadataId;
        }

        public void setServiceMetadataId(Id value){
            this.serviceMetadataId = value;
        }

        public Id getServiceIterationMetadataId(){
            return this.serviceIterationMetadataId;
        }

        public void setServiceIterationMetadataId(Id value){
            this.serviceIterationMetadataId = value;
        }

        public Id getServiceMethodMetadataId(){
            return this.serviceMethodMetadataId;
        }

        public void setServiceMethodMetadataId(Id value){
            this.serviceMethodMetadataId = value;
        }

        public Id getServiceImplementationMetadataId(){
            return this.serviceImplementationMetadataId;
        }
    
        public void setServiceImplementationMetadataId(Id value){
            this.serviceImplementationMetadataId = value;
        }

        public String getServiceStatus() { 
            return this.serviceStatus;
        }
        
        public void setServiceStatus(String value) { 
            this.serviceStatus = value;
        }
        
        public String getServiceType() {
            return this.serviceType;
        }

        public void setServiceType(String value) { 
            this.serviceType = value;
        }

        public void setImplementingClass(String value) {
            this.implementingClassName = value;
        }

        public void setImplementingType(String value) {
            this.implementingType = value;
        }

        public void setImplementingFlow(String value) {
            this.implementingFlow = value;
        }

        public void setExternalProcessingId(String value) {
            this.externalProcessingId = value;
        }

        public String getImplementingClass() {
            return this.implementingClassName;
        }

        public String getImplementingType() {
            return this.implementingType;
        }

        public String getImplementingFlow() {
            return this.implementingFlow;
        }

        public String getExternalProcessingId() {
            return this.externalProcessingId;
        }

        public void setNextInvocation(String value) {
            this.nextInvocation = value;
        }

        public void setResponseInvocation(String value) {
            this.responseInvocation = value;
        }

        public void setIsChained(boolean value) {
            this.isChained = value;
        }

        public void setConfiguredOutputCreationClass(String value) {
            this.outputCreationClass = value;
        }

        public String getNextInvocation() {
            return this.nextInvocation;
        }

        public String getResponseInvocation() {
            return this.responseInvocation;
        }

        public boolean getIsChained() {
            return this.isChained;
        }

        public String getConfiguredOutputCreationClass() {
            return this.outputCreationClass;
        }

        public void setConfigurationType(String value) { 
            this.configurationType = value;
        }

        public String getConfigurationType() {
            return this.configurationType;
        }
    
        public IService_Output_Master getOutputInterfaceInstance() {
            return (IService_Output_Master) getConfiguredOutputCreationClassType().newInstance();
        }

        private Type getConfiguredOutputCreationClassType() {
            String outputCreationClass = this.getConfiguredOutputCreationClass();
            return Type.forName(outputCreationClass);
        }
        
        public void setIsValidateSetup(boolean value) { 
            this.isValidateSetup = value;
        }

        public boolean getIsValidateSetup() {
            return this.isValidateSetup;
        }

        public void setValidationState(String value) { 
            this.validationState = value;
        }

        public String getValidationState() {
            return this.validationState;
        }

        public void setHasValidateWarning(boolean value) { 
            this.hasValidateWarning = value;
        }

        public boolean getHasValidateWarning() {
            return this.hasValidateWarning;
        }

        public void setValidationErrorMessage(String value) { 
            this.validationErrorMessage = value;
        }

        public String getValidationErrorMessage() {
            return this.validationErrorMessage;
        }
    }


    private inherited sharing virtual class InvocationDynamic implements IInvocation_Dynamic { 

        private DateTime invocationTime;
        private Id userId;
        private Id auditIdReplayed;

        public DateTime getInvocationTime() {
            return this.invocationTime;
        }

        public void setInvocationTime(DateTime invocationTime) {
            this.invocationTime = invocationTime;
        }

        public Id getUserId() {
            return this.userId;
        }

        public void setUserId(Id userId){
            this.userId = userId;
        }

        public Id getAuditIdReplayed() {
            return this.auditIdReplayed;
        }

        public void setAuditIdReplayed(Id auditId){
            this.auditIdReplayed = auditId;
        }
    }

    public inherited sharing class InvocationDetails extends ServiceInvocationImplementations.InvocationStored implements IInvocation_Details { 

        private ServiceInvocationImplementations.InvocationDynamic iDynamic = new ServiceInvocationImplementations.InvocationDynamic();
        private ServiceInvocationImplementations.InvocationStatic iStatic = new ServiceInvocationImplementations.InvocationStatic();
        private ServiceInvocationImplementations.InvocationStored iStored = new ServiceInvocationImplementations.InvocationStored();

        public IInvocation_Static getStatic(){
            return iStatic;
        }

        public void setStatic(IInvocation_Static structure){
            this.iStatic = (ServiceInvocationImplementations.InvocationStatic) structure;
        }

        /* Dynamic information */

        public void setInvocationTime(DateTime invocationTime) {
            this.iDynamic.invocationTime = invocationTime;
        }

        public DateTime getInvocationTime() {
            return this.iDynamic.getInvocationTime();
        }

        public void setUserId(Id userId){
            this.iDynamic.userId = userId;
        }
        
        public Id getUserId() {
            return this.iDynamic.getUserId();
        }

        public void setAuditIdReplayed(Id auditId){
            this.iDynamic.auditIdReplayed = auditId;
        }
        
        public Id getAuditIdReplayed() {
            return this.iDynamic.auditIdReplayed;
        }
        
        // Derived static.

        public Id getServiceMetadataId(){
            return this.iStatic.serviceMetadataId;
        }

        public void setServiceMetadataId(Id value){
            this.iStatic.serviceMetadataId = value;
        }

        public Id getServiceIterationMetadataId(){
            return this.iStatic.serviceIterationMetadataId;
        }

        public void setServiceIterationMetadataId(Id value){
            this.iStatic.serviceIterationMetadataId = value;
        }

        public Id getServiceMethodMetadataId(){
            return this.iStatic.serviceMethodMetadataId;
        }

        public void setServiceMethodMetadataId(Id value){
            this.iStatic.serviceMethodMetadataId = value;
        }

        public Id getServiceImplementationMetadataId(){
            return this.iStatic.serviceImplementationMetadataId;
        }
    
        public void setServiceImplementationMetadataId(Id value){
            this.iStatic.serviceImplementationMetadataId = value;
        }

        public String getServiceStatus() { 
            return this.iStatic.serviceStatus;
        }
        
        public void setServiceStatus(String value) { 
            this.iStatic.serviceStatus = value;
        }
        
        public String getServiceType() {
            return this.iStatic.serviceType;
        }

        public void setServiceType(String value) { 
            this.iStatic.serviceType = value;
        }

        public void setImplementingClass(String value) {
            this.iStatic.implementingClassName = value;
        }

        public void setImplementingType(String value) {
            this.iStatic.implementingType = value;
        }

        public void setImplementingFlow(String value) {
            this.iStatic.implementingFlow = value;
        }

        public void setExternalProcessingId(String value) {
            this.iStatic.externalProcessingId = value;
        }

        public String getImplementingClass() {
            return this.iStatic.implementingClassName;
        }

        public String getImplementingType() {
            return this.iStatic.implementingType;
        }

        public String getImplementingFlow() {
            return this.iStatic.implementingFlow;
        }

        public String getExternalProcessingId() {
            return this.iStatic.externalProcessingId;
        }

        public void setNextInvocation(String value) {
            this.iStatic.nextInvocation = value;
        }

        public void setResponseInvocation(String value) {
            this.iStatic.responseInvocation = value;
        }

        public void setIsChained(boolean value) {
            this.iStatic.isChained = value;
        }

        public void setConfiguredOutputCreationClass(String value) {
            this.iStatic.outputCreationClass = value;
        }

        public String getNextInvocation() {
            return this.iStatic.nextInvocation;
        }

        public String getResponseInvocation() {
            return this.iStatic.responseInvocation;
        }

        public boolean getIsChained() {
            return this.iStatic.isChained;
        }

        public String getConfiguredOutputCreationClass() {
            return this.iStatic.outputCreationClass;
        }

        public void setConfigurationType(String value) { 
            this.iStatic.configurationType = value;
        }

        public String getConfigurationType() {
            return this.iStatic.configurationType;
        }
    
        public IService_Output_Master getOutputInterfaceInstance() {
            return (IService_Output_Master) getConfiguredOutputCreationClassType().newInstance();
        }

        private Type getConfiguredOutputCreationClassType() {
            String outputCreationClass = this.iStatic.getConfiguredOutputCreationClass();
            return Type.forName(outputCreationClass);
        }
        
        public void setIsValidateSetup(boolean value) { 
            this.iStatic.isValidateSetup = value;
        }

        public boolean getIsValidateSetup() {
            return this.iStatic.isValidateSetup;
        }

        public void setValidationState(String value) { 
            this.iStatic.validationState = value;
        }

        public String getValidationState() {
            return this.iStatic.validationState;
        }

        public void setHasValidateWarning(boolean value) { 
            this.iStatic.hasValidateWarning = value;
        }

        public boolean getHasValidateWarning() {
            return this.iStatic.hasValidateWarning;
        }

        public void setValidationErrorMessage(String value) { 
            this.iStatic.validationErrorMessage = value;
        }

        public String getValidationErrorMessage() {
            return this.iStatic.validationErrorMessage;
        }


    }


}
