@RestResource(urlMapping='/servicerestjsonresponse/')
global inherited sharing class ServiceRestJsonResponse {

    // Provide an invocation name and the intended inputData format serialized and HTML escaped
    // Unpacks the inputData and invokes the service using the retrieved invocation details
    // Return outputData as a Json object

    @HttpPost
    global static IService_Output_Master invokeRestService (String serviceInvocationName, String escapedInputData)
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
        return outputData;
    }


}
