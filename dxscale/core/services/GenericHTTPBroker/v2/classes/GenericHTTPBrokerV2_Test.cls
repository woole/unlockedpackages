@isTest
public class GenericHTTPBrokerV2_Test {


    public static ServiceFrameworkBaseTestSetup initializeBaseSetup () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        // We test services using implementingClass, invokers using stubClass
        baseSetup.implementingClass = 'GenericHTTPBrokerV1';
        baseSetup.inputInterfaceVersion = 'IHTTPRequest';
        baseSetup.outputInterfaceVersion = 'IHTTPResponse';
        baseSetup.inputCreationClass = 'GenericHTTPRequest';
        baseSetup.invocationType = 'Sync';
        return baseSetup;
    }
   
    
    @isTest
    static void testSuccess(){
        GenericHTTPBrokerV2 service = new GenericHTTPBrokerV2();
        BrokerConfigCredentials.core_ConfigCredentials testAuth = new BrokerConfigCredentials.core_ConfigCredentials();
        testAuth.cacheTTL = 3300;
        testAUth.clientID = 'testClient';
        testauth.clientSecret = 'testSecret';
        testAuth.type = 'client_grant';
        testAuth.scope = 'auth scope';
        testAuth.url = 'https://some/url/oauth/v2/token';
        service.authInfo = testAuth;

        String reqbody = 'grant_type=client_credentials&client_id=BBDBDBHD&client_secret=shkksecret&scope=scop...';
        Map<String, String> headers = new Map<String,String>();
        headers.put('Content-Type', 'application/x-www-form-urlencoded');
        headers.put('X-Correlation-Id', 'test-1234');
                
        IHTTPRequest httpRequest = new GenericHTTPRequest(headers,reqbody,HTTPOperation.POST,'TestCredentials',null);
        IBrokerRequest brokerRequest = new BrokerRequest();
        brokerRequest.setBrokerRequest(httpRequest);
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        baseSetup.externalCredentialsLabel = 'TestCredentials';
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();            
            HTTPRequestMock mockResponse = new HTTPRequestMock(200,
                                                    'Complete',
                                                    '{"token_type": "Bearer", "expires_in":3599,"ext_expires_in":3599, "access_token": "ICAgICAgICA8dmFsdWUgeHNpOnR5cGU9InhzZDpzdHJpbmciPkFjdGl2ZTwvdmFsdWU+CiAgICA8L3ZhbHVlcz4KICAgIDx2YWx1ZXM+CiAgICAgICAgPGZpZWxkPlVzZV9PdXRib3VuZF9Ccm9rZXJfSWRfX2M8L2ZpZWxkPgogICAgICAgIDx2YWx1ZSB4c2k6bmlsPSJ0cnVlIi8+CiAgICA8L3ZhbHVlcz4KPC9DdXN0b21NZXRhZGF0YT4="}',
                                                    null);        

            Test.setMock(HttpCalloutMock.class, mockResponse);
            IService_Output_Master outputData = service.dispatch(invocationDetails,brokerRequest);
        Test.stopTest();
        System.assert(outputData!=null);
        IHTTPResponse httpResponse = (IHTTPResponse)outputData;
        System.assertEquals(200, httpResponse.getStatusCode());

    }

    @isTest
    static void testError_NoAuthInfo(){
        GenericHTTPBrokerV2 service = new GenericHTTPBrokerV2();

        String reqbody = 'mock request';
                
        IHTTPRequest httpRequest = new GenericHTTPRequest(null,reqbody,HTTPOperation.POST,null,null);
        IBrokerRequest brokerRequest = new BrokerRequest();
        brokerRequest.setBrokerRequest(httpRequest);        
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.externalCredentialsLabel = 'AuthInfoNoExist';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();            
            IService_Output_Master outputData = service.dispatch(invocationDetails,brokerRequest);
        Test.stopTest();
        System.assert(outputData!=null);
        IHTTPResponse httpResponse = (IHTTPResponse)outputData;
        System.assert(httpResponse.getErrorMessage().contains('AuthConnection not found'));
        System.assertEquals(500,httpResponse.getStatusCode());

    }

    @isTest
    static void testError_AuthInfoNotFound(){
        GenericHTTPBrokerV2 service = new GenericHTTPBrokerV2();
        String reqbody = 'mock request';
                
        IHTTPRequest httpRequest = new GenericHTTPRequest(null,reqbody,HTTPOperation.POST,null,null);
        IBrokerRequest brokerRequest = new BrokerRequest();
        brokerRequest.setBrokerRequest(httpRequest);        
        ServiceFrameworkBaseTestSetup baseSetup = initializeBaseSetup();
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IInvocation_Details invocationDetails = sinv.getInvocationDetails();
        Test.startTest();            
            IService_Output_Master outputData = service.dispatch(invocationDetails,brokerRequest);
        Test.stopTest();
        System.assert(outputData!=null);
        IHTTPResponse httpResponse = (IHTTPResponse)outputData;
        System.assert(httpResponse.getErrorMessage().contains('Config Error : Auth connection not supplied'));
        System.assertEquals(500,httpResponse.getStatusCode());

    }    
    
    @isTest
    static void testOperation(){
        Test.startTest();
            String postName = HTTPOperation.POST.name();
            String getName = HTTPOperation.GET.name();
        Test.stopTest();
        System.assertEquals('POST', postName);
        System.assertEquals('GET', getName);
    }

    public class HTTPRequestMock implements HttpCalloutMock {
        
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public HTTPRequestMock(Integer code, String status, String body,
                Map<String, String> responseHeaders) {
                    this.code = code;
                    this.status = status;
                    this.bodyAsString = body;
                    this.bodyAsBlob = null;
                    this.responseHeaders = responseHeaders;
        }
        public HTTPRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }             

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }
            System.debug('cb** - code = ' + code + ', status = ' + status + ', bodyAsString = ' + bodyAsString);
 
            if (responseHeaders != null) {
                 for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
                 }
            }
            return resp;          
        }
    }       
}