public inherited sharing class AuditServiceV1 implements IService_Implementation {
 
    public IStringOutput dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IService_Audit isi = (IService_Audit) inputData;
        return implementationBody(invocationDetails, isi);
    }

    @TestVisible private IStringOutput implementationBody(IInvocation_Details invocationDetails, IService_Audit isi) {       

        System.debug('AuditServiceV1');

        IStringOutput iso = new StringOutputV1();
        iso.setOutputMessage('Audit Message Posted');
        iso.setState('SUCCESS');
        iso.setDataStatus('Real');

        Service_Framework_Audit__c tl = new Service_Framework_Audit__c();
        tl.Input_Data__c = isi.getInputData();
        tl.Output_Data__c = isi.getOutputData();
        tl.Invocation_Details__c = isi.getInvocationDetails();
        tl.State__c =  extractState(isi.getState());
        tl.Error_Message__c =  isi.getErrorMessage();
        tl.Invocation_Type__c =  isi.getInvocationType();
        tl.Data_Status__c =  isi.getDataStatus();
        tl.Duration__c =  isi.getServiceDuration();
        tl.Service_Start_Time__c =  isi.getServiceStartTime();
        tl.Response_Time__c =  isi.getResponseTime();
        tl.Invocation_Time__c =  isi.getInvocationTime();
        tl.Invocation_Duration__c =  isi.getInvocationDuration();
        tl.Correlation_Id__c = isi.getCorrelationId();

        isi.parseInvocationDetails();
        tl.Implementing_Class__c = isi.getImplementingClass();
        tl.Service_Name__c = isi.getServiceName();
        tl.Iteration__c = isi.getIteration();
        tl.Method__c = isi.getMethod();
        tl.Invocation_Name__c = isi.getInvocationName();
        insert tl;

        return iso;
    }

    @TestVisible private static String extractState(String rawState) {
        return rawState.contains('FAIL') ? 'FAILURE' : 'SUCCESS';
    }

}
