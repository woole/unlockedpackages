@isTest
public class GenericServiceInvoker_Test {
    
    public static ServiceFrameworkBaseTestSetup initializeBaseSetup () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // We test services using implementingClass, invokers using stubClass
        baseSetup.implementingClass = 'DynamicQueryService_QueryV1';
        baseSetup.inputInterfaceVersion = 'IDynamicQueryConfigData';
        baseSetup.outputInterfaceVersion = 'IQueryListMap';
        baseSetup.inputCreationClass = 'DynamicQueryConfigData';
        baseSetup.invocationType = 'Sync';
        return baseSetup;
    }
    
    @TestSetup
    static void makeData(){
        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = 'DynamicQueryService_Invocation_1';
        sio.Metadata_Invoker_Id__c = 'DynamicQueryService_Invocation_1';        
        sio.Stub_Class__c = 'DynamicQueryV1_Stub';
        sio.Invocation_Type__c = 'Stub';
        sio.Override_Default__c = true;
        sio.Input_Creation_Class__c = 'DynamicQueryConfigData';
        sio.Service_Name__c = 'DynamicQueryService';
        insert sio;        
    }

    @isTest
    static void testInvoker(){
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        Test.startTest();
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());        
        
        GenericServiceInvoker invoker = new GenericServiceInvoker('DynamicQueryService_Invocation_1');
        invoker.setOverride(mockInvocation);
        IService_Output_Master output = invoker.call(new StringInputV1());
        
        Test.stopTest();
        System.assertEquals('SUCCESS', output.getState(),'expected SUCCESS but was ' + output.getState());
        
    }


    @isTest
    static void testInvoker_JSONPayload(){
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        Test.startTest();
        String queryJSON =  '{"whereClause":"id = ","enforceSecurity":true,"applyUserFLS":"READABLE","limitRows":500,"orderByClause":"Name","terminal":true,"fields":[{"api":"name","label":"Name","type":"String","display":true},{"api":"id","type":"id","display":true},{"api":"phone","type":"phone","display":true},{"api":"isActive","type":"boolean","display":true},{"api":"Latitude","type":"decimal","display":true},{"api":"lastvieweddate","type":"date","display":true},{"api":"NumberOfFailedLogins","type":"integer","display":true},{"api":"LanguageLocaleKey","type":"currency","display":true}],"objectType":"User"}';
        GenericServiceInvoker invoker = new GenericServiceInvoker('DynamicQueryService_Invocation_1');
        IService_Output_Master output = invoker.call(queryJSON);
        
        Test.stopTest();
        System.assert(output != null);
        System.assertEquals('SUCCESS', output.getState(),'expected SUCCESS but was ' + output.getState());
        
    }    

    public class MockServiceInvocation implements System.StubProvider {
        
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {        
              // This is a very simple mock provider that returns a hard-coded value 
              // based on the return type of the invoked.
              IService_Output_Master output = new StringOutputV1();
              output.setState('SUCCESS');
              return output;    
        }
    }      
}
