public with sharing class ServiceAuditPublisher {

    public static Integer MAX_AUDIT_SIZE = 128000;
    private static boolean hasAuditInvocationRecord;

    public ServiceAuditPublisher() {

    }

    private static ServiceInvocation getAuditInvocation () {
        ServiceInvocation sinv = ServiceInvocation.initialize(ServiceConfigStrings.AUDIT_SERVICE_INVOCATION);
        return sinv;
    }

    public static IService_Output_Master publishAudit (ServiceInvocation sinv, IInvocation_Details invocationDetails, IService_Input_Master inputData, IService_Output_Master outputData, IService_Output_Master auditOutputOverride) {
        if (sinv != null) {
            IService_Audit auditInput = createAuditMessage (invocationDetails, inputData, outputData, auditOutputOverride);
            IService_Output_Master auditOutput = sinv.invokeService(auditInput);  
            return auditOutput;
        }
        else {
            IService_Output_Master errorOutput = new ServiceOutputMaster();
            errorOutput.setState(ServiceErrorStrings.STATE_NO_AUDIT_INVOCATION_CONFIGURED);
            errorOutput.setErrorMessage(ServiceErrorStrings.ERRORMSG_NO_AUDIT_INVOCATION_CONFIGURED);
            return errorOutput;
        }
    }


    @TestVisible private static IService_Audit createAuditMessage (IInvocation_Details invocationDetails, IService_Input_Master inputData, IService_Output_Master outputData, IService_Output_Master auditOutputOverride) {

        IService_Audit auditInput = new ServiceAudit();

        // The total size of the IService_Audit when serialized and enqueued should be less than 131,072 characters

        String strInputData = ServiceSerialize.serializeObject(inputData);
        // if there is an audit override then we replace the output data with that value
        String strOutputData = (auditOutputOverride != null) ? ServiceSerialize.serializeObject(auditOutputOverride) : ServiceSerialize.serializeObject(outputData);
        Integer inputSize = strInputData.length();
        Integer outputSize = strOutputData.length();

        if (inputSize + outputSize > MAX_AUDIT_SIZE) {
            Decimal halfMax = MAX_AUDIT_SIZE / 2;
            Integer cutToSize = Math.round(halfMax);
            if (inputSize > MAX_AUDIT_SIZE / 2){
                strInputData = ServiceConfigStrings.AUDIT_MESSAGE_TOO_LONG + strInputData.substring(0,cutToSize);
            }

            if (outputSize > MAX_AUDIT_SIZE / 2){
                strInputData = ServiceConfigStrings.AUDIT_MESSAGE_TOO_LONG + strInputData.substring(0,cutToSize);
            }
        }
                
        auditInput.setInputData(strInputData);
        auditInput.setOutputData(strOutputData);
        // note that any subscriber can extract any details from the invocation detail
        // and by and larget that is a better place as we wish to reduce processing in the transaction
        auditInput.setInvocationDetails( ServiceSerialize.serializeObject(invocationDetails));
        auditInput.setInvocationType(invocationDetails.getInvocationType());

        // metrics
        auditInput.setServiceStartTime(outputData.getServiceStartTime());
        auditInput.setResponseTime(outputData.getResponseTime());
        auditInput.setServiceDuration(outputData.getServiceDuration());
        auditInput.setInvocationTime(outputData.getInvocationTime());
        auditInput.setInvocationDuration(outputData.getInvocationDuration());
        auditInput.setCorrelationId(outputData.getCorrelationId());

        // status
        auditInput.setDataStatus(outputData.getDataStatus());
        auditInput.setState(outputData.getState());
        auditInput.setErrorMessage(outputData.getErrorMessage());
        return auditInput;
    }


    // return what auditing should be done at which point.
    // Audits are never audited
    // Errors are reported for any invocation, even if invocation is set to not audit
    // Async calls are audited at the Service, others at the invoker

    @TestVisible private static boolean getAuditPoint(IInvocation_Details invocationDetails, String state, String callPoint) {
        if (invocationDetails.getInvocationType() == 'Audit') {
            return false;
        }

        if (state != 'SUCCESS') {
            return true;
        }

        boolean doAudit = false;

        if (invocationDetails.getLogRequests() == false) {
            return false;
        }
        else {
            if (invocationDetails.getInvocationType() == 'Async' || invocationDetails.getInvocationType() == 'Queueable') {
                if (invocationDetails.getAsyncOnlyLogService()) {
                    doAudit = (callPoint == 'Service'); // async only logs the Service, not the Invocation
                }
                else {
                    doAudit = (callPoint == 'Service' || callPoint == 'Invoker'); // async logs both the invocation and the service
                }
            }
            else {
                doAudit = (callPoint == 'Invoker'); // all syncs are audited from the invoker
            }
        }
        return doAudit;
    }

    /* Return the Audit Service Invocation to use if appropriate or null if not */

    public static ServiceInvocation getAuditServiceInvocation (IInvocation_Details invocationDetails, String state, String callPoint) {

        boolean doAudit = getAuditPoint(invocationDetails, state, callPoint);

        // Platform Cache would be a nicer way to do this
        if (hasAuditInvocationRecord == null)
        {
            // a quick check to see if there is an Audit Service invocation, a fuller check per user is performed later if this returns true
            IInvocation_Details auditInvocationDetails = ServiceInvocation.getMetadataRecord (ServiceConfigStrings.AUDIT_SERVICE_INVOCATION);
            hasAuditInvocationRecord = (auditInvocationDetails != null);
        }
        if (hasAuditInvocationRecord) {
            ServiceInvocation auditInvocation = getAuditInvocation();
            return (doAudit) ? auditInvocation : null;
        }
        return null;
    }

}
