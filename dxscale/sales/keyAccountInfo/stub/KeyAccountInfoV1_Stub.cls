public inherited sharing class KeyAccountInfoV1_Stub implements IService_Implementation {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IDynamicQueryConfigData isi = (IDynamicQueryConfigData) inputData;
        return stubBody(isi);
    }

    IQueryListMap stubBody (IDynamicQueryConfigData isi) {
        IQueryListMap iso = new QueryListMap();

        Map<String,Object> mapper = putToMap(isi.getFields());
        if(isi.getObjectType().equalsIgnoreCase('VW_Connect_AccountPartner__x') || isi.getObjectType().equalsIgnoreCase('VW_Connect_AccountPrompt__x') || isi.getObjectType().equalsIgnoreCase('VW_Connect_CustomerInteraction__x')){
            mapper.put('SalesforceAccountId', 'abc');
        }
        iso.add(mapper);   
        
        iso.setState('SUCCESS');
        System.debug('exiting stubBody with state:' + iso.getState());
        return iso;
    }



    private static  Map<String,Object> putToMap (List<IDynamicQueryConfigItem> fields) {
        Map<String,Object> mapper = new Map<String,Object>();
        for (IDynamicQueryConfigItem configItem : fields) {
            
                if(configItem.getApi().equals('CreditStatus__c')){
                    mapper.put(configItem.getApi(),'Good');
                }
                if(configItem.getApi().equals('AccountPassword__c')){
                    mapper.put(configItem.getApi(),'r4nD0mm121');
                }
                if(configItem.getApi().equals('HomeOrExport__c')){
                    mapper.put(configItem.getApi(),true);
                }
            
        }
        return mapper;
    }


}
