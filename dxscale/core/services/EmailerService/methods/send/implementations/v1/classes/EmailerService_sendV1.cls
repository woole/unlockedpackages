public inherited sharing class EmailerService_sendV1 implements IService_Implementation {
 
    static String CLASSNAME = 'EmailerService_sendV1';

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    
        IEmailRequestV1 isi = (IEmailRequestV1) inputData;
        return implementationBody(invocationDetails, isi);
    }

    @TestVisible 
    private IStringOutput implementationBody(IInvocation_Details invocationDetails, IEmailRequestV1 request) {
        IStringOutput iso = new StringOutputV1();
    
        iso.setCorrelationId(request.getCorrelationId());
        try
        {
            Messaging.SingleEmailMessage semail = EmailServiceHelper.getEmailMessage(request);
            EmailServiceHelper.sendEmail(semail);
            
        }
        catch(Exception ex) 
        {
            ExceptionLogger.logException(CLASSNAME,request.getCorrelationId(),ex, 'Unable send Email',true);
            iso.setState('FAIL');
            iso.setErrorMessage(ex.getMessage());
        }
        
        return iso;
    }

}
