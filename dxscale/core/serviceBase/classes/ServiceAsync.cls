public inherited sharing class ServiceAsync {

    public static String INPUT_DATA_FIELD = 'InputData__c';
    public static String INVOCATION_DETAILS_FIELD = 'InvocationDetails__c';
    public static String REPLAYID_FIELD = 'replayid';

    List<SObject> eventsToProcess = new List<SObject>(); 

    /* 
        The first input parameter to this method needs to be a list of Platform Events which also need to have a specific field definition
        For these fields see the method Service.getSerializedInvocationList referenced in this method
        Also note that direct testing of this method is in the demo as the core package does not have any PEs defined in it
    */

    public void processLimitedServicePE (List<SObject> sobjs, Integer numberToProcess) {

        Integer counter = 0;
    
        for (SObject event : sobjs) {
            // Increase batch counter.
            counter++;
            // Only process the first event message
            if (counter > numberToProcess) { 
              // Exit for loop when we have collected the right number of events.
              break;
            }
            else {
                eventsToProcess.add(event);
            }
       
            // Resume after the last successfully processed event message
            // after the trigger stops running. 
            // Set Replay ID after which to resume event processing 
            // in new trigger execution.
            EventBus.TriggerContext.currentContext().setResumeCheckpoint((String) event.get(ServiceAsync.REPLAYID_FIELD));
            System.debug('setting resume checkpoint as: ' + event.get(ServiceAsync.REPLAYID_FIELD));
        }
        // remaining events will be processed on the next pickup

    }

    public void runAsyncService () {    
        // invoke the Service for the selected events
        List<ServiceSerialize.SerializedInvocationStructure> listInputs = Service.getSerializedInvocationList(eventsToProcess);
        Service.asyncInvokeService(listInputs);    
    }

    public List<SObject> getEventsToProcess (){
        return this.eventsToProcess;
    } 
    

}
