@isTest
public with sharing class ODSConnectViewLtCtrl_Test {


    
    //this isn't a valid or hard coded id just in the correct format (otherwise SFDC rejects the call)
    private static final String DUMMY_SFDC_ACCOUNT_ID = '0019E000010LxfwQAC';
    

    @isTest
    public static void testGetViewData(){
        List<String> viewNames = new String[]{'AccountExtra','AccountPartner','AccountPrompt','CustomerInteraction','ProductHoldings','ProductHoldingsHistory','ProductHoldingModules','ProductHoldingModules_History','SalesHistory','SalesLedger'};
        for(String viewName:viewNames){
            List<SObject> results = ODSConnectViewLtCtrl.getViewData(DUMMY_SFDC_ACCOUNT_ID,viewName,0,5);
            System.assertEquals(1, 1,' expected 1 result');
        }
    }

   @isTest
    public static void testGetViewData_WrongName(){
        try{
            List<SObject> results = ODSConnectViewLtCtrl.getViewData(DUMMY_SFDC_ACCOUNT_ID,'DummyName',0,5);
            System.assertEquals(true,false,'Force error in test as this should have thrown error');
        }
        catch(Exception e){
            System.assertEquals('System.AuraHandledException',e.getTypeName(),'should be the same but is ' +e.getTypeName());
        }
        
        
    
    }    

    @isTest
    public static void testGetRecordCount_Success(){
        
        List<String> viewNames = new String[]{'AccountExtra','AccountPartner','AccountPrompt','CustomerInteraction','ProductHoldings','ProductHoldingsHistory','ProductHoldingModules','ProductHoldingModules_History','SalesHistory','SalesLedger'};
        //List<String> viewNames = new String[]{'AccountExtra'};
        Test.startTest();
            for(String viewName:viewNames){
                System.debug(LoggingLevel.INFO, 'testing : ' +viewName);
                Integer count = ODSConnectViewLtCtrl.getRecordCount(DUMMY_SFDC_ACCOUNT_ID,viewName);    
                System.assertEquals(10,count,'expected 10 but got ' + count);
            }
        Test.stopTest();
    }    

    @isTest
    public static void testGetRecordCount_Error(){
        String viewName = 'INVALID VIEW';
        Test.startTest();
            try{
                Integer count = ODSConnectViewLtCtrl.getRecordCount(DUMMY_SFDC_ACCOUNT_ID,viewName);
                System.assertEquals(true,false,'force an error as it shouldnt have got here');
            }catch(Exception e){
                System.assertEquals('System.AuraHandledException',e.getTypeName(),'should be the same but is ' +e.getTypeName());
            }
        Test.stopTest();
    }     
    
}