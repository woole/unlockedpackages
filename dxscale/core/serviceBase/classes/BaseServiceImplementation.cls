public virtual inherited sharing class BaseServiceImplementation {

    /**
     * validates the request. 
     * @returns empty if ok or a string of errors 
     */
    @TestVisible
    protected virtual String validate(IRequestValidator request){
        Map<String,String> errors = request.validate();
        String error = '';
        if(!errors.isEmpty()){
            for(String s:errors.keySet()){
                error += s + ' ' + errors.get(s) + ', ';
            }
        }
        return error;
    }

}
