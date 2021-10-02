public inherited sharing class billing_UpdateSObjectRequest extends ServiceInputMaster implements billing_IUpdateSObjectRequest {
    
    private List<billing_IUpdateRequest> requests;

    public billing_UpdateSObjectRequest(String correlationId, List<billing_IUpdateRequest> requests){
        this.requests = requests;
        setCorrelationId(correlationId);
    }

    public List<billing_IUpdateRequest> getRequests(){
        return this.requests;
    }

}