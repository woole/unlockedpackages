public with sharing class zuora_BillingAccount extends billing_BillingAccount{



    public zuora_BillingAccount(String accountId,Map<String, Object> queryResultsMap){
        super(accountId,queryResultsMap);
    }

    public override String getId(){
        return this.getValue('Id');
    }    
    public override String getBillingId(){
        return super.getValue('Zuora__Zuora_Id__c');
    }

    public override String getBillingAccountNumber(){
        return super.getValue('Zuora__AccountNumber__c');
    }
    public override String getBillToId(){
        return super.getValue('Zuora__BillToId__c');
    }           
    public override String getBillToEmail(){
        return super.getValue('Zuora__BillToWorkEmail__c');
    }

    public override String getSoldToId(){
        return super.getValue('Zuora__SoldToId__c');
    }           
    public override String getSoldToEmail(){
        return super.getValue('Zuora__SoldToWorkEmail__c');
    } 


}
