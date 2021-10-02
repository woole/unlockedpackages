trigger Audit_Inbound_Event_Trigger on Audit_Inbound_Event__e (after insert) {

    List<ServiceSerialize.SerializedInvocationStructure> listInputs = Service.getSerializedInvocationList(Trigger.New);
    Service.asyncInvokeService(listInputs);

}