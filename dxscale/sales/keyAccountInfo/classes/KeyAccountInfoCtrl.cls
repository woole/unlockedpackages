public inherited sharing class KeyAccountInfoCtrl {

    private static final String CLASS_NAME = 'KeyAccountInfoCtrl';
    enum CONFIGS {KeyInfo_AccountExtra, KeyInfo_AccountPartner, KeyInfo_AccountPrompt, KeyInfo_AccountCustInteraction1,KeyInfo_AccountCustInteraction2}

    @AuraEnabled(cacheable=true)
    public static String getRecordId(String recordId,String objectApiName, String globalAccountId){
        
        if(objectApiName != null && !objectApiName.equalsIgnoreCase('Account')){
            String fieldName = getFieldName(objectApiName,globalAccountId);
            String soql = String.escapeSingleQuotes('SELECT ' + fieldName + ' FROM ' + objectApiName + ' where id = :recordId LIMIT 1');
            try{
                SObject recordObject = Database.query(soql);
                if(recordObject != null && recordObject.get(fieldName) != null){
                    //check if the user can read the record and error if not
                    boolean access = recordObject.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible();
                    if(!access){
                        throw new AuraHandledException('You do not have access.');
                    }
                    System.debug(LoggingLevel.DEBUG, 'User access for : ' + fieldName + ' on Object : ' + objectApiName + ', is : ' + access);
                    return (String)recordObject.get(fieldName);
                }else{
                    throw new AuraHandledException('Unable to find record');
                }    
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, 'Unable to query for recordId ' + e);
                throw new AuraHandledException('Unable to derive for recordId, check config');
            }
        }else{
            String fieldName = getFieldName(objectApiName,globalAccountId);
            if(String.isNotBlank(globalAccountId) && fieldName.contains('__c')){
                String soql = String.escapeSingleQuotes('SELECT ' + fieldName + ' FROM ' + 'Account' + ' where id = :recordId LIMIT 1');
                try{
                    SObject recordObject = Database.query(soql);
                    if(recordObject != null && recordObject.get(fieldName) != null){
                        //check if the user can read the record and error if not
                        boolean access = recordObject.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible();
                        if(!access){
                            throw new AuraHandledException('You do not have access.');
                        }
                        System.debug(LoggingLevel.DEBUG, 'User access for : ' + fieldName + ' on Object : ' + ' Account ' + ', is : ' + access);
                            return (String)recordObject.get(fieldName);
                    }else{
                        throw new AuraHandledException('Unable to find record');
                    }    
                }catch(Exception e){
                    System.debug(LoggingLevel.ERROR, 'Unable to query for recordId ' + e);
                    throw new AuraHandledException('Unable to derive for recordId, check config');
                }
            }else{
                return recordId;
            }
        }        
    }

    //Standard Objects user AccountId, custom would use Account__c
    @TestVisible
    private static String getFieldName(String objectApiName, String globalAccountId){
        if(objectApiName.contains('__c')){
            if(String.isNotBlank(globalAccountId)){
                return 'Account__r.Global_Id__c';
            }else{
                return 'Account__c';
            }
        }else if(objectApiName.contains('Account') && String.isNotBlank(globalAccountId)){
            return 'Global_Id__c';     
        }else{
            return 'Id';
        }
    }


    @AuraEnabled
    public static List<KeyAccountInfo_d> getAccountExtra(String recordId,String invokerId){
        List<KeyAccountInfo_d> keyDataItems = new List<KeyAccountInfo_d>();
        IQueryListMap resultsMap = (IQueryListMap)fetchData(recordId,invokerId,getConfig(CONFIGS.KeyInfo_AccountExtra.name()));
        logStats('getAccountExtra',resultsMap);
        System.debug(LoggingLevel.DEBUG, 'getAccountExtra -> ' + resultsMap);
        if(resultsMap != null){
            for(Map<String,Object> item:resultsMap.getAll()){
                if(hasValue(item,'CreditStatus__c')){
                    keyDataItems.add(new KeyAccountInfo_d(1,'Credit Score : ' + item.get('CreditStatus__c'),false));
                }
                if(hasValue(item,'AccountPassword__c')){
                    keyDataItems.add(new KeyAccountInfo_d(1,'Password :  ' + item.get('AccountPassword__c'),false));
                }   
                if(hasValue(item,'HomeOrExport__c')){
                    keyDataItems.add(new KeyAccountInfo_d(1,formatMessage(false,Label.ExportCustomer),false));
                }
            }      
        }
        return keyDataItems;
    }
        

    @AuraEnabled
    public static List<KeyAccountInfo_d> getAcccountPartner(String recordId,String invokerId){
        List<KeyAccountInfo_d> keyDataItems = new List<KeyAccountInfo_d>();
        
        IQueryListMap resultsMap = (IQueryListMap)fetchData(recordId,invokerId,getConfig(CONFIGS.KeyInfo_AccountPartner.name()));
        System.debug(LoggingLevel.DEBUG, 'getAcccountPartner -> ' + resultsMap);
        logStats('getAcccountPartner',resultsMap);
        if(resultsMap != null && resultsMap.getAll().size() > 0){
            keyDataItems.add(new KeyAccountInfo_d(1,formatMessage(true,Label.Partner),false));
        }
        return keyDataItems;
    }
    @AuraEnabled
    public static List<KeyAccountInfo_d> getAccountPrompt(String recordId,String invokerId){
        IQueryListMap resultsMap = (IQueryListMap)fetchData(recordId,invokerId,getConfig(CONFIGS.KeyInfo_AccountPrompt.name()));
        System.debug(LoggingLevel.DEBUG, 'getAccountPrompt -> ' + resultsMap);
        logStats('getAccountPrompt',resultsMap);
        
        List<KeyAccountInfo_d> keyDataItems = new List<KeyAccountInfo_d>();
        if(resultsMap != null && resultsMap.getAll().size() > 0){
            keyDataItems.add(new KeyAccountInfo_d(2,formatMessage(true,Label.Prompts),false));
        }
        return keyDataItems;        
    }
    
    @AuraEnabled
    public static List<KeyAccountInfo_d> getAccountOriginInfo(String recordId, String globalAccountId){
        boolean hasAccess = Schema.sObjectType.Account.fields.Migration_Information__c.isAccessible();
        List<KeyAccountInfo_d> keyDataItems = new List<KeyAccountInfo_d>();
        String migrationOriginInfo;
        if(hasAccess){
            if(String.isNotBlank(globalAccountId) && globalAccountId.contains('Global_Id__c')){
                migrationOriginInfo = [Select Migration_Information__c from Account where Global_Id__c=:recordId].Migration_Information__c;
            }else{
                migrationOriginInfo = [Select Migration_Information__c from Account where Id=:recordId].Migration_Information__c;
            }
            if (String.isNotBlank(migrationOriginInfo)){
                keyDataItems.add(new KeyAccountInfo_d(1,'Migration Info :  ' +migrationOriginInfo,true));
            }
        }
        return keyDataItems;        
    }

    @AuraEnabled
    public static List<KeyAccountInfo_d> getCustomerInteraction(String recordId,String invokerId){
        List<KeyAccountInfo_d> keyDataItems = new List<KeyAccountInfo_d>();
       
        IQueryListMap resultsMap = (IQueryListMap)fetchData(recordId,invokerId,getConfig(CONFIGS.KeyInfo_AccountCustInteraction1.name()));
        System.debug(LoggingLevel.DEBUG, 'getCustomerInteraction:KeyInfo_AccountCustInteraction2 -> ' + resultsMap);
        logStats('getCustomerInteraction1',resultsMap);
        IQueryListMap resultsMap2 = (IQueryListMap)fetchData(recordId,invokerId,getConfig(CONFIGS.KeyInfo_AccountCustInteraction2.name()));
        System.debug(LoggingLevel.DEBUG, 'getCustomerInteraction:KeyInfo_AccountCustInteraction2 -> ' + resultsMap2);
        logStats('getCustomerInteraction2',resultsMap2);

        if(resultsMap != null && (resultsMap.getAll().size() > 0 || resultsMap2.getAll().size() > 0)){
            keyDataItems.add(new KeyAccountInfo_d(2,formatMessage(true,Label.Complaints),false));
        }
        return keyDataItems;        
    }



    private static String formatMessage(boolean isCanned, String message){
        String strReply = '';
        if(isCanned){
            strReply = Label.PreSummaryResponse + ' ' +  message;
        }else{
            strReply = message;
        }
        return strReply;
    }

    
    /**
     * fetchData Calls service Framwork for given invokerId
     * @param  recordId     recordId description
     * @param  invokerId    invokerId description
     * @param  masterConfig masterConfig description
     * @return              return IService_Output_Master - if an exception is rased it 
     */
    public static IService_Output_Master fetchData(String recordId, String invokerId, String masterConfig) {
        IService_Output_Master isom;
        LogControl.push('fetchData', CLASS_NAME);
        try{
            System.debug(LoggingLevel.DEBUG, 'recordId='+recordId+';invokerId='+invokerId+';masterConfig='+masterConfig);
            // retrieve the custom metadata for this invocation
            ServiceInvocation sinv = ServiceInvocation.initialize(invokerId);
            
            String inputCreationClass = sinv.getInvocationDetails().getInputCreationClass();

            // obtain an instance of the input interface, obtaining the concrete creation class from custom metadata
            IDynamicQueryConfigData cd = (IDynamicQueryConfigData) JSON.deserialize(masterConfig,Type.forName(inputCreationClass));
            cd.setQueryId(recordId);

            // invoke the service and cast the output to the correct interface
            
            isom = sinv.invokeService(cd);
            if(isom.getState() != 'SUCCESS'){
                AuraHandledException e = new AuraHandledException('Unable to query service  : ' + invokerId);
                e.setMessage(isom.getErrorMessage());
                throw e;
            }
        }catch(Exception e){
            LogControl.debugException(e);
            System.debug(Logginglevel.ERROR, e.getMessage());
            AuraHandledException ex = new AuraHandledException('Unable to invoke service : ' + invokerId);
            ex.setMessage(e.getMessage());
            throw ex;
        }finally{
            LogControl.pop();
        }
        
        return isom;
    }

    private static void logStats(String key,IService_Output_Master isom){
        String stats = 'STATS -> :'+key+': ';
        System.debug(LoggingLevel.DEBUG, stats);
    }

    /**
     * getValue returns the value or null
     * @param  resultsMap resultsMap description
     * @return            return description
     */ 
    private static boolean hasValue(Map<String,Object> items, String apiName){
        Object value;
        if(items != null && items.containsKey(apiName)){
            value = (Object)items.get(apiName);
        }
        return value != null;
        
    }

    @TestVisible
    private static String getConfig(String config){
        LogControl.push('getConfig', CLASS_NAME);
        QueryGridDisplayConfiguration__mdt queryConfig;
      
        try{
            queryConfig = DynamicQueryConfigLoader.getInstance().getConfig(config);
        }catch(DynamicQueryConfigLoader.DynamicQueryConfigLoaderException e){
            LogControl.debugException(e);
            throw new AuraHandledException('Unable to load Component config');
        }finally{
            LogControl.pop();
        }
        return queryConfig.JSONConfig__c; 
    }

    
}
