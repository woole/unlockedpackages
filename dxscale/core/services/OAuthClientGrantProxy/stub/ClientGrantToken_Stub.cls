/** 
 * For stubbing the OAUthClientGrantProxy - for CloudID_OrderManagement_ClientGrant or Azure_QuoteAPI_ClientGrant
 */
public inherited sharing class ClientGrantToken_Stub implements IService_Implementation {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        ITokenAuthRequest isi = (ITokenAuthRequest) inputData;
        return stubBody(isi);
    }

    ITokenAuthResponse stubBody (ITokenAuthRequest isi) {
        
        String correlationId = isi.getCorrelationId();
        String type = isi.getAuthCredentials();
        String token = type+':Stubby:YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd6eHk=';
        ITokenAuthResponse response = new TokenAuthResponse(token);
        response.setCorrelationId(correlationId);
        response.setState('SUCCESS');
        return response;
    }


}