@RestResource(urlMapping='/servicerestencodedresponse/')
global inherited sharing class ServiceRestEncodedResponse {

    // Provide an invocation name and the intended inputData format serialized and HTML escaped
    // Unpacks the inputData and invokes the service using the retrieved invocation details
    // Return outputData serialized and escaped

    @HttpPost
    global static String invokeRestService (String serviceInvocationName, String escapedInputData)
    {
        IService_Output_Master outputData;

        ServiceInvocation sinv = ServiceInvocation.initialize(serviceInvocationName);
        if (sinv.allowExternalCall()) {
            String serialInputData = ServiceSerialize.unescape(escapedInputData);

            IService_Input_Master inputData = Service.deserializeInput(serialInputData, sinv.getInvocationDetails());
            outputData = sinv.invokeService(inputData);
        }
        else {
            outputData = sinv.allowExternalCallFail();
        }
        return ServiceSerialize.serializeObjectEscape(outputData);
    }


}
