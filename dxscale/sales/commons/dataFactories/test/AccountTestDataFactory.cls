@isTest
public class AccountTestDataFactory {
    
    public static Account createAccount(String name){
        Account account = new Account(Name=name);
        insert account;
        return account;
    }

    public static Account createAccountWithBillingAddressUK (String name,String billingCity,String billingStreet){
        Account account = createAccount(name);
        account.Type = 'Customer';
        account.BillingCountry='United Kingdom';
        account.BillingCity=billingCity;
        account.BillingStreet=billingStreet;
        update account;
        return account;
    }  

    public static Account createAccountWithMigrationInfo (String name, String migratrionInfo){
        Account account = createAccount(name);
        account.Migration_Information__c = migratrionInfo;
        update account;
        return account;
    }   
}
