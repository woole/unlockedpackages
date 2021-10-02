@isTest
public class StringOutputV1_Test {
    

    private static final String OUTPUT_MSG = 'Output message';

    @isTest
    public static void testOutput(){
        StringOutputV1 output = new StringOutputV1();
        output.setOutputMessage(OUTPUT_MSG);
        System.assertEquals(output.getOutputMessage(), OUTPUT_MSG,'should have been the OUTPUT_MSG');
    }

    @isTest
    public static void testProcessFlowOutput(){
        StringOutputV1 output = new StringOutputV1();
        //can't mock out the FLows. so have to do some hacky stuff here
        Flow.Interview TestFlow;
        output.processFlowOutput(TestFlow);
        System.assertEquals(output.getState(),'ERROR','Should have set error state');
        System.assertEquals(output.getOutputMessage(),'outputMessage','Should have set outputMessage ');
        System.assertEquals(output.getErrorMessage(),'errorMessage','Should have set errorMessage confition');
    }
    
}
