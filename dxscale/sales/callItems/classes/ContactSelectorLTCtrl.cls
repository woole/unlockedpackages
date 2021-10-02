public inherited sharing class ContactSelectorLTCtrl {

    public static final String callItemApiName='Call_Item__c';


    /**
     * To Retrieve list of account contacts on the CallItem
     * @param  CallItem recordId
     * @return  return list of contacts
     */
    @AuraEnabled
    public static List<Contact> getContacts(Id recordId) {
        Call_Item__c callItem = [ SELECT Account__c, Contact__c FROM Call_Item__c WHERE Id = :recordId ];
        List<Contact> retVal = new List<Contact>();
        List<Contact> accountContacts;
        try{
                accountContacts = getContactsFromAccountId(callItem.Account__c);
        }catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'error fetching contacts ' + e.getStackTraceString());
            AuraHandledException ae = new AuraHandledException('unable to  query contacts : ' + e.getMessage());
            ae.setMessage('unable to  query contacts : ' + e.getMessage());
            throw ae;
        }
        for (Contact eachContact :getContactsFromAccountId(callItem.Account__c)) {
            if (eachContact.Id != callItem.Contact__c) {
                retVal.add(eachContact);
            } else {
                if (retVal.size() > 0) {
                    retVal.add(0, eachContact);
                } else {
                    retVal.add(eachContact);
                }
            }
        }

        return retVal;
    }

    @AuraEnabled
    public static List<Contact> getContactsFromAccountId(Id accountId) {
        List<Contact> accountContacts;
        List<String> fields = new List<String>{'Name','MailingStreet','MobilePhone','Phone',
        'Email','LeadSource','Job_Role__c','DoNotCall','Description','Phone_Call_Options__c',
        'Primary__c','Do_Not_Mail__c','TPS_Phone__c','TPS_Mobile__c','Inactive__c','AccountId'};
        Boolean hasPermission = hasPermission(fields,'read');
        if(hasPermission){
                accountContacts =  [    SELECT Id
                , Name
                , MailingStreet
                , MobilePhone
                , Phone
                , Email
                , LeadSource
                , Job_Role__c
                , DoNotCall
                , Description
                , Phone_Call_Options__c
                , Primary__c
                , Do_Not_Mail__c
                , TPS_Phone__c
                , TPS_Mobile__c
            FROM Contact
            WHERE AccountId = :accountId AND Inactive__c = false AND IsIndirectCustomer__c = false  WITH SECURITY_ENFORCED 
                ORDER BY Primary__c Desc];
        }else{
            System.debug(LoggingLevel.DEBUG, 'User does not have enough permission to run this query');
            throw new ContactSelectorException('You do not have the permissions needed to read this data');
        }
        return accountContacts;

    }

    /**
     * To Retrieve accountid on the CallItem
     * @param  CallItem recordId
     * @return  return Id of the Account
     */
    @AuraEnabled
    public static Id getAccountId(Id recordId) {
        String accountid = '';
        if(Schema.sObjectType.Call_Item__c.fields.Account__c.isAccessible()){
            accountid = [ SELECT Account__c FROM Call_Item__c WHERE Id = :recordId ][0].Account__c;
        }
        return accountid;
    }


    /**
     * To Set the Selected Contact on the CallItem
     * @param  Contact recordId
     * @param  CallItem recordId
     * @return  returns SUCCESS String
     */
    @AuraEnabled
    public static String setContact(Id contactId, Id callItemId) {
        System.debug(LoggingLevel.ERROR,contactId);
        System.debug(LoggingLevel.ERROR,callItemId);

        List<Call_Item__c> listci = [select id, Contact__c from Call_Item__c where id = :callItemId];
        Call_Item__c ci = listci[0];
        ci.Contact__c = contactId;
        try{
            if(Schema.sObjectType.Call_Item__c.fields.Contact__c.isupdateable()){
                update ci;    
                return 'SUCCESS';
            }else{
                throw new AuraHandledException('You do not have permission to update the Contact field on CallItem');
            }    
        }catch(DmlException e){
            throw new AuraHandledException('unable to update the call item contact');
        }
        
    }

    /**
    * To create contact on the CallItem
    * @param  CallItem recordId/Account recordId
    * @return  returns Contact
    */

    @AuraEnabled
    public static Contact saveNewContactApex(
            Id callItemId,
            String newContactFirstName,
            String newContactLastName,
            String newContactPhone,
            String newContactEmail,
            String newJobRole,
            String newContactMailingCountry,
            String newContactMailingState,
            String newContactMailingCity,
            String newContactMailingPostalCode,
            String newContactAccountId
    ) {
        List<String> updateFields = new List<String>{
            'FirstName','LastName','Phone','Email','Job_Role__c',
            'MailingCountry','MailingCity','MailingState','MailingPostalCode','AccountId'
        };
        Contact ct;
        if(hasPermission(updateFields,'create')){
            System.debug(LoggingLevel.ERROR,'saveNewContact');
            ct = new Contact();
            ct.FirstName = newContactFirstName;
            ct.LastName = newContactLastName;
            ct.Phone = newContactPhone;
            ct.Email = newContactEmail;
            ct.Job_Role__c = newJobRole;
            ct.MailingCountry = newContactMailingCountry;
            ct.MailingCity = newContactMailingCity;
            ct.MailingState = newContactMailingState;
            ct.MailingPostalCode = newContactMailingPostalCode;
            ct.AccountId = newContactAccountId;
            try {
                insert ct;
            } catch(DmlException caughtException) {
                throw new AuraHandledException('Unable to create contact. Error : ' + caughtException.getMessage());
            }

            String sObjName = callItemId.getSObjectType().getDescribe().getName();
            if(sObjName==callItemApiName){
                //this will throw and exception if it fails which will 
                String result = setContact(ct.Id, callItemId);
            }
            return [SELECT Id, Name, MailingStreet, Phone, Email, LeadSource, 
            Job_Role__c, DoNotCall, Description, Phone_Call_Options__c FROM Contact WHERE id = :ct.id][0];

        }
        else{
            throw new AuraHandledException('You do not have permission to create contact');
        }
    }

    private static boolean hasPermission(List<String> updateFields,String checkType){
        boolean hasPermission = true;
        // Obtaining the field name/token map for the Contact object
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Contact.fields.getMap();
        for (String fieldToCheck : updateFields) {
            // Check if the user has create access on the each field
            switch on checkType{
                when 'create'{
                    if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                        System.debug(LoggingLevel.DEBUG,'no Create permission for : ' + fieldToCheck);
                        hasPermission = false;
                    }    
                }
                when 'read'{
                    if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                        System.debug(LoggingLevel.DEBUG,'no Read permission for : ' + fieldToCheck);
                        hasPermission = false;
                    }   
                }
            }
        }
        return hasPermission;     
    }


    @AuraEnabled
    public static List<string> getMailingCountry(String fieldAPI)
    {
        List<String> options = new List<String>();

        Schema.sObjectType objType = Contact.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get(fieldAPI).getDescribe().getPickListValues();

        for (Schema.PicklistEntry v : values){
            options.add(v.getLabel());
        }
        return options;
    }

    /**
     * To generate click to dial params JSON to default what id in CCaaS soft phone
     * @param  Id accountId
     * @return  return String JSON for params attribute of click to dial component
     */
    @AuraEnabled
    public static String getPureCloudClickToDialParams(Id recordId) {
        List<SObject> lSObject;
        if (Account.getSObjectType() == recordId.getSobjectType()) {
            lSObject = [    SELECT Id
                                    , Name
                            FROM Account
                            WHERE Id = :recordId ];
        } else {
            lSObject = [    SELECT Id
                                    , Name
                            FROM Call_Item__c
                            WHERE Id = :recordId ];
        }
        if (lSObject != null && !lSObject.isEmpty()) {
            String strObject = JSON.serialize(lSObject);

            JSONGenerator gen = JSON.createGenerator(false);

            gen.writeStartObject();
            gen.writeStringField('associations', strObject);
            gen.writeBooleanField('autoPlace', true);
            gen.writeEndObject();

            return gen.getAsString();
        } else {
            return null;
        }
    }

    private class ContactSelectorException extends Exception {}
}