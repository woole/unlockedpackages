public class OpportunityTriggerHandler {
    public static Boolean isFirstTimeRun = true;
    static string CLASSNAME = 'OpportunityTriggerHandler';

    //Opportunity closed date has been pushed forward to future month/year, counter should be incremented
    public  static void OpportunityPushCounter(Map<ID, Opportunity> oldOppMap, List<Opportunity> newOppList){
         Date dNewCloseDate;
         Date dOldCloseDate;

         for(Opportunity opp : newOppList){
              if(oldOppMap != null && opp.closedate!=null && oldOppMap.get(opp.id).closedate!=null && (oldOppMap.get(opp.id).closedate < opp.closedate) ){
                 dNewCloseDate=opp.CloseDate; // get the new closedate 
                 dOldCloseDate=oldOppMap.get(opp.id).closedate;//get the old closedate for this opportunity
                   if( ( dOldCloseDate.month()<dNewCloseDate.month() ) ||
                       ( dOldCloseDate.year()<dNewCloseDate.year()   ) ){// the month number is higher, it's been pushed out
                                opp.Push_Counter__c=(opp.Push_Counter__c!=null)?(opp.Push_Counter__c+1):1;
                   }


              }

        }

    }
    
    public  static void OpportunityCloseDateCloseWon_lost(Map<ID, Opportunity> oldOppMap, List<Opportunity> newOppList){
        try{ 
            for(Opportunity opp : newOppList){
                                  
                  if((opp.StageName=='Closed Won' || opp.StageName=='Closed Lost' || opp.StageName=='Rejected')&& opp.StageName!=oldOppMap.get(opp.id).StageName){
                      opp.CloseDate = date.today();
                                        }                
                
            }
        
        
          } catch(Exception e){
            System.debug('Exception while in OpportunityCloseDateCloseWon_lost Tigger Handler '+e.getStackTraceString() );
        }
        
    }
    
    
      // Added as part of CCORE-1383 27-02-2019  by KIRAN MOOTA
      // Updated as the part of CCORE-2089 
     public static void OpportunityCloseDate(List<Opportunity> newOppList){
         
             
         try{
           
                for(Opportunity opp : newOppList){
                    
                    Boolean flag = false;
                    
                  if(opp.StageName=='Closed Won' || opp.StageName=='Closed Lost' || opp.StageName=='Rejected'){
                      opp.CloseDate = date.today();
                      flag=true;
                  }
                                       
                    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
                    String recordTypeName = opp.RecordTypeId != null?rtMap.get(opp.RecordTypeId).getName():'';
                            
                   if(opp.Is_Converted__c==true && flag==false){ // opportunity created from lead conversion.
                       
                     if(recordTypeName == Label.OPP_RT_MED_ALTIFY){

                                    opp.CloseDate = date.today() +270;
                                   
                                }

                              if(recordTypeName == Label.OPP_RT_MED_STANDARD){

                                    opp.CloseDate = date.today() +45;
                                    

                                }

                                if(recordTypeName == Label.OPP_RT_SMALL){

                                    opp.CloseDate = date.today() +30;
                                    System.debug('opp.CloseDate '+opp.CloseDate);
                                   

                                }
               
                    } }
         
                     


        } catch(Exception e){
            System.debug('Exception while in Close Date Tigger Handler '+e.getStackTraceString() );
        }
         

    }


    //CCORE-1202
    /**
     * @description method to change the owner of opportunities from within list view. This method is designed to be
     * used only in Before Update event call
     *
     * @param newOpps   list of new trigger records
     * @param oldMap    old map of trigger records
     */
    public static void massUpdateOppOwner(LIst<Opportunity> newOpps, Map<Id, Opportunity> oldMap){

        for (Opportunity opp : newOpps){
            //entry criteria
            if (String.isNotBlank(opp.TransferTo__c) //transfer to should be populated
                    //record type should be 'Small Opportunity'
                    //Transfer To look-up should be genuinely changed
                    && opp.TransferTo__c != oldMap.get(opp.Id).TransferTo__c){

                //stamping the new owner from the 'Transfer To' field and clearing the values on the 'Transfer To' field
                opp.OwnerId = opp.TransferTo__c;
                opp.TransferTo__c = null;
            }
        }

       //CCORE-1416    
       //Next Steps Starts            
       for (opportunity opp:newOpps){   
           if(opp.Next_Steps__c != Null){   
            opp.NS_Last_Update_Time__c = opp.LastModifiedDate;   
           }    
           else{   
             opp.NS_Last_Update_Time__c = null;   
           }   
       }   
       //Next Steps Ends   
    }
    
    //Next Steps Starts     
    //CCORE-1416  ::  Move Process Builder (Opp_NS_Last_Update) to Opp Trigger     
    public static void updatesNextSteps(LIst<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {     
        for (opportunity opp : newOpps) {     
            if (String.isNotBlank(opp.Next_Steps__c) && opp.Next_Steps__c != oldMap.get(opp.Id).Next_Steps__c) {     
                opp.NS_Last_Update_Time__c = opp.LastModifiedDate;     
            }     
        }           
         
    }     
    //Next Steps Ends     

    // EAD-2102 Replaced by method in OpportunityLineHandlerTriggerHelper class
	// public static void populateProductNamesOnOpportunity(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {  

    //CCORE-1418
    /**
     * @description method to send Email the CreatedBy Opportunity User and manager of opportunities after the update on the Opportunity
     *
     * @param newOpps   list of new trigger records
     * @param oldMap    old map of trigger records
     */
    public static void rejectedOppNotifications(LIst<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        try {
            LogControl.push('rejectedOppNotifications', CLASSNAME);
            List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
            List<Opportunity> oppList = [
                    select Id, Name, Owner.Name, Owner.Email, ownerid, 
                            Owner.Manager.Email,
                            Owner.Manager.isActive,
                            CreatedBy.name,
                            CreatedBy.email,
                            StageName,
                            Why_We_Lost__c,
                            CreatedBy.manager.email,
                            CreatedBy.manager.name
                    from opportunity
                    where id = :trigger.newMap.keySet()
            ];
            for (Opportunity opp : oppList) {
                if (String.isNotBlank(opp.StageName)
                        && opp.StageName != oldMap.get(opp.Id).StageName
                        && opp.StageName == Label.Opportunity_Sales_Stages_Stage6
                        && oldMap.get(opp.Id).StageName == Label.Opportunity_Sales_Stages_Stage1) {


                    String fullOppRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
                    String leadOwnerEmail = opp.CreatedBy.email;
                    String oppOwnerName = opp.Owner.Name;
                    String oppOwnerEmail = opp.Owner.Email;
                    system.debug('oppOwnerEmail' + oppOwnerEmail);
                    String leadOwnerMangerEmail = opp.CreatedBy.manager.email;
                    String oppOwnerManagerEmail = opp.Owner.Manager.Email;


                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> toAddresses = new List<String>();
                    if (String.isNotBlank(leadOwnerEmail)) {
                        toAddresses.add(leadOwnerEmail);
                    }
                    if (String.isNotBlank(leadOwnerMangerEmail)) {
                        toAddresses.add(leadOwnerMangerEmail);
                    }
                    if (String.isNotBlank(oppOwnerEmail)) {
                        toAddresses.add(oppOwnerEmail);
                    }
                    if (String.isNotBlank(oppOwnerManagerEmail) && opp.Owner.Manager.isActive) {
                        toAddresses.add(oppOwnerManagerEmail);
                    }
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Automated email: Opportunity has been Rejected.');

                    String strHtmlBody = 'Below Opportunity has been rejected  <br/><br/>';
                    strHtmlBody = strHtmlBody + '<b>Opportunity Name :</b>' + opp.name + '<br/>';
                    strHtmlBody = strHtmlBody + '<b>Rejected Reason  :</b>' + opp.Why_We_Lost__c + '<br/>';
                    strHtmlBody = strHtmlBody + '<b>Rejected By      :</b>' + oppOwnerName + '<br/><br/>';
                    strHtmlBody += 'Here’s the link to opportunity ' + fullOppRecordURL;

                    mail.setHtmlBody(strHtmlBody);

                    allEmails.add(mail);

                }
            }
            if(!allEmails.isEmpty()){
            Messaging.sendEmail(allEmails);
            }

        } catch (Exception e) {
            LogControl.debugException(e);
        } finally {
            LogControl.pop();
        }
    }
public static void populateCreatedByRole(LIst<Opportunity> newOpps) {
        //populate Created by role field when the Opportunity record is created
        Set<Id> roleIds = new Set<Id>();
        try{
            LogControl.push('populateCreatedByRole', CLASSNAME);
            for(Opportunity opp : newOpps){
                roleIds.add(UserInfo.getUserRoleId());
            }
            Map<Id, UserRole> rolesMap = new Map<Id,UserRole>(
                [SELECT ID, Name FROM USerRole WHERE Id IN :roleIds]);
            for(Opportunity opp : newOpps){
                opp.CreatedByRole__c = rolesMap.get(userinfo.getUserRoleId())!=null?rolesMap.get(userinfo.getUserRoleId()).Name:null;
            }
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        }
    }
    
    public static void populateOpportunityFieldsOnLeadConversion(List<Opportunity> listNewOpportunity){
        //Populate Type field on Opportunity with Opportunity_Type__c field value on Lead upon Lead Conversion to Opportunity.
        // EAD-1998
        String volumeOppRtId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Volume_Opportunity').getRecordTypeId();
        String partnerOppRtId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        for(Opportunity eachOpportunity :listNewOpportunity) {
            if(eachOpportunity.Opportunity_Type__c != null && eachOpportunity.Type == null) {
                eachOpportunity.Type = eachOpportunity.Opportunity_Type__c;
            }

            if (volumeOppRtId.equals(eachOpportunity.recordTypeId) && eachOpportunity.CreatedByFlow__c=='Regular') {
                eachOpportunity.CreatedByFlow__c = 'Standard';
            }
            if (eachOpportunity.Is_Converted__c) {
                if (partnerOppRtId.equals(eachOpportunity.recordTypeId)) {
                    eachOpportunity.Name = !eachOpportunity.Name.startsWithIgnoreCase('Recruitment - ') ? 'Recruitment - ' + eachOpportunity.Name : eachOpportunity.Name;
                }
                eachOpportunity.CreatedByFlow__c = 'Lead';
            }   
        }
    }
}