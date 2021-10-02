@isTest
public class CoreTestUtils {
    
    public static User createUser(Profile p,String locale,String emailDomain) {
        Blob aesKey = Crypto.GenerateAESKey(128);
        String aesKeyHex = EncodingUtil.ConvertTohex(aesKey);
          String uid = aesKeyHex.SubString(0,8);
           User adminUser = new User(Alias = uid,
                                FederationIdentifier =uid + '@'+emailDomain+'.com',   
                             Email= uid + '@'+emailDomain+'.com', 
                                      FirstName='Global Sales',       
                                LastName='Testing', 
                                LanguageLocaleKey=locale, 
                             EmailEncodingKey='UTF-8',
                                       LocaleSidKey=locale, 
                             ProfileId = p.Id, 
                             TimeZoneSidKey='America/New_York',
                             UserName= uid + '@'+emailDomain+'.com');
         insert(adminUser);
         return adminUser;
     }    

    public static User setUpUserWithPermissions(String emailDomain,String profileName,List<String> permissionSetNames){
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        user user = createUser(p, 'en_US', emailDomain);
        assignPermissionSet(user.id,permissionSetNames);
        return user;
    }
    
    @future
    public static void assignPermissionSet(String userId,List<String> permissionSetNames){
        List<PermissionSet> ps = [SELECT Id, Name, Label FROM PermissionSet where Name IN :permissionSetNames];
        
        List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();
        for(PermissionSet perm:ps){
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = perm.Id, AssigneeId = userId);
            permissions.add(psa);
        }
        try{
            insert permissions;
        }catch(Exception e){
            //probably allready assigned. do nothing
            System.debug('permission not assignable : ' + e.getMessage());
        }
        
  
    }     
}
