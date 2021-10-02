/*
 * Map the Account Billing Country or shipping Country to Opportunity.Country
 * Created by: Adam Annony
 */
public inherited sharing class MapAccountCountryToOppCountry {
    public void mapAccCtryToOppCtry(List<Opportunity> opps){
        Set<Id> accIds = new Set<Id>();
        Set<Id> ownIds = new Set<Id>();
        Map<Id, Account> accountMap ;
        Map<Id, User> ownerMap;
        for(Opportunity op :opps){
            accIds.add(op.AccountId);
            ownIds.add(op.OwnerId);
        }
        if(accIds.size() > 0){
            accountMap = new Map<Id, Account>([SELECT Id, Name, BillingCountry, ShippingCountry FROM Account WHERE Id IN :accIds WITH SECURITY_ENFORCED]);  
        }
        if(ownIds.size() > 0){
            ownerMap = new Map<Id, User>([SELECT Id, Country FROM User WHERE Id IN :ownIds WITH SECURITY_ENFORCED]);
        }
        for(Opportunity o :opps){
            String accBillingCtry = o.AccountId!=null&&accountMap.get(o.AccountId)!=null?accountMap.get(o.AccountId).BillingCountry:null;
            String accShippingCtry = o.AccountId!=null&&accountMap.get(o.AccountId)!=null?accountMap.get(o.AccountId).ShippingCountry:null;     
            if(accBillingCtry != null && o.Country__c != accBillingCtry){
                o.Country__c  = accBillingCtry;
            } else if(accBillingCtry == null && accShippingCtry != null){
                o.Country__c  = accShippingCtry;
            }
            else if(accBillingCtry != null && accShippingCtry != null && o.Country__c != accBillingCtry && o.Country__c != accShippingCtry){
                String ownerCountry = o.OwnerId!=null&&ownerMap.get(o.OwnerId)!=null?ownerMap.get(o.OwnerId).Country:null;
                o.Country__c = ownerCountry;
            }
        }
    }
    
   public void updateRegionOnOpportunity(Map<ID,Opportunity> oldOppMap,List<Opportunity> newOppList)
    {
        Map<String,String> crMap = new Map<String,String>();
        List<CountryMapping__mdt> clList = [select Sage_Region__c ,CountryName__c from CountryMapping__mdt WHERE CountryName__c!=null AND Sage_Region__c!=null WITH SECURITY_ENFORCED];
        for (CountryMapping__mdt cl : clList) {
            crMap.put(cl.CountryName__c,cl.Sage_Region__c);
        }
        for(Opportunity opp: newOppList) {
            if((opp.Country__c!=null)||(oldOppMap!=null && oldOppMap.get(opp.id)!=null && oldOppMap.get(opp.id).Country__c!=opp.Country__c)) {
                opp.Sage_Region__c=(crMap.get(opp.Country__c)!=null)?crMap.get(opp.Country__c):'Other'; 
                opp.Region__c=(crMap.get(opp.Country__c)!=null)?crMap.get(opp.Country__c):'Other'; 
            }
        }
    }
    
   //EAD-266 
   public void oppsWithQuotes(Map<ID,Opportunity> oldOppMap,List<Opportunity> newOppList, Map<ID,Opportunity> newOppMap) {
        Set<String> oppIds = new Set<String>();
        for(Opportunity opp : newOppList) {
            if(oldOppMap != null && oldOppMap.get(opp.Id)!=null && oldOppMap.get(opp.Id).AccountId != opp.AccountId){
                //collect all the opportunity Ids where the Account is changed
                oppIds.add(opp.Id);
            }
        }
        //Retrieve Quotes for each Opp which are sent ot Z-billing
        // Running outside testing context this required to be fixed using service framework or seperate package
        if (!Test.isRunningTest()) {
            List<SObject> lQuote = (List<SObject>) Database.query( ' SELECT Id, zqu__Opportunity__c FROM zqu__Quote__c '
                                                   + ' WHERE zqu__Status__c = \'Sent to Z-Billing\' '
                                                        + ' AND zqu__Opportunity__c IN :oppIds WITH SECURITY_ENFORCED');
            for (SObject eachQuote :lQuote) {
                newOppMap.get((Id) eachQuote.get('zqu__Opportunity__c')).addError(Label.AccountChangeError);
            }
        }
    }
    
    //EAD - 430 update to ACV/TCV process on Opportunity.
    public void updateTCV(List<Opportunity> newOppList)
    {
        for(Opportunity opp : newOppList)
        {
            if(opp.Amount == null){
            	opp.Amount = 0;    
            }
            if(opp.Total_Contract_Value_TCV_forecast__c == null){
                opp.Total_Contract_Value_TCV_forecast__c = 0;  
            }
            if(opp.Annual_recurring_ACV_rollup__c > 0){
            	opp.Amount_ACV__c = opp.Annual_recurring_ACV_rollup__c;
            }
            if(opp.Total_Contract_Value_TCV__c > 0){
                opp.Total_Contract_Value_TCV_forecast__c = opp.Total_Contract_Value_TCV__c;  
            }
            if(opp.Annual_Sales_Booking_Formula__c > 0){
                opp.Annual_Sales_Booking_ASB__c = opp.Annual_Sales_Booking_Formula__c;  
            }
        }
    }  
      
	/** public void copyContactDetails(List<Opportunity> newOppList){
        Set<Id> accIds = new Set<Id>();
        Map<String, Contact> accIdContMap = new Map<String, Contact>();
        Map<String, Contact> hasOptedOutContactsMap = new Map<String, Contact>();
        for(Opportunity opp :newOppList){
            accIds.add(opp.AccountId);
        }
        List<Contact> contacts = [SELECT Id, Name, HasOptedOutOfEmail, AccountId, Email FROM Contact 
                                 WHERE AccountId IN :accIds 
                                  //AND HasOptedOutOfEmail = false 
                                 ORDER BY CreatedDate ASC];
        for(Contact c :contacts){
            if(c.HasOptedOutOfEmail == false){
                accIdContMap.put(c.AccountId, c);
            } else{
                hasOptedOutContactsMap.put(c.AccountId, c);
            }
            
        }
        for(Opportunity opp :newOppList){
            if(accIdContMap.get(opp.AccountId)!=null){
                opp.Email__c = accIdContMap.get(opp.AccountId).Email;
            } else if(hasOptedOutContactsMap.get(opp.AccountId)!=null){
                opp.Email__c = hasOptedOutContactsMap.get(opp.AccountId).Email;
            }
        }
    } **/
}