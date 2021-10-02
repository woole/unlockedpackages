global interface IService_Output_Master extends IService_Input_Master{

    // Why does this extend IService_Input_Master?
    // This is necessitated by Apex not allowing an interface to extend more than one interface
    // ideally we have like the option for a class to act as both the input and output for services by stating
    // global interface IMyIO extends IService_Input_Master, IService_Output_Master 
    // but apex does not support this
    // To avoid making the interface structure any more complex (and as the requirement on IService_Input_Master are minimal)
    // we add the requirement that any output object must also satisfy the minimum to be an input object too.

    // invocation metrics
    void setServiceStartTime(Datetime serviceStartTime);
    Datetime getServiceStartTime ();

    void setResponseTime(Datetime responseTime);
    Datetime getResponseTime ();

    void setServiceDuration(long callDuration);
    long getServiceDuration ();

    void setInvocationTime(Datetime invocationTime);
    Datetime getInvocationTime ();

    void setInvocationDuration(long callDuration);
    long getInvocationDuration ();

    void setInvocationType(String invocationType);
    String getInvocationType ();

    /* supported DataStatus options are: Processed / Unsaved / Stubbed */
    void setDataStatus (String dataStatus);
    String getDataStatus ();

    void setState (String state);
    String getState ();

    void setErrorMessage (String errorMessage);
    String getErrorMessage ();

    void setTimingFields (Datetime serviceStartTime, Datetime invocationTime);

    void setOutputCreationClass (String outputCreationClass);
    String getOutputCreationClass ();

    void setDataReality (String dataReality);
    String getDataReality();



}
