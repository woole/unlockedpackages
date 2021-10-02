public virtual inherited sharing class BaseAuthenticatedService extends BaseServiceImplementation{

    private static final String CLASSNAME = 'BaseAuthenticatedService';

    private String correlationId;
    private transient ITokenAuthResponse authToken;
    //the Auth Credentials Name
    private String authCredentialsName;
    //the invocation for calling auth
    private String authInvokerName;
    //the invocation for calling the external system
    private String serviceInvokerName;

    private void init(String correlationId, String authCredentialsName,String authInvokerName, String serviceInvokerName){
        this.correlationId = correlationId;
        this.authCredentialsName = authCredentialsName;
        this.authInvokerName = authInvokerName;
        this.serviceInvokerName = serviceInvokerName;
    }

    @TestVisible
    protected String getCorrelationId(){
        return this.correlationId;
    }

    @TestVisible
    protected void setCorrelationId(String correlationId){
        this.correlationId = correlationId;
    }  

    @TestVisible
    protected ITokenAuthResponse getAuthToken(){
        return this.authToken;
    }

    @TestVisible
    protected String getAuthCredentialsName(){
        return this.authCredentialsName;
    }

    @TestVisible
    protected void setAuthInvokerName(String authInvokerName){
        this.authInvokerName = authInvokerName;
    }


    @TestVisible
    protected String getAuthInvokerName(){
        return this.authInvokerName;
    }

    @TestVisible
    protected void setServiceInvokerName(String serviceInvokerName){
        this.serviceInvokerName = serviceInvokerName;
    }


    @TestVisible
    protected String getServiceInvokerName(){
        return this.serviceInvokerName;
    }    
    
    
    /**
     * Authenticates Order Managemen 
     */
    @TestVisible
    private virtual void authenticate(){
        
        ITokenAuthRequest request = new TokenAuthRequest(getCorrelationId(),getAuthCredentialsName());
        GenericServiceInvoker invoker = new GenericServiceInvoker(getAuthInvokerName());
        IService_Output_Master outputData = invoker.call(request);
        if(outputData == null || outputData.getState() != 'SUCCESS'){
            String error = 'Auth Error : Failed to authenticate with '+ getAuthCredentialsName() + ' : ';
            if(outputData != null){
                error += outputData.getErrorMessage();
            }
            throw new AuthenticatedServiceException(error);
        }else{
            authToken = (ITokenAuthResponse)outputData;
        }
    }

    @TestVisible
    private virtual IHTTPResponse callBroker(IHTTPRequest request){
        String INVOKER_NAME = getServiceInvokerName();
        GenericServiceInvoker invoker = new GenericServiceInvoker(INVOKER_NAME);
        IHTTPResponse httpResponse;
        //sanity check the output
        IService_Output_Master outputData = invoker.call(request);
        
        System.debug(LoggingLevel.DEBUG, outputData);
        Boolean expectedType = outputData instanceof IHTTPResponse;
        //Check if the quote API failed
        if(outputData == null || !expectedType){
            throw new AuthenticatedServiceException(INVOKER_NAME + ' call failed : ' + outputData.getErrorMessage());
        }else{
            httpResponse = (IHTTPResponse)outputData;
        }
        return httpResponse;
    }    

    @TestVisible
    private virtual IHTTPRequest buildRequest(IExternalRequest request){
       
        Map<String, String> headers = new Map<String,String>();
        headers.put('Content-Type', 'application/json;charset=UTF-8');
        
        if(String.isNotBlank(getCorrelationId())){
            headers.put('X-Correlation-Id', getCorrelationId());
        }
        GenericHTTPRequest httpRequest = new GenericHTTPRequest(headers,request.getRequestJSON(),request.getOperation(),request.getAuthName(),request.getPath(),getCorrelationId());
        httpRequest.addBearerAuth(getAuthToken().getAccessToken());
        return httpRequest;
    }    

    /**
     * auth and call the external system. if either step fails, a AuthenticatedServiceException is generated
     * the caller needs to interpret the httpresponse
     */
    @TestVisible
    protected virtual IHTTPResponse processRequest(IExternalRequest request,String correlationId,String authCredentialsName,String authInvokerName, String serviceInvokerName){
        //sets the call context 
        init(correlationId, authCredentialsName, authInvokerName, serviceInvokerName);
        //auth
        authenticate();
        //convert the IExternalRequest to a HTTP Request
        IHTTPRequest httpRequest = buildRequest(request);
        //this is used to differentiate what this admin call was for
        String functionName = request.getFunctionName();
        IHTTPResponse httpResponse = callBroker(httpRequest);
        return httpResponse;
    }
    
    
    public class AuthenticatedServiceException extends Exception {}

}
