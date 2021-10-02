@isTest
public class MockODSConnectView_DAC implements System.StubProvider {



  public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {
        
        // The following debug statements show an example of logging 
        // the invocation of a mocked method.
       
        // You can use the method name and return type to determine which method was called.
        System.debug('Name of stubbed method: ' + stubbedMethodName);
        System.debug('Return type of stubbed method: ' + returnType.getName());
        
        // You can also use the parameter names and types to determine which method 
        // was called.
        for (integer i =0; i < listOfParamNames.size(); i++) {
            System.debug('parameter name: ' + listOfParamNames.get(i));
            System.debug('  parameter type: ' + listOfParamTypes.get(i).getName());
        }
        
        // This shows the actual parameter values passed into the stubbed method at runtime.
        System.debug('number of parameters passed into the mocked call: ' + 
            listOfArgs.size());
        System.debug('parameter(s) sent into the mocked call: ' + listOfArgs);
    
        String DUMMY_SFDC_ACCOUNT_ID = '0019E000010LxfwQAC';
        List<SObject> returnList = new List<SObject>();
        // This is a very simple mock provider that returns a hard-coded value 
        // based on the return type of the invoked.
        if (stubbedMethodName == 'getAccountExtras'){
            returnList.add(new VW_Connect_SalesHistory__x(
            ExternalId='12345',
            ProductName__c='Online Plus Support ',
            InvoiceDate__c= Date.today().addDays(-10),
            InvoiceNumber__c='INV06495461',
            InvoiceStatus__c = 'Open',
            ProductID__c = '0919664D2',
            NettAmount__c = 960,
            DiscountAmount__c = 10,
            TaxAmount__c = 102));
            return returnList;
        } else if (stubbedMethodName == 'getSalesLedger'){
            returnList.add(new VW_Connect_SalesLedger__x(
                Account_Key__c=234,
                Disputed__c='false',
                ExternalId='12345',
                GrossAmount__c=100,
                InvoiceDate__c=Date.today().addDays(-10),
                InvoiceDisputeReason__c='Unpaid',
                Invoiced_AccountNumber__c='ABC123',
                InvoiceNumber__c='NUM1289',
                SalesLedger_Key__c=7774747));
                return returnList;
        } else if (stubbedMethodName == 'getProductHoldingModuleHistory'){
            returnList.add(new VW_Connect_ProductHoldingModules_History__x(
                Account_Key__c=234,
                ExternalId='12345',
                ModuleValidToDate__c=Date.today().addDays(100),
                //ModuleVersion__c='1',
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                ProductHoldingModules_Key__c=1199290000,
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001'));
                return returnList;
        }else if (stubbedMethodName == 'getProductHoldingModules'){
            returnList.add(new VW_Connect_ProductHoldingModules__x(
                Account_Key__c=234,
                ExternalId='12345',
                ModuleValidToDate__c=Date.today().addDays(100),
                //ModuleVersion__c='1',
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                ProductHoldingModules_Key__c=1199290000,
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001'));
                return returnList;
        }else if (stubbedMethodName == 'getProductHoldingHistory'){
            returnList.add(new VW_Connect_ProductHoldingsHistory__x(
                Account_Key__c=234,
                ExternalId='12345',
                SupportTier__c='3',
                ValidCover__c=1,
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                TrialValidToDate__c=Date.today().addDays(30),
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001'));
                return returnList;
        }else if (stubbedMethodName == 'getCustomerInteractions'){
            returnList.add(new VW_Connect_ProductHoldings__x(
                Account_Key__c=234,
                ExternalId='12345',
                SupportTier__c='3',
                ValidCover__c=1,
                NoOfCompanies__c='10',
                NoOfEmployees__c='33',
                NoOfUsers__c='10',
                TrialValidToDate__c=Date.today().addDays(30),
                ProductHolding_Key__c=878172871,
                ProductName__c='Accounting 1001'));
                return returnList;
        }else if (stubbedMethodName == 'getProductHoldings'){
            returnList.add(new VW_Connect_CustomerInteraction__x(
            AccountID__c='12345', ContactName__c='frank1', InteractionDate__c=Date.parse('10/03/2018'),InteractionCategory__c='Case',SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID));

            returnList.add(new VW_Connect_CustomerInteraction__x(
            AccountID__c='876635', ContactName__c='frank2', InteractionDate__c=Date.parse('10/04/2019'),InteractionCategory__c='Complaint',SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID));
            return returnList;
        }else if (stubbedMethodName == 'getAccountPartners'){
            returnList.add(new VW_Connect_AccountPartner__x(
            PartnerAccountID__c='12345',
            SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID,
            SerialNumber__c='ABC321'));
            return returnList;
        }else if (stubbedMethodName == 'getAccountPrompts'){
            returnList.add(new VW_Connect_AccountPrompt__x(
            AccountNumber__c='12345',
            SalesforceAccountId__c=DUMMY_SFDC_ACCOUNT_ID,
            AccountPrompt_Key__c=124556,
            PromptText__c='DO NOT CALL'));
            return returnList;
        }else if (stubbedMethodName == 'getAccountExtras'){
            returnList.add(new VW_Connect_AccountExtra__x(
            AccountExtra_Key__c=66363,
            AccountPartner__c='ABC124356',
            AccountPassword__c='P@55w0000r66',
            CreditStatus__c='Good',
            HomeOrExport__c=true));
            return returnList;
        }else if(stubbedMethodName == 'getRecordCount'){
            Integer myInt = Integer.valueOf('10');
            return myInt;
        }else{
            return null;
        }
         
    }
}
