public without sharing class InventoryCallout{
    //public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    @future (callout=true)
    public static void sendinventory(set<Id> projectUnitIds){
        List<Project_Unit__c> objrecords = [select id,Saleable_Area__c,New_Floor__c,New_Type__c,New_View__c,RW_Param4__c,TowerName__r.Property_Type__c,RW_Unit_Status__c , TowerName__r.SAP_Plant_Code__c ,RW_Project__r.Project_Property_Type__c ,RW_Project__r.SAPMaterial_Code__c,Unit_SAP_Code__c,Carpet_Area__c,Deck_Area__c,Utility_Area__c, RW_Project__r.Unit_of_Area_for_SAP__c  from Project_Unit__c Where id IN :projectUnitIds];
        
        Map<String, Id> mapMaterialRecordId = new Map<string, Id>();
        SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT materialDetailsList = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT();
        materialDetailsList.item = new List<SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS>();
        // SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS materialItem1 = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS();
        Map<String, SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS> requestMap = new Map<String, SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS>();
        for(Project_Unit__c pUnitInput : objrecords){
            
            
            SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS materialItem1 = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS();
            materialItem1.MATNR = pUnitInput.Unit_SAP_Code__c;           
            materialItem1.MTART = 'ZFER';
            
            materialItem1.BISMT = pUnitInput.RW_Param4__c;
            materialItem1.BRGEW = string.valueof(pUnitInput.Saleable_Area__c);
            materialItem1.NTGEW = string.valueof(pUnitInput.Carpet_Area__c);
            //materialItem1.MEINS = 'FT2'; // Commented by coServe 16-05-2024
            if(pUnitInput.RW_Project__r.Unit_of_Area_for_SAP__c != null){ // Added by coServe 16-05-2024
                materialItem1.MEINS = pUnitInput.RW_Project__r.Unit_of_Area_for_SAP__c;
            }else{
                materialItem1.MEINS = 'FT2';
            }
            if(pUnitInput.RW_Unit_Status__c == 'Available')    
                materialItem1.MSTAV = '01';
            else if(pUnitInput.RW_Unit_Status__c == 'Blocked')
                materialItem1.MSTAV = '02';
            else if(pUnitInput.RW_Unit_Status__c == 'Sold')
                materialItem1.MSTAV = '03';
            else if(pUnitInput.RW_Unit_Status__c ==  'Hold')
                materialItem1.MSTAV = '04';
            else if(pUnitInput.RW_Unit_Status__c == 'Possession Given')   
                materialItem1.MSTAV = '05';
            else if(pUnitInput.RW_Unit_Status__c == 'Refuge Units')
                materialItem1.MSTAV = '06';
            else if(pUnitInput.RW_Unit_Status__c == 'Partner Share')
                materialItem1.MSTAV = '07';
            else if(pUnitInput.RW_Unit_Status__c == 'Hold for Approval')
                materialItem1.MSTAV = '08';
            else if(pUnitInput.RW_Unit_Status__c == 'Unit Cancelled')
                materialItem1.MSTAV = '09';
            else if(pUnitInput.RW_Unit_Status__c == 'Unit Transferred')
                materialItem1.MSTAV = '10';
            else if(pUnitInput.RW_Unit_Status__c == 'Lobby')
                materialItem1.MSTAV = '12';
            else
                materialItem1.MSTAV = '11';
            materialItem1.WERKS = pUnitInput.TowerName__r.SAP_Plant_Code__c;
            materialItem1.MAKTX = pUnitInput.RW_Param4__c;
            materialItem1.VKORG = pUnitInput.RW_Project__r.SAPMaterial_Code__c;
            materialItem1.MVGR1 = pUnitInput.new_floor__c;
            materialItem1.MVGR2 = pUnitInput.new_type__c;
            
           // materialDetails.MVGR3 ---Not required
           //materialItem1.MVGR3 ='001';
           
            materialItem1.MVGR4 = pUnitInput.new_view__c;
            if(pUnitInput.new_type__c == 'R45')
                materialItem1.MVGR5 = 'Z02';
            else
                materialItem1.MVGR5 = 'Z00';
            if(pUnitInput.TowerName__r.Property_Type__c == 'Residential'){   
                materialItem1.VTWEG = '10';
                materialItem1.KONDM = 'ZA';
                materialItem1.KTGRM = 'ZA';
            }else{
                materialItem1.VTWEG = '20';
                materialItem1.KONDM = 'ZB';
                materialItem1.KTGRM = 'ZB'; 
                
            }
            // materialDetails.TAXCLASS3 = Not found
            materialItem1.DECK_A = string.valueof(pUnitInput.Deck_Area__c);
            materialItem1.UTIL_A = string.valueof(pUnitInput.Utility_Area__c);
            if(pUnitInput.Carpet_Area__c != null){
            if((pUnitInput.Carpet_Area__c)/10.764 < 60){
                materialItem1.TAXCLASS3 = '0';
                materialItem1.MFRGR = '1';
            }else{
                materialItem1.TAXCLASS3 = '1';
                materialItem1.MFRGR = '2';
            }
            }
            mapMaterialRecordId.put(pUnitInput.Unit_SAP_Code__c , pUnitInput.Id);       
            requestMap.put(pUnitInput.Unit_SAP_Code__c , materialItem1);   
        }
        materialDetailsList.item.addAll(requestMap.Values());
        Boolean callOutError = false;
        String exceptionMsg = '';
        SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT inventoryCreationResponse = new SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT();
        try{
            SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND createInventory = new SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND();
            createInventory.timeout_x = 60000;
            inventoryCreationResponse = createInventory.ZSD_SFDC_WS_MAT_CRT_CHNG(materialDetailsList);
        }catch (Exception ex) {
            callOutError = true;
            exceptionMsg = ex.getMessage();
        }finally{
            //  Map<String ,  SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS> mapResponse = new  Map<String ,  SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS>();
            List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
            if(inventoryCreationResponse.item!= null && inventoryCreationResponse.item.size()> 0)
            for(SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS res : inventoryCreationResponse.item){
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                String requestF = JSON.SerializePretty(requestMap.get(res.MATERIALNO));
                requestF =  requestF.replaceAll('&quot;','"');
                //requestF  = requestF.replaceAll('\t', '&nbsp;');
                log.request__c = requestF;
                log.API_name__c = 'Unit Inventory';                
                log.Project_Unit__c = mapMaterialRecordId.get(res.MATERIALNO);
                String responseF = JSON.SerializePretty(res);
                responseF =  responseF.replaceAll('\n','<br/>');
                responseF  = responseF.replaceAll('\t', '&nbsp;');
                log.response__c = responseF;
                if(res.Status == 'SUCCESS'){
                    log.Status__c = 'Success';
                }else{
                    if(!callOutError){
                        log.Status__c = 'Failure';
                        log.Error_Type__c='Data Error';
                        log.Error_Reason__c = res.ErrorMessage;
                    }else{
                        log.Status__c='Failure';
                        log.Error_Type__c='Timeout Error';
                        log.Error_Reason__c = exceptionMsg;
                    }
                }
                erpLogList.add(log);  
            }else{     
                for(String s : requestMap.keyset()){
                    ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                    String requestF = JSON.SerializePretty(requestMap.get(s));
                    requestF =  requestF.replaceAll('&quot;','"');
                    //requestF  = requestF.replaceAll('\t', '&nbsp;');
                    log.request__c = requestF;
                    log.API_name__c = 'Unit Inventory';                
                    log.Project_Unit__c = mapMaterialRecordId.get(s);
                    String responseF = JSON.SerializePretty(inventoryCreationResponse);
                    responseF =  responseF.replaceAll('\n','<br/>');
                    responseF  = responseF.replaceAll('\t', '&nbsp;');
                    log.response__c = responseF;
                    log.Status__c='Failure';
                    log.Error_Type__c='Timeout Error';
                    log.Error_Reason__c = exceptionMsg;
                    erpLogList.add(log);  
                    
                } 
            }
            insert erpLogList;
            /*  }
else
{
ERP_Integration_Log__c log = new ERP_Integration_Log__c();
String requestF = JSON.SerializePretty(materialDetailsList);
requestF =  requestF.replaceAll('\n','<br/>');
requestF  = requestF.replaceAll('\t', '&nbsp;');
log.request__c = requestF;
log.API_name__c = 'Unit Inventory';                
//log.Project_Unit__c = mapMaterialRecordId.get(res.MATERIALNO);
String responseF = JSON.SerializePretty(inventoryCreationResponse);
responseF =  responseF.replaceAll('\n','<br/>');
responseF  = responseF.replaceAll('\t', '&nbsp;');
log.response__c = responseF;
log.Status__c = 'Failure';
log.Error_Type__c='Timeout Error';
log.Error_Reason__c = exceptionMsg;
}*/
        } 
    }
}