@isTest
public class QuoteLoginRequestor_Test {
    
    @isTest
    static void testCall_OK(){
        TestGenericServiceInvoker testInvoker = new TestGenericServiceInvoker();
        testInvoker.responseJSON = '{    "quoteToken": "quote-abcdefghijk1234567",    "refreshToken": "refreh-abcdefghijk1234567"}';
        QuoteLoginRequestor.invoker = testInvoker;
        QuoteLoginRequestV1 request = new QuoteLoginRequestV1();
        Test.startTest();
            QuoteLogin loginResponse = QuoteLoginRequestor.login(request);
        Test.stopTest();
        System.assert(loginResponse != null);
        System.assertEquals(loginResponse.quoteToken,'quote-abcdefghijk1234567');
        System.assertEquals(loginResponse.refreshToken,'refreh-abcdefghijk1234567');

    }

    @isTest
    static void testCall_Failure(){
        TestGenericServiceInvoker testInvoker = new TestGenericServiceInvoker();
        testInvoker.isErroring = true;
        QuoteLoginRequestor.invoker = testInvoker;
        QuoteLoginRequestV1 request = new QuoteLoginRequestV1();
        Test.startTest();
            try{
                QuoteLogin loginResponse = QuoteLoginRequestor.login(request);
                System.assert(false,'should never get here');
            }catch(Exception e){
                System.assert(e instanceof QuoteLoginRequestor.QuoteLoginException);
                System.assert(e.getMessage().contains('Failed to Login to the QuoteAPI'));
            } 
        Test.stopTest();


    }    


    public class TestGenericServiceInvoker extends GenericServiceInvoker{
        public Boolean isErroring = false;
        public String responseJSON;
        

        public override IService_Output_Master call(String jsonPayload){
            IService_Output_Master output;
            if(!isErroring){
                QuoteLogin quoteLogin = (QuoteLogin)JSON.deserialize(responseJSON, QuoteLogin.class);
                quoteLogin.setState('SUCCESS');
                output = quoteLogin;
            }else{
                output = new StringOutputV1();
                output.setState('FAIL');
                output.setErrorMessage('failed to login');

            }
            return output;
        }
    }
    
}
