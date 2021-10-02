/**
 * EAD-2415 - to support sharing a high level "type" for the account, we abstract away from our internal SF types.
 * Custom settings called AccountTypeMap__c hold the mapping of the Account.Type to asbstract value.
 * Caller can use getAccountType (passing the Acccount.Type value) to get the AccountType. this defauls to "Customer" for no mapping
 */
public inherited sharing class AccountTypeUtils {

    public static AccountType DEFAULT_VALUE = AccountType.Customer;
    public static final String CLASS_NAME = 'AccountTypeUtils';
    
    public static List<String> getListForType(AccountType type){
        List<String> mappings = new List<String>();
        List<AccountTypeMap__c> results = [select Name from AccountTypeMap__c where Value__c = :type.name()];
        for(AccountTypeMap__c value:results){
            mappings.add(value.Name);
        }
        return mappings; 
    }

    public static AccountType getDefaultType(){
        return DEFAULT_VALUE;
    }

    /**
     * Pass in the value from the Account.Type to return the generic Mapping
     */
    public static AccountType getAccountType(String typeValue){
        
        AccountType resultType = DEFAULT_VALUE;
        AccountTypeMap__c value;
        try{
            value = [Select Value__c From AccountTypeMap__c where Name = :typeValue];
        }catch(Exception e){
            ExceptionLogger.logException(CLASS_NAME, e, 'No account type map exists for : ' + typeValue);
        }
        
        if(value != null){
            for (AccountType at: AccountType.values()) {
                if (at.name() == value.Value__c) {
                    resultType = at;
                    break;
                }
            } 
        }
        return resultType;
    }
    
}
