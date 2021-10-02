@isTest
public class ValidatorUtils_Test {
    @TestSetUp static void setupTestData() {
        // create any record
        Database.insert(new Logger__c(
                Name = 'ValidatorUtils_Test'
            ,   Correlation_Id__c = 'test-123455'
            ,   Record_Name_Id__c = '123456789'
            ,   Exception_Error_Message__c = 'validation failure'
            ,   Exception_Type__c = ExceptionLogger.ERROR_TYPE.VALIDATION.name()
        ));
    }
    
    @isTest
    static void testValidateEmail(){
        //INVALID EMAILS
        Boolean result = ValidatorUtils.validateEmail('<script>@example.com');
        System.assertEquals(false, result,'email should not have been valid');
        result = ValidatorUtils.validateEmail('test@rep.cloud3');
        System.assertEquals(false, result,'email should Not have been valid');
        result = ValidatorUtils.validateEmail('test@rep.øn');
        System.assertEquals(false, result,'email should Not have been valid');        
        //VALID EMAILS
        result = ValidatorUtils.validateEmail('joe.tester@example.com');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('joe.tester@example.com');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('test@teddy.group');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('some.one@brownlake.partners');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('info@saturn.productions');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('ted.taddle@lbz.world');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('clients@exampleweb.design');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('info@itest.company');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('test@rep.cloud');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('test@tv.codes');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('us_promo706@yopmail.com');
        System.assertEquals(true, result,'email should have been valid');
        //SPECIAL CHARs
        result = ValidatorUtils.validateEmail('Féal@yopmail.com');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('ølg1@workspacetest-uk.com');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('åldø-123@siå.edu.an');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('test+test_04_08_21@ça-visiø.io');
        System.assertEquals(true, result,'email should have been valid');
        result = ValidatorUtils.validateEmail('frank.tËt@ipsa-abc1.org');
        System.assertEquals(true, result,'email should have been valid');
         
    }

    @isTest
    static void testValidateLocale(){
        Boolean result = ValidatorUtils.validateLocale('en_GBP');
        System.assertEquals(false, result,'locale should not have been valid');
        result = ValidatorUtils.validateLocale('fr_FR');
        System.assertEquals(true, result,'locale should have been valid');        
    }

    @isTest
    static void testValidateSepcialCharacters(){
        //NOT ALLOWED
        Boolean result = ValidatorUtils.validateSpecialChar('some info with a <!script>');
        System.assertEquals(false, result,'String should not have been valid');
        result = ValidatorUtils.validateSpecialChar('Some stuff [some thing] that');
        System.assertEquals(false, result,'String should not have been valid');
        result = ValidatorUtils.validateSpecialChar('Some stuff $ that');
        System.assertEquals(false, result,'String should not have been valid');           
        result = ValidatorUtils.validateSpecialChar('Some stuff &_! that');
        System.assertEquals(false, result,'String should not have been valid');           

        //ALLOWED
        result = ValidatorUtils.validateSpecialChar('Some stuff @ that');
        System.assertEquals(true, result,'String should have been valid');
        result = ValidatorUtils.validateSpecialChar('Some stuff > that');
        System.assertEquals(true, result,'String should have been valid');
        result = ValidatorUtils.validateSpecialChar('some value');
        System.assertEquals(true, result,'String should have been valid');
        result = ValidatorUtils.validateSpecialChar('some value1 and value2 1234');
        System.assertEquals(true, result,'String should have been valid');
        result = ValidatorUtils.validateSpecialChar('Won from UKI Accounts / Payroll');
        System.assertEquals(true, result,'String should have been valid'); 
        result = ValidatorUtils.validateSpecialChar('Accountant Recommended (please specify in notes)');
        System.assertEquals(true, result,'String should have been valid'); 
        result = ValidatorUtils.validateSpecialChar('Montréal');
        System.assertEquals(true, result,'String should have been valid');
        result = ValidatorUtils.validateSpecialChar('Henry\'s Repair');
        System.assertEquals(true, result,'String should have been valid');
        result = ValidatorUtils.validateSpecialChar('Frank Tester Plumbing & Heating');
        System.assertEquals(true, result,'String should have been valid');           

    } 
    
