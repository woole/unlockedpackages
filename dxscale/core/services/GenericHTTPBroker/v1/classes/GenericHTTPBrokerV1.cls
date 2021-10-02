public inherited sharing virtual class GenericHTTPBrokerV1 implements IService_Implementation {

    private String correlationId;
    @TestVisible
    private IConfigCredentials authInfo;

    static String CLASSNAME = 'GenericHTTPBrokerV1';

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IHTTPRequest isi = (IHTTPRequest) inputData;
        return implementationBody(invocationDetails, isi);
    }

    @TestVisible 
    private IService_Output_Master implementationBody(IInvocation_Details invocationDetails, IHTTPRequest request) {
        String serviceName = invocationDetails.getServiceName();
        Service svc = Service.initialize(serviceName);
        IHTTPResponse response;
        String correlationId = request.getCorrelationId();
        //What you connect to can be defined at the service config or request level. start at service
        String authConnectName = String.isBlank(svc.getExternalCredentialsLabel())?request.getCredentialsName():svc.getExternalCredentialsLabel();
        if(String.isBlank(authConnectName)){
            String errorMessage = 'Config Error : Auth connection not supplied. AuthCredential name needs supplying in the request or via the service External_Credentials_Label__c';
            System.debug(LoggingLevel.ERROR, errorMessage);
            response = new GenericHTTPResponse(errorMessage,500);
            response.setState('FAIL');
            response.setErrorMessage(errorMessage);
        }else{
            try{
                HttpRequest httpRequest = getHttpRequest(request,authConnectName);
                response = send(httpRequest);
            }catch(GenericHTTPBrokerException e){
                ExceptionLogger.logException(CLASSNAME,correlationId,e, 'AuthConnection not found',true);
                String errorMessage = 'AuthConnection not found : ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, errorMessage);
                response = new GenericHTTPResponse(errorMessage,500);
                response.setErrorMessage(errorMessage);
                response.setState('FAIL');
            }catch(CalloutException e){
                ExceptionLogger.logException(CLASSNAME,correlationId,e, 'Callout Failed',true);
                String errorMessage = 'Callout Failure : ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, errorMessage);
                response = new GenericHTTPResponse(errorMessage,500);
                response.setErrorMessage(errorMessage);
                response.setState('FAIL');             
            }
            catch(Exception e){
                ExceptionLogger.logException(CLASSNAME,correlationId,e, 'Unexpected Error',true);
                String errorMessage = 'Unexpected Error : ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, errorMessage);
                response = new GenericHTTPResponse(errorMessage,500);
                response.setErrorMessage(errorMessage);
                response.setState('FAIL');             
            }
            
        }
        response.setCorrelationId(correlationId);
        return response;
    }

    private IHTTPResponse send(HttpRequest request){
    
        Http http = new Http();
        System.debug(LoggingLevel.DEBUG, 'HTTPRequest = ' + request);
        HttpResponse httpResponse = http.send(request);
        System.debug(LoggingLevel.DEBUG, 'HTTPResponse = ' + httpResponse);
        Integer responseStatus = httpResponse.getStatusCode();
        String responseBody = httpResponse.getBody();
        GenericHTTPResponse response = new GenericHTTPResponse(responseBody,responseStatus);
        response.setCorrelationId(this.correlationId);
    
        return response;        
    }



    private String getEndPoint(IHTTPRequest serviceRequest,String authName){
        IConfigCredentials authInfo = getAuthConnectInfo(authName);
        String endPoint;
        if(authInfo == null){
            throw new GenericHTTPBrokerException('Not credentialsfound for : ' + authName + '. Authentication Failure');
        }else{
            //use Named credentials
            if(String.isNotEmpty(authInfo.getNamedCredentialName())){
                endPoint = 'callout:'+authInfo.getNamedCredentialName();
            }else{
                endPoint = authInfo.getURL();
            }
        }
        if(String.isNotBlank(serviceRequest.getURLInfo())){
                endPoint += serviceRequest.getURLInfo();
        }
        System.debug('ENDPOINT -> ' + endPoint);
        return endPoint;
        
    }


    @TestVisible
    private IConfigCredentials getAuthConnectInfo(String label){
        if(authInfo == null){
            BrokerConfigCredentials credentialConfig = new BrokerConfigCredentials();
            authInfo = credentialConfig.getCredentials(label);
        }
        return authInfo;
    }    

    @TestVisible
    HttpRequest getHttpRequest(IHTTPRequest request,String authConnectName) {

        String endPoint = getEndPoint(request,authConnectName);
        IConfigCredentials connectionInfo = getAuthConnectInfo(authConnectName);
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod(request.getOperation().name());
        if(String.isNotBlank(request.getRequestBody())){
            httpRequest.setBody(request.getRequestBody());
        }
        //EAD-2256 read and set the timeout or default to 30 seconds (not the default of 10 in SF)
        if(connectionInfo != null){
            httpRequest.setTimeout(connectionInfo.getRequestTimeOut());
        }else{
            httpRequest.setTimeout(30000);
        }
        
        if(request.getRequestHeaders() != null)
        for(String key:request.getRequestHeaders().keySet()){
            if(key.equalsIgnoreCase('X-Correlation-Id')){
                this.correlationId = request.getRequestHeaders().get(key);
            }
            System.debug(LoggingLevel.DEBUG, 'ADDing Header : KEY : ' + key + ' VALUE : ' + request.getRequestHeaders().get(key));
            httpRequest.setHeader(key,request.getRequestHeaders().get(key));
            System.debug(LoggingLevel.DEBUG, 'HEADER : ' + httpRequest.getHeader(key));
        }
        if(request.getAuthHeaders() != null){
            for(String key:request.getAuthHeaders().keySet()){
                httpRequest.setHeader(key,request.getAuthHeaders().get(key));
                System.debug(LoggingLevel.DEBUG, 'Auth  Header Added');
            }
        }
        httpRequest.setEndpoint(endPoint);
        return httpRequest;
        
    }       

    public class GenericHTTPBrokerException extends Exception {}
}