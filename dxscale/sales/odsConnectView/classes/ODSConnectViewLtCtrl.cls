public with sharing class ODSConnectViewLtCtrl {
    
    static ODSConnectView_DAC dac;
    static{
        if(Test.isRunningTest()){
            dac = (ODSConnectView_DAC)Test.createStub(ODSConnectView_DAC.class, new MockODSConnectView_DAC());
        }else{
            dac = new ODSConnectView_DAC();
        }
         
    }

    @TestVisible 
    private static List<SObject> mockedResponseData = new List<SObject>();

    @AuraEnabled
    public static List<SObject> getViewData(Id accountId,String viewName,Integer rowLimit, Integer rowOffSet) {
        System.debug(LoggingLevel.DEBUG, 'getViewData->accountID = ' + accountId + ',viewName = ' + viewName + ',rowLimit = '+rowLimit+',rowOffSet = '+rowOffSet);

        if(viewName.endsWithIgnoreCase('AccountExtra')){
            return dac.getAccountExtras(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('AccountPartner')){
            return dac.getAccountPartners(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('AccountPrompt')){
            return dac.getAccountPrompts(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('CustomerInteraction')){
            return dac.getCustomerInteractions(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('ProductHoldings')){
            return dac.getProductHoldings(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('ProductHoldingsHistory')){
            return dac.getProductHoldingHistory(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('ProductHoldingModules')){
            return dac.getProductHoldingModules(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('ProductHoldingModules_History')){
            return dac.getProductHoldingModuleHistory(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('SalesHistory')){
            return dac.getSalesHistory(accountId,rowLimit,rowOffSet);
        }else if(viewName.endsWithIgnoreCase('SalesLedger')){
            return dac.getSalesLedger(accountId,rowLimit,rowOffSet);
        }
        //if we get here we're not supporing whatever the viewName is
        throw new AuraHandledException('viewName : ' + viewName + ' Not supported.');
        
    }

    @AuraEnabled
    public static Integer getRecordCount(Id accountId,String viewName){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        return dac.getRecordCount(accountId, viewName);       
    }

    



}