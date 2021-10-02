@IsTest
public with sharing class ServiceCacheHandler_Test {

    /* Important Note: 

        This test method can run in two different contexts.
        This is because we cannot create test cache partitions and of course do not wish to have a dependency on a particular named partition being present in an org

        When the demo app is installed the referenced cache partition is available and so the real mechanism of using cache is tested.    

        However when only the service framework is installed the partition is not present so we instead run the cacheless version of the service.  
        This version will result in reduced test coverage as the methods that interact with the partition's cache will not be run.  

        If a customer uses caching then it is recommended that they create a bespoke test, using this as a baseline, that references their concrete partition.    

    */

    private static void twoRunsOfServiceByPartitionName (String partitionName) {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.useCache = true;
        baseSetup.useCachePartition = partitionName;
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        // Note that Org Custom Metadata is available to test classes
        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 
        IStringOutput outputData = (IStringOutput) sinv.invokeService(sinput);

        ServiceInvocation sinv2 = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IStringInput sinput2 = (IStringInput) sinv2.getInputInterfaceInstance();
        sinput2.setInputMessage('SUCCESS'); 
        IStringOutput outputData2 = (IStringOutput) sinv2.invokeService(sinput2);

        System.assertEquals('SUCCESS', outputData.getState(),'Cache Miss of a synchronous service run should return state = SUCCESS');
        System.assertEquals('SUCCESS Message', outputData.getOutputMessage(),'Cache Miss run should return populated output fields');
        System.assertEquals('Real', outputData.getDataReality(),'Services need to inform if data if data is from a real source or is stubbed');

        System.assertEquals('SUCCESS', outputData2.getState(),'Cache Hit Invocation of a synchronous service run should return state = SUCCESS');
        System.assertEquals('SUCCESS Message', outputData2.getOutputMessage(),'Cache Hit run should return populated output fields');
        System.assertEquals('Real', outputData2.getDataReality(),'Services need to inform if data if data is from a real source or is stubbed');

    }

    /* Here the partition exists when the demo framework is in place */

    @IsTest
    public static void twoRunsOfService_PartitionMayExist () {
        twoRunsOfServiceByPartitionName ('local.FrameworkCache');
    }

    /* Here the partition does not exist - but the invocations should still run */

    @IsTest
    public static void twoRunsOfService_PartitionCannotExist () {
        twoRunsOfServiceByPartitionName ('local.dudpart');
    }
    
    @IsTest
    public static void hashStoredInvocation () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.useCache = true;
        baseSetup.useCachePartition = 'local.FrameworkCache';
        baseSetup.insertServiceInvocationOverride();
        baseSetup.serviceSetup();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);

        String hashValue = ServiceCacheHandler.hashStoredInvocation((IInvocation_Stored) sinv.getInvocationDetails());
        System.assert(String.isNotBlank(hashValue));
    }

    @IsTest
    public static void getCachePartitionExists_BadPartition () {
        ServiceCacheHandler sch = new ServiceCacheHandler('local.dudpart');
        System.assert(!sch.getCachePartitionExists(),'getCachePartitionExists should return false for a non-existent partition');
    }


    @IsTest
    public static void validateInvocation_BadCachePartition() {

        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.useCache = true;
        baseSetup.useCachePartition = 'local.dudpart';
        baseSetup.invocationType = 'Sync';
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();
        
        IInvocation_Details invocationDetails = ServiceValidator.getInvocationStatic(baseSetup.serviceInvocationName);

        System.assert(invocationDetails.getIsValidateSetup(),'Bad Cache Partition name should not stop processing but should continue without using cache');
        System.assert(invocationDetails.getHasValidateWarning(),'Bad Cache Partition name should raise a warning');
        System.assert(invocationDetails.getValidationState().startsWith(ServiceErrorStrings.STATE_BAD_CACHE_PARTITION_NAME),'Bad Cache Partition name should raise validation state warning');
        System.assert(invocationDetails.getValidationErrorMessage().startsWith(ServiceErrorStrings.ERRORMSG_BAD_CACHE_PARTITION_NAME),'Bad Cache Partition name should raise validation state warning');

    }

    @IsTest
    public static void initializeInvocation_BadCachePartition () {
        ServiceFrameworkBaseTestSetup baseSetup = new ServiceFrameworkBaseTestSetup();
        baseSetup.useCache = true;
        baseSetup.useCachePartition = 'local.dudpart';
        baseSetup.serviceSetup();
        baseSetup.insertServiceInvocationOverride();

        ServiceInvocation sinv = ServiceInvocation.initialize(baseSetup.serviceInvocationName);
        IStringInput sinput = (IStringInput) sinv.getInputInterfaceInstance();
        sinput.setInputMessage('SUCCESS'); 
        IStringOutput outputData = (IStringOutput) sinv.invokeService(sinput);
        System.assertEquals('SUCCESS', outputData.getState(),'Cache Miss of a synchronous service run should return state = SUCCESS');
    }


}
