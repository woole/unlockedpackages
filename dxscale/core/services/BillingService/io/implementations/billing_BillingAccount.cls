/**
 * Represents a Billing account. This should be extended per vendor
 */
public inherited sharing virtual class billing_BillingAccount {


    private String accountId {get;set;}        

    private Map<String, Object> queryResultsMap;

    public billing_BillingAccount(String accountId,Map<String, Object> queryResultsMap){
        this.accountId = accountId;
        this.queryResultsMap = queryResultsMap;        
    }
    public virtual String getId(){
        return this.getValue('Id');
    }
    public virtual String getBillingId(){
        return this.getValue('BillingId');
    }

    public virtual String getBillingAccountNumber(){
        return this.getValue('AccountNumber');
    }
    public virtual String getBillToId(){
        return this.getValue('BillToId');
    }           
    public virtual String getBillToEmail(){
        return this.getValue('BillToWorkEmail');
    }

    public virtual String getSoldToId(){
        return this.getValue('SoldToId');
    }           
    public virtual String getSoldToEmail(){
        return this.getValue('SoldToWorkEmail');
    }


    public String getAccountId(){
        return this.accountId;
    }


    protected virtual String getValue(String apiName){    
        Object value;
        
        if(this.queryResultsMap != null && this.queryResultsMap.containsKey(apiName)){
            value = this.queryResultsMap.get(apiName);
        }
        return (String)value;
    }



}
