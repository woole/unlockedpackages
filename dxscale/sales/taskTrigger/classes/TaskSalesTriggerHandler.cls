public inherited sharing class TaskSalesTriggerHandler extends TriggerService {
    private TaskSalesHelper taskSalesHelper;

    public TaskSalesTriggerHandler() {
        this.taskSalesHelper = new TaskSalesHelper();
    }

    public override void onBeforeInsert() {
        this.taskSalesHelper.UpdateTaskDueDate((List<Task>) listNewSObject, new Map<Id,Task>());
        this.taskSalesHelper.UpdateTaskComments((List<Task>) listNewSObject, new Map<Id,Task>());
        this.taskSalesHelper.populateCreatedByRole((List<Task>) listNewSObject);
        this.taskSalesHelper.UpdateTaskType((List<Task>) listNewSObject);
    }

    public override void onBeforeUpdate() {
        this.taskSalesHelper.UpdateTaskDueDate((List<Task>) listNewSObject, new Map<Id,Task>());
        this.taskSalesHelper.UpdateTaskComments((List<Task>) listNewSObject, new Map<Id,Task>());
        this.taskSalesHelper.UpdateTaskType((List<Task>) listNewSObject);
    }

    public override void onAfterInsert() {
        this.taskSalesHelper.updateCallitemAttemptedCalls((List<Task>) listNewSObject);
    }
}