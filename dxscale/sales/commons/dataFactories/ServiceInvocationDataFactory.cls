
public inherited sharing class ServiceInvocationDataFactory {
    
    private static final String TYPE_STUB = 'Stub';
    
    public class InvokerParams {
        public String invokerName {get;set;}
        public String stubClassName {get;set;}
        public String inputClassName {get;set;}
        public String serviceName {get;set;}
    }

    public static Service_Invocation_Override__c createStubOverride(InvokerParams params){
        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = params.invokerName;
        sio.Metadata_Invoker_Id__c = params.invokerName;        
        sio.Stub_Class__c = params.stubClassName;
        sio.Invocation_Type__c = TYPE_STUB;
        sio.Override_Default__c = true;
        sio.Input_Creation_Class__c = params.inputClassName;
        sio.Service_Name__c = params.serviceName;
        insert sio;
        return sio;
    
    }
    
}
