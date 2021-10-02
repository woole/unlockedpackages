public inherited sharing class QueryListMap extends ServiceOutputMaster implements IQueryListMap {

    private List<Map<String,Object>> theList = new List<Map<String,Object>>();
    private Integer currentIndex = 0;
    private Boolean potentiallyMoreRows = false;

    /* creating the list */
 
    public void add(Map<String,Object> item){
        theList.add(item);
    }

    /* processing the list */

    public boolean hasNext(){
        if (currentIndex > theList.size() - 1) {
            return false;
        }
        return true;
    }

    public Map<String,Object> getNext(){
        Map<String,Object> item = theList[currentIndex];
        currentIndex++;
        return item;
    }

    public List<Map<String,Object>> getAll() {
        return theList;
    } 

    public Integer getNumberRows() {
        return theList.size();
    }

    public Boolean getPotentiallyMoreRows() {
        return potentiallyMoreRows;
    }

    public void setPotentiallyMoreRows(Boolean potentiallyMoreRows) {
        this.potentiallyMoreRows = potentiallyMoreRows;
    }

}
