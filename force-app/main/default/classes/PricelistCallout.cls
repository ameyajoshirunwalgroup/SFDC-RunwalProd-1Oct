public with sharing class PricelistCallout {
    @future (callout=true)
    public static void sendPricelist(List<Id> rateids){
	
	    List<String> SAPConditionTypes = new List<String>();
          Global_Charges_SAP_Condition__mdt[] sapMappings = [SELECT Id,Label FROM Global_Charges_SAP_Condition__mdt];
           Boolean byPassTriggerExceution = false;
           for(Global_Charges_SAP_Condition__mdt sap : sapMappings){
              SAPConditionTypes.add(sap.Label);
           }
		   
        List<Rate_List__c> objrecords = [select Amount__c,Charge_Based_On_Master__c,Rate__c,Project_Unit__r.TowerName__r.Property_Type__c,Project__r.Project_Property_Type__c,Global_Charges__r.SAP_Material_Type__c,Global_Charges__r.SAP_condition_type__c,Global_Charges__r.SAP_Material_Code__c,Project__r.SAPMaterial_Code__c,Project_Unit__r.TowerName__r.SAP_Plant_Code__c,Project_Unit__r.Unit_SAP_Code__c,Project_Unit__c from Rate_List__c Where id IN :rateids and Global_Charges__r.SAP_condition_type__c != 'ZAC0'];
        
        SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT pricingDataList = new SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT();
        string ProjectUnitRecordId = '';
        if(objrecords.size() > 0){
        	 ProjectUnitRecordId = objrecords[0].Project_Unit__c;
        }
        Map<String,String> inputMap = new Map<String,String>();
        //loop through objrecords
        for(Rate_List__c priceInput : objrecords){
        string strKBETR;
        string strMATNR;
        string strVTWEG;    
            if(priceInput.Charge_Based_On_Master__c == 'Rate'){
                strKBETR = string.valueOf(priceInput.Rate__c.setScale(2, RoundingMode.HALF_UP));
            }else if(priceInput.Charge_Based_On_Master__c == 'Lumpsum'){
                strKBETR = string.valueOf(priceInput.Amount__c.setScale(2, RoundingMode.HALF_UP));
            }
            
          /*  if(priceInput.Global_Charges__r.SAP_Material_Type__c == 'ZFER' || priceInput.Global_Charges__r.SAP_condition_type__c == 'ZFR0' 
               ||priceInput.Global_Charges__r.SAP_condition_type__c ==  'ZPLC' || priceInput.Global_Charges__r.SAP_condition_type__c == 'ZSDR' )
            {
                strMATNR = priceInput.Project_Unit__r.Unit_SAP_Code__c;
            }*/
			
			 if(priceInput.Global_Charges__r.SAP_Material_Type__c == 'ZFER' || SAPConditionTypes.contains(priceInput.Global_Charges__r.SAP_condition_type__c)){
                
                strMATNR = priceInput.Project_Unit__r.Unit_SAP_Code__c;
            }else{
                strMATNR = priceInput.Global_Charges__r.SAP_Material_Code__c;
            }
            
            if(priceInput.Project_Unit__r.TowerName__r.Property_Type__c == 'Residential'){
                strVTWEG = '10';
            }else{
                strVTWEG = '20'; 
            }
            
            
            String MapKey = priceInput.Global_Charges__r.SAP_condition_type__c +'-'+ priceInput.Project__r.SAPMaterial_Code__c + '-' + priceInput.Project_Unit__r.TowerName__r.SAP_Plant_Code__c + '-' + strMATNR + '-' + strVTWEG;
            String MapValue = strKBETR;
            inputMap.put(MapKey,MapValue); 
            
        }
        pricingDataList.item = new List<SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS>();

        for (String key : inputMap.keySet()){
            List<String> Keys  = Key.split('-');
        SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS priceItem = new SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS();

            priceItem.KSCHL = Keys[0];
            priceItem.VKORG = Keys[1];
            priceItem.WERKS = Keys[2];
            priceItem.MATNR = Keys[3];                     
            priceItem.KBETR = inputMap.get(Key);
            priceItem.VTWEG = Keys[4]; 
            
            pricingDataList.item.add(priceItem);
        }   
   
        
        
        Boolean callOutError = false;
        String exceptionMsg = '';
        SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT priceResponse = new SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT();
        try{
        SAPPricelistAPI.ZSD_SFDC_WSDL_PRC_UPDT_BND createPrice = new SAPPricelistAPI.ZSD_SFDC_WSDL_PRC_UPDT_BND();
        createPrice.timeout_x = 60000;
        priceResponse = createPrice.ZSD_SFDC_WS_PRI_CRT(pricingDataList);
        }catch(Exception ex){
            callOutError = true;
            exceptionMsg = ex.getMessage();
        }finally{
            //List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            String requestF = JSON.SerializePretty(pricingDataList);
            requestF =  requestF.replaceAll('&quot;','"');
            //	requestF  = requestF.replaceAll('\t', '&nbsp;');
            log.request__c = requestF;
            log.API_name__c = 'Price Change';                
            //log.Project_Unit__c = ProjectUnitRecordId;
            String responseF = JSON.SerializePretty(priceResponse);
            responseF =  responseF.replaceAll('\n','<br/>');
            responseF  = responseF.replaceAll('\t', '&nbsp;');
            log.response__c = responseF;
            if(callOutError){
                log.Status__c = 'Failure';
                log.Error_Reason__c = exceptionMsg;
                log.Error_Type__c = 'Timeout Error';
            }else{
                log.Status__c = 'Success';
            }
            insert log;
        }
    }   
}