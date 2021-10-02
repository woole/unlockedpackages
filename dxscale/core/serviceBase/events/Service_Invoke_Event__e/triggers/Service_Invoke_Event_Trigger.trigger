trigger Service_Invoke_Event_Trigger on Service_Invoke_Event__e (after insert) {
    TriggerFactory.executeTrigger();
}