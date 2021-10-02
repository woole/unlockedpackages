/**
 * DAC for ODS Client Pagination Connect Views
 * These accessors fetch all columns form the relevant Connect views for an account
 * Support pagination on Client side to reduce hits on database
 * @author pete.wilson@sage.com
 * @date Nov 2019
 */
public with sharing class ODSConnectCPView_DAC {

    @TestVisible 
    private List<SObject> mockedResponseData = new List<SObject>();

    public ODSConnectCPView_DAC() {}

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_SalesHistory__x objects
     */
    public List<VW_Connect_SalesHistory__x> getSalesHistory(Id accountId) {

        List<VW_Connect_SalesHistory__x> listResults = new List<VW_Connect_SalesHistory__x>();

        listResults = [
            SELECT  Account_Key__c,
                    DiscountAmount__c,
                    Disputed__c,
                    ExternalId,
                    GrossAmount__c,
                    InvoiceDate__c,
                    InvoiceDisputeReason__c,
                    Invoiced_AccountNumber__c,
                    InvoiceNumber__c,
                    InvoiceStatus__c,
                    InvoiceType__c,
                    Invoice_Currency__c,
                    NettAmount__c,
                    OrderPlacedByEmployeeName__c,
                    ProductID__c,
                    ProductName__c,
                    Quantity__c,
                    SalesHistory_Key__c,
                    System_Key__c,
                    TaxAmount__c
            FROM VW_Connect_SalesHistory__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY InvoiceDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        }
            
        System.debug(LoggingLevel.DEBUG, 'getSalesHistory->' + listResults);
        return listResults;
    }

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_SalesLedger__x objects
     */
    public List<VW_Connect_SalesLedger__x> getSalesLedger(Id accountId) {

        List<VW_Connect_SalesLedger__x> listResults = new List<VW_Connect_SalesLedger__x>();
  
        listResults = [
            SELECT  Account_Key__c,
                    Disputed__c,
                    ExternalId,
                    GrossAmount__c,
                    InvoiceDate__c,
                    InvoiceDisputeReason__c,
                    Invoiced_AccountNumber__c,
                    InvoiceNumber__c,
                    InvoiceOpen__c,
                    InvoiceStatus__c,
                    InvoiceType__c,
                    Invoice_Currency__c,
                    NettAmount__c,
                    PaymentDueDate__c,
                    SalesLedger_Key__c,
                    System_Key__c,
                    TaxAmount__c,
                    UnpaidAmount__c
            FROM VW_Connect_SalesLedger__x 
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY InvoiceDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getSalesLedger->' + listResults);
        return listResults;
    }

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_ProductHoldingModules_History__x objects
     */
    public List<VW_Connect_ProductHoldingModules_History__x> getProductHoldingModuleHistory(Id accountId) {

        List<VW_Connect_ProductHoldingModules_History__x> listResults = new List<VW_Connect_ProductHoldingModules_History__x>();

        listResults = [
            SELECT  AccountID__c,
                    Account_Key__c,
                    ExternalId,
                    ModuleValidToDate__c,
                    //ModuleVersion__c,
                    NoOfCompanies__c,
                    NoOfEmployees__c,
                    NoOfUsers__c,
                    ProductHoldingModules_Key__c,
                    ProductHoldingStatus__c,
                    ProductHolding_Key__c,
                    ProductID__c,
                    ProductName__c,
                    RecordValidFrom__c,
                    RegistrationDate__c,
                    SerialNumber__c,
                    System_Key__c
            FROM VW_Connect_ProductHoldingModules_History__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY RegistrationDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 
        
        System.debug(LoggingLevel.DEBUG, 'getProductHoldingModuleHistory->' + listResults);
        return listResults;
    }

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_ProductHoldingModules__x objects
     */
    public List<VW_Connect_ProductHoldingModules__x> getProductHoldingModules(Id accountId) {

        List<VW_Connect_ProductHoldingModules__x> listResults = new List<VW_Connect_ProductHoldingModules__x>();
      
        listResults = [
            SELECT  Account_Key__c,
                    ExternalId,
                    ModuleValidToDate__c,
                    //ModuleVersion__c,
                    NoOfCompanies__c,
                    NoOfEmployees__c,
                    NoOfUsers__c,
                    ProductHoldingModules_Key__c,
                    ProductHoldingStatus__c,
                    ProductHolding_Key__c,
                    ProductID__c,
                    ProductName__c,
                    RegistrationDate__c,
                    SalesforceAccountId__c,
                    SerialNumber__c,
                    System_Key__c
            FROM VW_Connect_ProductHoldingModules__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY RegistrationDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getProductHoldingModules->' + listResults);
        return listResults;
    } 


    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_ProductHoldingsHistory__x objects
     */
    public List<VW_Connect_ProductHoldingsHistory__x> getProductHoldingHistory(Id accountId) {

        List<VW_Connect_ProductHoldingsHistory__x> listResults = new List<VW_Connect_ProductHoldingsHistory__x>();
       
        listResults = [
            SELECT  AccountID__c,
                    Account_Key__c,
                    ActivationKey__c,
                    ContractType__c,
                    ExternalId,
                    InvoiceStatus__c,
                    IsTrial__c,
                    NoOfCompanies__c,
                    NoOfEmployees__c,
                    NoOfUsers__c,
                    ProductHoldingStatus__c,
                    ProductHolding_Key__c,
                    ProductID__c,
                    ProductName__c,
                    ProductType__c,
                    ProductVersion__c,
                    RegistrationDate__c,
                    SalesforceAccountId__c,
                    SerialNumber__c,
                    SupportExpiryDate__c,
                    SupportLevel__c,
                    SupportPartnerAccountID__c,
                    SupportPartnerType__c,
                    SupportPartner__c,
                    SupportTier__c,
                    System_Key__c,
                    TrialValidToDate__c,
                    ValidCover__c,
                    WarrantyExpiryDate__c
            FROM VW_Connect_ProductHoldingsHistory__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY WarrantyExpiryDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        }

        System.debug(LoggingLevel.DEBUG, 'getProductHoldingHistory->' + listResults);
        return listResults;
    } 

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_ProductHoldings__x objects
     */
    public List<VW_Connect_ProductHoldings__x> getProductHoldings(Id accountId) {

        List<VW_Connect_ProductHoldings__x> listResults = new List<VW_Connect_ProductHoldings__x>();
   
        listResults = [
            SELECT  AccountID__c,
                    Account_Key__c,
                    ActivationKey__c,
                    ContractType__c,
                    ExternalId,
                    InvoiceStatus__c,
                    IsTrial__c,
                    NoOfCompanies__c,
                    NoOfEmployees__c,
                    NoOfUsers__c,
                    ProductHoldingStatus__c,
                    ProductHolding_Key__c,
                    ProductID__c,
                    ProductName__c,
                    ProductType__c,
                    ProductVersion__c,
                    RegistrationDate__c,
                    SalesforceAccountId__c,
                    SerialNumber__c,
                    SupportExpiryDate__c,
                    SupportLevel__c,
                    SupportPartnerAccountID__c,
                    SupportPartnerType__c,
                    SupportPartner__c,
                    SupportTier__c,
                    System_Key__c,
                    TrialValidToDate__c,
                    ValidCover__c,
                    WarrantyExpiryDate__c
            FROM VW_Connect_ProductHoldings__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY WarrantyExpiryDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getProductHoldings->' + listResults);
        return listResults;
    } 

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_CustomerInteraction__x objects
     */
    public List<VW_Connect_CustomerInteraction__x> getCustomerInteractions(Id accountId) {

        List<VW_Connect_CustomerInteraction__x> listResults = new List<VW_Connect_CustomerInteraction__x>();
 
        listResults = [
            SELECT  AccountID__c,
                    Account_Key__c,
                    ContactName__c,
                    CustomerInteraction_Key__c,
                    EmployeeName__c,
                    ExternalId,
                    InteractionCategory__c,
                    InteractionDate__c,
                    InteractionDescription__c,
                    InteractionMajorComment__c,
                    InteractionMediumComment__c,
                    InteractionMethod__c,
                    InteractionMinorComment__c,
                    InteractionNotes__c,
                    InteractionReason__c,
                    InteractionResult__c,
                    InteractionStatus__c,
                    InteractionType__c,
                    ProductVersion__c,
                    SerialNumber__c,
                    StockCode__c,
                    System_Key__c
            FROM VW_Connect_CustomerInteraction__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY InteractionDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getCustomerInteractions->' + listResults);
        return listResults;
    }     

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_AccountPartner__x objects
     */
    public List<VW_Connect_AccountPartner__x> getAccountPartners(Id accountId) {

        List<VW_Connect_AccountPartner__x> listResults = new List<VW_Connect_AccountPartner__x>();

        listResults = [
            SELECT  AccountNumber__c,
                    Account_Key__c,
                    ExternalId,
                    PartnerAccountID__c,
                    PartnerLevel__c,
                    PartnerName__c,
                    PartnerType__c,
                    ProductName__c,
                    SerialNumber__c
            FROM VW_Connect_AccountPartner__x 
            WHERE SalesforceAccountId__c = :accountId 
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getAccountPartners->' + listResults);
        return listResults;
    } 

    /**
     * getSalesHistory returns VW_Connect_AccountPrompt__x for given account limited by limit and offset
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_AccountPrompt__x objects
     */
    public List<VW_Connect_AccountPrompt__x> getAccountPrompts(Id accountId) {

        List<VW_Connect_AccountPrompt__x> listResults = new List<VW_Connect_AccountPrompt__x>();

        listResults = [
            SELECT  AccountNumber__c,
                    AccountPrompt_Key__c,
                    ExternalId,
                    PromptArea__c,
                    PromptCreatedBy__c,
                    PromptCreatedDate__c,
                    PromptModifiedBy__c,
                    PromptModifiedDate__c,
                    PromptRequiresConfirmation__c,
                    PromptText__c,
                    PromptType__c,
                    PromptValidFrom__c,
                    PromptValidTo__c
            FROM VW_Connect_AccountPrompt__x
            WHERE SalesforceAccountId__c = :accountId
            ORDER BY PromptCreatedDate__c DESC
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getAccountPrompts->' + listResults);
        return listResults;
    }    

    /**
     * @param  accountId accountId the SFDC accountID
     * @return return List of VW_Connect_AccountExtra__x objects
     */
    public List<VW_Connect_AccountExtra__x> getAccountExtras(Id accountId) {

        List<VW_Connect_AccountExtra__x> listResults = new List<VW_Connect_AccountExtra__x>();

        listResults = [
            SELECT  AccountExtra_Key__c,
                    AccountNumber__c,
                    AccountPartner__c,
                    AccountPassword__c,
                    CreditStatus__c,
                    ExternalId,
                    HomeOrExport__c
            FROM VW_Connect_AccountExtra__x
            WHERE SalesforceAccountId__c = :accountId
            LIMIT 9999
        ];
        
        if (Test.isRunningTest()) {
            listResults = mockedResponseData;
        } 

        System.debug(LoggingLevel.DEBUG, 'getAccountExtras->' + listResults);
        return listResults;
    }
}