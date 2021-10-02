public with sharing class ProductHoldingLTCtrl {
    

    private static final String CLASS_NAME = 'ProductHoldingLTCtrl';


    /* Screen constructs */
    public class ScreenItem {
        @AuraEnabled public Map<String,Object> screenFields; 
    }

    public class ScreenData {

        @AuraEnabled public String state;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Boolean potentiallyMoreRows;
        @AuraEnabled public String viewConfig;

        @AuraEnabled
        public List<ScreenItem> items = new List<ScreenItem>();

        public void render(IService_Output_Master outputData) {
            // Cast outputData to the correct detailed interface
            IQueryListMap iso = (IQueryListMap) outputData;

            while(iso.hasNext()) {
                Map<String,Object> mapper = iso.getNext();         
                ScreenItem item = new ScreenItem();
                for (String thisKey : mapper.keySet()) {
                    item.screenFields = mapper;
                }
                items.add(item);
            }
        }

    }    
 
    @AuraEnabled
    public static ScreenData getScreenData(Id accountId, String queryConfig,String invokerId,String fieldName) {
        LogControl.push('getScreenData', CLASS_NAME);
        ScreenData sd = new ScreenData();
        try{
            String masterConfig = getJSONConfig(queryConfig);
            IQueryListMap outputData = (IQueryListMap)fetchData(accountId,invokerId,masterConfig,fieldName);
            // Prepare the screen output
            sd.state = outputData.getState();
            sd.errorMessage = outputData.getErrorMessage();
            sd.potentiallyMoreRows = outputData.getPotentiallyMoreRows();
            sd.viewConfig = masterConfig;
    
            // if we have a SUCCESS scenario then we drill down into the specifc interface for our current use case.
            if (sd.state == 'SUCCESS') {
                sd.render (outputData);
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
        return sd;
    }

    /**
     * fetchData Calls service Framwork for given invokerId
     * @param  recordId     recordId description
     * @param  invokerId    invokerId description
     * @param  masterConfig masterConfig description
     * @return              return IService_Output_Master - if an exception is rased it 
     */
    public static IService_Output_Master fetchData(String recordId, String invokerId, String masterConfig, String fieldName) {
        IService_Output_Master isom;
        LogControl.push('fetchData', CLASS_NAME);
        try{
            System.debug(LoggingLevel.DEBUG, 'recordId='+recordId+';invokerId='+invokerId+';masterConfig='+masterConfig+';fieldName='+fieldName);
            // retrieve the custom metadata for this invocation
            ServiceInvocation sinv = ServiceInvocation.initialize(invokerId);
            
            String inputCreationClass = sinv.getInvocationDetails().getInputCreationClass();

            // obtain an instance of the input interface, obtaining the concrete creation class from custom metadata
            IDynamicQueryConfigData cd = (IDynamicQueryConfigData) JSON.deserialize(masterConfig,Type.forName(inputCreationClass));
            //cd.setQueryId(recordId);
            
            // Passing the Global Id for ODS integration
            if(String.isNotBlank(fieldName) && fieldName.contains('Global_Id__c')){
                String soql = String.escapeSingleQuotes('SELECT ' + fieldName + ' FROM ' + 'Account' + ' where id = :recordId LIMIT 1');
                SObject recordObject = Database.query(soql);
                if(recordObject != null && recordObject.get(fieldName) != null){
                    //check if the user can read the record and error if not
                    boolean access = recordObject.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible();
                    if(!access){
                        throw new AuraHandledException('You do not have access.');
                    }
                    System.debug(LoggingLevel.DEBUG, 'User access for : ' + fieldName + ' on Object : ' + ' Account ' + ', is : ' + access);
                }
                cd.setQueryId((String)recordObject.get(fieldName));
            }else{
                cd.setQueryId(recordId);
            }

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

    
    private static String getJSONConfig(String pageComponentId) {
        QueryGridDisplayConfiguration__mdt qgdc = DynamicQueryConfigLoader.getInstance().getConfig(pageComponentId);
        return qgdc.JSONConfig__c;
    }   

}