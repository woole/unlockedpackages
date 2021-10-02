@isTest
public without sharing class opportunityTriggerHandlerTest{
    final static Integer OppPushCounter=10;

    @testsetup static void setup() {

        Account acc = new Account(Name = 'Opportunity Push Counter', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street');
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();

        for(Integer i=0;i<OppPushCounter;i++) {

            //Insert Opportunity
            //EAD-1084 Updated to include Why_We_Lost for Validation
            Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'OppPushCounter'+i, 
                                              StageName = Label.Opportunity_Sales_Stages_Stage1,
                                              //Why_We_Lost__c = 'No Reason Specified',
                                              CloseDate = Date.today(),Lead_Source__c = 'Marketing');
            oppList.add(opp);


        }
        insert oppList;
    }
    static testMethod void validateOPPCounterNewOpp() {

        Test.startTest();
        List<Opportunity> oppList = [select id,Push_Counter__c,closedate from Opportunity where Push_Counter__c=0];
        // For all Brand new Opportunities Push Counter is set to 0
        System.assertEquals(OppPushCounter, oppList.size());
        ShowLimits();
        Test.stopTest();

    }

static testMethod void OpportunityCloseDate() {

       Account acc = [ SELECT Id FROM Account WHERE Name = 'Opportunity Push Counter' ];

        List<Opportunity> oppList = new List<Opportunity>();
        
        List<RecordType> rtypes = [ SELECT Id
                                        , Name
                                    FROM RecordType
                                    WHERE sObjectType='Opportunity' 
                                     AND DeveloperName != 'Partner_Opportunity'
                                     AND isActive=true ];

        for(Integer i=0;i< rtypes.size();i++) {

            //Insert Opportunity
            //1084 Included Why We Lost reason for Validation
            Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'OppPushCounter'+i, 
                                              StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                              Why_We_Lost__c = 'Won from Competitor',
                                              recordtypeid = rtypes[i].id ,CloseDate = Date.today());
            oppList.add(opp);

        }
        insert oppList;

    }    


    static testMethod void validateOPPCounterMonthChange() {

        Test.startTest();
        List<Opportunity> oppList = [select id,Push_Counter__c,closedate from Opportunity];
        // For all opp add a month and check the push counter
        for(Opportunity opp : oppList)
        {
            opp.closedate=opp.closedate.addMonths(2);

        }
        update oppList;

        List<Opportunity> oppUpdateList = [select id,Push_Counter__c,closedate from Opportunity  where Push_Counter__c=1];
        System.assertEquals(OppPushCounter, oppUpdateList.size());
        ShowLimits();
        Test.stopTest();


    }

    static testMethod void validateOPPCounterYearChange() {

        Test.startTest();
        List<Opportunity> oppList = [select id,Push_Counter__c,closedate from Opportunity];
        // For all opp add a month and check the push counter
        for(Opportunity opp : oppList)
        {
            opp.closedate=opp.closedate.addYears(1);

        }
        update oppList;

        List<Opportunity> oppUpdateList = [select id,Push_Counter__c,closedate from Opportunity  where Push_Counter__c=1];
        System.assertEquals(OppPushCounter, oppUpdateList.size());
        ShowLimits();
        Test.stopTest();


    }

    static testMethod void validateOPPCounterMonthYearChange() {

        Test.startTest();
        List<Opportunity> oppList = [select id,Push_Counter__c,closedate from Opportunity];
        // For all opp add a month and check the push counter
        for(Opportunity opp : oppList)
        {
            opp.closedate=opp.closedate.addYears(1);

        }
        update oppList; // Push Counter will increment from 0 to 1

        oppList = [select id,Push_Counter__c,closedate from Opportunity];
        for(Opportunity opp : oppList)
        {
            opp.closedate=opp.closedate.addMonths(1);

        }
        update oppList; // Push Counter will increment from 1 to 2

        List<Opportunity> oppUpdateList = [select id,Push_Counter__c,closedate from Opportunity  where Push_Counter__c=2];
        System.assertEquals(OppPushCounter, oppUpdateList.size());
        ShowLimits();
        Test.stopTest();


    }


    // REMOVED BELOW METHOD TO REMOVE SUCCESS PLAN AND Zuora Quote Dependency for SFDX Migtation
    // FUTUTRE WORK REQUIRED TO REMOVE DEPENDENCIES USING SERVICE FRAMEWORK
    /*public static testMethod void INC0421888(){
        Test.startTest();
        Account accnt = new Account();
        accnt.Existing_Salesforce_User__c = 'Yes';
        accnt.Name = 'accnt.Name';
        insert accnt;
        Opportunity opportunty = new Opportunity();
        opportunty.AccountId = accnt.Id;
        opportunty.Name = 'opportunty.Name';
        opportunty.StageName = Label.Opportunity_Sales_Stages_Stage1;
        opportunty.CloseDate = system.today();
        insert opportunty;
        Success_Plan__c successPlan = new Success_Plan__c();
        successPlan.Account__c = accnt.Id;
        successPlan.Opportunity__c = opportunty.Id;
        insert successPlan;
        zqu__Quote__c zquQuote = new zqu__Quote__c();
        zquQuote.zqu__Opportunity__c = opportunty.Id;
        zquQuote.zqu__Status__c = 'Sent to Z-Billing';
        insert zquQuote;
        Opportunity opportnity = new Opportunity();
        opportnity = [SELECT Id FROM Opportunity WHERE Id =: opportunty.Id];
        opportnity.StageName = Label.Opportunity_Sales_Stages_Closed_Won;
        //EAD-1084 Updated to Include Why We Lost for Validation
        opportnity.Why_We_Lost__c = 'No Reason Specified';
        update opportnity;
        system.assertNotEquals(null, successPlan.Id);
        system.assertEquals(0, [SELECT Id FROM Case WHERE Success_Plan__c =: successPlan.Id].size());
        Test.stopTest();
    }*/

    private static void ShowLimits() {
        system.debug(LoggingLevel.info, 'SOQL count ' + limits.getQueries());
        system.debug(LoggingLevel.info, 'SOQL rows ' + limits.getQueryRows());
        system.debug(LoggingLevel.info, 'Heap size ' + limits.getHeapSize());
        system.debug(LoggingLevel.info, 'Heap size ' + limits.getCpuTime());

    }

    /*
    @description    test method to validate mass assignment of owners to opportunities via list views.
     */
    public static testMethod void test_massUpdateOppOwner() {

        List<Opportunity> opptys = [
                SELECT Id,
                        TransferTo__c,
                        OwnerId
                FROM Opportunity
                WHERE CreatedDate = TODAY
        ];

        List<user> ccoreUser = [
                SELECT Id
                FROM User
                WHERE Profile.Name = :Label.Profile_SageUKISalesStandardUser
                AND IsActive = TRUE
                LIMIT 1
        ];

        List<user> adminUsers = [
                SELECT Id
                FROM User
                WHERE Profile.Name = :Label.Profile_SystemAdministrator
                AND IsActive = TRUE
                LIMIT 1
        ];
        if (!ccoreUser.isEmpty()) {
            System.runAs(ccoreUser[0]) {
                    Test.startTest();
                if (!opptys.isEmpty()) {
                    for (Opportunity opp : opptys) {
                        opp.TransferTo__c = adminUsers[0].id;
                    }

                    update opptys;

                    opptys = [
                            SELECT Id,
                                    TransferTo__c,
                                    OwnerId
                            FROM Opportunity
                            WHERE CreatedDate = TODAY
                    ];

                    //validating the owner Ids
                    for (Opportunity opp : opptys) {
                        System.assertEquals(opp.OwnerId, adminUsers[0].id);
                        System.assert(String.isBlank(opp.TransferTo__c));
                    }
                } else {
                    System.assert(false, 'No opportunities found. Something has gone wrong with test data creation');
                }
            } 
            Test.stopTest();                
        }
    }


    static testMethod void validateOPPRejectionEmailNotification() {

        Test.startTest();
        List<Opportunity> oppList = [select id,StageName, why_we_lost__c  from Opportunity ];
        // For all opp add a month and check the push counter
        for(Opportunity opp : oppList)
        {
            opp.StageName=Label.Opportunity_Sales_Stages_Stage1;

        }
        update oppList;
        oppList = [select id,StageName from Opportunity ];

        for(Opportunity opp : oppList)
        {

            opp.StageName='Closed Lost';
            opp.why_we_lost__c='Lost from Competitor';

        }
        update oppList;
         Test.stopTest();

    }

 static testMethod void OpportunityCloseDateTest() {
        
        Test.startTest();
        Account acc = new Account(Name = 'Opp', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100001))+Datetime.now().millisecond()));
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Opportunity' and isActive=true];
        Map<String,String> OppRecordTypes = new Map<String,String>{};
      
      for(RecordType rt: rtypes)
        OppRecordTypes.put(rt.Name,rt.Id);

        
        Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opptest', 
                                              StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                              recordtypeid = oppRecordTypes.get(Label.OPP_RT_MED_ALTIFY) ,CloseDate = Date.today()+10);
        oppList.add(opp);
     
        Opportunity Opp1 = new Opportunity(AccountId = acc.Id, name = 'Opptest1', 
                                              StageName = Label.Opportunity_Sales_Stages_Stage1,Is_Converted__c=true, 
                                              recordtypeid = oppRecordTypes.get(Label.OPP_RT_MED_ALTIFY) ,CloseDate = Date.today()+10);
        oppList.add(opp1);

       
        insert oppList;
        Test.stopTest();
        List<Opportunity> oppListtest = [select id,name,CloseDate from opportunity where  name='Opptest1' OR name='Opptest'];
     
     for(Opportunity o :oppListtest){
         
         if(o.Name=='Opptest'){system.assertEquals(o.CloseDate , Date.today());}
         if(o.Name=='Opptest1'){system.assertEquals(o.CloseDate , Date.today()+270);}
         
     }
   
    }
  static testMethod void OpportunityCloseDateVolumeOppTest() {
        
        Test.startTest();
        Account acc = new Account(Name = 'Opp', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100002))+Datetime.now().millisecond()));
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Opportunity' and isActive=true];
        Map<String,String> OppRecordTypes = new Map<String,String>{};
      
      for(RecordType rt: rtypes)
        OppRecordTypes.put(rt.Name,rt.Id);

        
        Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opptest', 
                                              StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                              recordtypeid = oppRecordTypes.get(Label.OPP_RT_SMALL) ,CloseDate = Date.today()+10);
        oppList.add(opp);
     
        Opportunity Opp1 = new Opportunity(AccountId = acc.Id, name = 'Opptest1', 
                                              StageName = Label.Opportunity_Sales_Stages_Stage1,Is_Converted__c=true, 
                                              recordtypeid = oppRecordTypes.get('Small Opportunity') ,CloseDate = Date.today()+10);
        oppList.add(opp1);

       
        insert oppList;
        Test.stopTest();
        List<Opportunity> oppListtest = [select id,name,CloseDate from opportunity where  name='Opptest1' OR name='Opptest'];
     
     for(Opportunity o :oppListtest){
         
         if(o.Name=='Opptest'){system.assertEquals(o.CloseDate , Date.today());}
         if(o.Name=='Opptest1'){system.assertEquals(o.CloseDate , Date.today()+30);}
         
     }
   
    }  
  static testMethod void OpportunityCloseDateStandardOppTest() {
        
        Test.startTest();
        Account acc = new Account(Name = 'Opp', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Opportunity' and isActive=true];
        Map<String,String> OppRecordTypes = new Map<String,String>{};
      
      for(RecordType rt: rtypes)
        OppRecordTypes.put(rt.Name,rt.Id);

        
        Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opptest', 
                                              StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                              recordtypeid = oppRecordTypes.get(Label.OPP_RT_MED_STANDARD) ,CloseDate = Date.today()+10);
        oppList.add(opp);
     
        Opportunity Opp1 = new Opportunity(AccountId = acc.Id, name = 'Opptest1', 
                                              StageName = Label.Opportunity_Sales_Stages_Stage1,Is_Converted__c=true, 
                                              recordtypeid = oppRecordTypes.get(Label.OPP_RT_MED_STANDARD) ,CloseDate = Date.today()+10);
        oppList.add(opp1);

       
        insert oppList;
        Test.stopTest();
        List<Opportunity> oppListtest = [select id,name,CloseDate from opportunity where  name='Opptest1' OR name='Opptest'];
     
     for(Opportunity o :oppListtest){
         
         if(o.Name=='Opptest'){system.assertEquals(o.CloseDate , Date.today());}
         if(o.Name=='Opptest1'){system.assertEquals(o.CloseDate , Date.today()+45);}
         
     }
   
    }  
    
    
    static testMethod void OpportunityCloseDateCloseWon_lost() {
        
        Test.startTest();
        Account acc = new Account(Name = 'Opp', Sales_Office__c='Dublin CBC',Type = 'Customer', Industry = 'Automotive',BillingCountry='United Kingdom',BillingCity='Alphareeta',BillingStreet='street',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100004))+Datetime.now().millisecond()));
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Opportunity' and isActive=true];

        for(Integer i=0;i< rtypes.size();i++) {

            //Insert Opportunity
            Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opp'+i, 
                                              StageName = Label.Opportunity_Sales_Stages_Closed_Won, 
                                              recordtypeid = rtypes[i].id ,CloseDate = Date.today()+1);
            oppList.add(opp);

        }
       insert oppList;
       Test.stopTest();
        
       List<Opportunity> oppListtest = [select id,name,CloseDate from opportunity where StageName ='Closed Won'];
       system.assertEquals(oppListtest[0].CloseDate , Date.today());

    }

    static testMethod void populateTypeUponLeadConversion() {
         Test.startTest();
        Account acc = new Account(Name = 'OppAcc',Type = 'Customer', Industry = 'test',BillingCountry='United Kingdom',BillingCity='Test',BillingStreet='TestStrret',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100000))+Datetime.now().millisecond()));
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Opportunity' and isActive=true];

      for(Integer i=0;i< rtypes.size();i++) {
        //Insert Opportunity
        
        Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'Opp'+i, StageName = Label.Opportunity_Sales_Stages_Closed_Won, recordtypeid = rtypes[i].id ,CloseDate = Date.today(), Type='',Opportunity_Type__c='Migration');
        oppList.add(opp);
      }
      insert oppList;    
      Test.stopTest();
    }

}