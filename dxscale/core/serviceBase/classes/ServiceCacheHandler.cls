public with sharing class ServiceCacheHandler {

    private Cache.Partition orgPart;
    private static Integer TTL_SECS = 300; // time to live for cache in seconds 
    private boolean cachePartitionExists;

    public ServiceCacheHandler(String fqPartitionName) {
        try {
            orgPart = new Cache.OrgPartition(fqPartitionName); 
            cachePartitionExists = true;
        }
        catch (cache.Org.OrgCacheException e) {
            cachePartitionExists = false;
        }
    }

    public static String hashStoredInvocation(IInvocation_Stored invocationStored) {
        String serial = ServiceSerialize.serializeObject (invocationStored);
        return ServiceUtils.getHashBase16(serial);
    }

    /* called in service code to store and retrieve hash values */

    public void saveInvocationStatic(String key, IInvocation_Static value) {
        orgPart.put(key, value, TTL_SECS);
    }

    public IInvocation_Static retrieveInvocationStatic(String key) {
        return (IInvocation_Static) orgPart.get(key);
    }

    public boolean getCachePartitionExists() {
        return this.cachePartitionExists;
    }
    
}
