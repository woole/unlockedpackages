
/* This Class is only used for testing the Services Framework */

@IsTest
public inherited sharing class SampleServiceImplementation_Test implements IService_Implementation, IService_Implementation_Audit_Override {

    public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
        IStringInput isi = (IStringInput) inputData;
        return implementationBody(invocationDetails,isi);
    }

    @TestVisible private IService_Output_Master implementationBody (IInvocation_Details invocationDetails,IStringInput isi) {

        String inputMessage = isi.getInputMessage();

        if (inputMessage == 'Throw') {
            throw new Service.ServiceFrameworkException (inputMessage);
        }

        IStringOutput iso = (IStringOutput) invocationDetails.getOutputInterfaceInstance();
        iso.setOutputMessage(inputMessage + ' Message');
        iso.setState(inputMessage);
        if (inputMessage == 'Failure') {
            iso.setErrorMessage('Failure Message');
        }
        return iso;

    }

    public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
        IStringOutput stringOutput = new StringOutputV1();
        stringOutput.setOutputMessage ('Audit Override');
        stringOutput.setState(isom.getState());
        stringOutput.setErrorMessage(isom.getErrorMessage());
        return stringOutput;
    }


}
