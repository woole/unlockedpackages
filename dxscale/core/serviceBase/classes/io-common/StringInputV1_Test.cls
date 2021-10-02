@isTest
public class StringInputV1_Test {

    private static final String CORRELATION_ID = 'cpq-1234-abc-123';
    private static final String INPUT_MSG = 'input message{}';

    @isTest
    public static void testCorrelationId(){
        StringInputV1 input = new StringInputV1();
        input.setCorrelationId(CORRELATION_ID);
        System.assertEquals(input.getCorrelationId(),CORRELATION_ID,'should have set correlationId');
    }

    @isTest
    public static void testInputMessage(){
        StringInputV1 input = new StringInputV1();
        input.setInputMessage(INPUT_MSG);
        System.assertEquals(input.getInputMessage(),INPUT_MSG,'should have set input message');
    }

    @isTest
    public static void testCreateFlowInput(){
        StringInputV1 input = new StringInputV1();
        input.setInputMessage(INPUT_MSG);
        Map<String,Object> flowOut = input.createFlowInput();
        System.assertEquals(flowOut.size(),1,'should have one row');
        System.assertEquals(flowOut.get('inputMessage'),INPUT_MSG,'input should have been the input message');
    }    

    
}
