/**
 * @description  PracticeEfficiencyReview Helper Test
 * @author Betty Phan
 * @date 03/02/2021
 */
@IsTest
public class PracticeEfficiencyReview_Helper_Test {
    @IsTest
    static void testPopulateFieldsFromAccount() {
        Account acct = new Account(Name='Acc 1',Local_CRM_AccountID__c='PER-1234567890', BillingCity='Irvine', BillingCountry='United States', BillingPostalCode='92606',
                                    Phone='9999999', Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100001))+Datetime.now().millisecond()));
        insert acct;
        Contact cont = new Contact(AccountId= acct.id, LastName='TestContact', Email = 'testuser@per.org',
                                   Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200005))+Datetime.now().millisecond()));  
        insert cont;
        PracticeEfficiencyReviewV2__c per = new PracticeEfficiencyReviewV2__c( PracticeName__c = acct.id, ClientName__c = cont.id);
        insert per;      
        
        Test.startTest();        
        per = [SELECT ReviewTitle__c, LocalCRMAccountID__c, BillingCity__c, BillingCountry__c, BillingPostalCode__c from PracticeEfficiencyReviewV2__c where LocalCRMAccountID__c = 'PER-1234567890' LIMIT 1];  
        System.assert(per.BillingCity__c=='Irvine');
        System.assert(per.BillingCountry__c=='United States');
        System.assert(per.BillingPostalCode__c=='92606');      
        Test.stopTest();        
    }
}