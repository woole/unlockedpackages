@isTest
public class PlatformCacheManager_Test {
   
    @isTest
    static void testOrgCache(){
        //The cache partition is metadata. in a sandbox the AuthCache will exist but the TestCache never has a partition assinged (side effect of unlocked packages)
        String paritionName = 'local.TestCache';
        try {
            Cache.Partition orgPart = new Cache.OrgPartition('local.AuthCache'); 
            paritionName = 'local.AuthCache';
        }
        catch (cache.Org.OrgCacheException e) {
            
        }     
        PlatformCacheManager.ICacheManager orgCacheManager = PlatformCacheManager.getOrgCacheInstance(paritionName);
        orgCacheManager.addToCache('myKey','Some String or Object',500);
        Object value = orgCacheManager.getFromCache('myKey');
        System.assertEquals('Some String or Object', (String)value);
        //REMOVE
        orgCacheManager.removeFromCache('myKey');
        //check removal
        value = orgCacheManager.getFromCache('myKey');
        System.assert(value == null,'item should not have been on the cache anymore');
    }

    @isTest
    static void testOrgCache_NotFound(){
        try{
            PlatformCacheManager.ICacheManager orgCacheManager = PlatformCacheManager.getOrgCacheInstance('local.Dummy');
            System.assert(false,'Should not reach here');
        }catch(PlatformCacheManager.CacheManagerException e){
            
        }catch(Exception ex){
            System.assert(false,'Should not reach here');
        }
        
        
    }    

}
