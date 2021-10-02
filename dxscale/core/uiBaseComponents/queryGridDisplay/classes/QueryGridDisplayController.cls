public inherited sharing class QueryGridDisplayController {

    /* Screen constructs */
    public class ScreenItem {
        @AuraEnabled public Map<String,Object> screenFields; 
    }

    public class ScreenData {

        @AuraEnabled public String state;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Boolean potentiallyMoreRows;

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

    // Method that LWC talks to

    @AuraEnabled
    public static String getJSONConfig(String pageComponentId) {
        QueryGridDisplayConfiguration__mdt qgdc = DynamicQueryConfigLoader.getInstance().getConfig(pageComponentId);

        return qgdc.JSONConfig__c; 
    }


    @AuraEnabled
    public static ScreenData fetchData(String recordId, String objectApiName, String globalAccountId, String invokerId, String masterConfig) {

        ScreenData sd = new ScreenData(); 

        try {
            // retrieve the custom metadata for this invocation
            ServiceInvocation sinv = ServiceInvocation.initialize(invokerId);
            String inputCreationClass = sinv.getInvocationDetails().getInputCreationClass();

            // obtain an instance of the input interface, obtaining the concrete creation class from custom metadata
            IDynamicQueryConfigData cd = (IDynamicQueryConfigData) ServiceSerialize.deserializeByClassName(masterConfig,inputCreationClass);
            if(String.isNotBlank(globalAccountId) && String.isNotBlank(objectApiName)){
                String fieldApiName = globalAccountId;
                String soql = String.escapeSingleQuotes('SELECT ' + fieldApiName + ' FROM ' + objectApiName + ' where id = :recordId LIMIT 1');
                SObject recordObject = Database.query(soql);
                //check if the user can read the record and error if not
                boolean access = recordObject.getSObjectType().getDescribe().fields.getMap().get(fieldApiName).getDescribe().isAccessible();
                if(!access){
                    throw new AuraHandledException('You do not have access.');
                }
                System.debug(LoggingLevel.DEBUG, 'User access for : ' + fieldApiName + ' on Object : ' + objectApiName + ', is : ' + access);
                cd.setQueryId((String)recordObject.get(fieldApiName));
            }else{
                cd.setQueryId(recordId);
            }

            // invoke the service and cast the output to the correct interface
            IQueryListMap outputData = (IQueryListMap) sinv.invokeService(cd);

            // Prepare the screen output
            sd.state = outputData.getState();
            sd.errorMessage = outputData.getErrorMessage();
            sd.potentiallyMoreRows = outputData.getPotentiallyMoreRows();

            // if we have a SUCCESS scenario then we drill down into the specifc interface for our current use case.
            if (sd.state == 'SUCCESS') {
                sd.render (outputData);
            }
        }
        catch (Exception e) {
            // add logging here ....
            sd.state = 'FAILURE';
            sd.errorMessage = 'An unexpected error has occurred, contact your administrator';
        }
        return sd;
    }

}
