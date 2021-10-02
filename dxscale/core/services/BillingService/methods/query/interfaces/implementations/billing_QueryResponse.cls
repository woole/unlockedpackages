public inherited sharing class billing_QueryResponse extends ServiceOutputMaster implements billing_IQueryResponse {

    private List<billing_BillingAccount> accounts;
    

    public billing_QueryResponse(List<billing_BillingAccount> accounts){
        this.accounts = accounts;
    }

    public List<billing_BillingAccount> getAccounts(){
        return this.accounts;
    }   

}
