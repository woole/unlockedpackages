@isTest
public with sharing class ODSConnectView_DAC_Test {
    
    //this isn't a valid or hard coded id just in the correct format (otherwise SFDC rejects the call)
    private static final String DUMMY_SFDC_ACCOUNT_ID = '0019E000010LxfwQAC';

    @isTest
    public static void testGetSalesHistory() {
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_SalesHistory__x mockData = new VW_Connect_SalesHistory__x(
            ExternalId='12345',
            ProductName__c='Online Plus Support ',
            InvoiceDate__c= Date.today().addDays(-10),
            InvoiceNumber__c='INV06495461',
            InvoiceStatus__c = 'Open',
            ProductID__c = '0919664D2',
            NettAmount__c = 960,
            DiscountAmount__c = 10,
            TaxAmount__c = 102);
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_SalesHistory__x> viewData = dac.getSalesHistory(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('Online Plus Support ', viewData[0].ProductName__c,'expected Online Plus Support  for record 1 ProductName__c');        
    }

    @isTest
    public static void testGetSalesLedger(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_SalesLedger__x mockData = new VW_Connect_SalesLedger__x(
                Account_Key__c=234,
                Disputed__c='false',
                ExternalId='12345',
                GrossAmount__c=100,
                InvoiceDate__c=Date.today().addDays(-10),
                InvoiceDisputeReason__c='Unpaid',
                Invoiced_AccountNumber__c='ABC123',
                InvoiceNumber__c='NUM1289',
                SalesLedger_Key__c=7774747);
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_SalesLedger__x> viewData = dac.getSalesLedger(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('NUM1289', viewData[0].InvoiceNumber__c,'expected InvoiceNumber__c to be NUM1289');  
    }

    @isTest
    public static void testGetProductHoldingModuleHistory(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_ProductHoldingModules_History__x mockData = new VW_Connect_ProductHoldingModules_History__x(
                Account_Key__c=234,
                ExternalId='12345',
                ModuleValidToDate__c=Date.today().addDays(100),
                //ModuleVersion__c='1',
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                ProductHoldingModules_Key__c=1199290000,
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001');
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_ProductHoldingModules_History__x> viewData = dac.getProductHoldingModuleHistory(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('Accounting 1001', viewData[0].ProductName__c,'expected Accounting 1001 for record 1 ProductName__c');
    } 
    @isTest
    public static void testGetProductHoldingModules(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_ProductHoldingModules__x mockData = new VW_Connect_ProductHoldingModules__x(
                Account_Key__c=234,
                ExternalId='12345',
                ModuleValidToDate__c=Date.today().addDays(100),
                //ModuleVersion__c='1',
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                ProductHoldingModules_Key__c=1199290000,
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001');
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_ProductHoldingModules__x> viewData = dac.getProductHoldingModules(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('Accounting 1001', viewData[0].ProductName__c,'expected Accounting 1001 for record 1 ProductName__c');
    }        
    
    @isTest
    public static void testGetProductHoldingHistory(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_ProductHoldingsHistory__x mockData = new VW_Connect_ProductHoldingsHistory__x(
                Account_Key__c=234,
                ExternalId='12345',
                SupportTier__c='3',
                ValidCover__c=1,
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                TrialValidToDate__c=Date.today().addDays(30),
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001');
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_ProductHoldingsHistory__x> viewData = dac.getProductHoldingHistory(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('Accounting 1001', viewData[0].ProductName__c,'expected Accounting 1001 for record 1 ProductName__c');
    }  

    @isTest
    public static void testGetProductHoldings(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_ProductHoldings__x mockData = new VW_Connect_ProductHoldings__x(
                Account_Key__c=234,
                ExternalId='12345',
                SupportTier__c='3',
                ValidCover__c=1,
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                TrialValidToDate__c=Date.today().addDays(30),
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001');
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_ProductHoldings__x> viewData = dac.getProductHoldings(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('Accounting 1001', viewData[0].ProductName__c,'expected Accounting 1001 for record 1 ProductName__c');        

    }     


    @isTest
    public static void testGetCustomerInteractions(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_CustomerInteraction__x mockInformation1 = new VW_Connect_CustomerInteraction__x(
            AccountID__c='12345', ContactName__c='frank1', InteractionDate__c=Date.parse('10/03/2018'),InteractionCategory__c='Case',SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID);
        dac.mockedResponseData.add(mockInformation1);

        VW_Connect_CustomerInteraction__x mockInformation2 = new VW_Connect_CustomerInteraction__x(
            AccountID__c='876635', ContactName__c='frank2', InteractionDate__c=Date.parse('10/04/2019'),InteractionCategory__c='Complaint',SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID);          
        dac.mockedResponseData.add(mockInformation2);
        Test.startTest();
            List<VW_Connect_CustomerInteraction__x> viewData = dac.getCustomerInteractions(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(2, viewData.size(),'Should have returned 2 records');
        System.assertEquals(DUMMY_SFDC_ACCOUNT_ID, viewData[1].SalesforceAccountId__c,'SalesforceAccountId__c should have matched the DUMMY ID');        

    } 

    @isTest
    public static void testGetAccountPartners(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_AccountPartner__x mockData = new VW_Connect_AccountPartner__x(
            PartnerAccountID__c='12345',
            SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID,
            SerialNumber__c='ABC321');
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_AccountPartner__x> viewData = dac.getAccountPartners(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('12345', viewData[0].PartnerAccountID__c,'PartnerAccountID__c should have been 12345');          

    }

    @isTest
    public static void testGetAccountPrompts(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_AccountPrompt__x mockData = new VW_Connect_AccountPrompt__x(
            AccountNumber__c='12345',
            SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID,
            AccountPrompt_Key__c=124556,
            PromptText__c='DO NOT CALL');
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_AccountPrompt__x> viewData = dac.getAccountPrompts(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('DO NOT CALL', viewData[0].PromptText__c,'PromptText__c should have been DO NOT CALL');      
    }
     

    @isTest
    public static void testGetAccountExtras(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        VW_Connect_AccountExtra__x mockData = new VW_Connect_AccountExtra__x(
            AccountExtra_Key__c=66363,
            AccountPartner__c='ABC124356',
            AccountPassword__c='P@55w0000r66',
            CreditStatus__c='Good',
            HomeOrExport__c=true);
        dac.mockedResponseData.add(mockData);
        Test.startTest();
            List<VW_Connect_AccountExtra__x> viewData = dac.getAccountExtras(DUMMY_SFDC_ACCOUNT_ID,0,5);
        Test.stopTest();
        System.assertEquals(1, viewData.size(),'Should have returned 1 record');
        System.assertEquals('P@55w0000r66', viewData[0].AccountPassword__c,'AccountPassword__c should have been P@55w0000r66'); 
    }

    @isTest
    public static void testGetRecordCount_Success(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        List<String> viewNames = new String[]{'AccountExtra','AccountPartner','AccountPrompt','CustomerInteraction','ProductHoldings','ProductHoldingsHistory','ProductHoldingModules','ProductHoldingModules_History','SalesHistory','SalesLedger'};
        //List<String> viewNames = new String[]{'AccountExtra'};
        Test.startTest();
            for(String viewName:viewNames){
                System.debug(LoggingLevel.INFO, 'testing : ' +viewName);
                Integer count = dac.getRecordCount(DUMMY_SFDC_ACCOUNT_ID,viewName);    
                System.assertEquals(10,count,'expected 10 records');
            }
        Test.stopTest();
    }

    @isTest
    public static void testGetRecordCount_Error(){
        ODSConnectView_DAC dac = new ODSConnectView_DAC();
        String viewName = 'INVALID VIEW';
        Test.startTest();
            try{
                Integer count = dac.getRecordCount(DUMMY_SFDC_ACCOUNT_ID,viewName);
                System.assertEquals(true,false,'force an error as it shouldnt have got here');
            }catch(Exception e){
                System.assertEquals('System.AuraHandledException',e.getTypeName(),'should be the same but is ' +e.getTypeName());
            }
        Test.stopTest();
    }    
    

}
