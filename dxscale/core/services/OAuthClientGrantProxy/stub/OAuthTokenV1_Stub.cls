/**
 * Stub is you want to override the HTTPCalloutBrokerInvocationV1_send - set this as the stub
 */
public inherited sharing class OAuthTokenV1_Stub implements IService_Implementation, IService_Implementation_Audit_Override {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IHTTPRequest isi = (IHTTPRequest) inputData;
        return stubBody(isi);
    }

    IHTTPResponse stubBody (IHTTPRequest isi) {
        String pnGuid = GuidUtils.getGUID();
        String correlationId = isi.getCorrelationId();
        String type = isi.getCredentialsName();
        String responseBody = '{    "token_type": "Bearer",    "expires_in": 3599,    "ext_expires_in": 3599,    "access_token": "'+type+':Stubby:ajasdfk99KDKJDk88a99kjkdjksjdksjdakk!_lDUMMYzzzzzjaksdjaaa_0dadaliw_MADEUPqqqqicvmvadfjfj"}';
        GenericHTTPResponse response = new GenericHTTPResponse(responseBody,200);
        response.setCorrelationId(correlationId);
        response.setState('SUCCESS');
        
        return response;
    }

    public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {

        IHTTPResponse httpresp = (IHTTPResponse) isom;
        String resp = httpresp.getStatusCode() + ' | ' + httpresp.getResponseBody();

        IStringOutput stringOutput = new StringOutputV1();
        stringOutput.setOutputMessage ('Stubbed Response : ' + resp);
        stringOutput.setState(isom.getState());
        stringOutput.setErrorMessage(isom.getErrorMessage());
        return stringOutput;
    }

}