global interface IInvocation_Details extends IInvocation_Stored {

    // Design is that invocation details is in fact made up of stored, static and dynamic parts
    // IInvocation Details extends IInvocation_Stored and has IInvocation_Static (for enriched static from other CMT Records) and
    // IInvocation_Dynamic with data that is per user or context (timing fields for example)
    // For legacy reasons we repeat methods in IInvocation_Dynamic and IInvocation_Stored in IInvocation_Details so that they can be referenced off that interface

    IInvocation_Static getStatic();
    void setStatic(IInvocation_Static structure);

    // ultimately we aim to have IInvocation_Stored as a member variable on IInvocation_Details but this is not at present implemented
    // IInvocation_Stored getStored();
    // void setStored(IInvocation_Stored structure);

    // baseline

    /* DYNAMIC - Information that is dynamically generated during an invocation. */
    DateTime getInvocationTime();
    void setInvocationTime(DateTime invocationTime);
    Id getUserId();
    void setUserId(Id userId);
    Id getAuditIdReplayed();
    void setAuditIdReplayed(Id auditId);



    /* STATIC */
    /* Static derived from Invocation metadata but not directly stored against the Service Invocation CMT or Custom Setting Override */    

    /* Stored in ServiceValidator */

    // metadata ids and key fields for all of the referenced CMT Records
    Id getServiceMetadataId();
    void setServiceMetadataId(Id value);
    Id getServiceIterationMetadataId();
    void setServiceIterationMetadataId(Id value);
    Id getServiceMethodMetadataId();
    void setServiceMethodMetadataId(Id value);
    Id getServiceImplementationMetadataId();
    void setServiceImplementationMetadataId(Id value);

    /* per object data added during Service Validator processing */

    void setServiceStatus(String value);
    String getServiceStatus();
    void setServiceType(String value);
    String getServiceType();

    void setImplementingClass(String value);
    String getImplementingClass();
    void setImplementingFlow(String value);
    String getImplementingFlow();
    void setExternalProcessingId(String value);
    String getExternalProcessingId();
    void setImplementingType(String value);
    String getImplementingType();
    void setNextInvocation(String value);
    String getNextInvocation();
    void setResponseInvocation(String value);
    String getResponseInvocation();
    void setIsChained(boolean value);
    boolean getIsChained();
    void setConfiguredOutputCreationClass(String value);
    String getConfiguredOutputCreationClass();

    /* Set in Service invocation */
    IService_Output_Master getOutputInterfaceInstance(); // convenience method

    void setConfigurationType(String value);
    String getConfigurationType();

    // setup validation
    // Note that if getIsValidateSetup() is set to false the invocation will fail and changes must be made to resolve
    boolean getIsValidateSetup();
    void setIsValidateSetup(boolean value);
    // Note that if getHasValidateWarning() is set to true the invocation setup is sub-optimal but it will still run
    boolean getHasValidateWarning();
    void setHasValidateWarning(boolean value);
    String getValidationState();
    void setValidationState(String value);
    String getValidationErrorMessage();
    void setValidationErrorMessage(String value);

    /* STORED values. */
    String getServiceInvocationName();
    String getServiceName();
    String getInvocationType();

    Id getMetadataId();
    boolean getLogRequests();
    boolean getAsyncOnlyLogService();
    String getStubClass();
    String getAsyncPlatformEvent();
    Integer getIteration();
    String getMethod();
    String getInputInterfaceVersion();
    String getOutputInterfaceVersion();
    String getInputCreationClass();
    String getOutputAuditOverrideOption();
    boolean getUseCache();
    String getUseCachePartition();

    // external call-in relevant
    boolean getExternalInvocation();
    String getInvocationPermission();
    boolean getInvocationRestrictedByPermission();

    boolean getOverrideDefault();
    String getUserPermission();


}


