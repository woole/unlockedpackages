@isTest
public class billing_BillingAccount_Test {
    @istest
    static void testData(){
        Map<String,Object> dataMap = new Map<String,Object>{
            'Id' => 'record-id',
            'BillingId' => 'billing-id',
            'BillToId' => 'bill-to-id',
            'AccountNumber' => 'account-number',
            'BillToWorkEmail' => 'bill-to-email',
            'SoldToId' => 'sold-to-id',
            'SoldToWorkEmail' => 'sold-to-email'};
        
        billing_BillingAccount testAccount = new billing_BillingAccount('1234',dataMap);
        System.assertEquals('1234', testAccount.getAccountId());
        System.assertEquals('record-id', testAccount.getId());
        System.assertEquals('billing-id', testAccount.getBillingId());
        System.assertEquals('account-number', testAccount.getBillingAccountNumber());
        System.assertEquals('bill-to-id', testAccount.getBillToId());
        System.assertEquals('bill-to-email', testAccount.getBillToEmail());
        System.assertEquals('sold-to-id', testAccount.getSoldToId());
        System.assertEquals('sold-to-email', testAccount.getSoldToEmail());


    }
}
