public inherited sharing class TaskSalesHelper {
    private final String CLASS_NAME = 'TaskSalesHelper';

    public void UpdateTaskDueDate(List<Task> newObjects,Map<Id, Task> oldObjectsMap) {
        final String METHOD_NAME = 'UpdateTaskDueDate';
        
        try {
            LogControl.push(METHOD_NAME, this.CLASS_NAME);

            for(Task eachTask : newObjects) {
                if(eachTask.DueDateTime__c != null) {
                    eachTask.ActivityDate = (eachTask.DueDateTime__c).date();
                }
                if (eachTask.CallObject != null && eachTask.ActivityDate == null) {
                    eachTask.ActivityDate = System.today();
                }
            }
        } catch(Exception ex) {
            LogControl.debugException(ex);
        } finally {
            LogControl.pop();
        }
    }

    public void UpdateTaskComments(List<Task> newObjects,Map<Id, Task> oldObjectsMap){
        final String METHOD_NAME = 'UpdateTaskComments';
        
        try{
            LogControl.push(METHOD_NAME, this.CLASS_NAME);
            for(Task task : newObjects){                
               
            if(task.Description!=null)  {
                
                if( (task.Description).length()<255){
                    task.Task_Comments__c=task.Description; 
                    }
                //CCORE-1996
                 if((task.Description).length()>=255){
                          task.Task_Comments__c=(task.Description).substring(0,255);
                   }
                }
            }            
            
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        } 
    }

    public void populateCreatedByRole(final List<Task> newObjects) {
        //populate Created by role field when the task record is created
        Set<Id> roleIds = new Set<Id>();
        try{
            LogControl.push('populateCreatedByRole', this.CLASS_NAME);
            for(Task task : newObjects){
                roleIds.add(UserInfo.getUserRoleId());
            }
            Map<Id, UserRole> rolesMap = new Map<Id,UserRole>(
                [SELECT ID, Name FROM USerRole WHERE Id IN :roleIds]);
            for(Task task : newObjects){
                task.Created_By_Role__c = rolesMap.get(userinfo.getUserRoleId())!=null?rolesMap.get(userinfo.getUserRoleId()).Name:null;
            }
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        }
    }

    public void UpdateTaskType(List<Task> newTasks){
    
        for(Task t: newTasks){
            if(t.Type != null){
                t.Type__c = t.Type;
            }
        }
    
    }

    public void updateCallitemAttemptedCalls(final List<Task> newObjects) {
        
        Set<Id> CI_Ids = new Set<Id>();
        List<Call_Item__c> CI_list= new List<Call_Item__c>(); 
        try{
            LogControl.push('updateCallitemAttemptedCalls', this.CLASS_NAME);
            for(Task task : newObjects){
                if(task.WhatId != null && task.WhatId.getSobjectType().getDescribe().getName()=='Call_Item__c'){
                    CI_Ids.add(task.WhatId);
                }
            }
            if(CI_Ids != null && !CI_Ids.isEmpty()){
                for(Call_Item__c ci: [SELECT Id, Attempted_Calls__c from Call_Item__c where Id in:CI_Ids]){
                    
                    ci.Attempted_Calls__c = ci.Attempted_Calls__c+1;
                    CI_list.add(ci);
                }
                if (CI_list != null && !CI_list.isEmpty()){
                    update CI_list;
                }
            }    
        }
        catch(Exception ex){
            LogControl.debugException(ex);
        }
        finally{
            LogControl.pop();
        }
    }
}
