public with sharing class CarParkingCallout {
    @future (callout=true)
        public static void sendCarPakingList(List<Id> carParkingChargeids)
        {
               System.debug('*After insert*'+ carParkingChargeids);
               List<Car_Parking_Charge__c> objrecords = [select SAP_Material_Code__c, Project__r.SAPMaterial_Code__c, Name, Parking__c, Status__c, 
                                                         Project__r.Project_Property_Type__c, Car_Parking_Number__c, Height_of_Car_Park_in_ft__c,
                                                         Length_of_Car_Park_in_ft__c, Width_of_Car_Park_in_ft__c
                                                         from Car_Parking_Charge__c Where id IN :carParkingChargeids];
            
              system.debug('Return value of car charge' + objrecords);
              Map<String , Id> mapMaterialRecordId = new Map<string , Id>();
            
               SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT carParkingDataList = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT();
               carParkingDataList.item = new List<SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS>();
               Map<String , SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS> requestMap = new Map<String , SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS>();
               for(Car_Parking_Charge__c carParkingInput : objrecords)
               {
                SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS carParkingItem = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS();           
                   carParkingItem.MATNR = carParkingInput.SAP_Material_Code__c ; 
                carParkingItem.MTART = 'ZCRP';
                //carParkingItem.WERKS = '1001' ;
                carParkingItem.VKORG = carParkingInput.Project__r.SAPMaterial_Code__c;
                //Added by coServe 06-06-2024 Start 
                /*if(carParkingInput.Car_Parking_Number__c != null){ //Commented by Vinay 05-05-2025
                    carParkingItem.MAKTX = carParkingInput.Car_Parking_Number__c;
                }else{
                    carParkingItem.MAKTX = carParkingInput.Parking__c + carParkingInput.Name;
                }*/
                //Added by Prashant to take care of null value being passed.. 23-05-25..
                if(carParkingInput.Parking__c!= null){
                    carParkingItem.MAKTX = carParkingInput.Parking__c + carParkingInput.Name;
                }else{
                    carParkingItem.MAKTX = carParkingInput.Name; //Added by Vinay 05-05-2025
                }
                
                carParkingItem.LENGTH = String.valueOf(carParkingInput.Length_of_Car_Park_in_ft__c);
                carParkingItem.BREADTH = String.valueOf(carParkingInput.Width_of_Car_Park_in_ft__c);
                carParkingItem.HEIGHT = String.valueOf(carParkingInput.Height_of_Car_Park_in_ft__c);
                //Commented by coServe 06-06-2024 End
                //carParkingItem.MAKTX = carParkingInput.Parking__c + carParkingInput.Name; //Commented by coServe 06-06-2024
                carParkingItem.BRGEW = '1';
                carParkingItem.NTGEW = '1';
                 carParkingItem.MEINS ='EA';
                //carParkingItem.MSTAV = carParkingInput.Status__c;
                   switch on carParkingInput.Status__c{
                       when  'Vacant' {
                           carParkingItem.MSTAV = '01';
                       }
                      when  'Booked' , 'Sold' {
                           carParkingItem.MSTAV = '03';
                       }
                       
                   }
                //carParkingItem.MVGR1 = '' ;// not required
                //carParkingItem.MVGR2 = carParkingInput.Parking__c;
                   switch on carParkingInput.Parking__c{
                       when  'Single Covered' {
                           carParkingItem.MVGR2 = 'C18';
                       }
                      when  'Single Open'  {
                           carParkingItem.MVGR2 = 'C20';
                       }
                       when  'MLCP'  {
                           carParkingItem.MVGR2 = 'C19';
                       }
                       when  'Stilt'  {
                           carParkingItem.MVGR2 = 'C02';
                       }
                       when  'Tandem Open'  {
                           carParkingItem.MVGR2 = 'C17';
                       }
                       when  'Tandem Covered'  {
                           carParkingItem.MVGR2 = 'C17';
                       }
                        when  'Covered Stack'  {
                           carParkingItem.MVGR2 = 'C21';
                       }
                       //Added by vinay 22-12-2021 Start//
                       when  'Basement'  {
                           carParkingItem.MVGR2 = 'C01';
                       }
                       //Added by vinay 22-12-2021 end//
                       //Added by coServe 18-11-2023
                       when  'Podium'  {
                           carParkingItem.MVGR2 = 'C03';
                       }
                       when  'Puzzle Car Park'  { //Added by Vinay 28-03-2025
                           carParkingItem.MVGR2 = 'C23';
                       }
                   }
                //carParkingItem.MVGR3 = '' ;// not required
                //carParkingItem.MVGR4 = '' ;// not required
                //carParkingItem.MVGR5 = '' ;// not required
                //carParkingItem.Deck_A = ''; // not required
                //carParkingItem.Util_A = '' ;// not required
                
               if(carParkingInput.Project__r.Project_Property_Type__c == 'Residential')
                 carParkingItem.VTWEG = '10';
               else
                 carParkingItem.VTWEG = '20';  
                   
                carParkingItem.TAXCLASS3 = '2'; // TAXKM
                //carParkingItem.KONDM = ''; // not required
                //carParkingItem.KTGRM = ''; // not required
                //carParkingItem.MFRGR = ''; // not required
                //carParkingItem.BISMT =  carParkingInput.Name.replace('-' , ''); //Commented by coServe 06-06-2024 Start
                //Added by coServe 06-06-2024 Start
                if(carParkingInput.Car_Parking_Number__c != null){
                    carParkingItem.BISMT =  carParkingInput.Car_Parking_Number__c;
                }else{
                    carParkingItem.BISMT =  carParkingInput.Name.replace('-' , '');
                }
                //Added by coServe 06-06-2024 End
               mapMaterialRecordId.put(carParkingInput.SAP_Material_Code__c , carParkingInput.Id);       
               requestMap.put(carParkingInput.SAP_Material_Code__c , carParkingItem);     
              
               }
                
                carParkingDataList.item.addAll(requestMap.Values());
                  Boolean callOutError = false;
                String exceptionMsg = '';
                SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT carParkingResponse = new SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT();          
               system.debug(json.serialize(carParkingDataList));
            try{
               SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND createCarParking = new SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND();
               createCarParking.timeout_x = 60000; 
               carParkingResponse = createCarParking.ZSD_SFDC_WS_MAT_CRT_CHNG(carParkingDataList); 
               System.debug('New car parking response:' +json.serialize(carParkingResponse));
            }
            catch (Exception ex) {
                    System.debug('Exception:' + ex.getMessage());
                    callOutError = true;
                    exceptionMsg = ex.getMessage();
                }
            
            finally {
                    System.debug('JSON Logger request:' + JSON.SerializePretty(carParkingResponse));
                  //  Map<String ,  SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS> mapResponse = new  Map<String ,  SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS>();
                    List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
                     if(carParkingResponse.item!= null && carParkingResponse.item.size()> 0)
                    for(SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS res : carParkingResponse.item)
                    {
                        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                        String requestF = JSON.SerializePretty(requestMap.get(res.MATERIALNO));
                        requestF =  requestF.replaceAll('&quot;','"');
                        //requestF  = requestF.replaceAll('\t', '&nbsp;');
                        log.request__c = requestF;
                        log.API_name__c = 'Car Parking Inventory';                
                           log.Car_Parking__c = mapMaterialRecordId.get(res.MATERIALNO);
                        String responseF = JSON.SerializePretty(res);
                        responseF =  responseF.replaceAll('\n','<br/>');
                        responseF  = responseF.replaceAll('\t', '&nbsp;');
                        log.response__c = responseF;
                        if(res.Status == 'SUCCESS') 
                            {
                                    log.Status__c = 'Success';
                            
                            } 
                        else 
                        {  
                            log.Status__c = 'Failure';
                         if(!callOutError){
                            log.Error_Type__c='Data Error';
                            
                            log.Error_Reason__c = res.ErrorMessage;
                        }else{
                            log.Error_Type__c='Timeout Error';
                            log.Error_Reason__c = exceptionMsg;
                        }	}
                        erpLogList.add(log);  
                        
                    } 
                     else{     
                      for(String s : requestMap.keyset())
                {
     ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                    String requestF = JSON.SerializePretty(requestMap.get(s));
                    requestF =  requestF.replaceAll('&quot;','"');
                    //requestF  = requestF.replaceAll('\t', '&nbsp;');
                    log.request__c = requestF;
                    log.API_name__c = 'Unit Inventory';                
                           log.Car_Parking__c = mapMaterialRecordId.get(s);
                    String responseF = JSON.SerializePretty(carParkingResponse);
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
                        String requestF = JSON.SerializePretty(carParkingDataList);
                        requestF =  requestF.replaceAll('\n','<br/>');
                        requestF  = requestF.replaceAll('\t', '&nbsp;');
                        log.request__c = requestF;
                        log.API_name__c = 'Car Parking Inventory';                
                           //log.Project_Unit__c = mapMaterialRecordId.get(res.MATERIALNO);
                        String responseF = JSON.SerializePretty(carParkingResponse);
                        responseF =  responseF.replaceAll('\n','<br/>');
                        responseF  = responseF.replaceAll('\t', '&nbsp;');
                        log.response__c = responseF;
                        log.Status__c = 'Failure';
                        log.Error_Reason__c = exceptionMsg;
                     }*/
                } 
             
               
        } 
    }