public inherited sharing class EmailerService_sendV1_Stub implements IService_Implementation {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IEmailRequestV1 isi = (IEmailRequestV1) inputData;
        return implementationBody(isi);
    } 

    @TestVisible private IStringOutput implementationBody(IEmailRequestV1 isi) {       

        IStringOutput iso = new StringOutputV1();
    
        iso.setCorrelationId(isi.getCorrelationid());
        iso.setState('SUCCESS');
        iso.setDataStatus('Stubbed');

        return iso;

    }

}