    @isTest
    static void testValidateCurrency(){
        //NOT ALLOWED
        Boolean result = ValidatorUtils.validateCurrency('gb');
        System.assertEquals(false, result,'currency should not have been valid');
        result = ValidatorUtils.validateCurrency('<!0');
        System.assertEquals(false, result,'currency should not have been valid');
        result = ValidatorUtils.validateCurrency('a8i');
        System.assertEquals(false, result,'currency should not have been valid');  
        //ALLOWED
        result = ValidatorUtils.validateCurrency('GBP');
        System.assertEquals(true, result,'currency should have been valid');
        result = ValidatorUtils.validateCurrency('usd');
        System.assertEquals(true, result,'currency should have been valid');            
    }
    
    @isTest
    static void testValidateLength(){
        Boolean result = ValidatorUtils.validateLength('', 0);
        System.assertEquals(false, result,'No value should return false');
        result = ValidatorUtils.validateLength('a', 1);
        System.assertEquals(false, result,'should return false');
        result = ValidatorUtils.validateLength('aa', 1);
        System.assertEquals(true, result,'should return true');

    }

    @isTest static void isValidIdWithValidIdTest() {
        // GIVEN
        Logger__c loggerRecord = [ SELECT Id
                                        , Name 
                                    FROM Logger__c LIMIT 1];

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidId(loggerRecord.Id);
        Test.stopTest();

        //THEN
        System.assertEquals(true, actualReturnValue, 'Invalid salesforce record id');
    }

    @isTest static void isValidIdWithInvalidIdTest() {
        // GIVEN
        String invalidRecordId = 'INVALID_ID';

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidId(invalidRecordId);
        Test.stopTest();

        //THEN
        System.assertEquals(false, actualReturnValue, 'Invalid salesforce record id');
    }

    @isTest static void isValidObjectIdWithValidObject() {
        // GIVEN
        Logger__c loggerRecord = [ SELECT Id
                                        , Name 
                                    FROM Logger__c LIMIT 1];

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidObjectId(loggerRecord.Id, 'Logger__c');
        Test.stopTest();

        //THEN
        System.assertEquals(true, actualReturnValue, 'Invalid logger record id');
    }

    @isTest static void isValidObjectIdWithInvalidObject() {
        // GIVEN
        Logger__c loggerRecord = [ SELECT Id
                                        , Name 
                                    FROM Logger__c LIMIT 1];
        
        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidObjectId(loggerRecord.Id, 'Account');
        Test.stopTest();

        //THEN
        System.assertEquals(false, actualReturnValue, 'Record id and object type do not match');
    }

    @isTest static void isValidObjectIdWithInvalidId() {
        // GIVEN
        String invalidRecordId = 'INVALID_ID'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidObjectId(invalidRecordId, 'Logger__c');
        Test.stopTest();

        //THEN
        System.assertEquals(false, actualReturnValue, 'Record id and object type do not match');
    }

