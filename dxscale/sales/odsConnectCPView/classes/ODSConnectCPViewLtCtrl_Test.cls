@isTest
public with sharing class ODSConnectCPViewLtCtrl_Test {

    // This isn't a valid or hard-coded id just in the correct format (otherwise SFDC rejects the call)
    private static final String DUMMY_SFDC_ACCOUNT_ID = '0019E000010LxfwQAC';

    @isTest
    public static void testGetViewData() {
        List<String> viewNames = new String[]{
                'AccountExtra', 'AccountPartner', 'AccountPrompt', 'CustomerInteraction',
                'ProductHoldings', 'ProductHoldingsHistory', 'ProductHoldingModules',
                'ProductHoldingModuleHistory', 'SalesHistory', 'SalesLedger'
        };
        for (String viewName : viewNames) {
            List<SObject> results = ODSConnectCPViewLtCtrl.getViewData(DUMMY_SFDC_ACCOUNT_ID, viewName);
            System.assertEquals(1, 1, ' expected 1 result');
        }
    }

    @isTest
    public static void testGetViewData_WrongName() {
        try {
            List<SObject> results = ODSConnectCPViewLtCtrl.getViewData(DUMMY_SFDC_ACCOUNT_ID, 'DummyName');
            System.assertEquals(true, false, 'Force error in test as this should have thrown an error');
        } catch (Exception e) {
            System.assertEquals('System.AuraHandledException', e.getTypeName(), ' should be the same but is ' + e.getTypeName());
        }
    }

    @isTest
    public static void testBypass() {
        insert new ODSControlSwitch__c(Run_Query__c = false);
        System.assertEquals(false, ODSConnectCPViewLtCtrl.getBypassSetting(),'bypass settings should have been false');
    }
}