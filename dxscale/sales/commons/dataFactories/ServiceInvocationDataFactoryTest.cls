@isTest
public class ServiceInvocationDataFactoryTest {

    @TestSetup
    static void makeData(){
        ServiceInvocationDataFactory.InvokerParams params = new ServiceInvocationDataFactory.InvokerParams();
        params.inputClassName = 'ServiceInputDataMock';
        params.invokerName = 'TestCodeService_Invoker';
        params.serviceName = 'MockTestService';
        params.stubClassName = 'MockTestService_Stub_v1';
        ServiceInvocationDataFactory.createStubOverride(params);
        
    }

    @isTest
    public static void testCreateStubOverride(){
        Service_Invocation_Override__c record = [select Name,Metadata_Invoker_Id__c,Stub_Class__c,Invocation_Type__c,Override_Default__c,Input_Creation_Class__c,Service_Name__c FROM Service_Invocation_Override__c LIMIT 1];
        System.assertEquals('TestCodeService_Invoker', record.Name,'Invoker name should have matached');
        System.assertEquals('TestCodeService_Invoker', record.Metadata_Invoker_Id__c,'Invoker ID should have matached');
        System.assertEquals('MockTestService_Stub_v1', record.Stub_Class__c,'Stub Classes should have matached');
        System.assertEquals('Stub', record.Invocation_Type__c,'Invoker Type should have been Stub');
        System.assertEquals(true, record.Override_Default__c,'Override should have been true');
        System.assertEquals('ServiceInputDataMock', record.Input_Creation_Class__c,'Input class should have matched');
        System.assertEquals('MockTestService', record.Service_Name__c,'Service Name should have been MockTestService');

    }

}

