@isTest
public with sharing class SalesTestUtility {
  
    public static List<SObject> createRecords( List<SObject> records, Boolean doInsert, Map<String, Object> attributes ){
        Integer i = 0;
        if( attributes != null ){
            for ( Integer j =0; j < records.size(); j ++ ) {
              SObject record = records[j];
              for (String key : attributes.keySet()) {
                Object value = attributes.get(key);
                if (value instanceof List<Object>) {
                  Object obj =  ((List<Object>) value).get(i);
                  if( obj instanceof SObject ){
                    Id sObjectId = ((SObject) obj).Id;
                    record.put( key,sObjectId );
                  }
                  else {
                    record.put(key,obj);
                  }
                } else {
                  record.put(key, value);
                }
              }
              i++;
            }
        }
        if (doInsert) {
          insert records;
        }
        return records;
    }

    public static List<SObject> createSObject( Integer numToInsert, Boolean doInsert, Map<String, Object> nameValueMap , String sobjType){
        List<SObject> objList = new List<SObject>();
        for( Integer i=0; i< numToInsert; i++ ){
          SObject obj = Schema.getGlobalDescribe().get(sobjType).newSObject();
          objList.add( obj );
        }
        return createRecords( objList, doInsert, nameValueMap );
    }

    public static PermissionSet createMockPermissionSet() {
        PermissionSet mockPermissionSet = new PermissionSet(Label = 'mockPermissionSet', Name = 'mockPermissionSet');
        Database.insert(mockPermissionSet);
        return mockPermissionSet;
    }

	public static PermissionSet createMockPermissionSet(String premSetName) {
        PermissionSet mockPermissionSet = new PermissionSet(Label = premSetName, Name = premSetName);
        Database.insert(mockPermissionSet);
        return mockPermissionSet;
    }
    
    public static void assignCustomPermToPermSet(Id permissionSetId, String customPermApiName) {
        SetupEntityAccess seAccess = new SetupEntityAccess(
            	ParentId = permissionSetId
            ,	SetupEntityId = [	SELECT Id FROM CustomPermission 
                              		WHERE DeveloperName = :customPermApiName ][0].Id);
		Database.insert(seAccess);
    }
    
    
    public static User createUsSystemAdminUser() {
      Profile p = [SELECT Id FROM Profile WHERE Name=:Label.Profile_SystemAdministrator]; 
      return createUser(p,'en_US','myorgsage');
    }

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
    
    public static void createUsersWithCustomPermission(Integer intCount, String customPermissionName) {
        List<User> listUserInsert = new List<User>();
        List<PermissionSetAssignment> listPermSetAssignmentInsert = new List<PermissionSetAssignment>();
        PermissionSet mockPermissionSet = SalesTestUtility.createMockPermissionSet();
        SalesTestUtility.assignCustomPermToPermSet(mockPermissionSet.Id, customPermissionName);
        
        String userName;
        for (Integer iterator = 0; iterator < intCount; iterator++) {
            userName = 'nca.plus.cust.perm@' + String.valueOf(System.now().millisecond()) + '.com';
            listUserInsert.add(new User(
                        FirstName = 'Global'
                    ,   LastName = 'Sales User'
                    ,   Alias = 'GS' + String.valueOf(System.now().millisecond())
                    ,   Email = 'global.sales.test.user@qwertyuioplkj.com'
                    ,   ProfileId = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ].get(0).Id
                    ,   Username = userName
                    ,   EmailEncodingKey = 'UTF-8'
                    ,   LanguageLocaleKey = 'en_US'
                    ,   LocaleSidKey = 'en_GB'
                    ,   TimeZoneSidKey='Europe/London'
            ));
        }
        List<Database.SaveResult> lUserSaveResult = Database.insert(listUserInsert);
        for (Database.SaveResult eachSaveResult :lUserSaveResult) {
            listPermSetAssignmentInsert.add(new PermissionSetAssignment(
					        AssigneeId = eachSaveResult.getId()
                ,	PermissionSetId = mockPermissionSet.Id));
        }
        Database.insert(listPermSetAssignmentInsert);
    }

    public static void createUserWithProfileAndCustomPerm(Set<String> setCustomPermission, String emailUserName, String profileName) {
		PermissionSet mockPermissionSet = SalesTestUtility.createMockPermissionSet(emailUserName);

		List<SetupEntityAccess> listEntityAccess = new List<SetupEntityAccess>();
		for (CustomPermission eachCp :[	SELECT Id FROM CustomPermission WHERE DeveloperName IN :setCustomPermission ]) {
			listEntityAccess.add(new SetupEntityAccess(ParentId = mockPermissionSet.Id, SetupEntityId = eachCp.Id));
		}
		Database.insert(listEntityAccess);

		Database.SaveResult userSaveResult = Database.insert(new User(
				FirstName = 'Global'
			,   LastName = 'Sales User'
			,   Alias = 'GS' + String.valueOf(System.now().millisecond())
			,   Email = 'global.sales.test.user@qwertyuioplkj.com'
			,   ProfileId = [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1 ].get(0).Id
			,   Username = emailUserName + '@' + String.valueOf(System.now().millisecond()) + '.com'
			,   EmailEncodingKey = 'UTF-8'
			,   LanguageLocaleKey = 'en_US'
			,   LocaleSidKey = 'en_GB'
			,   TimeZoneSidKey='Europe/London')
		);

		Database.insert(new PermissionSetAssignment(
			AssigneeId = userSaveResult.getId(), PermissionSetId = mockPermissionSet.Id));
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

    public static Account createAccount(Id locId){
        Account acc = new Account();
        acc.Name = 'acme' + String.valueOf(System.now().millisecond());
        acc.BillingCity = 'Atlanta' + String.valueOf(System.now().millisecond());
        acc.BillingCountry = 'United States';
        acc.BillingCountryCode = 'US';
        acc.BillingStreet ='Some Street' + String.valueOf(System.now().millisecond());
        acc.BillingPostalCode = '30318';
        acc.BillingState = 'Georgia';
        acc.BillingStateCode = 'GA';
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.Locale_Billing_CC__c = 'US';
        acc.Locale__c = locId;
        insert acc;

        //To evaluate the cross reference values and derive the formula 
        acc.Locale__c = locId;
        upsert acc;

        //Get the locale tied to the quote account
        //account a = [select locale__c, locale__r.name, RecordTypeId from account where id  = :acc.id];

        return acc;
    }

    public static Contact createContact(Id accId){
        Contact con = new Contact();
        con.FirstName = 'john';
        con.LastName = 'galt' + String.valueOf(Datetime.now().getTime());   // 05/09/2019 bphan Add TimeStamp for uniqueness 
        con.AccountId = accId;
        con.MailingCity = 'New York';
        con.MailingCountry = 'United States';
        con.MailingStreet = 'Some Street';
        con.MailingPostalCode = '10082';
        con.MailingState = 'New York';
        con.Language__c = 'English';
        con.ELanguage__c = 'EN';

        insert con;
        return con;
    }

    public static void createLocalCrmCustomSetting() {
        List<LocalCRM__c> listLocalCrm = new List<LocalCRM__c>();
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'AU'
                ,   Country__c = 'AU - Australia'
                ,   Default_CRM__c = 'AUS - None'
                ,   Region__c = 'AUS'
        ));
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'GB'
                ,   Country__c = 'GB - United Kingdom'
                ,   Default_CRM__c = 'INT - InTouch'
                ,   Region__c = 'EUR'
        ));
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'US'
                ,   Country__c = 'US - United States'
                ,   Default_CRM__c = 'FUS - Fusion'
                ,   Region__c = 'AMR'
        ));
        listLocalCrm.add(new LocalCRM__c(
                    Name = 'ZA'
                ,   Country__c = 'ZA - South Africa'
                ,   Default_CRM__c = 'ENI - Enigma'
                ,   Region__c = 'AFR'
        ));
        Database.insert(listLocalCrm);
    }

    public static Locale__c createLocale(String country, String default_locale, String name, String Language) {
        // 05/09/2019 bphan  only create if not exist
       List<Locale__c> matches = new List<Locale__c>([SELECT Id, Country__c, Default_Locale__c, Name, Language__c FROM Locale__c
                                       WHERE Country__c =: country AND Default_Locale__c =: default_locale AND Name =:name AND Language__c =:Language]);
       Locale__c loc = new Locale__c();
       if (matches.size() == 0){
          loc.Country__c = country;
          loc.Default_Locale__c = default_locale;
          loc.Name = name;
          loc.Language__c = Language;
          loc.LanguageLocaleKey__c = 'en_US';
          insert loc;
       }
       else
       {
         for (Locale__c l:matches){
           loc = l;
           break;
        }
       }
      return loc;
    }

	public static Locale__c createLocaleGB() {
		Locale__c locale1 = new Locale__c(
			Name='en_GB',
			Basket_Name_Text__c= 'Your Order',
			LanguageLocaleKey__c= 'en_GB',
			BillingBatch__c= 'Batch2',
			Country__c= 'GB - United Kingdom',
			Currency_Symbol__c= '£',
			Default_Locale__c= 'Yes',
			Disclaimer_Header__c= 'Disclaimer',
			Language__c= 'English',
			Order_Total_Text__c= 'Order total:',
			Sub_Total_before_Tax__c= 'Subtotal before tax:',
			Tax_Text__c= 'Tax:',
			Total_footnote__c= 'incl. Tax',
			PayNow_EmailTemplateName__c= 'PayNow Complete',
			Commerce_PayNow_EmailTemplateName__c='Commerce PayNow Complete'
		);
		insert locale1;
		return locale1;
	}

	public static Locale__c createLocaleUS() {
		Locale__c locale1 = new Locale__c(
			Name='en_US',
			Basket_Name_Text__c= 'Your Order',
			LanguageLocaleKey__c= 'en_US',
			BillingBatch__c= 'Batch2',
			Country__c= 'US - United States',
			Currency_Symbol__c= '$',
			Default_Locale__c= 'Yes',
			Disclaimer_Header__c= 'Disclaimer',
			Language__c= 'English',
			Order_Total_Text__c= 'Order total:',
			Sub_Total_before_Tax__c= 'Subtotal before tax:',
			Tax_Text__c= 'Tax:',
			Total_footnote__c= 'incl. Tax',
			PayNow_EmailTemplateName__c= 'PayNow Complete',
			Commerce_PayNow_EmailTemplateName__c='Commerce PayNow Complete'
		);
		insert locale1;
		return locale1;
	}
}