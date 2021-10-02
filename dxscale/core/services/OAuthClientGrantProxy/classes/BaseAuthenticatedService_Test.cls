@isTest
public class BaseAuthenticatedService_Test {
    
    private static final String correlationId = 'test-1234-5678-00-121211';

    @TestSetup
    static void makeData(){

    
        
        //Overrides the HTTP Callout to ClouID
        Service_Invocation_Override__c cio = new Service_Invocation_Override__c();
        cio.Name = 'CloudID_OrderManagement_ClientGrant';
        cio.Metadata_Invoker_Id__c = 'CloudID_OrderManagement_ClientGrant';        
        cio.Stub_Class__c = 'ClientGrantToken_Stub';
        cio.Invocation_Type__c = 'Stub';
        cio.Override_Default__c = true;
        cio.Input_Creation_Class__c = 'TokenAuthRequest';
        cio.Service_Name__c = 'OAuthClientGrantProxy';
        insert cio;

        Service_Invocation_Override__c tio = new Service_Invocation_Override__c();
        tio.Name = 'HTTPCalloutBrokerInvocationV1_send';
        tio.Metadata_Invoker_Id__c = 'HTTPCalloutBrokerInvocationV1_send';        
        tio.Stub_Class__c = 'OAuthTokenV1_Stub';
        tio.Invocation_Type__c = 'Stub';
        tio.Override_Default__c = true;
        tio.Input_Creation_Class__c = 'GenericHTTPResponse';
        tio.Service_Name__c = 'HTTPCalloutBroker';
        insert tio;                               
    }

    @isTest
    static void testAuthenticate(){
      try{
        MockBaseAuthenticatedService service = new MockBaseAuthenticatedService(correlationId,'HTTPCalloutBrokerInvocationV1_send','CloudID_OrderManagement_ClientGrant');
        service.authenticate();
        System.assert(service.getAuthToken() != null,'the AuthToken should not have been null');
        System.assertEquals(correlationId,service.getCorrelationId(),'expected the correalationID to be set and the same');
      }catch(Exception e){
        System.assert(false,'should not have thrown and exception');
      }

    }

    //Test Auth - reports error fetching OAuth Token
    @isTest
    static void testAuthenticate_Error(){
      Service_Invocation_Override__c quoteOverride = [select Id,Stub_Class__c from Service_Invocation_Override__c where Name = 'CloudID_OrderManagement_ClientGrant'];
      quoteOverride.Stub_Class__c = 'BaseAuthenticatedService_Test.OAuthTokenV1_Stub_ValidError';
      update quoteOverride;      
      try{
        MockBaseAuthenticatedService service = new MockBaseAuthenticatedService(correlationId,'HTTPCalloutBrokerInvocationV1_send','CloudID_OrderManagement_ClientGrant');
        service.authenticate();
        System.assert(false,'should not reach here');
      }catch(BaseAuthenticatedService.AuthenticatedServiceException e){
        
      }catch(Exception e){
        //unexpected
        System.assert(false,'unexpected exception : ' + e.getStackTraceString());
      }
      
    }       

    @isTest
    static void testCallBroker_success(){
      IHTTPRequest httpRequest = new GenericHTTPRequest(null,null,null,null,null,'12345'); 
      MockBaseAuthenticatedService service = new MockBaseAuthenticatedService('123454','HTTPCalloutBrokerInvocationV1_send','CloudID_OrderManagement_ClientGrant');
      IHTTPResponse response = service.callBroker(httpRequest);
      System.assert(response != null,'the reponse should not have been null');
      System.assertEquals(200, response.getStatusCode(),'Expected the status code to be 200 but was : '+response.getStatusCode());
    }

    //Converting the API request into a HTTP Request
    @isTest
    static void testBuildRequest(){  
      //SET UP
      
      MockAPI apiRequest = new MockAPI();
      MockBaseAuthenticatedService service = new MockBaseAuthenticatedService(correlationId,'HTTPCalloutBrokerInvocationV1_send','CloudID_OrderManagement_ClientGrant');
      //needed for authtoken
      service.authenticate();
      //TEST
      IHTTPRequest httpRequest = service.buildRequest(apiRequest);
      //ASSERT
      System.assert(httpRequest != null,'The HTTPRequest should not have been null');
      System.assertEquals(2, httpRequest.getRequestHeaders().size(),'expected the HTTP Headers to have 2 items but had ' + httpRequest.getRequestHeaders().size());
      System.assertEquals(1, httpRequest.getAuthHeaders().size(),'ectected the HTTP Auth headers to have 1 value');
      System.assertEquals(correlationId, httpRequest.getCorrelationId(),'the correalation id should have been set and the same');
    }    

    //ProcessRequest pulls all these methods together
    @isTest
    static void testProcessRequest_OK(){
      MockAPI apiRequest = new MockAPI();
      MockBaseAuthenticatedService service = new MockBaseAuthenticatedService(correlationId,'HTTPCalloutBrokerInvocationV1_send','CloudID_OrderManagement_ClientGrant');
      IHTTPResponse output = service.processRequest(apiRequest,correlationId,'','CloudID_OrderManagement_ClientGrant','HTTPCalloutBrokerInvocationV1_send');
      System.assertEquals(false, output.hasError(),'Expected the processRequest call not to have errors');
    }    

    public class MockAPI implements IExternalRequest{
    


        public String getFunctionName(){
            return 'Cancel Subscription';
        }        

        public String getRequestJSON(){
            return JSON.serialize(this);
        }
        public String getAuthName(){
            return 'MyMockAuth_Name';
        }
        public String getPath(){
            return '/mock-path';
        }

        public HTTPOperation getOperation(){
            return HTTPOperation.PUT;
        }          

    }



    public class MockBaseAuthenticatedService extends BaseAuthenticatedService{
        public MockBaseAuthenticatedService(String correlationId,String serviceInvokerId,String authInvokerId){
            super.setCorrelationId(correlationId);
            super.setServiceInvokerName(serviceInvokerId);
            super.setAuthInvokerName(authInvokerId);
        }
    }

    public inherited sharing class OAuthTokenV1_Stub_ValidError implements IService_Implementation {

        public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
            IHTTPRequest isi = (IHTTPRequest) inputData;
            return stubBody(isi);
        }
    
        IHTTPResponse stubBody (IHTTPRequest isi) {

            String resp = '404:Error';
            GenericHTTPResponse response = new GenericHTTPResponse(resp,404);
            response.setCorrelationId(isi.getCorrelationId());
            response.setState('FAIL');
            
            return response;
        }
    }  


}
