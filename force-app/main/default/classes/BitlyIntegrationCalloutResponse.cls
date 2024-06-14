public class BitlyIntegrationCalloutResponse {
    
    public String created_at {get;set;} 
    public String id {get;set;} 
    public String link {get;set;} 
    public List<Custom_bitlinks> custom_bitlinks {get;set;} 
    public String long_url {get;set;} 
    public Boolean archived {get;set;} 
    public List<Custom_bitlinks> tags {get;set;} 
    public List<Custom_bitlinks> deeplinks {get;set;} 
    public References references {get;set;} 
    
    public class Custom_bitlinks {}
    
    public class References {
        public String group_Z {get;set;} // in json: group
        
        public References(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'group') {
                            group_Z = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'References consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
    
}