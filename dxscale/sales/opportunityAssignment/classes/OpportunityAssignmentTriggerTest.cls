/*
 * OpportunityAssignmentTriggerTest
 * Tests the OpportunityAssignmentTrigger and its helper class
 */
@IsTest
public class OpportunityAssignmentTriggerTest {
    @TestSetup
    static void dataSetup() {
      Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(Alias='usera',
                           Email='a@aaa.com',
                           EmailEncodingKey='ISO-8859-1',
                           FirstName='aaa',
                           LastName='aaa',
                           LanguageLocaleKey='en_US',
                           LocaleSidKey='en_GB',
                           ProfileId=p1.Id,
                           TimeZoneSidKey='Europe/London',
                           CommunityNickname = 'aaa',
                           IsActive=true,
                           Username='a@aaa.com.sage');
        insert u1;
        User u2 = new User(Alias='userb',
                           Email='b@bbb.com',
                           EmailEncodingKey='ISO-8859-1',
                           FirstName='bbb',
                           LastName='bbb',
                           LanguageLocaleKey='en_US',
                           LocaleSidKey='en_GB',
                           ProfileId=p1.Id,
                           TimeZoneSidKey='Europe/London',
                           CommunityNickname = 'bbb',
                           IsActive=true,
                           Username='b@bbb.com.sage');
        insert u2;
        Account acc = new Account(Name='testAccount',
                                  Type='Customer',
                                  BillingCountry='United Kingdom',
                                  BillingCity='Blyth',
                                  BillingStreet='Any Street');
        insert acc;
        RecordType rt = [SELECT Id FROM RecordType WHERE Name =:Label.OPP_RT_MED_STANDARD];
        // 10 Opportunities as 201 was breaking CPU limits
        // The 10th has no Lead_Source__c but can be inserted because the validation rule on this field is bypassed via missing custom setting
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i=0; i<10; i++) {
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'TestOpp_' + i;
            opp.StageName = 'Qualification';
            opp.CloseDate = System.today() - 2;  // 06/12/2020 bphan EAD-1539
            opp.RecordTypeId = rt.Id;
            opp.OwnerId = u1.Id;
            if (i<9) { opp.Lead_Source__c = 'Marketing'; }
            oppList.add(opp);
        } 
        insert oppList;
    }
    
    @IsTest
    static void testOpportunityAssignment() {       
        System.debug('OpportunityAssignmentTriggerTest: testOpportunityAssignment START');
        // Retrieve test data
        List<Opportunity> oppIds = [SELECT Id FROM Opportunity];
        User assignee = [SELECT Id FROM User WHERE Alias='userb'][0];       
        // Switch on validation rules which have the bypass setting to catch Opportunity errors
        OpportunityControlSwitch__c setting = new OpportunityControlSwitch__c ();
		setting.Name = 'VR';
		setting.RunValidationRules__c = true;
		insert setting;
        
        Test.startTest();
        List<Opportunity_Assignment__c> oaList = new List<Opportunity_Assignment__c>();
        // 10 opportunity assignments (though one should fail validation on save due to empty Lead_Source__c field)
        for (Integer i=0; i<9; i++) {
            Opportunity_Assignment__c oa = new Opportunity_Assignment__c();
            oa.Opportunity__c = oppIds[i].Id;
            oa.Assignee__c = assignee.Id;
            //06/12/2020 bphan EAD_1539
            oa.CloseDate__c = System.today();
            oa.Amount_ACV__c = 100;
            oa.Annual_Sales_Booking_ASB__c = 100;
            oa.Channel_Type__c = 'Direct';
            //oa.CurrencyIsoCode = 'USD';
            oa.Opportunity_Name__c = 'OppAss ' + i;
            oa.Contract_Due_Date_For_Renewal__c = System.today() + 10;
            oa.Pain_Points_w_Current_Solution__c = 'OppAss painpoint solution' + i;
            oa.Discovery_Notes__c = 'OppAss notes ' + i;
            oa.Stage__c = Label.Opportunity_Sales_Stages_Closed_Won;
            oa.Total_Contract_Value_TCV_forecast__c = 200;
            oa.Win_Loss_Other_Reason__c = 'OppAss win loss reason ' + i;
            oa.Why_We_Lost__c = 'Won from Competitor';
            oa.Win_Loss_Reject_Reasons_Level1__c = '';
            oa.Win_Loss_Reject_Reasons_Level2__c = '';
            oa.Win_Loss_Reject_Reasons_Level3__c = '';   
            oa.Renewal_BillingPeriod__c  = 'Quarterly';
            oa.Renewal_Yearlyvaluebeingrenewed__c = '1 year';
            oa.Renewal_Status__c = 'Paid';
            oa.Renewal_PromisePaiddate__c = Date.today();
            oa.Renewal_InterventionDate__c = Date.today();
            oa.Renewal_FirstBillingDate__c = Date.today();
            oa.Renewal_Billingfilefullvalue__c =10;
             
            if (i<9) { oa.Lead_Source__c = 'Marketplace'; }

            oaList.add(oa);
        }
        // Add a duplicate Opportunity update
        Opportunity_Assignment__c oad = new Opportunity_Assignment__c(); 
        oad.Opportunity__c = oppIds[0].Id;
        oad.Assignee__c = assignee.Id;
        oaList.add(oad);
        
        // Inserting the Opportunity_Assignment__c objects should fire the associated trigger
        insert oaList;   
        // Ensure trigger completed (and hopefully the batch)
        Test.stopTest();
        
        // Check only the good Opportunities changed owner
        Integer goodOpps = [SELECT COUNT() 
                            FROM Opportunity
                            WHERE OwnerId = :assignee.Id];
        System.debug('OpportunityAssignmentTriggerTest: Good Opps');
        System.assertEquals(9, goodOpps);
        // Check all of the Opportunity Assignments changed status appropriately
        Integer retOAs = [SELECT COUNT()  
                          FROM Opportunity_Assignment__c
                          WHERE Status__c = 'Success'];
        System.debug('OpportunityAssignmentTriggerTest: Success');
        System.assertEquals(9, retOAs);
        Integer retOAs2 = [SELECT COUNT()  
                          FROM Opportunity_Assignment__c
                          WHERE Status__c = 'Fail'];
         System.debug('OpportunityAssignmentTriggerTest: Fail');                     
        System.assertEquals(0, retOAs2);
        Integer retOAs3 = [SELECT COUNT()  
                           FROM Opportunity_Assignment__c
                           WHERE Status__c = 'Duplicate'];
        System.debug('OpportunityAssignmentTriggerTest: Duplicate');
        System.assertEquals(1, retOAs3);
        System.debug('OpportunityAssignmentTriggerTest: testOpportunityAssignment FINISH');
    }
}