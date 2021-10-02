@isTest
public class ContactTestDataFactory {

    public static Contact createContact(String firstname, String lastname, String accountID){
        Contact contact = createContact(firstname,lastname);
        contact.accountId=accountID;
        contact.MailingCity = 'Atlanta';
        contact.MailingCountry = 'United States';
        contact.MailingStreet = '17 North West St';
        contact.MailingPostalCode = '30005';
        contact.MailingState = 'New York';
        upsert contact; 
        return contact;
    }

    public static Contact createContact(String firstname, String lastname){
        Contact contact = new Contact(FirstName=firstname,LastName=lastname);
        insert contact;
        return contact;
    }    
    

    public static Contact createContact(String firstname, String lastname, String accountID, String globalContactID){
        Contact contact = createContact(firstname,lastname);
        contact.accountId=accountID;
        contact.MailingCity = 'Atlanta';
        contact.MailingCountry = 'United States';
        contact.MailingStreet = '17 North West St';
        contact.MailingPostalCode = '30005';
        contact.MailingState = 'New York';
        contact.Global_Id__c = globalContactID;
        upsert contact; 
        return contact;
    } 
}