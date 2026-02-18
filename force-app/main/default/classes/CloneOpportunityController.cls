/* Issue : I0087
 * Created by Sheetal on 24/12/2021
 */
public class CloneOpportunityController {
    @AuraEnabled
    public static String creteCloneOpportunities(String oppId){
        Id UserId= userinfo.getUserId();
        System.debug('Current User Id---------:'+UserId);
        User U = new User();
        U = [SELECT Id, Name, UserRole.Name FROM User WHERE Id =: UserId];  
        System.debug('Current User Role-----    ----:'+U.UserRole.Name);
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        
        Opportunity opp = [SELECT Name,AccountId,OwnerId,RW_Project__c,RW_Co_Owner_Name__c,RW_Type_of_Client__c,CampaignId,StageName,RW_Email__c,RW_Secondary_Email__c,RW_Mobile_No__c,RW_Reason_for_Cancellation__c,RW_Secondary_Mobile_No__c,RW_Booking_Date_Opp__c,RW_Phone_No__c,CloseDate,
                           RW_Sourcing_Manager__c,Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,RW_Sourcing_Head__c,NRI_OS_Sourcing_Manager__c,NRI_OS_Sourcing_Head__c,Anarock_Sourcing__c,Anarock_sourcing_manager__c,RW_Broker__c,LeadSource,Lead_Sub_Source__c,Lead_Sub_Sub_Source__c,RW_Reference_Source__c,RW_Referral_Details__c,Customer_Reference__c,
                           Corporate_Company__c,NameofUnregisteredCorporate_LeadSource__c,Booking_Feedback_Link__c,Data_Error_Fixed__c,Walk_In_Details__c,
                           RW_Opportunity_Status__c,RW_Rating__c,RW_Pre_Sales_User__c,Remark__c,RW_Site_Visit_Completion__c,RW_RM_Name__c,Corporate__c,Booking__c,Primary_Name__c,Latest_SV_Survey_Link__c,RW_Sent_to_IRIS__c,Walk_in_Corporate__c,
                           Walkin_Source__c,Walkin_SubSource__c,Walkin_sub_sub_source__c,Walk_in_Source_change__c,RW_Walkin_Channel_Partner__c,RW_Walkin_Corporate_Company__c,Name_of_Unregistered_Corporate__c,RW_Walkin_Reference_Source__c,RW_Walkin_Customer_Reference__c,Last_Site_Visit_Date__c,Date_Of_Visit__c,
                           Name_Of_Walkin_Referee__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,RW_Closing_Head__c,Allocation_Manager__c,First_Site_Visit_Date__c,RW_Number_of_Visits__c,RW_Number_of_Re_Visit__c,RW_CIF_form_number__c,Closing_type__c,
                           RW_Time_line__c,RW_Configuration__c,RW_Budget__c,RW_Others__c,RW_Floor_Choices__c,RW_Vaastu_Entry_Towards__c,RW_With_Balcony__c,Purpose__c,Client_Type__c,RW_Facing__c,RW_Neighbourhood_Places__c,RW_Number_of_Cars__c,RW_With_Servant_Room__c,RW_Sales_Manager_Comment__c,Budget_In_Cr__c,                         
                           HL_RM_Name__c,Preferred_Bank__c,Source_of_Funding__c,Sanction_Status__c,HL_Comments__c,
                           RW_Location_Rating__c,RW_Price_Rating__c,RW_Product_Flat_Size_Rating__c,RW_Product_Flat_Configuration_Rating__c,RW_Rating_Value__c,RW_Project_Amenities_Rating__c,RW_Project_Theme_Layout_Rating__c,RW_Possession_Timelines_Rating__c,RW_Runwal_Brand_Rating__c,
                           RW_Apply_Unregistered_Broker__c,RW_Unregistered_Broker_Name__c,Walkin_Apply_Unregistered_ChannelPartner__c,Walkin_Unregistered_ChannelPartner_Name__c,RW_Unregistered_Broker_Email__c,RW_Unregistered_Broker_Mobile__c,Walkin_Unregistered_ChannelPartner_Email__c,Walkin_UnregisteredChannelPartner_Mobile__c,
                           RW_AADHAR_Card_Received__c,RW_PAN_Card_Received__c,RW_Passport_Received__c,RW_AADHAR_Card_Number__c,RW_PAN_Card_Number__c,RW_Passport_Number__c,
                           RW_19_99_Received__c,RW_Customer_Applied_for_Applicant_Ledger__c,RW_Applicant_Ledger_Generated__c,Possession_NOC_by_Finance__c,Payment_received_Zero_day__c,RW_Approval_Status__c,RW_Ledger_Valid_To__c,RW_Possession_Done__c,Date_of_Possesion__c,Checklist_Date__c,
                           First_Call_Attempt_Date__c,Last_call_attempted_by__c,Last_Call_Attempt_Date__c,Last_call_description__c,Presales_Call_counter__c,First_Call_Attempt_Status__c,Last_call_attempt_status__c,call_proposed_date_of_visit__c,Next_Action_Date__c,
                           First_Sales_Call_Attempt_Date__c,Sales_Call_Attempted_By__c,Sales_Call_Attempt_Status__c,Sales_Call_Follow_Up_Bucket__c,Sales_Call_Description__c,Sales_Call_Count__c,First_Sales_Call_Attempt_Status__c,Sales_Call_Attempt_Date__c,Sales_Call_Proposed_Date_Of_Visit__c,Sales_Call_Reason_Not_Interested__c,
                           Sales_Next_Action_Date__c,Mailing_Address__c,Permanent_Address__c,
                           FV_Unit_Name__c,RW_Project_Unit__c,FV_Application_ID__c,FV_Booked_Amount__c,FV_Booked_Date__c,FV_Booked_ID__c,FV_Cancellation_Flag__c,FV_Cancelled_Date__c,Employee_Reference__c,RW_Employee_Reference__c
                           FROM Opportunity WHERE Id =: oppId];	 	//Added Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025
        
        //if(opp.OwnerId == UserId || profileName == 'Receptionist' || (U != NULL && U.UserRole.Name == 'Receptionist')){
		   if(profileName == 'Receptionist' || profileName == 'System Admin' || profileName == 'System Administrator' || U != NULL ){
            Opportunity op = opp.clone(false,true);
            op.StageName = 'Qualification';
            op.RW_Project_Unit__c = NULL;
            op.SAP_Customer_Number__c = '';
            op.SalesOrder_Number__c = '';
            op.RW_Agreement_Value__c = NULL;
            op.RW_Booking_Date_Opp__c = NULL;
            op.Booking__c = NULL;
			op.Primary_Name__c = NULL;
            op.Latest_SV_Survey_Link__c = NULL;
            op.RW_Sent_to_IRIS__c = False;
			op.Booking_Feedback_Link__c = NULL;
            op.Sales_Manager_User__c = NULL; //Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
            op.Sourcing_Manager_User__c = NULL; // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__c by Vinay 04-12-2025
            op.RW_Sourcing_Head__c = NULL;
            op.Walkin_Source__c = NULL;

           // op.Is_Customer_Portal_Account_Enabled__c =NULL;
            insert op;
            return op.Id;
        }
        else{
            return 'Error';
        }
        
    }
    
}