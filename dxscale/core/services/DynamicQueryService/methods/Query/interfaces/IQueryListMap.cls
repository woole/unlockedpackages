public interface IQueryListMap extends IService_Output_Master{
    void add(Map<String,Object> item);
    boolean hasNext();
    Map<String,Object> getNext();
    List<Map<String,Object>> getAll();
    Integer getNumberRows();
    Boolean getPotentiallyMoreRows();
    void setPotentiallyMoreRows(Boolean potentiallyMoreRows);
 
}
