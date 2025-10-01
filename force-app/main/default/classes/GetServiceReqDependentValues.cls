@RestResource(urlMapping='/GetServiceReqDependentValues/*')
global without sharing class GetServiceReqDependentValues {
    
    @HttpGet
    global static List<String> getServiceReqDependentValues(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Schema.sObjectField dependentField;
        String data = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('data: ' + data);
        if(data != null && data != ''){
            //String fieldNm = data.split(':')[0];
            //String fieldval = data.split(':')[1];
            List<String> dataSplit = data.split(':');
            String fieldNm = (dataSplit.size() >= 1)? data.split(':')[0] : '';
            String fieldval = (dataSplit.size() >= 2)? data.split(':')[1] : '';
            fieldval = fieldval.replace('%20', ' ');
            System.debug('fieldval: ' + fieldval);
            if(fieldNm == 'RW_Complaint_Type__c'){
                dependentField = Case.RW_Complaint_Type__c;
            }else if(fieldNm == 'RW_Complaint_SubType__c'){
                dependentField = Case.RW_Complaint_SubType__c;
            }
            Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
            //Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe(); //Commented by Vinay 29-01-2025
            //Schema.sObjectField controllerField = dependentFieldResult.getController(); //Commented by Vinay 29-01-2025
            //Added by Vinay 29-01-2025 Start
            Schema.DescribeFieldResult dependentFieldResult;
            Schema.sObjectField controllerField;
            if(dependentField != null)
                dependentFieldResult = dependentField.getDescribe();
            if(dependentFieldResult != null)
                controllerField = dependentFieldResult.getController();
            //Added by Vinay 29-01-2025 End
            if(controllerField == null){
                return null;
            } 
            Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
            List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
            
            
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
                
                if (entry.isActive()){
                    List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                    
                    for (Integer i = 0; i < controllerValues.size(); i++){
                        Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                        System.debug('controllerValues[i].getLabel(): ' + controllerValues[i].getLabel());
                        System.debug('fieldval: ' + fieldval);
                        if(controllerValues[i].getLabel() == fieldval){
                            Integer bitIndex = i / 6;
                            Integer bitShift = 5 - Math.mod(i, 6 );
                            if (bitIndex > base64chars.size() - 1) {
                                break;
                            }
                            if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                                continue;
                            }
                            if (!dependentPicklistValues.containsKey(controllerValue)){
                                dependentPicklistValues.put(controllerValue, new List<String>());
                            }
                            dependentPicklistValues.get(controllerValue).add(entry.getLabel()); 
                        }
                        
                    }               
                    
                }
            }
            if(fieldval != null){
                return dependentPicklistValues.get(fieldval);
            }
        }
        
        return null;
    }
}