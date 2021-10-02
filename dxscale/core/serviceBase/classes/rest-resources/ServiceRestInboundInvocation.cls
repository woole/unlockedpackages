@RestResource(urlMapping='/servicerestinboundinvocation/')
global inherited sharing class ServiceRestInboundInvocation {

    // Provide invocation details and the intended inputData format serialized and HTML escaped
    // Unpacks both input parameters and invokes the service using the retrieved invocation details
    // Return outputData serialized and escaped



    @HttpPost
    global static IService_Output_Master invokeRestService (String remoteInvocationId, String escapedInvocationDetails, String escapedInputData)
    {


        IService_Output_Master outputData;

        ServiceInvocation sinv = new ServiceInvocation(remoteInvocationId);
        if (sinv.allowExternalCall()) {

            String originatingSerialInvocationDetails = ServiceSerialize.unescape(escapedInvocationDetails);

            IInvocation_Details originatingInvocationDetails = (IInvocation_Details) Service.deserializeInvocationDetails (originatingSerialInvocationDetails);
    

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
