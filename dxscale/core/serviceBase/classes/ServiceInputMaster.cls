public inherited sharing virtual class ServiceInputMaster implements IService_Input_Master {
    private String correlationId;

    public virtual String getCorrelationId() {
        return correlationId;
    }    
    public void setCorrelationId(String correlationId) {
        this.correlationId = correlationId;
    }    

}
