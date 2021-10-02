public with sharing class AssistedSalesController {

    private static final String CLASS_NAME = 'AssistedSalesController';
    
    public class AssistedSalesController_d {

        public AssistedSalesController_d(){
            sameWindow = false;
        }

        @AuraEnabled public List<String> errorList {get;set;}
        @AuraEnabled public QuoteLoginRequestV1 qlv {get;set;} // this is the payload
        @AuraEnabled public String quoteRequest {get;set;} // same payload in string format
        @AuraEnabled public String quoteToken {get;set;}
        @AuraEnabled public String refreshToken {get;set;}
        @AuraEnabled public String destination {get;set;} // destination URL for use with tokens
        @AuraEnabled public Boolean sameWindow {get;set;}
        @testVisible private Map<Id,Id> contactToLocale;
    }
    
    @testVisible
    private static AssistedSalesController_d checkSwitch() {
        LogControl.push('checkSwitch', CLASS_NAME);
    
        List<String> errors = new List<String>();
        String destination;
        AssistedSalesController_d asco = new AssistedSalesController_d();
        Assisted_Sales_Control__c setting = Assisted_Sales_Control__c.getInstance();
        
        if (setting == null || setting.Active__c == false) {
            errors.add('Assisted Sales is currently not configured to be available.');
        } else if (setting.Destination_URL__c == null || setting.Destination_URL__c == '') {
            errors.add('Assisted Sales destination is not configured.');
        } else {
            asco.sameWindow = setting.Open_In_Same_Window__c;
            destination = setting.Destination_URL__c;
        }
        
        asco.errorList = errors;
        asco.destination = destination;
        
        return asco;
    }
    
    @AuraEnabled
    public static AssistedSalesController_d checkRequest(Id oppId) {
        LogControl.push('checkRequest', CLASS_NAME);
        
        // set destination url from custom setting
        AssistedSalesController_d ascon = checkSwitch();
        
        // quit if Assisted Sales is switched off
        if (ascon.errorList == null || ascon.errorList.isEmpty() == false) {
            return ascon;
        } 

        List<String> errors = new List<String>();
        List<Id> contactIds = new List<Id>();
        Id sellToContactId;
        Id billToContactId;
        Map<Id,Id> contactsToLocales;
        
        // create payload record with reference to Opportunity record Id
        QuoteLoginRequestV1 qr = new QuoteLoginRequestV1();
        QuoteLoginRequestV1.Client_d qc = new QuoteLoginRequestV1.Client_d();
        qc.id = 'salesforce-global';
        qc.Name = 'Salesforce Global';
        qr.client = qc; 
        QuoteLoginRequestV1.Opportunity_d qo = new QuoteLoginRequestV1.Opportunity_d();
        qo.id = oppId;
        qr.opportunity = qo;
        
        // update payload with user details
        qr = fetchUser(qr);
        QuoteLoginRequestV1.User_d usr = qr.user;
        
        if (usr.name == null || usr.email == null || usr.federatedId == null) {
            errors.add('Your user record should contain your name, email address and Federation Id');
        } 
        
        // update payload with user group memberships
        qr = fetchGroupMembers(qr);
        List<String> grpms = qr.user.groups;
        
        if (grpms == null || grpms.isEmpty()) {
            errors.add('You are not currently a member of any Assisted Sales public group (Manager or Agent)');
        } 
        
        // update payload with opportunity contact roles
        qr = fetchOpportunityContactRoles(qr); 

        if (qr.opportunity.billToContact != null && qr.opportunity.billToContact.id != null) {
            contactIds.add(qr.opportunity.billToContact.id);
            billToContactId = qr.opportunity.billToContact.id;
        }
        
        if (qr.opportunity.sellToContact != null && qr.opportunity.sellToContact.id != null) {
            contactIds.add(qr.opportunity.sellToContact.id);
            sellToContactId = qr.opportunity.sellToContact.id;
        }
        
        if (sellToContactId != null || billToContactId != null) {
            AssistedSalesController_d ascd1 = fetchOpportunityContacts(qr, contactIds);
            qr = ascd1.qlv;
            contactsToLocales = ascd1.contactToLocale;
        }
        
        if (sellToContactId == null) {
            errors.add('Please supply a Sell To Contact Role on your Opportunity');
        } else {
            errors.addAll(checkContactData('Sell To',qr.opportunity.sellToContact));
        }
            
        if (billToContactId == null) {
            errors.add('Please supply a Bill To Contact Role on your Opportunity');
        } else {
            errors.addAll(checkContactData('Bill To',qr.opportunity.billToContact));
        }

        // Update contacts with missing locales or ones not matching their Account(s)
        // if we have no errors at this point
        if (errors.isEmpty() && !contactsToLocales.isEmpty()) {
            if (updateContactLocales(contactsToLocales)) {
                // returns true if user does not have field permissions
                errors.add('You need permission to update Contact locale field value to continue');
            }
        }            
        
        // these variables will be available in the view of the associated component
        ascon.qlv = qr;
        ascon.errorList = errors; 
        
        try {
            String temp = JSON.serialize(qr);
            ascon.quoteRequest = temp;
        } catch (Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'checkRequest',true);
            throw new AuraHandledException('Unable to serialize quote request: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }
        
        return ascon;
    } 
    
    @testVisible
    private static QuoteLoginRequestV1 fetchUser(QuoteLoginRequestV1 qlreq) {
        LogControl.push('fetchUser', CLASS_NAME);
        
        User usr;
        
        try {
            usr = [SELECT Id, Name, Email, FederationIdentifier 
                   FROM User 
                   WHERE Id = :UserInfo.getUserId()];
        } catch(Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'fetchUser',true);
            throw new AuraHandledException('Unable to query User: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }
              
        // store returned values at class level
        QuoteLoginRequestV1.User_d qu = new QuoteLoginRequestV1.User_d();
        qu.id = usr.Id;
        qu.email = usr.Email;
        qu.name = usr.Name;
        qu.federatedId = usr.FederationIdentifier;
        qlreq.user = qu;
        
        return qlreq;
    }
    
    @testVisible
    private static QuoteLoginRequestV1 fetchGroupMembers(QuoteLoginRequestV1 qlreq) {
        LogControl.push('fetchGroupMembers', CLASS_NAME);
        
        List<GroupMember> grpms;
        
        try {
            grpms = [SELECT UserOrGroupId, Group.Name 
                     FROM GroupMember 
                     WHERE UserOrGroupId = :UserInfo.getUserId()
                     AND Group.Name IN ('Assisted Sales Manager','Assisted Sales Agent')];
        } catch(Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'fetchGroupMembers',true);
            throw new AuraHandledException('Unable to query User Group Memberships: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }

        // store returned values at class level
        QuoteLoginRequestV1.User_d qu = qlreq.user;
        
        for (GroupMember gm : grpms) {
            qu.addGroup(gm.Group.Name);    
        }
        
        qlreq.user = qu; 
        return qlreq;
    }
    
    @testVisible
    private static QuoteLoginRequestV1 fetchOpportunityContactRoles(QuoteLoginRequestV1 qlreq) {
        LogControl.push('fetchOpportunityContactRoles', CLASS_NAME);
        
        List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
        String recordId = qlreq.opportunity.id;

        if (recordId != null) {
            try {
                ocrs = [SELECT ContactId, Role, Opportunity.Name 
                        FROM OpportunityContactRole 
                        WHERE OpportunityId = :recordId 
                        AND Role IN ('Sell To','Bill To')];
            } catch(Exception e) {
                ExceptionLogger.logException(CLASS_NAME,null,e,'fetchOpportunityContactRoles',true);
                throw new AuraHandledException('Unable to query Opportunity Contact Roles: ' + e.getMessage());
            } finally {
                LogControl.pop();
            }
        }

        for (OpportunityContactRole o : ocrs) {
            QuoteLoginRequestV1.Contact_d qct = new QuoteLoginRequestV1.Contact_d();
            qct.id = o.ContactId;
            
            if (o.Role.equals('Sell To')) {
                qlreq.opportunity.name = o.Opportunity.Name;
                qlreq.opportunity.sellToContact = qct;
            } else if (o.Role.equals('Bill To')) {
                qlreq.opportunity.billToContact = qct;
            }
        }
        
        return qlreq;
    }
    
    @testVisible
    private static AssistedSalesController_d fetchOpportunityContacts(QuoteLoginRequestV1 qlreq, List<Id> conIds) {
        LogControl.push('fetchOpportunityContacts', CLASS_NAME);       
        Id sellToId, billToId;
        
        if (qlreq.opportunity.sellToContact != null) {
            sellToId = qlreq.opportunity.sellToContact.Id;
        }
        
        if (qlreq.opportunity.billToContact != null) {
            billToId = qlreq.opportunity.billToContact.Id;
        }
        
        List<Contact> cons;
        Map<Id,String> contactsForLocaleUpdate = new Map<Id,String>();
        List<String> errors = new List<String>();
        AssistedSalesController_d ascd = new AssistedSalesController_d();
        
        try {
            if (conIds != null && !conIds.isEmpty()) {
                cons = [SELECT Id, Name, FirstName, LastName, Email, Locale__c, MailingAddress, MailingStreet, MailingState, 
                        MailingPostalCode, MailingCity, MailingCountry, Account.Id, Account.Name, Account.CurrencyIsoCode,
                        Account.BillingCountryCode, Account.Sales_Office__c, Account.Locale__r.Id, Account.Locale__r.Name, Account.VAT_Number__c 
                        FROM Contact 
                        WHERE Id IN :conIds];
            }
        } catch(Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'fetchOpportunityContacts',true);
            throw new AuraHandledException('Unable to query Contacts: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }

        for (Contact c : cons) {
            QuoteLoginRequestV1.Contact_d qcon = new QuoteLoginRequestV1.Contact_d();
            qcon.id = c.Id;
            qcon.firstName = c.FirstName;
            qcon.lastName = c.LastName;
            qcon.displayName = c.Name;
            qcon.email = c.Email;
            QuoteLoginRequestV1.Account_d qacc = new QuoteLoginRequestV1.Account_d();
            qacc.id = c.Account.Id;
            qacc.Name = c.Account.Name;
            qacc.countryCode = c.Account.BillingCountryCode;
            qacc.currencyCode = c.Account.CurrencyIsoCode;
            qacc.salesOffice = c.Account.Sales_Office__c;
            qacc.locale = c.Account.Locale__r.Name;
            qacc.vatRegistrationNumber = c.Account.VAT_Number__c;
            QuoteLoginRequestV1.Address_d qadd = new QuoteLoginRequestV1.Address_d();
            if (c.MailingStreet != null) {
                String[] addressLines = c.MailingStreet.split('\r\n');
                qadd.line1 = addressLines[0];
            }
            qadd.postalCode = c.MailingPostalCode;
            qadd.state = c.MailingState;
            qadd.city = c.MailingCity;
            qadd.country = c.MailingCountry;
            // set account and contact on parents
            qacc.address = qadd;
            qcon.account = qacc;

            if (qcon.id == sellToId) qlreq.opportunity.sellToContact = qcon;
            if (qcon.id == billToId) qlreq.opportunity.billToContact = qcon;
            
            // check for unmatched Locale between Contact and Account - these will be updated
            if (c.Locale__c == null || c.Locale__c != c.Account.Locale__r.Id) {
                contactsForLocaleUpdate.put(qcon.id,c.Account.Locale__r.Id);
            }
            
            ascd.contactToLocale = contactsForLocaleUpdate;
        }
        
        ascd.qlv = qlreq;
        return ascd;
    }
    
    @testVisible
    private static Boolean updateContactLocales (Map<Id,Id> contacts) {
        LogControl.push('updateContactLocales', CLASS_NAME);
        
        List<Contact> contactsForUpdate = new List<Contact>();
        Boolean isMissingPermissions = false;
        
        for (Id con : contacts.keySet()) {
            Contact c = new Contact();
            c.Id = con;
            c.Locale__c = contacts.get(con);
            contactsForUpdate.add(c);
        }
        
        if (Schema.sObjectType.Contact.fields.Locale__c.isUpdateable()) {
            try {
                update contactsForUpdate;
            } catch(Exception e) {
                ExceptionLogger.logException(CLASS_NAME,null,e,'updateContactLocales',true);
                throw new AuraHandledException('Unable to query Contact Locales: ' + e.getMessage());
            } finally {
                LogControl.pop();
            }
        } else {
            isMissingPermissions = true;
        }
        
        return isMissingPermissions;
    }

    @testVisible
    private static List<String> checkContactData (String role, QuoteLoginRequestV1.Contact_d c) {
        LogControl.push('checkContactData', CLASS_NAME);

        List<String> errors = new List<String>();
        
        if (c.email == null) { errors.add(role + ' Contact needs an Email address'); }
        if (c.Account == null || c.account.Id == null) { 
            errors.add(role + ' Contact needs to reference an Account Id'); 
        } else {
            if (c.account.countryCode == null) { errors.add(role + ' Contact needs to reference an Account with Billing Country set'); }
            if (c.account.salesOffice == null) { errors.add(role + ' Contact needs to reference an Account with a Sales Office'); }
            if (c.account.locale == null) { errors.add(role + ' Contact needs to reference an Account with a Locale set'); }
            if (c.account.address.line1 == null ||
                c.account.address.postalCode == null ||
                c.account.address.country == null) { errors.add(role + ' Contact needs to have a full Mailing Address'); }
        }
        
        return errors;
    }
    
    @AuraEnabled
    public static AssistedSalesController_d getTokens(String qrequest, String destinationUrl, Boolean sameWindow) {
        LogControl.push('getTokens', CLASS_NAME);
        
        AssistedSalesController_d obj;
        QuoteLoginRequestV1 quoteRequest;
        
        try {
            quoteRequest = (QuoteLoginRequestV1)JSON.deserialize(qrequest, QuoteLoginRequestV1.Class);
        } catch (Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'getTokens',true);
            throw new AuraHandledException('Unable to deserialize quote request: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }
        
        try {
            QuoteLogin ql = QuoteLoginRequestor.login(quoteRequest); 
            obj = new AssistedSalesController_d(); // class used to send >1 tokens back
            obj.quoteToken = ql.quoteToken;
            obj.refreshToken = ql.refreshToken;
            obj.destination = destinationUrl;
            obj.sameWindow = sameWindow;
        } catch (Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'getTokens',true);
            throw new AuraHandledException('Unable to retrieve tokens from Quote API: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }
        
        return obj;
    }

    @AuraEnabled
    public static List<sObject> updateMissedAccountInfo(Id oppId, String loc, String salesOfc) {
        // Functionality to update Account Locale and Sales Office and to automate SellTo/Bill To Opportunity contact roles
        LogControl.push('updateMissedAccountInfo', CLASS_NAME);
        List<sObject> objLst = new List<sObject>();
        Account acc = new Account();
        String accId;
        Locale__c locale;
        try {
            if (oppId != null && Schema.sObjectType.Opportunity.fields.AccountId.isAccessible())
                accId = [SELECT AccountId FROM opportunity WHERE id = :oppId].AccountId;
            if (accId != null && Schema.sObjectType.Account.fields.Locale__c.isAccessible())
                acc = [
                    SELECT id, name, Locale__r.name, Locale__c,Sales_office__c
                    FROM Account
                    WHERE id = :accId
                ];
            if ((!String.isEmpty(loc)) && Schema.sObjectType.Locale__c.fields.Country_Code__c.isAccessible())
                locale = [SELECT id,Country_Code__c FROM Locale__c WHERE name = :loc];
    
            if (Schema.sObjectType.Account.fields.Locale__c.isUpdateable() && locale.id!=null && (!String.isBlank(locale.Country_Code__c))) {
                    acc.Locale__c = locale.id;
                    acc.Sales_office__C = salesOfc;
                    acc.Locale_Billing_CC__c = locale.Country_Code__c;
                    update acc;
                    objLst.add(acc);
            }
        } catch (Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'updateMissedAccountInfo',true);
            throw new AuraHandledException('Unable to update Contact Locales/SalesOffices: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }
        return objLst;
    }
    
    @AuraEnabled
    public static List<sObject> updateMissedContactRoleInfo(Id oppId) {
        // Functionality to update Account Locale and Sales Office and to automate SellTo/Bill To Opportunity contact roles
        LogControl.push('updateMissedContactRoleInfo', CLASS_NAME);
        List<sObject> objLst = new List<sObject>();
        String conId;
        List<OpportunityContactRole> oldOcrs = new List<OpportunityContactRole>();
        List<OpportunityContactRole> newOcrs = new List<OpportunityContactRole>();
        Set<String> roleSet = new Set<String>();
        try {
            if (oppId != null) {
                if(Schema.sObjectType.OpportunityContactRole.fields.ContactId.isAccessible() && Schema.sObjectType.OpportunityContactRole.fields.Role.isAccessible()){
                    oldOcrs = [
                        SELECT ContactId, Role, Opportunity.Name
                        FROM OpportunityContactRole
                        WHERE OpportunityId = :oppId
                    ];
                }
                if (oldOcrs.size() > 0) {
                    conId = oldOcrs[0].contactId;
                    for (OpportunityContactRole o : oldOcrs) {
                        roleSet.add(o.Role);
                    }
                    if (!roleSet.contains('Sell To')) {
                        OpportunityContactRole ocrST = new OpportunityContactRole();
                        ocrST.ContactId = conId;
                        ocrST.Role = 'Sell To';
                        ocrST.OpportunityId = oppId;
                        ocrST.IsPrimary = false;
                        newOcrs.add(ocrST);
                    }
                    if (!roleSet.contains('Bill To')) {
                        OpportunityContactRole ocrBT = new OpportunityContactRole();
                        ocrBT.ContactId = conId;
                        ocrBT.Role = 'Bill To';
                        ocrBT.OpportunityId = oppId;
                        ocrBT.IsPrimary = false;
                        newOcrs.add(ocrBT);
                    }
                }
            }
            if (newOcrs.size() > 0) {
                if (Schema.sObjectType.OpportunityContactRole.fields.ContactId.isCreateable() && Schema.sObjectType.OpportunityContactRole.fields.OpportunityId.isCreateable() &&Schema.sObjectType.OpportunityContactRole.fields.Role.isCreateable() && Schema.sObjectType.OpportunityContactRole.fields.isPrimary.isCreateable()){
                    insert newOcrs;
                    objLst.addAll(newOcrs);
               }
            }
        } catch (Exception e) {
            ExceptionLogger.logException(CLASS_NAME,null,e,'updateMissedContactRoleInfo',true);
            throw new AuraHandledException('Unable to insert Opportunity Contact Roles: ' + e.getMessage());
        } finally {
            LogControl.pop();
        }
        return objLst;
    }
}