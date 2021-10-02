@isTest
public class OnboardingSuccessGoals_Test {
    public static String ObjName = 'Opportunity';
    @isTest
    public static void getAllSuccessGoalsTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User userWithCustomPermission  = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='onboardingsuccessgoals@testorg.com');
        insert userWithCustomPermission;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Sage_Global_Sales_Admin'];
        insert new PermissionSetAssignment(AssigneeId = userWithCustomPermission.id, PermissionSetId = ps.Id);

        System.runAs(userWithCustomPermission){
            OnboardingSuccessGoals.getAllSuccessGoals();
            OnboardingSuccessGoals.getAllOnboardingScores();
            Account acc=new Account();
            acc.Name='Test Acc';
            acc.Type='Partner';
            acc.Phone='1234567890';
            insert acc;

            Opportunity opp=new Opportunity();
            opp.Name='Test';
            opp.AccountId=acc.Id;
            opp.Type='Upsell';
            opp.StageName='Discovery';
            opp.CloseDate=Date.newInstance(2021, 12, 31);
            opp.Lead_Source__c='Marketing';
            opp.Country__c='France';
            insert opp;

            String oppId=opp.Id;
            List<String> Goals=new List<String>();
            Goals.add('Saving time');
            String otherGoal='Other';
            String onboardingScore='Amber';
            Test.startTest();
            OnboardingSuccessGoals.updateRecord(oppId,onboardingScore, Goals, Goals,otherGoal);
            List<String> storedGoals=OnboardingSuccessGoals.getStoredEngagements(oppId);
            OnboardingSuccessGoals.getStoredFinalEngagements(oppId);
            OnboardingSuccessGoals.getStoredOtherGoals(oppId);
            OnboardingSuccessGoals.getStoredOnboardingScore(oppId);
            System.assert(storedGoals!=null);
            Test.stopTest();
        }
    }
}