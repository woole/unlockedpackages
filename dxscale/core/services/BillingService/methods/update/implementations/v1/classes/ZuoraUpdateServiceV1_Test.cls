@isTest
public class ZuoraUpdateServiceV1_Test {

    @isTest
    static void testCallUtil(){
        ZuoraUpdateServiceV1 service = new MockZuoraUpdateServiceV1('ZuoraUpdateServiceV1_Test.MockZuoraUtil');
        Map<String,String> udateParams = new Map<String, String>{
            'Id' => 'zuoraBillToId',
            'AccountId' => 'zuoraAccountId',
            'WorkEmail' => 'email.test@example.com'
          };           
        billing_IUpdateRequest request = new billing_UpdateRequest('TestClassName','Dummy',udateParams);

        IService_Output_Master output  = service.dispatch(null,request);
        System.assertEquals('SUCCESS', output.getState(), 'Service request should succeed');
    } 
    
    @isTest
    static void testCallUtil_Error(){
        ZuoraUpdateServiceV1 service = new MockZuoraUpdateServiceV1('ZuoraUpdateServiceV1_Test.MockZuoraUtilError');
        Map<String,String> udateParams = new Map<String, String>{
            'Id' => 'zuoraBillToId',
            'AccountId' => 'zuoraAccountId',
            'WorkEmail' => 'email.test@example.com'
          };           
        billing_IUpdateRequest request = new billing_UpdateRequest('TestClassName','Dummy',udateParams);

        IService_Output_Master output  = service.dispatch(null,request);
        System.assertEquals('FAIL', output.getState(), 'Service request should fail');
    }     


    public class MockZuoraUtil implements Callable{
        public Object call(String sObjectName, Map<String, Object> parameters) {
            return true;
        }
    }

    public class MockZuoraUtilError implements Callable{
        public Object call(String sObjectName, Map<String, Object> parameters) {
            return false;
        }
    }    

    public class MockZuoraUpdateServiceV1 extends ZuoraUpdateServiceV1{
        String clzzName;
        public MockZuoraUpdateServiceV1(String clzzName ){
            this.clzzName = clzzName;
        }

        protected override String getCallableClassName(){
            return this.clzzName;
        }
    }
}
