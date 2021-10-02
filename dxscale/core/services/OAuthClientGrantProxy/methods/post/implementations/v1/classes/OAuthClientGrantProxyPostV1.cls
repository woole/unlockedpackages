public virtual inherited sharing class OAuthClientGrantProxyPostV1 extends BaseServiceImplementation implements IService_Implementation,IService_Implementation_Audit_Override {
    //this is the time to live value that the cache will expire after 
    //@see https://developer.salesforce.com/docs/atlas.en-us.224.0.apexcode.meta/apexcode/apex_class_cache_Partition.htm#apex_class_cache_Partition
    //public static Integer ttlSecs = 3420;
    @TestVisible
    private Integer ttlSecs = 300;

    static String CLASSNAME = 'OAuthClientGrantProxyPostV1';
    
    @TestVisible
    private String AUTH_CACHE_NAME = 'local.AuthCache';

    @TestVisible
    private PlatformCacheManager.ICacheManager cacheManager;

    @TestVisible
    private String correlationId;
    
    //holds the connection info - can be set via test
    @TestVisible
    private IConfigCredentials authConnectInfo;
    
    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        ITokenAuthRequest request = (ITokenAuthRequest)inputData;
        return implementationBody(invocationDetails, request);
    }

    public PlatformCacheManager.ICacheManager getCacheManager(){
        if(cacheManager == null){
            cacheManager = PlatformCacheManager.getOrgCacheInstance(AUTH_CACHE_NAME);
        }
        return cacheManager;
    }

    @TestVisible 
    private ITokenAuthResponse implementationBody(IInvocation_Details invocationDetails, ITokenAuthRequest isi) { 
        
        TokenAuthResponse response = new TokenAuthResponse();
        correlationId = isi.getCorrelationId();
        //if not correlationId passed then create one
        if(String.isBlank(correlationId)){
        correlationId = GuidUtils.getGUID();
        }
        response.setCorrelationId(correlationId);
        //validate request
        String validations = validate((IRequestValidator)isi);
        System.debug(LoggingLevel.DEBUG,'validation errors : ' + validations);
        if(String.isNotEmpty(validations)){
            response.setState('FAIL');
            response.setErrorMessage(validations);
        }else{
            try{
                String authConnectName = isi.getAuthCredentials();
                
                //check cache - the key is the external credentials label
                RemoteCallResponse token = (RemoteCallResponse)getCacheManager().getFromCache(authConnectName);
                if(token == null){
                    System.debug(LoggingLevel.INFO, 'Cached token EXPIRED re-authing for authConnectName');
                    //go fetch new token and cache
                    ClientCredentials credentials = getClientCredentials(authConnectName);
                    token = getAccessToken(credentials);
                    //if we got anything other than OK (200)
                    if(token.hasError){
                        response.setState('FAIL');
                        response.setErrorMessage('Unable Authenticate :' + token.errorJSON);                    
                    }else{
                        getCacheManager().addToCache(authConnectName,token,ttlSecs);
                    }
                    
                }
                response.setAccessToken(token.tokenReponse.access_token);
            }catch(Exception e){
                ExceptionLogger.logException(CLASSNAME,correlationId,e,'Unable to Authenticate',true);
                System.debug('EXCEPTION CAUGHT ' + e);
                response.setState('FAIL');
                response.setErrorMessage('Unable Authenticate :' + e.getMessage());
                
            }
        }


    
        return response;
    }

    public RemoteCallResponse getAccessToken (ClientCredentials credentials)
    {
        
        /* As this is only linking to a dev org it's ok to use OAuth Username Password */
        /* Note: I did try a loop back but it was not successful, OAuth between scratch orgs was tricky */

        String reqbody = 'grant_type='+credentials.grant_type+'&client_id=' + credentials.client_id
            + '&client_secret=' + credentials.client_secret;
        if(credentials.providerType == 'Auth0'){
            reqbody += '&audience=' + credentials.scope;
        }else{
            reqbody += '&scope=' + credentials.scope;
        }
        
        System.debug(LoggingLevel.DEBUG, 'Calling : ' + credentials.name);
        System.debug(LoggingLevel.DEBUG, 'Request  :' + reqbody);
        Map<String, String> headers = new Map<String,String>();
        headers.put('Content-Type', 'application/x-www-form-urlencoded');
        if(String.isNotBlank(correlationId)){
            headers.put('X-Correlation-Id', correlationId);
        }        
        IHTTPRequest httpRequest = new GenericHTTPRequest(headers,reqbody,HTTPOperation.POST,credentials.name,null);
        httpRequest.setCorrelationId(correlationId);
        IService_Output_Master outputData = callBroker(httpRequest);

        if(outputData == null || outputData.getState() == 'FAIL'){
            throw new ClientAuthException('Unable to Authenticate against Azure');
        }
        IHTTPResponse httpResponse = (IHTTPResponse)outputData;
        RemoteCallResponse callResponse = new RemoteCallResponse();
        // TODO should add some success/error logic based on the status code
        if(httpResponse.hasError()){
            //treat as a problem
            callResponse.hasError = true;
            callResponse.errorJSON = httpResponse.getResponseBody();
        }else{
            RemoteCallResponse.AccessTokenResponse authToken = (RemoteCallResponse.AccessTokenResponse) ServiceSerialize.deserializeByClassType(httpResponse.getResponseBody(),RemoteCallResponse.AccessTokenResponse.class);
            callResponse.tokenReponse = authToken;
            //SF 
            callResponse.createdDatetime = System.now();
         
        }
        return callResponse;
    }

    public virtual IService_Output_Master callBroker(IHTTPRequest httpRequest){
    
        GenericServiceInvoker invoker = new GenericServiceInvoker('HTTPCalloutBrokerInvocationV1_send');
    
        return invoker.call(httpRequest);
    }

    public class ClientCredentials{
        public String name {get;set;}
        public String grant_type {get;set;}
        public String client_id {get;set;}
        public String client_secret {get;set;}
        public String scope {get;set;}
        public String tokenURL {get;set;}
        public String providerType {get;set;}
    }

    @TestVisible
    private IConfigCredentials getAuthConnectInfo(String label){
    
        if(authConnectInfo == null){
            BrokerConfigCredentials credentialConfig = new BrokerConfigCredentials();
            authConnectInfo = credentialConfig.getCredentials(label);
        }
        return authConnectInfo;
    }



    @TestVisible
    public ClientCredentials getClientCredentials(String label) {
        IConfigCredentials authInfo = getAuthConnectInfo(label);

        if(authInfo == null){
            //thorw an error
            throw new ClientAuthException('No oAuthCLientGrant configured for  : ' + label);
        }
        if(authInfo.getCacheTTL() != null){
            ttlSecs = authInfo.getCacheTTL();
        }
        ClientCredentials credentials = new ClientCredentials();
        credentials.name = label;
        credentials.grant_type = authInfo.getType();
        credentials.client_id = authInfo.getClientID();
        credentials.client_secret = authInfo.getClientSecret();
        credentials.scope = authInfo.getScope();
        credentials.tokenURL = authInfo.getURL();
        credentials.providerType = authInfo.getProviderType();
    
        return credentials;
    
    }


    public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
        ITokenAuthResponse iqlm = (ITokenAuthResponse) isom;
        boolean accessToken = iqlm.getAccessToken()!=null?true:false;

        IStringOutput stringOutput = new StringOutputV1();
        stringOutput.setOutputMessage ('Access Token returned = ' + accessToken);
        stringOutput.setState(isom.getState());
        stringOutput.setErrorMessage(isom.getErrorMessage());
        stringOutput.setCorrelationId(isom.getCorrelationId());
        return stringOutput;
    }    



    public class ClientAuthException extends Exception {}


}
