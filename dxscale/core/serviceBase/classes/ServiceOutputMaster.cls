public inherited sharing virtual class ServiceOutputMaster implements IService_Output_Master {

    /* Standard Fields */

    private String state = 'SUCCESS';
    private String errorMessage;
    private String invocationType = 'Unknown';
    private String dataReality = 'Real';
    private String dataStatus = 'Processed';
    private String outputCreationClass = '';

    private String correlationId;



    /* Timing Fields */


    private Datetime invocationTime;
    private Datetime serviceStartTime;
    private Datetime responseTime;
    private long serviceDuration;
    private long invocationDuration;

    public void setCorrelationId(String correlationId){
        this.correlationId = correlationId;
    }

    public String getCorrelationId(){
        return this.correlationId;
    }

    public void setServiceStartTime (Datetime serviceStartTime) {
        this.serviceStartTime = serviceStartTime;
    }
    public Datetime getServiceStartTime () {
        return this.serviceStartTime;
    }

    public void setResponseTime (Datetime responseTime) {
        this.responseTime = responseTime;
    }
    public Datetime getResponseTime () {
        return this.responseTime;
    }

    public void setServiceDuration (long serviceDuration) {
        this.serviceDuration = serviceDuration;
    }
    public long getServiceDuration () {
        return this.serviceDuration;
    }

    public void setInvocationTime (Datetime invocationTime) {
        this.invocationTime = invocationTime;
    }
    public Datetime getInvocationTime () {
        return this.invocationTime;
    }


    public void setInvocationDuration (long invocationDuration) {
        this.invocationDuration = invocationDuration;
    }
    public long getInvocationDuration () {
        return this.invocationDuration;
    }


    public void setInvocationType (String invocationType) {
        this.invocationType = invocationType;
    }
    public String getInvocationType () {
        return this.invocationType;
    }

    public void setState (String state) {
        this.state = state;
    }
    public String getState () {
        return this.state;
    }

    public void setErrorMessage (String errorMessage) {
        this.errorMessage = errorMessage;
    }
    public String getErrorMessage () {
        return this.errorMessage;
    }

    public void setDataStatus (String dataStatus) {
        this.dataStatus = dataStatus;
    }
    public String getDataStatus () {
        return this.dataStatus;
    }

    public void setTimingFields (Datetime serviceStartTime, Datetime invocationTime) {
        this.responseTime = Datetime.now();
        this.serviceStartTime = serviceStartTime;
        this.invocationTime = invocationTime;
        this.serviceDuration = this.responseTime.getTime() - serviceStartTime.getTime();
        this.invocationDuration = this.responseTime.getTime() - invocationTime.getTime();
    }

    /* Output Creation */

    public void setOutputCreationClass (String outputCreationClass) {
        this.outputCreationClass = outputCreationClass;
    }

    public String getOutputCreationClass () {
        return this.outputCreationClass;
    }

    public void setDataReality (String dataReality) {
        this.dataReality = dataReality;
    }
    public String getDataReality () {
        return this.dataReality;
    }



}
