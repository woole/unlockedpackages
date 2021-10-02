@IsTest
public  class ServiceRestInvocation_Test {

    @IsTest
    public static void RestEncodedInvocation () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS');

        // serialize and escape the input to invoke the REST call
        String escapedInput = ServiceSerialize.serializeObjectEscape(sinput);
        String sReturn = ServiceRestEncodedResponse.invokeRestService ( baseSetup.serviceInvocationName, escapedInput);

        // unescape and deserialize the output to perform assertions
        String sUnescaped = ServiceSerialize.unescape(sReturn);
        IStringOutput outputData = (IStringOutput) ServiceSerialize.deserializeByClassType(sUnescaped, StringOutputV1.class);

        System.assertEquals('SUCCESS', outputData.getState(),'REST Encoded invocation should return SUCCESS on valid setup');
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'REST Encoded invocation should return correct response on valid setup');        
    }

    @IsTest
    public static void RestJsonInvocation () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS');

        // serialize and escape the input to invoke the REST call
        String escapedInput = ServiceSerialize.serializeObjectEscape(sinput);
        IStringOutput outputData = (IStringOutput) ServiceRestJsonResponse.invokeRestService ( baseSetup.serviceInvocationName, escapedInput);

        System.assertEquals('SUCCESS', outputData.getState(),'REST Json invocation should return SUCCESS on valid setup');
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'REST Json invocation should return correct response on valid setup');        
    }


}
