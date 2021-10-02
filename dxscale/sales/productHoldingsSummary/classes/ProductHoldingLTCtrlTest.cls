@isTest
public class ProductHoldingLTCtrlTest {

    @TestSetup
    static void makeData(){
        Account account = AccountTestDataFactory.createAccount('Dummy Account');
    }

    @IsTest
    public static void testGetScreenData () {

        // this is the invokerId used by teh QueryGridDisplayController
        String invokerId = 'ProductHoldingSummary_Invocation_1';
        // setup the invocation to use a stub by tweaking the custom metadata

        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = invokerId;
        sio.Metadata_Invoker_Id__c = invokerId;        
        sio.Stub_Class__c = 'DynamicQueryV1_Stub';
        sio.Invocation_Type__c = 'Stub';
        sio.Override_Default__c = true;
        sio.Input_Creation_Class__c = 'DynamicQueryConfigData';
        sio.Service_Name__c = 'DynamicQueryService';
        insert sio;
        Account acc = [select id,Global_Id__c  from account where name = 'Dummy Account' limit 1];
        Id recordId = acc.Id;
        
        ProductHoldingLTCtrl.ScreenData sd = ProductHoldingLTCtrl.getScreenData(recordId, 'ProdHoldingSumm_ProdHolding',invokerId,'Global_Id__c');
        System.assertEquals('SUCCESS',sd.state,'Should have returned success');
        System.assertEquals(10,sd.items.size(),'should have returned 10 rows but returned ' + sd.items.size()); // stub returns 10 rows by default
        System.assert(!sd.potentiallyMoreRows,'should not have had more rows');
    }

    @IsTest
    public static void testGetScreenDataInvalidInvoker () {

        String invokerId = 'ProductHoldingSummary_NotValid_Invocation_1';

        Id recordId = UserInfo.getUserId();
        try{
            ProductHoldingLTCtrl.ScreenData sd = ProductHoldingLTCtrl.getScreenData(recordId, 'ProdHoldingSumm_ProdHolding',invokerId,'Global_Id__c');
            System.assert(!true,'should not have got here, forced error');
        }catch(Exception e){
            
            System.assert(e instanceof AuraHandledException,'should have thrown an AuraHandledException but was ' + e.getTypeName());
        }
        

    }
    
    @IsTest
    public static void testGetScreenDataInvalidID () {

        String invokerId = 'ProductHoldingSummary_Invocation_1';

        Id recordId = null;
        try{
            ProductHoldingLTCtrl.ScreenData sd = ProductHoldingLTCtrl.getScreenData(recordId, 'ProdHoldingSumm_ProdHolding',invokerId,'Global_Id__c');
            System.assert(!true,'should not have got here, forced error');
        }catch(Exception e){
            
            System.assert(e instanceof AuraHandledException,'should have thrown an AuraHandledException but was ' + e.getTypeName());
        }
        

    }      

}
