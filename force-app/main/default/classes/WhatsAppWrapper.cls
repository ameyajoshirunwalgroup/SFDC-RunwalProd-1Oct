public class WhatsAppWrapper {
	Public WhatsAppWrapper(){}
    	public class Components {
		//public String default_Z {get;set;} // in json: default
        public String type_Z {get;set;}
        public List<Parameters> parameters {get;set;} 
        //public Parameters parameters {get;set;} 
         
		public Components(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
                    System.debug('text: ' + text);
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'parameters') {
							//parameters = new Parameters(parser);
                            parameters = arrayOfParameters(parser);
						}else {
							System.debug(LoggingLevel.WARN, 'Components consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    public class Parameters {
		//public String default_Z {get;set;} // in json: default
        public String type_Z {get;set;}
        public String text_Z {get;set;}
         
		public Parameters(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
                    System.debug('text: ' + text);
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'text') {
							text_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Parameters consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    private static List<Parameters> arrayOfParameters(System.JSONParser p) {
        List<Parameters> res = new List<Parameters>();
        System.debug('p: ' + p);
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Parameters(p));
            System.debug('res: ' + res);
        }
        return res;
    }
	
	public class Template {
		public String namespace {get;set;} 
		public String name {get;set;} 
		public Language language {get;set;} 
        //public Components components {get;set;}
		public List<Components> components {get;set;} 
        public Template(){}
		public Template(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'namespace') {
							namespace = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'language') {
							language = new Language(parser);
						} else if (text == 'components') {
							components = arrayOfComponents(parser);
                            //components = new Components(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Template consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Integer business_id {get;set;} 
	public String to {get;set;} 
	public String type_Z {get;set;} // in json: type
	public Template template {get;set;} 

	public WhatsAppWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'business_id') {
						business_id = parser.getIntegerValue();
					} else if (text == 'to') {
						to = parser.getText();
					} else if (text == 'type') {
						type_Z = parser.getText();
					} else if (text == 'template') {
						template = new Template(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Language {
		public String policy {get;set;} 
		public String code {get;set;} 
        public Language(){}
		public Language(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'policy') {
							policy = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Language consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static JSON2Apex parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new JSON2Apex(parser);
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
	




    private static List<Components> arrayOfComponents(System.JSONParser p) {
        List<Components> res = new List<Components>();
        System.debug('p: ' + p);
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            System.debug('p.getCurrentToken(): ' + p.getCurrentToken());
            res.add(new Components(p));
            System.debug('res: ' + res);
        }
        return res;
    }
}