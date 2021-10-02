@isTest
public class BaseServiceImplementation_Test {
    @isTest
    static void testValidate(){
        BaseServiceImplementation impl = new BaseServiceImplementation();
        TestRequest request = new TestRequest('message');
        String errors = impl.validate(request);
        System.assert(String.isBlank(errors));
        request = new TestRequest(null);
        errors = impl.validate(request);
        System.assert(errors.containsIgnoreCase('mandatory'));
    }


    public class TestRequest implements IRequestValidator {
        private String message;

        public TestRequest(String message){
            this.message = message;
        }

        public Map<String,String> validate(){
            Map<String,String> errors = new Map<String,String>();
            if(String.isBlank(this.message)){
                errors.put('errors','mandatory');
            }
            return errors;
        }
    }
}
