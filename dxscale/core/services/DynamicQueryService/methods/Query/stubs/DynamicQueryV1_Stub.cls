
public inherited sharing class DynamicQueryV1_Stub implements IService_Implementation, IService_Implementation_Audit_Override {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IDynamicQueryConfigData isi = (IDynamicQueryConfigData) inputData;
        return implementationBody(isi);
    }
 
    // for this stub we push back some random values based on what the input config is
    // we default to 10 rows returned.
    // input is ignored.

    IQueryListMap implementationBody (IDynamicQueryConfigData isi) {

        IQueryListMap outputData = new QueryListMap();

        for (Integer loopCount = 0; loopCount < 10; loopCount++) {
            Map<String,Object> mapper = putToMap(isi.getFields(),loopCount);

            outputData.add(mapper);   
        }            
        outputData.setState('SUCCESS');
        outputData.setDataStatus('Stubbed');

        System.debug('exiting implementationBody with state:' + outputData.getState());
        return outputData;
    }



    private static  Map<String,Object> putToMap (List<IDynamicQueryConfigItem> fields, Integer loopCount) {
        Map<String,Object> mapper = new Map<String,Object>();

        for (IDynamicQueryConfigItem configItem : fields) {
            if (configItem.getType() == 'text' || configItem.getType() == 'string') {
                mapper.put(configItem.getApi(), configItem.getLabel() + ' ' + loopCount + ' stub value');
            }
            if (configItem.getType() == 'currency') {
                mapper.put(configItem.getApi(), 15129.15423 - loopCount);
            }
            if (configItem.getType() == 'integer') {
                mapper.put(configItem.getApi(), 3 * loopCount);
            }
            if (configItem.getType() == 'phone') {
                mapper.put(configItem.getApi(), '07782736328');
            }
            if (configItem.getType() == 'decimal') {
                mapper.put(configItem.getApi(), 41.02837 * loopCount);
            }
            if (configItem.getType() == 'date') {
                mapper.put(configItem.getApi(), Date.Today().addDays(- loopCount));
            }
            if (configItem.getType() == 'boolean') {
                mapper.put(configItem.getApi(), true);
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
