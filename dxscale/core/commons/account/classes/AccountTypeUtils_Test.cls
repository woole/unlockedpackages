@isTest
public class AccountTypeUtils_Test {

    @TestSetup
    static void makeData(){
        List<AccountTypeMap__c> mappings = new List<AccountTypeMap__c>();

        mappings.add(new AccountTypeMap__c(Name='Accountant Customer',Value__c='Accountant'));
        mappings.add(new AccountTypeMap__c(Name='Reseller',Value__c='Partner'));
        mappings.add(new AccountTypeMap__c(Name='Customer',Value__c='Customer'));
        mappings.add(new AccountTypeMap__c(Name='Partner',Value__c='Partner'));
        mappings.add(new AccountTypeMap__c(Name='Former Customer (Non Accountant)',Value__c='Customer'));
        mappings.add(new AccountTypeMap__c(Name='Accountant',Value__c='Accountant'));
        mappings.add(new AccountTypeMap__c(Name='Accountant Prospect',Value__c='Accountant'));
        mappings.add(new AccountTypeMap__c(Name='Prospect',Value__c='Customer'));
        mappings.add(new AccountTypeMap__c(Name='Former Customer',Value__c='Customer'));
        insert mappings;

    }
    
    @isTest
    static void testGetTypeForAccountType(){
        AccountType type = AccountTypeUtils.getAccountType('Accountant Prospect');
        System.assertEquals(AccountType.Accountant, type,'Expected Accountant');
        type = AccountTypeUtils.getAccountType('Accountant Customer');
        System.assertEquals(AccountType.Accountant, type,'Expected Accountant');      
        type = AccountTypeUtils.getAccountType('Reseller');
        System.assertEquals(AccountType.Partner, type,'Expected Partner');      
        //Default / unkown        
        type = AccountTypeUtils.getAccountType('Does not exist');
        System.assertEquals(AccountType.Customer, type,'Expected Customer');      
                
    }
    
    @isTest
    static void testGetValues(){
        List<String> values = AccountTypeUtils.getListForType(AccountType.Customer);
        System.assertEquals(4, values.size(),'expected 2 mappings');
        System.assertEquals('Customer', values[0],'Customer should have been 1st in the list');
        System.assertEquals('Prospect', values[2],'Prospect should have been 3rd in the list');

        values = AccountTypeUtils.getListForType(AccountType.Partner);
        System.assertEquals(2, values.size(),'expected 2 mappings');
        System.assertEquals('Reseller', values[0],'Reseller should have been 1st in the list');
        System.assertEquals('Partner', values[1],'Partner should have been 2nd in the list');
    }

}
