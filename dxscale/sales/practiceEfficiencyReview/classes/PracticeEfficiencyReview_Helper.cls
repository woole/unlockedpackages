/**
 * @description PracticeEfficiencyReview Helper is a helper class that performs a variety of field level checking and manipulated based on Contact data
 * Contains all the GLOBAL related logics
 * Use PracticeEfficiencyReview_ValidationRules for any REGIONAL related rules
 */

public inherited sharing class PracticeEfficiencyReview_Helper {
  static String CLASSNAME = 'PracticeEfficiencyReview_Helper';
    /**
     * @description: PopulateFieldsFromAccount
     * @param: List of trigger new PracticeEfficiencyReview
     * @param: Map of trigger old PracticeEfficiencyReview
    **/
    public static void PopulateFieldsFromAccount (List<PracticeEfficiencyReviewV2__c> PERS) {
        try {
            LogControl.push('PopulateFieldsFromAccount', CLASSNAME);
            Set<Id> practiceNames = new Set<Id>();
            for (PracticeEfficiencyReviewV2__c per : PERS) {
                practiceNames.add(per.PracticeName__c);
            }
            Map<Id, Account> acctMap = new Map<Id, Account>([SELECT ID, Name, Local_CRM_AccountID__c, BillingCity, BillingCountry, BillingPostalCode FROM Account WHERE ID IN :practiceNames]);            
            String quarter;
            String fiscalyear;
            for (PracticeEfficiencyReviewV2__c per : PERS) {
                if (acctMap != null && acctMap.get(per.PracticeName__c) != null) {  
                    // BeforeInsert trigger -> created DATE = System.Today()
                    date crDt = System.Today();
                                 
                    per.LocalCRMAccountID__c =  acctMap.get(per.PracticeName__c).Local_CRM_AccountID__c;
                    per.BillingCity__c =  acctMap.get(per.PracticeName__c).BillingCity;
                    per.BillingCountry__c =  acctMap.get(per.PracticeName__c).BillingCountry;
                    per.BillingPostalCode__c =  acctMap.get(per.PracticeName__c).BillingPostalCode; 
                    
                    // Pre-populate the Review Title with the Account Name, the Year Half and the Finacial Year.  Eg. ABCAccountants_H1_FY21
	   		   		// Date Created is between 1st October and 31st March = H1
					// Date Created is between 1st April and 30th September = H2
					// Date Created is between 1st October 2020 - 30th September 2021 = FY21
					// Date Created is between 1st October 2021 - 30th September 2022 = FY22
			        IF ((crDt > date.newInstance(crDt.year(), 01, 01)) &&  
              	        (date.valueOf(crDt) <= date.newInstance(crDt.year(), 03, 31))) {
       						quarter = 'H1';
              				fiscalyear = string.valueOf(crDt.year());
          			}ELSE IF ((date.valueOf(crDt) > date.newInstance(crDt.year(), 03, 31)) &&  
                    	      (date.valueOf(crDt) <= date.newInstance(crDt.year(), 09, 30))) {
   							quarter = 'H2';
                        	fiscalyear = string.valueOf(crDt.year());                      
          			}ELSE{                        
      						quarter = 'H1';
                        	fiscalyear = string.valueOf(crDt.year() + 1);                  
          			}
                    per.ReviewTitle__c = acctMap.get(per.PracticeName__c).Name.left(42) + '_' + quarter + '_' + fiscalyear;  //Review Title
                }
            }  
        } catch (Exception e) { LogControl.debugException(e);
        } finally { LogControl.pop(); 
        }
	}
    
}