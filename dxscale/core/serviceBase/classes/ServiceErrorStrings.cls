public with sharing class ServiceErrorStrings {

    /* FAILURES */

    // Services

    public static String STATE_NO_SERVICE_DEFINED = 'FAILURE: FrameworkConfiguration: No Service Defined';
    public static String ERRORMSG_NO_SERVICE_DEFINED_PT1 = 'No Service found for serviceName: ' ;
    public static String ERRORMSG_NO_SERVICE_DEFINED_PT2 = '. This may be expected in the scratch org. You may need to use a stub override for the invocation ';

    public static String STATE_SERVICE_IS_DOWN = 'FAILURE: Service: Service is Down';
    public static String ERRORMSG_SERVICE_IS_DOWN = 'Service is currently not available for invocation: ';

    public static String STATE_STUB_SERVICE_REAL_CALL = 'FAILURE: FrameworkConfiguration: Stubbed Service with Real call';
    public static String ERRORMSG_STUB_SERVICE_REAL_CALL = 'FAILURE: FrameworkConfiguration: Stubbed Service will only accept Stubbed calls: ';

    public static String STATE_NO_IMPLEMENTING_CLASS = 'FAILURE: FrameworkConfiguration: No Implementing Class';
    public static String ERRORMSG_NO_IMPLEMENTING_CLASS = 'FAILURE: FrameworkConfiguration: Implementing Class is not correctly configured for invocation. Check that the service name, iteration and method values in the Service Invocation Metadata match values in the Service Method Metadata. If so then check that the Service Method points to a Service Implementation. Invocation Name: ';

    public static String STATE_NO_SERVICE_METHOD = 'FAILURE: FrameworkConfiguration: No Service Method';
    public static String ERRORMSG_NO_SERVICE_METHOD = 'FAILURE: FrameworkConfiguration: Service Method is not correctly configured for invocation. Check that the service name, iteration and method values in the Service Invocation Metadata match values in the Service Method Metadata. Invocation Name: ';

    public static String STATE_NO_IMPLEMENTING_FLOW = 'FAILURE: FrameworkConfiguration: No Implementing Flow';
    public static String ERRORMSG_NO_IMPLEMENTING_FLOW = 'FAILURE: FrameworkConfiguration: Implementing Flow is not correctly configured for invocation. Check that the service name, iteration and method values in the Service Invocation Metadata match values in the Service Method Metadata. If so then check that the Service Method points to a Service Implementation. Invocation Name: ';

    public static String STATE_PASS_THROUGH_WO_NEXT_INV = 'FAILURE: FrameworkConfiguration: PassThrough Service Methods must have a Next Invocation';
    public static String ERRORMSG_PASS_THROUGH_WO_NEXT_INV = 'FAILURE: FrameworkConfiguration: PassThrough Service Methods must have a Next Invocation - check configuration ';

    public static String STATE_IMPLEMENTING_CLASS_INVALID = 'FAILURE: FrameworkConfiguration: Implementing Class invalid';
    public static String ERRORMSG_IMPLEMENTING_CLASS_INVALID = 'FAILURE: FrameworkConfiguration: Implementing Class configured is does not exists or is not an implementation of IService_Implementation ';


    public static String STATE_SERVICE_GENERIC_EXCEPTION = 'FAILURE: Service: Exception';

    // Service Invocations

    public static String STATE_INVOCATION_GENERIC_EXCEPTION = 'FAILURE: ServiceInvocation: Exception';

    public static String STATE_EVENT_CREATION_FAILURE = 'FAILURE: ServiceInvocation: Platform Event Creation';
    public static String ERRORMSG_EVENT_CREATION_FAILURE = 'Error creating asyncPlatformEvent: ';

    public static String STATE_QUEUEABLE_CREATION_FAILURE = 'FAILURE: ServiceInvocation: Queueable Creation';
    public static String ERRORMSG_QUEUEABLE_CREATION_FAILURE = 'Error creating Queueable Job: ';

    public static String STATE_EVENT_PUBLISH_FAILURE = 'FAILURE: ServiceInvocation: Publish Event';

    public static String STATE_INVALID_EXTERNAL_USER = 'FAILURE: Invocation not configured for external access';
    public static String ERRORMSG_INVALID_EXTERNAL_USER = 'Attempt to call a service externally that is not configured for external access';

    public static String STATE_UNPERMISSIONED_USER = 'FAILURE: ServiceInvocation: User not permissioned';
    public static String ERRORMSG_UNPERMISSIONED_USER = 'Running user is not allowed to invoke the service requested';

    public static String STATE_NO_INVOCATION_TYPE = 'FAILURE: ServiceInvocation: No invocation type called';
    public static String STATE_NO_INVOCATION_FOUND = 'No Service Invocation found for serviceInvocationame: ';

    public static String ERRORMSG_NO_SERVICE_IMPLEMENTATION_FOUND = 'No Service Implementation found for serviceImplementationName: '; 

    /* EXTERNAL */

    public static String STATE_CALLOUT_FAILED = 'FAILURE: Outbound Call Failed';
    public static String ERRORMSG_CALLOUT_FAILED = 'Outbound Call Failed, response received was:';

    /* WARNINGS */

    public static String STATE_NO_AUDIT_INVOCATION_CONFIGURED = 'WARNING: FrameworkConfiguration: No Audit Invocation configured.';
    public static String ERRORMSG_NO_AUDIT_INVOCATION_CONFIGURED = 'No Audit Invocation configured.';

    public static String STATE_BAD_CACHE_PARTITION_NAME = 'WARNING: ServiceInvocation: A bad partition name is configured: ';
    public static String ERRORMSG_BAD_CACHE_PARTITION_NAME = 'WARNING: ServiceInvocation: A bad partition name is configured: ';

}
