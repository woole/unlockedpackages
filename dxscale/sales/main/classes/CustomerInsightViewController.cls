public With Sharing class CustomerInsightViewController {
    
    @auraEnabled
    public static boolean getInsightFieldAccess(){
        boolean isEditable = false;
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([SELECT Id, PermissionSet.Name FROM PermissionSetAssignment 
                                                                               WHERE PermissionSet.Name = 'Sage_Global_Sales_Operations' AND AssigneeId =:userInfo.getUserId()]);
        if(psa.size() > 0){
            isEditable = true; 
        } 
        return isEditable;
    }
}