/**
 * DAC for ODS Connect views
 * These accessors fetch all columns form the relevant Connect views for an account. Support pagination via limit and offset
 * @author craig.bradshaw@sage.com
 * @date Aug 2019
 */
public with sharing class ODSConnectView_DAC {


    @TestVisible 
    private List<SObject> mockedResponseData = new List<SObject>();

    

    public ODSConnectView_DAC() {

    }

    /**
     * getSalesHistory returns VW_Connect_SalesHistory__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_SalesHistory__x objects
     */
    public List<VW_Connect_SalesHistory__x> getSalesHistory(Id accountId,Integer rowLimit, Integer rowOffSet){
            

            List<VW_Connect_SalesHistory__x> listRsults = [
                SELECT
                Account_Key__c,
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
                order by InvoiceDate__c desc
                LIMIT :Integer.valueOf(rowLimit)
                OFFSET :Integer.valueOf(rowOffSet)                  
                ];
            if(Test.isRunningTest()) {
                    listRsults = mockedResponseData;
            }                
            
            System.debug(LoggingLevel.DEBUG, 'getSalesHistory->' + listRsults);
            
            return listRsults;
    }

    /**
     * getSalesHistory returns VW_Connect_SalesLedger__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_SalesLedger__x objects
     */
    public List<VW_Connect_SalesLedger__x> getSalesLedger(Id accountId,Integer rowLimit, Integer rowOffSet){

            List<VW_Connect_SalesLedger__x> listRsults = [
                SELECT
                Account_Key__c,
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
                order by InvoiceDate__c desc
                LIMIT :Integer.valueOf(rowLimit)
                OFFSET :Integer.valueOf(rowOffSet)  
                ];
            if(Test.isRunningTest()) {
                    listRsults = mockedResponseData;
            }             
            System.debug(LoggingLevel.DEBUG, 'getSalesLedger->' + listRsults);
            
            return listRsults;
    }

    /**
     * getSalesHistory returns VW_Connect_ProductHoldingModules_History__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_ProductHoldingModules_History__x objects
     */
    public List<VW_Connect_ProductHoldingModules_History__x> getProductHoldingModuleHistory(Id accountId,Integer rowLimit, Integer rowOffSet){
            

            List<VW_Connect_ProductHoldingModules_History__x> listRsults = [
                SELECT
                AccountID__c,
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
                order by RegistrationDate__c desc
                LIMIT :Integer.valueOf(rowLimit)
                OFFSET :Integer.valueOf(rowOffSet)  
                ];
            
            System.debug(LoggingLevel.DEBUG, 'getProductHoldingModuleHistory->' + listRsults);
            if(Test.isRunningTest()) {
                    listRsults = mockedResponseData;
            }             
            return listRsults;
    }

    /**
     * getSalesHistory returns VW_Connect_ProductHoldingModules__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_ProductHoldingModules__x objects
     */
    public List<VW_Connect_ProductHoldingModules__x> getProductHoldingModules(Id accountId,Integer rowLimit, Integer rowOffSet){
            
            List<VW_Connect_ProductHoldingModules__x> listRsults = [
                SELECT
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
                RegistrationDate__c,
                SalesforceAccountId__c,
                SerialNumber__c,
                System_Key__c
                FROM VW_Connect_ProductHoldingModules__x 
                WHERE SalesforceAccountId__c = :accountId 
                order by RegistrationDate__c desc
                LIMIT :Integer.valueOf(rowLimit)
                OFFSET :Integer.valueOf(rowOffSet)                  
                ];
            
            System.debug(LoggingLevel.DEBUG, 'getProductHoldingModules->' + listRsults);
            if(Test.isRunningTest()) {
                    listRsults = mockedResponseData;
            }             
            return listRsults;
    } 


    /**
     * getSalesHistory returns VW_Connect_ProductHoldingsHistory__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_ProductHoldingsHistory__x objects
     */
    public List<VW_Connect_ProductHoldingsHistory__x> getProductHoldingHistory(Id accountId,Integer rowLimit, Integer rowOffSet){

            List<VW_Connect_ProductHoldingsHistory__x> listRsults = [
                SELECT
                AccountID__c,
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
                order by WarrantyExpiryDate__c desc
                LIMIT :Integer.valueOf(rowLimit)
                OFFSET :Integer.valueOf(rowOffSet)                  
                ];
            
            System.debug(LoggingLevel.DEBUG, 'getProductHoldingHistory->' + listRsults);
            if(Test.isRunningTest()) {
                    listRsults = mockedResponseData;
            }             
            return listRsults;
    } 

    /**
     * getSalesHistory returns VW_Connect_ProductHoldings__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_ProductHoldings__x objects
     */
    public List<VW_Connect_ProductHoldings__x> getProductHoldings(Id accountId,Integer rowLimit, Integer rowOffSet){
        
        List<VW_Connect_ProductHoldings__x> listRsults = [
            SELECT
            AccountID__c,
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
            order by WarrantyExpiryDate__c desc
            LIMIT :Integer.valueOf(rowLimit)
            OFFSET :Integer.valueOf(rowOffSet)               
            ];
        
        System.debug(LoggingLevel.DEBUG, 'getProductHoldings->' + listRsults);
        if(Test.isRunningTest()) {
                listRsults = mockedResponseData;
        }         
        return listRsults;
    } 

    /**
     * getSalesHistory returns VW_Connect_CustomerInteraction__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_CustomerInteraction__x objects
     */
    public List<VW_Connect_CustomerInteraction__x> getCustomerInteractions(Id accountId,Integer rowLimit, Integer rowOffSet){

        List<VW_Connect_CustomerInteraction__x> listRsults = [
            SELECT
            AccountID__c,
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
            order by InteractionDate__c desc
            LIMIT :Integer.valueOf(rowLimit)
            OFFSET :Integer.valueOf(rowOffSet)            
            ];
        
        System.debug(LoggingLevel.DEBUG, 'getCustomerInteractions->' + listRsults);
        if(Test.isRunningTest()) {
                listRsults = mockedResponseData;
        }         
        return listRsults;
    }     

    /**
     * getSalesHistory returns VW_Connect_AccountPartner__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_AccountPartner__x objects
     */
    public List<VW_Connect_AccountPartner__x> getAccountPartners(Id accountId,Integer rowLimit, Integer rowOffSet){
        
        List<VW_Connect_AccountPartner__x> listRsults = [
            SELECT
            AccountNumber__c,
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
            LIMIT :Integer.valueOf(rowLimit)
            OFFSET :Integer.valueOf(rowOffSet)              
            ];
        
        System.debug(LoggingLevel.DEBUG, 'getAccountPartners->' + listRsults);
        if(Test.isRunningTest()) {
                listRsults = mockedResponseData;
        }         
        return listRsults;
    } 

    /**
     * getSalesHistory returns VW_Connect_AccountPrompt__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_AccountPrompt__x objects
     */
    public List<VW_Connect_AccountPrompt__x> getAccountPrompts(Id accountId,Integer rowLimit, Integer rowOffSet){
 
        List<VW_Connect_AccountPrompt__x> listRsults = [
            SELECT
            AccountNumber__c,
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
            order by PromptCreatedDate__c desc
            LIMIT :Integer.valueOf(rowLimit)
            OFFSET :Integer.valueOf(rowOffSet)  
            ];
        
        System.debug(LoggingLevel.DEBUG, 'getAccountPrompts->' + listRsults);
        if(Test.isRunningTest()) {
                listRsults = mockedResponseData;
        }         
        return listRsults;
    }    

    /**
     * getSalesHistory returns VW_Connect_AccountExtra__x for given account limited byt limit and offset
     * @param  accountId accountId the SFDC accountID
     * @param  rowLimit  rowLimit is how many rows to return
     * @param  rowOffSet rowOffSet the row offset
     * @return           return List of VW_Connect_AccountExtra__x objects
     */
    public List<VW_Connect_AccountExtra__x> getAccountExtras(Id accountId,Integer rowLimit, Integer rowOffSet){
        
        List<VW_Connect_AccountExtra__x> listRsults = [
            SELECT
            AccountExtra_Key__c,
            AccountNumber__c,
            AccountPartner__c,
            AccountPassword__c,
            CreditStatus__c,
            ExternalId,
            HomeOrExport__c
            FROM VW_Connect_AccountExtra__x 
            WHERE SalesforceAccountId__c = :accountId 
            LIMIT :Integer.valueOf(rowLimit)
            OFFSET :Integer.valueOf(rowOffSet)              
            ];
        
        System.debug(LoggingLevel.DEBUG, 'getAccountExtras->' + listRsults);
        if(Test.isRunningTest()) {
                listRsults = mockedResponseData;
        }         
        return listRsults;
    }

    /**
     * getRecordCount returns the record count for the accountId
     * @param  accountId accountId SFDC account Id
     * @param  viewName  viewName relates to the simplified format of the view name
     * @return           return the Integer Count
     */
    public Integer getRecordCount(Id accountId, String viewName){
        String tableName = '';
        if(viewName.endsWithIgnoreCase('AccountExtra')){
            tableName = 'VW_Connect_AccountExtra__x';
        }else if(viewName.endsWithIgnoreCase('AccountPartner')){
            tableName = 'VW_Connect_AccountPartner__x';
        }else if(viewName.endsWithIgnoreCase('AccountPrompt')){
            tableName = 'VW_Connect_AccountPrompt__x';
        }else if(viewName.endsWithIgnoreCase('CustomerInteraction')){
            tableName = 'VW_Connect_CustomerInteraction__x';
        }else if(viewName.endsWithIgnoreCase('ProductHoldings')){
            tableName = 'VW_Connect_ProductHoldings__x';
        }else if(viewName.endsWithIgnoreCase('ProductHoldingsHistory')){
            tableName = 'VW_Connect_ProductHoldingsHistory__x';
        }else if(viewName.endsWithIgnoreCase('ProductHoldingModules')){
            tableName = 'VW_Connect_ProductHoldingModules__x';
        }else if(viewName.endsWithIgnoreCase('ProductHoldingModules_History')){
            tableName = 'VW_Connect_ProductHoldingModules__x';
        }else if(viewName.endsWithIgnoreCase('SalesHistory')){
            tableName = 'VW_Connect_SalesHistory__x';
        }else if(viewName.endsWithIgnoreCase('SalesLedger')){
            tableName = 'VW_Connect_SalesLedger__x';
        }else{
             throw new AuraHandledException('viewName : ' + viewName + ' Not supported.');  
        }
        if(Test.isRunningTest()) {
                return 10;
        }

        String sqolCount = 'SELECT count() FROM ' + tableName + ' WHERE SalesforceAccountId__c = :accountId ';
        return Database.countQuery(sqolCount);
    }

}