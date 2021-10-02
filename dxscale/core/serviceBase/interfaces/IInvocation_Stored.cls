global interface IInvocation_Stored {

    /* Data from Invocation Static */

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

    void setServiceInvocationName(String value);
    void setInvocationType(String value);    
    void setMetadataId(Id value);
    void setLogRequests(boolean value);
    void setAsyncOnlyLogService(Boolean value);
    void setStubClass(String value);
    void setAsyncPlatformEvent(String value);
    void setInputInterfaceVersion(String value);
    void setOutputInterfaceVersion(String value);
    void setInputCreationClass(String value);
    void setServiceName(String value);
    void setIteration(Integer value);
    void setMethod(String value);
    void setOutputAuditOverrideOption(String value);
    void setUseCache(boolean value);
    void setUseCachePartition(String value);

    // external call-in relevant
    boolean getExternalInvocation();
    String getInvocationPermission();
    boolean getInvocationRestrictedByPermission();

    void setExternalRestrictedUser(String value);
    void setExternalInvocation(boolean value);
    void setInvocationPermission(String value);
    void setInvocationRestrictedByPermission(boolean value);

    
    // custom settings relevant
    boolean getOverrideDefault();
    void setOverrideDefault(boolean value);

    String getUserPermission();
    void setUserPermission(String value);

    // Cache
    String getInvocationHash();
    void setInvocationHash(String value);


    
}
