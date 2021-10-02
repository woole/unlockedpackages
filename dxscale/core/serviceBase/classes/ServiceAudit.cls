global inherited sharing class ServiceAudit extends ServiceOutputMaster implements IService_Audit {

    private String inputData;
    private String outputData;
    private String invocationDetails;
    private String implementingClass;
    private String serviceName;
    private Integer iteration;
    private String method;
    private String invocationName;

    public void setInputData(String inputData){
        this.inputData = inputData ;
    }
    public String getInputData(){
        return this.inputData  ;
    }

    public void setOutputData(String outputData){
        this.outputData = outputData ;
    }
    public String getOutputData(){
        return this.outputData  ;
    }

    public void setInvocationDetails(String invocationDetails){
        this.invocationDetails = invocationDetails ;
    }
    public String getInvocationDetails(){
        return this.invocationDetails  ;
    }

    public void setImplementingClass (String implementingClass) {
        this.implementingClass = implementingClass;
    }

    public void parseInvocationDetails(){
        IInvocation_Details iid = Service.deserializeInvocationDetails (getInvocationDetails());
        this.implementingClass = iid.getImplementingClass();
        this.serviceName = iid.getServiceName();
        this.iteration = iid.getIteration();
        this.method = iid.getMethod();
        this.invocationName = iid.getServiceInvocationName();
    }

    public String getImplementingClass () {
        return this.implementingClass;
    }

    public String getServiceName () {
        return this.serviceName;
    }

    public Integer getIteration () {
        return this.iteration;
    }

    public String getMethod () {
        return this.method;
    }

    public String getInvocationName () {
        return this.invocationName;
    }


}
