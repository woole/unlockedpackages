/**
 * Because of run time dependencies, this class mirrors the commerce IQuoteLoginRequest interface.
 * If you change this call, you need to probably reflect this in IQuoteLoginRequest of salesforce-global-commerce
 * QuoteLoginRequestV1
 */
public inherited sharing class QuoteLoginRequestV1{


    public Client_d client {get;set;}
    public User_d user {get;set;}
    public Opportunity_d opportunity {get;set;}
    public List<Lookup_d> lookups {get;set;}   

    public void addLookup(Lookup_d lookup){
        if(this.lookups == null){
            lookups = new List<Lookup_d>();
        }
        this.lookups.add(lookup);
    }


public class Client_d{
    public String name {get;set;}
    public String id {get;set;}

}

public class User_d{
    public String id {get;set;}
    public String federatedId {get;set;}
    public String name {get;set;}
    public String email{get;set;}
    public List<String> groups{get;set;}
    
    public void addGroup(String groupName){
        if(this.groups == null){
            groups = new List<String>();
        }
        this.groups.add(groupName);
    }

}

public class Opportunity_d{
    public String id{get;set;}
    public String name{get;set;}
    public Contact_d billToContact{get;set;}
    public Contact_d sellToContact{get;set;}
}

public class Contact_d{
    public String id{get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String displayName{get;set;}
    public String email{get;set;}
    public Account_d account{get;set;}
}

public class Account_d{
    public String id{get;set;}
    public String name{get;set;}
    public String countryCode{get;set;}
    public String currencyCode{get;set;}
    public String salesOffice{get;set;}
    public String locale{get;set;}
    public String billingAccountId{get;set;}
    public Address_d address{get;set;}
    public String vatRegistrationNumber{get;set;}
}

public class Address_d{
    public String line1 {get;set;}
    public String line2 {get;set;}
    public String state {get;set;}
    public String postalCode {get;set;}
    public String city {get;set;}
    public String country {get;set;}        
}

public class Lookup_d{
    public String lookupType {get;set;}
    public String id {get;set;}
    public String displayText {get;set;}
    public String parentLookupType {get;set;}
    public String parentLookupId {get;set;}
}

}
