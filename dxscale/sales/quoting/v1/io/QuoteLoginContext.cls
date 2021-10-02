public inherited sharing class QuoteLoginContext implements IService_Input_Master {
    private String correlationId;
    public QuoteLoginRequestV1 context {get;set;}

    public String getCorrelationId() {
        return correlationId;
    }    
    public void setCorrelationId(String correlationId) {
        this.correlationId = correlationId;
    }         
}
