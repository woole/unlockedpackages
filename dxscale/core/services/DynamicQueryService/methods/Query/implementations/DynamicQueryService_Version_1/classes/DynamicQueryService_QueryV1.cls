public inherited sharing class DynamicQueryService_QueryV1 implements IService_Implementation, IService_Implementation_Audit_Override {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IDynamicQueryConfigData isi = (IDynamicQueryConfigData) inputData;
        return implementationBody(isi);
    }

    IQueryListMap implementationBody (IDynamicQueryConfigData isi) {
        String queryId;
        IQueryListMap outputData = new QueryListMap();
        List<String> apis;

        try {

            queryId = isi.getQueryId();
            apis = isi.getQueryFieldAPIs();

            if (queryId == null) {
                throw new Service.ServiceFrameworkException('Queries must be qualified by an id');
            }
        }
        catch (Exception e) {
            outputData.setState ('FAILURE: DynamicQueryService: Invalid Query Structure');
            outputData.setErrorMessage('Configuration Error - contact your administrator: ' + e.getMessage());
            return outputData;
        }

        try {
            List<SObject> sobjs = isi.runQuery(queryId);
            for (SObject sobj : sobjs) {
                Map<String,Object> mapper = new Map<String,Object>();
                for (String s : apis) {
                    String fieldAPIName = s;
                    SObject tmpObj = sobj;
                    //to support relationships navigate
                    if(s.contains('.')){
                        String[] objectNavList = s.split('\\.');
                        for(Integer i=0; i< (objectNavList.size() - 1); i++ ) {
                            tmpObj = tmpObj.getSObject(objectNavList[i]);
                        } 
                        //field name is the last in the array
                        fieldAPIName = objectNavList[objectNavList.size()-1];
                    }
                    //EAD-2353 if the ObjectA__r.ObectB__r.Name is null 
                    if(tmpObj == null){
                    	mapper.put(s, null);    
                    }else{
	                    mapper.put(s, tmpObj.get(fieldAPIName));                                        
                    }                    
                    
                }
                outputData.add(mapper);   
            }            
            
            outputData.setState('SUCCESS');

            outputData.setCorrelationId(isi.getCorrelationId());

            boolean potentiallyMoreRows = (isi.hasLimitRows() && isi.getLimitRows() <= sobjs.size() );
            outputData.setPotentiallyMoreRows(potentiallyMoreRows);

        }
        catch (Exception e) {
            outputData.setState ('FAILURE: DynamicQueryService: Query Failed');
            outputData.setErrorMessage('Query failed - contact your administrator: '  + e.getMessage());
            return outputData;
        }
        return outputData;
    }

    public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {

        IQueryListMap iqlm = (IQueryListMap) isom;
        Integer numberReturnedItems = iqlm.getNumberRows();

        IStringOutput stringOutput = new StringOutputV1();
        stringOutput.setOutputMessage ('Returned rows: ' + numberReturnedItems);
        stringOutput.setState(isom.getState());
        stringOutput.setErrorMessage(isom.getErrorMessage());
        stringOutput.setCorrelationId(isom.getCorrelationId());
        return stringOutput;
    }




}

