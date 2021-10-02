@isTest
public with sharing class CoreTestUtility {
    public static List<SObject> createRecords( List<SObject> records, Boolean doInsert, Map<String, Object> attributes ){
		Integer i = 0;
		if( attributes != null ) {
			for ( Integer j =0; j < records.size(); j ++ ) {
				SObject record = records[j];
				for (String key : attributes.keySet()) {
					Object value = attributes.get(key);
					if (value instanceof List<Object>) {
						Object obj =  ((List<Object>) value).get(i);
						if( obj instanceof SObject ){
							Id sObjectId = ((SObject) obj).Id;
							record.put( key,sObjectId );
						}
						else {
							record.put(key,obj);
						}
					} else {
						record.put(key, value);
					}
				}
				i++;
			}
		}
		if (doInsert) {
			insert records;
		}
        return records;
    }

    public static List<SObject> createSObject( Integer numToInsert, Boolean doInsert, Map<String, Object> nameValueMap , String sobjType){
        List<SObject> objList = new List<SObject>();
        for( Integer i=0; i< numToInsert; i++ ){
			SObject obj = Schema.getGlobalDescribe().get(sobjType).newSObject();
			objList.add( obj );
        }
        return createRecords( objList, doInsert, nameValueMap );
    }
}