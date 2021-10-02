public virtual with sharing class GenericServiceInvoker {

    private ServiceInvocation invoker;

    @TestVisible
    public GenericServiceInvoker(){}

    public GenericServiceInvoker(String invokerId){
        invoker = ServiceInvocation.initialize(invokerId);
    }

    public void setOverride(ServiceInvocation invocation){
        invoker = invocation;
    }

    public virtual IService_Output_Master call(String jsonPayload){
        String inputCreationClass = invoker.getInvocationDetails().getInputCreationClass();
        IService_Input_Master serviceRequest = (IService_Input_Master) ServiceSerialize.deserializeByClassName(jsonPayload,inputCreationClass);
        return call(serviceRequest);
        
    }        
   
    public virtual IService_Output_Master call(IService_Input_Master request){
        
        return invoker.invokeService(request);
        
    }    
}
