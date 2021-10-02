

@IsTest
public class ServiceImplementation_Test {

    @IsTest
    public static void serviceImplementationBadNameThrowsError () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        try {
            ServiceImplementation.getMetadataWrap('Dud');
        }
        catch (Service.ServiceFrameworkException sfe) {
            System.assert(sfe.getMessage().startsWith(ServiceErrorStrings.ERRORMSG_NO_SERVICE_IMPLEMENTATION_FOUND),'Retrieving metadata for a Service Invocation that is not setup should result in a meaningful error');
        }
    }

    @IsTest
    public static void serviceBadNameThrowsError () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.serviceSetup();
        try {
            Service.initialize('Dud');
        }
        catch (Service.ServiceFrameworkException sfe) {
            System.assert(sfe.getMessage().startsWith(ServiceErrorStrings.ERRORMSG_NO_SERVICE_DEFINED_PT1),'Retrieving metadata for a Service that is not configured should result in a meaningful error');
            System.assert(sfe.getMessage().endsWith(baseSetup.serviceImplementationName), 'Retrieving metadata for a Service that is not configured should result in a meaningful error');
        }
    }

}



