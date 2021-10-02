
/**
 * Load QueryGridDisplayConfiguration__mdt Custom Metadata
 * @author : cjbradshaw
 * @date : March 2020
 * 
 */
public with sharing class DynamicQueryConfigLoader {

    private static DynamicQueryConfigLoader clzInstance;

    private final String CLASS_NAME = 'DynamicQueryConfigLoader';

    public Map<String,QueryGridDisplayConfiguration__mdt> configs = new Map<String,QueryGridDisplayConfiguration__mdt>();

    public static DynamicQueryConfigLoader getInstance(){
        if(clzInstance == null){
            clzInstance = new DynamicQueryConfigLoader();
        }
        return clzInstance;
    }

    
    private DynamicQueryConfigLoader(){
        LogControl.push('DynamicQueryConfigLoader', CLASS_NAME);
        try{
            List<QueryGridDisplayConfiguration__mdt> mdConfigs = [select DeveloperName, JSONConfig__c from QueryGridDisplayConfiguration__mdt];
            for(QueryGridDisplayConfiguration__mdt cnf : mdConfigs){
                configs.put(cnf.DeveloperName,cnf);
            }
            LogControl.push('DynamicQueryConfigLoader', 'initialised');
        }catch(Exception e){
            LogControl.debugException(e);
        }finally{
            LogControl.pop();
        }
        
    }

    public QueryGridDisplayConfiguration__mdt getConfig(String configName){
        QueryGridDisplayConfiguration__mdt cfg;
        if(configs != null && configs.size() > 0 ){
            cfg =  configs.get(configName);
        }else{
            throw new DynamicQueryConfigLoaderException('No QueryGridDisplayConfiguration__mdt records found');
        }
        if(cfg == null){
            throw new DynamicQueryConfigLoaderException('No Config found for configName = ' + configName);
        }

        return cfg;
    }

    public class DynamicQueryConfigLoaderException extends Exception{}

}
