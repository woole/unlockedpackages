global with sharing class AuditRepublish {

    public class ScreenData {
        @AuraEnabled public String state;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String returnMessage;
    }


    @AuraEnabled
    public static ScreenData rerun (Id recordId, String inputMessage) {
        Service_Framework_Audit__c sfa = 
        [select Invocation_Details__c,Invocation_Name__c 
            from Service_Framework_Audit__c
            where id = :recordId];
        
        ServiceInvocation sinv = ServiceInvocation.initialize(sfa.Invocation_Name__c);        
        IInvocation_Details invocationDetails = (IInvocation_Details) Service.deserializeInvocationDetails (sfa.Invocation_Details__c);        
        IService_Input_Master isi = Service.deserializeInput(inputMessage, invocationDetails);                

        IService_Output_Master outputData = sinv.invokeService(isi);
        // store the State
        String outputState = outputData.getState();

        // start to populate the intended output
        ScreenData sd = new ScreenData(); 
        sd.state = outputState;
        sd.returnMessage = 'Successfully republished';

        if (outputState != 'SUCCESS') {
            sd.returnMessage = outputData.getErrorMessage();
        }        
        return sd;
    }

    @AuraEnabled
    public static String getInput (Id recordId) {
        String inputDate;
        List<String> fieldList = new List<String>{'Input_Data__c','Output_Data__c','Invocation_Details__c','Invocation_Name__c'};
        Boolean hasPermission = PermissionUtils.checkFieldPermissions(fieldList,'Service_Framework_Audit__c',PermissionUtils.PERMISSION_TYPE.READ_PERMISSION);
        if(hasPermission){
            Service_Framework_Audit__c sfa = [select Input_Data__c,Output_Data__c,Invocation_Details__c,Invocation_Name__c from Service_Framework_Audit__c where id = :recordId];
            inputDate = sfa.Input_Data__c;
        }
        
        return inputDate;
    }

    


}
