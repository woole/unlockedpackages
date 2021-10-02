global interface IInvocation_Static {

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


}
