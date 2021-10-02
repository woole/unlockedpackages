@isTest
public class zuora_BillingAccount_Test {
    

    @istest
    static void testData(){
        Map<String,Object> dataMap = new Map<String,Object>{
            'Zuora__Zuora_Id__c' => 'acccount-id',
            'Zuora__AccountNumber__c' => 'account-number',
            'Zuora__BillToId__c' => 'bill-to-id',
            'Zuora__BillToWorkEmail__c' => 'bill-to-email',
            'Zuora__SoldToId__c' => 'sold-to-id',
            'Zuora__SoldToWorkEmail__c' => 'sold-to-email'};
        
        zuora_BillingAccount testAccount = new zuora_BillingAccount('1234',dataMap);
        System.assertEquals('1234', testAccount.getAccountId());
        System.assertEquals('acccount-id', testAccount.getBillingId());
        System.assertEquals('account-number', testAccount.getBillingAccountNumber());
        System.assertEquals('bill-to-id', testAccount.getBillToId());
        System.assertEquals('bill-to-email', testAccount.getBillToEmail());
        System.assertEquals('sold-to-id', testAccount.getSoldToId());
        System.assertEquals('sold-to-email', testAccount.getSoldToEmail());


    }

}
