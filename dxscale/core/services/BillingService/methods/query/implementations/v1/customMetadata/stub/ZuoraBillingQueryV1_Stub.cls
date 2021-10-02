
public inherited sharing class ZuoraBillingQueryV1_Stub implements IService_Implementation, IService_Implementation_Audit_Override {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IDynamicQueryConfigData isi = (IDynamicQueryConfigData) inputData;
        return stubBody(isi);
    }

    IQueryListMap stubBody (IDynamicQueryConfigData isi) {
        IQueryListMap iso = new QueryListMap();
        
        Map<String,Object> mapper = putToMap(isi.getFields(),isi.getQueryId());
        iso.add(mapper);   
        
        iso.setState('SUCCESS');
        iso.setCorrelationId(isi.getCorrelationId());
        System.debug('exiting stubBody with state:' + iso.getState());
        return iso;
    }



    private static  Map<String,Object> putToMap (List<IDynamicQueryConfigItem> fields, String recordId) {
        Map<String,Object> mapper = new Map<String,Object>();
        for (IDynamicQueryConfigItem configItem : fields) {
            
                if(configItem.getApi().equals('Zuora__Zuora_Id__c')){
                    mapper.put(configItem.getApi(),'stub-id-2c92c0f8749ff0ed0174a0cb29926c46');
                }
                if(configItem.getApi().equals('Zuora__AccountNumber__c')){
                    mapper.put(configItem.getApi(),'C00012345');
                }
                if(configItem.getApi().equals('Zuora__Account__c')){
                    mapper.put(configItem.getApi(),recordId);
                }
                if(configItem.getApi().equals('Zuora__BillToId__c')){
                    mapper.put(configItem.getApi(),'2c92a0ff64d60ab30164db947844445e');
                }
                if(configItem.getApi().equals('Zuora__BillToWorkEmail__c')){
                    mapper.put(configItem.getApi(),'stubby.email@example.com');
                }
                if(configItem.getApi().equals('Zuora__SoldToId__c')){
                    mapper.put(configItem.getApi(),'2c92a0ff64d60ab30164db947844445e');
                }
                if(configItem.getApi().equals('Zuora__SoldToWorkEmail__c')){
                    mapper.put(configItem.getApi(),'stubby.email@example.com');
                } 
                if(configItem.getApi().equals('Zuora__Zuora_Id__c')){
                    mapper.put(configItem.getApi(),'2c92a0ff64d60ab30164db947844445e');
                }                 
                                                 
        }
        return mapper;
    }

    public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {

        IQueryListMap iqlm = (IQueryListMap) isom;
        Integer numberReturnedItems = iqlm.getNumberRows();

        IStringOutput stringOutput = new StringOutputV1();
        stringOutput.setOutputMessage ('Returned rows: ' + numberReturnedItems);
        stringOutput.setState(isom.getState());
        stringOutput.setErrorMessage(isom.getErrorMessage());
        return stringOutput;
    }

}
