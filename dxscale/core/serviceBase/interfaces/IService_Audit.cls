global interface IService_Audit extends IService_Output_Master {

/*    
    userId
    SUCCESS/FAILURE
    invocation name
    service method/iteration/service etc.
    Invocation Type.
*/    

    void setInputData(String inputData);
    String getInputData();

    void setOutputData(String outputData);
    String getOutputData();

    // invocationDetails can be parsed by recipient
    // useful fields are invocation name, service method/iteration/service, Invocation Type.

    void setInvocationDetails(String invocationDetails);
    String getInvocationDetails();
    
    void parseInvocationDetails();

    String getImplementingClass();

    String getServiceName();

    Integer getIteration();

    String getMethod();

    String getInvocationName();

}