    @isTest static void validAccountGlobalIdTest() {
        // GIVEN
        String globalId = '1000000010'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, 'account');
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, actualReturnValue, 'Invalid global id for account');
    }
    @isTest static void validAccountGlobalIdTest2() {
        // GIVEN
        String globalId = '1000000001'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, 'account');
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, actualReturnValue, 'Invalid global id for account');
    }    

    @isTest static void getIdTypeTest_Global(){
        // GIVEN
        String globalIdOK = '1000000001';
        String globalIdNotOK = '2000000010';

        // WHEN
        ValidatorUtils.IDTYPE globalOKActualReturnValue;
        ValidatorUtils.IDTYPE globalNOKActualReturnValue;
        ValidatorUtils.IDTYPE globalCtcOKActualReturnValue;

        Test.startTest();
        globalOKActualReturnValue = ValidatorUtils.getIdType(globalIdOK, 'account');
        globalNOKActualReturnValue = ValidatorUtils.getIdType(globalIdNotOK, 'account');
        globalCtcOKActualReturnValue = ValidatorUtils.getIdType(globalIdNotOK, 'contact');

        Test.stopTest();

        //THEN
        System.assertEquals(ValidatorUtils.IDTYPE.GlobalID, globalOKActualReturnValue, 'SHould have been a valid account global Id');
        System.assertEquals(ValidatorUtils.IDTYPE.InvalidID, globalNOKActualReturnValue, 'Was not valid format for the account GID');
        System.assertEquals(ValidatorUtils.IDTYPE.GlobalID, globalCtcOKActualReturnValue, 'Should have been a valid contact global ID');
        
    }

    @isTest static void getIdTypeTest_RecordId(){
        // GIVEN
        String accountIdOK = '0010Q00001MK76CQAT';
        String contactIdOK = '0030Q000015hHJNQA2';
        String notGoodvalue = '00D0Q000015h00000';

        // WHEN
        ValidatorUtils.IDTYPE accountOKResult;
        ValidatorUtils.IDTYPE contactOKResult;
        ValidatorUtils.IDTYPE notOkResult;
        Test.startTest();
        accountOKResult = ValidatorUtils.getIdType(accountIdOK, 'account');
        contactOKResult = ValidatorUtils.getIdType(contactIdOK, 'contact');
        notOkResult = ValidatorUtils.getIdType(notGoodvalue, 'contact');

        Test.stopTest();

        //THEN
        System.assertEquals(ValidatorUtils.IDTYPE.RecordID, accountOKResult, 'Should be a valid Account Record Id');        
        System.assertEquals(ValidatorUtils.IDTYPE.RecordID, contactOKResult, 'Should be a valida Contact Record Id');  
        System.assertEquals(ValidatorUtils.IDTYPE.InvalidID, notOkResult, 'Not have been a valid Record Id');        
    }    
    
    @isTest static void validContactGlobalIdTest() {
		// GIVEN
        String globalId = '2000023459'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, 'contact');
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, actualReturnValue, 'Invalid global id for contact');        
    }
    
    @isTest static void invalidAccountGlobalIdTest() {
		// GIVEN
        String globalId = '2000023459'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, 'account');
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Pass an invalid global id for account');
    }
    
    @isTest static void invalidContactGlobalIdTest() {
		// GIVEN
        String globalId = '1000023459'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, 'contact');
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Pass an invalid global id for contact');
    }
    
    @isTest static void invalidIdTypeTest() {
		// GIVEN
        String globalId = '9000023459'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, 'INVALID_TYPE');
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Pass invalid id type');
    }
    
    @isTest static void emptyIdTypeTest() {
		// GIVEN
        String globalId = '9000023459'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.isValidGlobalId(globalId, '');
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Do not pass id type');
    }

    @isTest static void validVatFormatTest() {
		// GIVEN
        // BETWEEN 5-15 CHARS
        String vatNumber = 'GB12345678901'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.validateVatFormat(vatNumber);
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, actualReturnValue, 'Input vat number is invalid');
    }

    @isTest static void validVatFormatSpaceTest() {
		// GIVEN
        // BETWEEN 5-15 CHARS
        String vatNumber = '912 4321 00'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.validateVatFormat(vatNumber);
        Test.stopTest();
        
        //THEN
        System.assertEquals(true, actualReturnValue, 'Input vat number is invalid');
    }
    @isTest static void validVatFormatHyphenTest() {
		// GIVEN
        // BETWEEN 5-15 CHARS
        String vatNumber = '912-4321-00'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.validateVatFormat(vatNumber);
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Input vat number is invalid');
    }

    @isTest static void maxLengthVatFormatTest() {
		// GIVEN
        // MORE THAN 15 CHARS
        String vatNumber = 'GBP123456ADA7890'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.validateVatFormat(vatNumber);
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Input vat number is not more than 15 characters');
    }

    @isTest static void minLengthVatFormatTest() {
		// GIVEN
        // LESS THAN 5 CHARS
        String vatNumber = 'GB12'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.validateVatFormat(vatNumber);
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Input vat number should be smaller than 4 characters');
    }
   
   
    @isTest static void invalidCharVatFormatTest() {
		// GIVEN
        // LESS THAN 5 CHARS
        String vatNumber = '912/4321/00'; 

        // WHEN
        Boolean actualReturnValue;
        Test.startTest();
        actualReturnValue = ValidatorUtils.validateVatFormat(vatNumber);
        Test.stopTest();
        
        //THEN
        System.assertEquals(false, actualReturnValue, 'Input vat number should be smaller than 4 characters');
    } 
}