public inherited sharing class ProductHoldingSummaryV1_Stub implements IService_Implementation {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IDynamicQueryConfigData isi = (IDynamicQueryConfigData) inputData;
        return stubBody(isi);
    }

    // for this stub we push back some random values based on what the input config is
    // input is ignored
    
    IQueryListMap stubBody (IDynamicQueryConfigData isi) {
        IQueryListMap iso = new QueryListMap();

        if (isi.getObjectType().equalsIgnoreCase('VW_Connect_ProductHoldings__x')) {
            // we default to 20 PH rows returned
            for (Integer loopCount = 0; loopCount < 20; loopCount++) {
                Map<String,Object> mapper = putToMap(isi.getFields(), loopCount, isi.getObjectType());
                iso.add(mapper);
            }  
        } 
        else if (isi.getObjectType().equalsIgnoreCase('VW_Connect_ProductHoldingModules__x')) {
            // 50 product holding modules are created and shared between the product holdings, leaving a couple without modules
            for (Integer loopCount = 0; loopCount < 50; loopCount++) {
                Map<String,Object> mapper = putToMap(isi.getFields(), loopCount, isi.getObjectType());
                iso.add(mapper);   
            }  
        }
          
        iso.setState('SUCCESS');
        System.debug('Exiting stubBody with state:' + iso.getState());
        return iso;
    }

    private static Map<String,Object> putToMap (List<IDynamicQueryConfigItem> fields, Integer loopCount, String objectType) {
        Map<String,Object> mapper = new Map<String,Object>();

        for (IDynamicQueryConfigItem configItem : fields) {
            if (configItem.getApi() == 'ProductHolding_Key__c') {
                if (objectType.equalsIgnoreCase('VW_Connect_ProductHoldings__x')) {
                    mapper.put('ProductHolding_Key__c', 'PH KEY ' + loopcount);
                }
                else if (objectType.equalsIgnoreCase('VW_Connect_ProductHoldingModules__x')) {
                    mapper.put('ProductHolding_Key__c', 'PH KEY ' + Integer.valueof((Math.random() * 8))); 
                }
            }
            else if(configItem.getApi() == 'SupportRAGStatus__c') {
                if (objectType.equalsIgnoreCase('VW_Connect_ProductHoldings__x') || objectType.equalsIgnoreCase('VW_Connect_ProductHoldingsHistory__x')) {
                    mapper.put('SupportRAGStatus__c', getRagStatus());
                }                
            }            
            else if (configItem.getType() == 'text' || configItem.getType() == 'string') 
           	{
           	   mapper.put(configItem.getApi(), configItem.getLabel() + ' ' + loopCount);
           	}
            else if (configItem.getType() == 'currency') {
                mapper.put(configItem.getApi(), 9999.99999 - loopCount); 
            }
            else if (configItem.getType() == 'integer') {
                mapper.put(configItem.getApi(), Integer.valueof(Math.random() * 9999));
            }
            else if (configItem.getType() == 'phone') {
                mapper.put(configItem.getApi(), '0' + Integer.valueof(Math.random() * 99999999));
            }
            else if (configItem.getType() == 'decimal') {
                mapper.put(configItem.getApi(), 41.02837 * loopCount);
            }
            else if (configItem.getType() == 'date') {
                // we need dates in the past AND future to test the "Active" filter
                mapper.put(configItem.getApi(), Date.Today().addDays(Integer.valueof(Math.random() * 300 - 100)));
            }
            else if (configItem.getType() == 'boolean') {
                mapper.put(configItem.getApi(), Math.mod(Integer.valueof((Math.random() * 10)),2) == 0 ? true : false);
            }

            
        }
        return mapper;
    }
    private static String getRagStatus(){
        Set<String> setArray = new Set<String> {'Red', 'Amber', 'Green'};
        // Convert the Set to a list
        List<String> lstArray = new List<String>(); 
        lstArray.addAll(setArray); 
        //Generate a random list index
        Double randomNumber = Math.random(); 
        Integer arrayLength = lstArray.size(); 
        Integer randomIndex = (randomNumber *(arrayLength)).intValue(); 
        //Output the element at the list index generated above
		String value = lstArray[randomIndex];
        System.debug('Random element: '+value);        
        return value;

    }    
}