/**
 * Manages the adding,removing and getting from the cache
 * Only the TestPartition exists for testing
 */
public without sharing class PlatformCacheManager {
    
    public interface ICacheManager{
        void addToCache(String key,Object value,Integer ttlSecs);
        Object getFromCache(String key);
        void removeFromCache(String key);
    }

    public static ICacheManager getOrgCacheInstance(String partitionName){
        return new OrgPartitionCacheImpl(partitionName);
    }

    public virtual class OrgPartitionCacheImpl implements ICacheManager{
        
        @TestVisible
        private Cache.OrgPartition orgPartition;
        @TestVisible
        private Boolean cachePartitionExists = false;

        public OrgPartitionCacheImpl(String partitionName){
            try {
                orgPartition = new Cache.OrgPartition(partitionName); 
                System.debug(LoggingLevel.DEBUG,partitionName+ ' exists!');
                cachePartitionExists = true;
            }
            catch (cache.Org.OrgCacheException e) {
                String errorMsg = partitionName+ ' does not exist!';
                System.debug(LoggingLevel.DEBUG,errorMsg);
                cachePartitionExists = false;
                throw new CacheManagerException(errorMsg);
            }            
        }

        public virtual void addToCache(String key,Object value,Integer ttlSecs){
            if(cachePartitionExists){
                orgPartition.put(key, value,ttlSecs);
            }
            
        }

        public virtual Object getFromCache(String key){
            Object value;
            if(cachePartitionExists){
                value = orgPartition.get(key);
            }
            return value;
        }

        public virtual void removeFromCache(String key){
            if(cachePartitionExists){
                Object cachedValue = getFromCache(key);
                if(cachedValue != null){
                    orgPartition.remove(key);
                }
            }
                
        }
        
                
    }

    public class CacheManagerException extends Exception{}

}
