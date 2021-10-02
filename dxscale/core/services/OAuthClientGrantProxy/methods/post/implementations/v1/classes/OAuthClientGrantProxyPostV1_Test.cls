@IsTest
public class OAuthClientGrantProxyPostV1_Test {

    public static ServiceFrameworkBaseTestSetup initializeBaseSetup () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // We test services using implementingClass, invokers using stubClass
        baseSetup.implementingClass = 'OAuthClientGrantProxyPostV1';
        baseSetup.inputInterfaceVersion = 'ITokenAuthRequest';
        baseSetup.outputInterfaceVersion = 'ITokenAuthResponse';
        baseSetup.inputCreationClass = 'TokenAuthRequest';
        baseSetup.invocationType = 'Sync';
        baseSetup.externalCredentialsLabel = 'TestCredentials';
        return baseSetup;
    }

    @TestSetup
    static void makeData(){
        Service_Invocation_Override__c sio = new Service_Invocation_Override__c();
        sio.Name = 'HTTPCalloutBrokerInvocationV1_send';
        sio.Metadata_Invoker_Id__c = 'HTTPCalloutBrokerInvocationV1_send';        
        sio.Stub_Class__c = 'OAuthTokenV1_Stub';
        sio.Invocation_Type__c = 'Stub';
        sio.Override_Default__c = true;
        sio.Input_Creation_Class__c = 'GenericHTTPResponse';
        sio.Service_Name__c = 'HTTPCalloutBroker';
        insert sio;                
    }

    

    @isTest
    static void testDispatch(){
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);        
        OAuthClientGrantProxyPostV1 service = new OAuthClientGrantProxyPostV1();
        service.AUTH_CACHE_NAME = 'local.TestCache';
        BrokerConfigCredentials.core_ConfigCredentials testAuth = new BrokerConfigCredentials.core_ConfigCredentials();
        testAuth.cacheTTL = 3300;
        testAUth.clientID = 'testClient';
        testauth.clientSecret = 'testSecret';
        testAuth.type = 'client_grant';
        testAuth.scope = 'auth scope';
        testAuth.url = 'https://some/url/oauth/v2/token';
        service.authConnectInfo = testAuth;
        ITokenAuthRequest inputData = new TokenAuthRequest('correlation-id','TestAuthName');
        // HTTPRequestMock mockResponse = new HTTPRequestMock(200,
        //                                          'Complete',
        //                                          '{"token_type": "Bearer", "expires_in":3599,"ext_expires_in":3599, "access_token": "ICAgICAgICA8dmFsdWUgeHNpOnR5cGU9InhzZDpzdHJpbmciPkFjdGl2ZTwvdmFsdWU+CiAgICA8L3ZhbHVlcz4KICAgIDx2YWx1ZXM+CiAgICAgICAgPGZpZWxkPlVzZV9PdXRib3VuZF9Ccm9rZXJfSWRfX2M8L2ZpZWxkPgogICAgICAgIDx2YWx1ZSB4c2k6bmlsPSJ0cnVlIi8+CiAgICA8L3ZhbHVlcz4KPC9DdXN0b21NZXRhZGF0YT4="}',
        //                                          null);         
        // Test.setMock(HttpCalloutMock.class, mockResponse);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();
            ITokenAuthResponse response = (ITokenAuthResponse)service.dispatch(invocationDetails,inputData);
        Test.stopTest();
        System.assert(response != null,'Expected a token returned');
        // System.assert(response.getAccessToken() != null);
        // System.assertEquals('SUCCESS', response.getState());
    }

    @isTest
    static void testDispatch_Error(){
        Service_Invocation_Override__c stubOverride = [select Name,Id,Stub_Class__c from Service_Invocation_Override__c];
        stubOverride.Stub_Class__c = 'OAuthClientGrantProxyPostV1_Test.AzureTokenV1_Stub_Eith_Error';
        update stubOverride;
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);        
        OAuthClientGrantProxyPostV1 service = new OAuthClientGrantProxyPostV1();
        service.AUTH_CACHE_NAME = 'local.TestCache';
        BrokerConfigCredentials.core_ConfigCredentials testAuth = new BrokerConfigCredentials.core_ConfigCredentials();
        testAuth.cacheTTL = 3300;
        testAUth.clientID = 'testClient';
        testauth.clientSecret = 'testSecret';
        testAuth.type = 'client_grant';
        testAuth.scope = 'auth scope';
        testAuth.url = 'https://some/url/oauth/v2/token';
        service.authConnectInfo = testAuth;
        ITokenAuthRequest inputData = new TokenAuthRequest('correlation-id','TestAuthName');
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();
            ITokenAuthResponse response = (ITokenAuthResponse)service.dispatch(invocationDetails,inputData);
        Test.stopTest();
        System.assert(response != null,'Expected a token returned');
        System.assertEquals('FAIL', response.getState());
        System.assert(response.getErrorMessage().contains('Unable Authenticate :'));
    }    

    @isTest
    static void test_getAuthConnectInfo(){
        OAuthClientGrantProxyPostV1 service = new OAuthClientGrantProxyPostV1();
        service.AUTH_CACHE_NAME = 'local.TestCache';
        BrokerConfigCredentials.core_ConfigCredentials testAuth = new BrokerConfigCredentials.core_ConfigCredentials();
        testAuth.cacheTTL = 222;
        testAUth.clientID = 'testClient';
        testauth.clientSecret = 'testSecret';
        testAuth.type = 'client_grant';
        testAuth.scope = 'auth scope';
        testAuth.url = 'https://some/url/oauth/v2/token';
        service.authConnectInfo = testAuth;
        IConfigCredentials authInfo = service.getAuthConnectInfo('testConfig');
        System.assertEquals(222, authInfo.getCacheTTL());
    }

    @isTest
    static void testGetCredentials(){
        OAuthClientGrantProxyPostV1 service = new OAuthClientGrantProxyPostV1();
        service.AUTH_CACHE_NAME = 'local.TestCache';
        BrokerConfigCredentials.core_ConfigCredentials testAuth = new BrokerConfigCredentials.core_ConfigCredentials();
        testAuth.cacheTTL = 3300;
        testAUth.clientID = 'testClient';
        testauth.clientSecret = 'testSecret';
        testAuth.type = 'client_grant';
        testAuth.scope = 'auth scope';
        testAuth.url = 'https://some/url/oauth/v2/token';
        service.authConnectInfo = testAuth;
        OAuthClientGrantProxyPostV1.ClientCredentials credentials = service.getClientCredentials('testConfig');
        System.assertEquals('testSecret',credentials.client_secret);
        System.assertEquals('testClient',credentials.client_id);
        System.assertEquals('client_grant',credentials.grant_type);
        System.assertEquals(3300,service.ttlSecs);
    }

    @isTest
    static void testGetAccessToken_Success(){
        OAuthClientGrantProxyPostV1 service = new OAuthClientGrantProxyPostV1();
        service.AUTH_CACHE_NAME = 'local.TestCache';
        BrokerConfigCredentials.core_ConfigCredentials testAuth = new BrokerConfigCredentials.core_ConfigCredentials();
        testAuth.cacheTTL = 3300;
        testAUth.clientID = 'testClient';
        testauth.clientSecret = 'testSecret';
        testAuth.type = 'client_grant';
        testAuth.scope = 'auth scope';
        testAuth.url = 'https://some/url/oauth/v2/token';
        service.authConnectInfo = testAuth;

        OAuthClientGrantProxyPostV1.ClientCredentials credentials = service.getClientCredentials('testConfig');
        RemoteCallResponse token = service.getAccessToken(credentials);
        System.assert(token != null,'Expected a token returned');
        System.assertEquals(token.hasError,false);
        System.assert(token.tokenReponse!=null);
        System.assertEquals(token.tokenReponse.token_type,'Bearer');
        System.assertEquals(token.tokenReponse.expires_in,3599);
    
    }

    @isTest
    static void testAuditOverride(){
        OAuthClientGrantProxyPostV1 service = new OAuthClientGrantProxyPostV1();
        service.AUTH_CACHE_NAME = 'local.TestCache';
        String token = 'my-authtoken-not-for-auditting';
        TokenAuthResponse responseWithToken = new TokenAuthResponse(token);
        IStringOutput audit = (IStringOutput)service.overrideAuditOutput(responseWithToken);
        
        System.assert(!audit.getOutputMessage().containsIgnoreCase(token));
    }

    //Cache metadata can't be part of the package as it 
    // public class MockOrgPartitionCacheImpl implements PlatformCacheManager.ICacheManager{
    
    // }


    public inherited sharing class AzureTokenV1_Stub_Eith_Error implements IService_Implementation {

        public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
            IHTTPRequest isi = (IHTTPRequest) inputData;
            return stubBody(isi);
        }
    
        IHTTPResponse stubBody (IHTTPRequest isi) {
            String pnGuid = GuidUtils.getGUID();
            String correlationId = isi.getCorrelationId();
            String responseBody = '{    "error": "invalid_scope",    "error_description": "AADSTS70011: some error",    "error_codes": [        70011    ],    "timestamp": "2020-10-18 11:10:01Z",    "trace_id": "b072eb0c-4983-43b3-aeaa-902360a76200",    "correlation_id": "634a5080-b044-4677-8d4f-226ef87f60ea"}';
            GenericHTTPResponse response = new GenericHTTPResponse(responseBody,400);
            response.setCorrelationId(correlationId);
            response.setState('FAIL');
            
            return response;
        }
    
    
    }  


}


