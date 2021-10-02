public with sharing class ODSConnectCPViewLtCtrl {
    
    static ODSConnectCPView_DAC dac;
    static {
        if (Test.isRunningTest()) {
            dac = (ODSConnectCPView_DAC)Test.createStub(ODSConnectCPView_DAC.class, new MockODSConnectView_DAC());
        } else {
            dac = new ODSConnectCPView_DAC();
        }
    }

    @TestVisible 
    private static List<SObject> mockedResponseData = new List<SObject>();

    @AuraEnabled(cacheable=true)
    public static List<SObject> getViewData(Id accountId, String viewName) {
        System.debug(LoggingLevel.DEBUG, 'getViewData->accountID = ' + accountId + ',viewName = ' + viewName);

        if (viewName.endsWithIgnoreCase('AccountExtra')) {
            return dac.getAccountExtras(accountId);
        } else if (viewName.endsWithIgnoreCase('AccountPartner')) {
            return dac.getAccountPartners(accountId);
        } else if (viewName.endsWithIgnoreCase('AccountPrompt')) {
            return dac.getAccountPrompts(accountId);
        } else if (viewName.endsWithIgnoreCase('CustomerInteraction')) {
            return dac.getCustomerInteractions(accountId);
        } else if (viewName.endsWithIgnoreCase('ProductHoldings')) {
            return dac.getProductHoldings(accountId);
        } else if (viewName.endsWithIgnoreCase('ProductHoldingsHistory')) {
            return dac.getProductHoldingHistory(accountId);
        } else if (viewName.endsWithIgnoreCase('ProductHoldingModules')) {
            return dac.getProductHoldingModules(accountId);
        } else if (viewName.endsWithIgnoreCase('ProductHoldingModuleHistory')) {
            return dac.getProductHoldingModuleHistory(accountId);
        } else if (viewName.endsWithIgnoreCase('SalesHistory')) {
            return dac.getSalesHistory(accountId);
        } else if (viewName.endsWithIgnoreCase('SalesLedger')) {
            return dac.getSalesLedger(accountId);
        }
        // if we get here we're not supporting whatever the viewName is
        throw new AuraHandledException('viewName: ' + viewName + ' not supported.');
    }
    
    @AuraEnabled
    public static boolean getBypassSetting() {
        return ODSControlSwitch__c.getInstance().Run_Query__c;
    }
}