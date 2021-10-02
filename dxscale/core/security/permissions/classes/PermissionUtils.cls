public inherited sharing class PermissionUtils {

    public enum PERMISSION_TYPE { 
        READ_PERMISSION, 
        CREATE_PERMISSION,
        UPDATE_PERMISSION,
        DELETE_PERMISSION
    }

    public static boolean userHasCustomPermission (String permissionName) {
        return FeatureManagement.checkPermission(permissionName);
    }


    /**
     * based on supplied fieldList - returns which fields user does not have access to read/create/delete etc
     */
    public static Map<PERMISSION_TYPE,List<String>> getDoesNotHaveAccessMap(List<String> fieldList,String objectAPIName){
        SObjectType sobjectType = Schema.getGlobalDescribe().get(objectAPIName);
        // Obtaining the field name/token map for the Contact object
        Map<String,Schema.SObjectField> permissionMap = sobjectType.getDescribe().fields.getMap();

        Map<PERMISSION_TYPE,List<String>> userPermissions = new  Map<PERMISSION_TYPE,List<String>>();

        //delete permission is at object not field
        if (!sobjectType.getDescribe().isDeletable()) {
            System.debug(LoggingLevel.DEBUG,'no Delete permission for : ' + objectAPIName);
            addNewList(userPermissions,objectAPIName,PERMISSION_TYPE.DELETE_PERMISSION);            
        }

        for (String fieldToCheck : fieldList) {
            // Check if the user has create access on the each field
                
            if (!permissionMap.get(fieldToCheck).getDescribe().isCreateable()) {
                System.debug(LoggingLevel.DEBUG,'no Create permission for : ' + fieldToCheck);
                addNewList(userPermissions,fieldToCheck,PERMISSION_TYPE.CREATE_PERMISSION);
            }    
            if (!permissionMap.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug(LoggingLevel.DEBUG,'no Read permission for : ' + fieldToCheck);
                addNewList(userPermissions,fieldToCheck,PERMISSION_TYPE.READ_PERMISSION);
            }
            if (!permissionMap.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug(LoggingLevel.DEBUG,'no Update permission for : ' + fieldToCheck);
                addNewList(userPermissions,fieldToCheck,PERMISSION_TYPE.UPDATE_PERMISSION);
            }             
        
        } 
        return userPermissions;
    }

    @TestVisible
    private static void addNewList(Map<PERMISSION_TYPE,List<String>> permissionMap,String fieldName,PERMISSION_TYPE type){
        if(!permissionMap.containsKey(type)){
            List<String> createList = new List<String>{fieldName};
            permissionMap.put(type,createList);
        }else{
            permissionMap.get(type).add(fieldName);
        }
    }

    public static boolean checkFieldPermissions(List<String> fieldList,String objectAPIName,PERMISSION_TYPE checkType){
        boolean hasPermission = true;
        Map<PERMISSION_TYPE,List<String>> userPerms = getDoesNotHaveAccessMap(fieldList,objectAPIName);
        hasPermission = !userPerms.containsKey(checkType);
        return hasPermission;     
    }    
}
