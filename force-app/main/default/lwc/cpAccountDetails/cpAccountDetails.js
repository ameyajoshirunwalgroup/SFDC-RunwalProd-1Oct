import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getCPRecord from '@salesforce/apex/CPBookingController.ChannelPartnerId';
export default class CpAccountDetails extends LightningElement {
    @track CPId;
    showEditField;
    @api objectApiName = 'Broker__c';
    @api fieldList = ["Broker_Type__c","TITLE__c","NAME_FIRST__c", "NAME_MIDDLE__c", "NAME_LAST__c", "RW_Mobile_No__c","RW_Email__c", "TITLE__c",
    "RW_RERA_Registration_Number__c", "RW_GST_Number__c","Company_Name_As_per_RERA__c",
    "Broker_Pan_No__c", "Expertise__c","Experience__c","Place_of_Supply__c",
    "Developers_Worked_For__c", "Team_Size__c","House_Flat_Company__c",
    "STREET__c", "City__c","State__c","Country__c","Pin_Code__c",
    "Bank_Name__c","Cheque_DD_Favouring_Name__c","Branch_Code__c","IFSC_Code__c","Account_Number__c"];
    @api fieldUpdateList = ["RW_Mobile_No__c","Company_Name_As_per_RERA__c","Expertise__c","Experience__c",
    "Developers_Worked_For__c", "Team_Size__c","House_Flat_Company__c",
    "STREET__c", "City__c","State__c","Country__c","Pin_Code__c"];
    connectedCallback(){
        console.log('Rendered::'+this.bId);
        getCPRecord().then(result=>{
            this.CPId = result
            this.error = undefined;
        }).catch(error =>{
            window.alert("error :"+JSON.stringify(error));
        });
    }
    handleSuccess(event) {
        this.showEditField = false;
    }
    handleEdit() {
        this.showEditField = !this.showEditField;
    }
}