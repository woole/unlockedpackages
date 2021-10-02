public inherited sharing class Service_Invoke_Event_TriggerHandler extends TriggerService {


    public override void onAfterInsert() {
        System.debug(LoggingLevel.DEBUG,'onAfterInsert trigger : Service_Invoke_Event_TriggerHandler');
        List<ServiceSerialize.SerializedInvocationStructure> listInputs = Service.getSerializedInvocationList(this.listNewSObject);
        if(!Test.isRunningTest()){
            Service.asyncInvokeService(listInputs);
        }
        
    }


}
