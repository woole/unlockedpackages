global class PracticeEfficiencyReview_Schedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {             
        // We now call the batch class to be scheduled
        PracticeEfficiencyReview_Batch b = new PracticeEfficiencyReview_Batch();      
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    } 
}