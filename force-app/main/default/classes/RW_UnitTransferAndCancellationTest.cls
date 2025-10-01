@isTest
public class RW_UnitTransferAndCancellationTest {
    
   	@isTest
    public static void TestgetBookingInformation(){
        
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SAPInventoryCallMock());
        Test.stopTest();
            
        
        UserRole obj=new UserRole(Name= 'ABC'); 
		insert obj;
            
        Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];

        
        String orgId1 = UserInfo.getOrganizationId();
        String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName1 = orgId1 + dateString1 + randomInt1;
        User tuser1 = new User(  firstname = 'TestUser',
                               lastName = 'TestUser',
                               email = uniqueName1 + '@gmail' +'.com',
                               Username = uniqueName1 + '@test' + orgId1 + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName1.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = p1.id,
                               UserRoleId = obj.Id
                              );
        insert tuser1;
            
         List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0]){    
                String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
                //Inserting account
                Account objAcc = new Account();
                objAcc.FirstName ='TestAccount11';
                objAcc.RecordTypeID=recordTypeId ;
                objAcc.LastName ='TestAccount22';
                objAcc.PersonEmail = 'wc@email.com';
                objAcc.City__c='TestCity';
                objAcc.RW_Zip_Code__c = '9999999';
                objAcc.State__c ='Karnataka';
                objAcc.Country__c ='India';
                objAcc.Mobile_No__c = '9876543212';
                objAcc.Alternate_Email__c = 'wc1@email.com';
                objAcc.Gender__c='Male';
                objAcc.Salutation = 'Mr.';
                objAcc.Birth_Date__c = System.today().addYears(-20); 
                objAcc.OwnerId = tuser1.Id;
                insert objAcc;
                
                
                system.debug('*1*');
                //Inserting Project
                Project__c objpr = new Project__c();
                objpr.RW_Project_Code__c = 'T31';
                objpr.Name = 'Runwal Bliss';
                objpr.RDS_Short_Name__c = 'T';
                objpr.Start_Date__c = System.today().addDays(-5);
                objpr.RDS_Interest_Rate__c = 12;
                objpr.Sales_Site_Head__c = tuser1.Id;
                objpr.SAPMaterial_Code__c = '1211';
                objpr.RW_Project_Location_Videos_Link__c='test';
                objpr.RW_Project_Brochure_PublicUrl__c='test1';
                objpr.RW_SAP_Company_Code__c='5245';
                objpr.CRMHead__c = tuser1.Id;
                objpr.Overall_CRM_Head__c = tuser1.Id;
                insert objpr;
            
            Opp_Close_Date__c opc = new Opp_Close_Date__c();
            opc.Name = objpr.id;
            opc.No_of_Days__c = 60;
            opc.Project_Name__c = objpr.Name;
            insert opc;
                
                Opportunity oppRec= new Opportunity();
                oppRec.RW_Project__c=objpr.id;
                oppRec.name='Test 1';
                oppRec.RW_Email__c=objAcc.PersonEmail;
                oppRec.StageName='Qualification';
                oppRec.CloseDate=system.today()+10;
                oppRec.Status__c ='Active';
                oppRec.AccountId = objAcc.Id;
                oppRec.Sales_Manager__c = 'SM2@g.com';
                oppRec.Sourcing_Manager__c='Aniket Sapre';
                oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
                oppRec.RW_Sales_Associate__c='Karthik Chettiar';
                oppRec.RW_Closing_Head__c='Karthik Chettiar';
                oppRec.Walkin_Source__c='Direct';
                oppRec.SAP_CUstomer_Number__c='0020009875';
                oppRec.SalesOrder_Number__c ='3262627';
                oppRec.RW_Agreement_Value__c=13425663;
                oppRec.Booking_Feedback_Link__c='654864524';
                oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
                insert oppRec;
                
                Booking__c objBking = new Booking__c();
                objBking.Customer__c = oppRec.Id;
                objBking.Project__c = objpr.Id;
                objBking.Opportunity__c = oppRec.Id;
                //objBking.Unit_No__c = objPUU.id;
                objBking.Booking_Date__c = Date.today().addDays(-1);
                objBking.Status__c ='Cancellation Initiated';
                objBking.Cancellation_Requested_Status__c = 'Cancellation Confirmed';
                objBking.Cancellation_Sub_reason__c = 'Z1';
                objBking.Cancellation_Reason__c = 'Unit cancelled';
                objBking.RW_Total_Interest_Amount_Waived__c=6736;
                objBking.RW_Total_Collectable_Interest__c=6757;
                objBking.RW_Total_Amount_Collected__c=75757;
                objBking.RW_Total_Amount_Balance__c=75757;
                objBking.RW_Total_TDS_Due__c=56565;
                objBking.Floor__c=3;
                objBking.RW_Agreement_Status__c='Approved';
                objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
                objBking.Token_Amount__c=2000;
                objBking.Allotment_Premium__c=3000;
                objBking.Source_of_Booking__c='Direct';
                objBking.Carpet_Area__c=23;
                objBking.Cancellation_Request_Date__c = system.today();
                insert objBking;
                    
                RW_UnitTransferAndCancellation.getBookingInformation(objBking.id); 
                
                objBking.Status__c = 'Cancellation Initiated';
                objBking.Cancellation_Requested_Status__c = 'Cancellation Confirmed';
                objBking.Old_status__c = 'Booking Confirmed';
                objBking.Old_Opp_Status__c = 'Unit Booked';
                objBking.Is_Retained__c = false;
                objBking.Retention_Date__c = system.today();
                update objBking;
                RW_UnitTransferAndCancellation.updateRetainBooking(objBking.id);
            
            
                string cancelReason = 'Unit cancelled';
                string cancellationSubReason = 'Z1';
                string ForfeitureAmount = '9000';
                string BrokerageAmount = '9000';
                string InterestValue = '9000';
                string Taxesifany = '9000';
                string ForfeitureAmounttype = 'Total received amount';
                string Otherforfeitureamount = '9000';
                string ForfeiPercentage = '9';
                string TotalForfeitureAmount = '9000';
                string TotalRefundAmount = '9000';
                string FinalRefundAmount= '9000';
                string MVAT = '9000';
                string TDS = '9000';
                string cancellationdescription = 'Unit cancelled' ;
                string CGST =  '9000';
                string SGST = '9000';
                string TotalRecievedAmount = '9000'; 
                String cancSubType = '';
                String modeofCanc = '';
                String payRefAmt = '';
                String ResaleStatus = 'Sold';
                String newRate = '1000';
                String newFlatAgrVal = '100000';
                String recvAmt = '10000';
                String referralAmt = '1000';
            	string canceldesc = 'testing cancellation';
            	String swipeCharges = '1000';
            	String brokeragePaid = '1000';
            	String totalAmtToBeTransfrd = '100000';
            	String note = 'Test';
            	String gst = '10';
            
            	RW_UnitTransferAndCancellation.bookingcancelled(objBking.id ,cancelReason,cancellationSubReason,ForfeitureAmount,BrokerageAmount,InterestValue,Taxesifany,ForfeitureAmounttype,Otherforfeitureamount,ForfeiPercentage,TotalForfeitureAmount,TotalRefundAmount,FinalRefundAmount,MVAT ,TDS,cancellationdescription ,CGST,SGST , TotalRecievedAmount, cancSubType, modeofCanc, payRefAmt, ResaleStatus, newRate, newFlatAgrVal, recvAmt, referralAmt, swipeCharges, brokeragePaid, totalAmtToBeTransfrd, note, gst);
            
            	Map<String,String> cancDetails = new Map<String,String>();
                cancDetails.put('BrokerageAmount','1000');
                cancDetails.put('InterestValue','1000');
                cancDetails.put('Taxesifany','1000');
                cancDetails.put('Otherforfeitureamount','1000');
                cancDetails.put('TDS','1000');
                cancDetails.put('MVAT','1000');
                cancDetails.put('CGST','1000');
                cancDetails.put('SGST','1000');
                cancDetails.put('TotalRecievedAmount','1000');
                cancDetails.put('newRate','1000');
                cancDetails.put('newFlatAgrVal','1000');
                cancDetails.put('recvAmt','1000');
                cancDetails.put('referralAmt','1000');
                cancDetails.put('swipeCharges','1000');
                cancDetails.put('brokeragePaid','1000');
                cancDetails.put('totalAmtToBeTransfrd','1000');
                cancDetails.put('gst','1000');
            	cancDetails.put('BookingId',objBking.id);
                RW_UnitTransferAndCancellation.bookingcancelledUpgrade(cancDetails);
            
            	RW_UnitTransferAndCancellation.bookingUnitTransfer(objBking.id ,cancelReason,cancellationSubReason,canceldesc);
            
            	objBking.RW_Registration_Status__c = 'Registration Pending';
                objBking.Cancellation_checklist_Upload_Date__c = system.today();
                objBking.Cancellation_Checklist_Uploaded__c = true;
                objBking.Deed_of_Cancellation_Upload_Date__c = system.today();
                objBking.Cancellation_Deed_Uploaded__c = true;
                objBking.Cancellation_Letter_Upload_Date__c = system.today();
                objBking.Cancellation_Requested_Status__c = 'Cancellation Confirmed';
            	update  objBking;
            
            	RW_UnitTransferAndCancellation.sendApprovalRequest(objBking.id);
            	
            	objBking.Cancellation_Reason__c = 'Unit cancelled';
                objBking.Refund_handover_document_uploaded__c = true;
                objBking.Refund_Date__c = system.today();
                objBking.Refund_Bank__c = 'HDFC';
                objBking.Refund_Instrument_Number__c = 'HDFCIO';
                objBking.Unit_Transfer_Request_Upload_Date__c = system.today();
                objBking.Transfer_Request_Uploaded__c = true;
                update  objBking;
            	
            	RW_UnitTransferAndCancellation.updateRefundHandoverDocument(objBking.id);
        		RW_UnitTransferAndCancellation.getRefundHandoverInfo(objBking.Id);
            	
            	RW_UnitTransferAndCancellation.cloneOpportunityRecord(new List<Id> {oppRec.id}); 
            
            	RW_UnitTransferAndCancellation.updateCancellationChecklistDate(objBking.Id);   
                RW_UnitTransferAndCancellation.updateCancellationLetterDate(objBking.Id);
                RW_UnitTransferAndCancellation.updateDeedofCancellationDate(objBking.Id);
                RW_UnitTransferAndCancellation.transferRequestUpload(objBking.Id);
            	RW_UnitTransferAndCancellation.getBookingRecordData(objBking.id);
        } 
    }
    
}