public inherited sharing class ExceptionEvent_TriggerHandler extends TriggerService {
    
    public override void onAfterInsert(){
        ExceptionEvent_Helper.processEventToLogger((List<ExceptionEvent__e>) this.listNewSObject);
    }
}
