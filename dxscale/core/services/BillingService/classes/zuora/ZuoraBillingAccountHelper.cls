public inherited sharing class ZuoraBillingAccountHelper {
    
    public static final String CLASS_NAME = 'ZuoraBillingAccountHelper';

    public static String getBillingAccount(String recordId,String correlationId){
        LogControl.push('getBillingAccount', CLASS_NAME);
        String billingAccountNumber;
        try{
            String queryConfig = DynamicQueryConfigLoader.getInstance().getConfig('QueryZuoraBillingAccount').JSONConfig__c;
            IQueryListMap resultsMap = (IQueryListMap)fetchData(recordId,'ZuoraBillingAccount_Invocation_1',queryConfig,correlationId);
            if(resultsMap != null){
                if(resultsMap.getNumberRows() > 1){
                    System.debug(LoggingLevel.WARN, 'More than one billing account returned for ' + recordId);
                }
                for(Map<String,Object> item:resultsMap.getAll()){
                    String accountNumber = getValue(item,'Zuora__AccountNumber__c');
                    if(String.isNotBlank(accountNumber)){
                        billingAccountNumber = accountNumber;
                        break;
                    }
                }
            }
        }catch(Exception e){
            LogControl.debugException(e);
        }finally{
            LogControl.pop();
        }

        return billingAccountNumber;
    }

    /**
     * Gets the Billing account infor for the supplied recordId. Pass in the fields you wanch back
     */
    public static List<billing_BillingAccount> getBillingAccountInfo(String sfAccountId,String correlationId){
        LogControl.push('getBillingAccountInfo', CLASS_NAME);
        List<billing_BillingAccount> results = new List<billing_BillingAccount>();
        
    
        String queryConfig = DynamicQueryConfigLoader.getInstance().getConfig('QueryZuoraBillingAccountList').JSONConfig__c;
        IService_Output_Master output = fetchData(sfAccountId,'ZuoraBillingAccount_Invocation_1',queryConfig,correlationId);
        if(output.getState() != 'SUCCESS'){
            throw new ZuoraServiceException('Query Error : ' + output.getErrorMessage());
        }
        IQueryListMap resultsMap = (IQueryListMap)output;
        if(resultsMap != null){
                for(Map<String,Object> item:resultsMap.getAll()){
                    billing_BillingAccount billingAccount = new zuora_BillingAccount(sfAccountId,item);
                    results.add(billingAccount);
            }
        }

        return results;        
    }

    @TestVisible
    private static String getValue(Map<String,Object> items, String apiName){
        Object value;
        if(items != null && items.containsKey(apiName)){
            value = (Object)items.get(apiName);
        }
        return (String)value;
        
    }    
    /**
     * fetchData Calls service Framwork for given invokerId
     * @param  recordId     recordId description
     * @param  invokerId    invokerId description
     * @param  masterConfig masterConfig description
     * @return              return IService_Output_Master - if an exception is rased it 
     */
    @TestVisible
    private static IService_Output_Master fetchData(String recordId, String invokerId, String masterConfig,String correlationId) {
        IService_Output_Master isom;
        LogControl.push('fetchData', CLASS_NAME);
        try{
            System.debug(LoggingLevel.DEBUG, 'recordId='+recordId+';invokerId='+invokerId+';masterConfig='+masterConfig);
            // retrieve the custom metadata for this invocation
            ServiceInvocation sinv = ServiceInvocation.initialize(invokerId);
            
            String inputCreationClass = sinv.getInvocationDetails().getInputCreationClass();

            // obtain an instance of the input interface, obtaining the concrete creation class from custom metadata
            IDynamicQueryConfigData cd = (IDynamicQueryConfigData) JSON.deserialize(masterConfig,Type.forName(inputCreationClass));
            cd.setCorrelationId(correlationId);
            cd.setQueryId(recordId);

            // invoke the service and cast the output to the correct interface
            
            isom = sinv.invokeService(cd);
            //we don't do anything if it failed

        }catch(Exception e){
            //unexpected error. log it and throw
            LogControl.debugException(e);
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw e;
        }finally{
            LogControl.pop();
        }
        
        return isom;
    }    

}
