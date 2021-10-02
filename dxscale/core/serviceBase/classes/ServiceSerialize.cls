public inherited sharing class ServiceSerialize {

    public static Object deserializeByClassName (String serialized, String className) {
        Type classType = Type.forName(className);
        return JSON.deserialize(serialized,classType);
    }

    public static Object deserializeByClassType (String serialized, Type classType) {
        return JSON.deserialize(serialized,classType);
    }

    public static String serializeObject (Object obj) {
        return JSON.serialize(obj);
    }

    public static String serializeObjectEscape (Object obj) {
        return serializeObject(obj).escapeHtml4();
    }

    public static String unescape (String escaped) {
        return escaped.unescapeHtml4();
    }

    // format for invoking a service asynchronously
    public class SerializedInvocationStructure { // change to serizliaed inocation and move to serialization class?
        public String strEncoding = 'None'; // TODO think about this to reuse this structure for PEs and http callouts
        public String strInvocationDetails;
        public String strInputData;
        public String replayid;
    }



}
