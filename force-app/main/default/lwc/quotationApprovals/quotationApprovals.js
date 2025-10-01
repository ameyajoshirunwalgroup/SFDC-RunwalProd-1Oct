import { api, LightningElement ,wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getApprval from '@salesforce/apex/SubmitForApprovalQuotationLwc.CheckAttachment';
import sendapproval from '@salesforce/apex/SubmitForApprovalQuotationLwc.SendForApproval';
import referralsendapproval from '@salesforce/apex/SubmitForApprovalQuotationLwc.ReferralPassbackSendForApproval';

export default class QuotationApprovals extends LightningElement {
    @api recordId;
    @track cmnt;
    @track isAttachmentExist= false;

    // get URL Parameter
    currentPageReference = null; 
    urlStateParameters = null;
    /* Params from Url */
    QId = null;  
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) 
    {
       if (currentPageReference) 
       {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    setParametersBasedOnUrl() 
    {
       this.QId = this.urlStateParameters.c__QId || null;
    }
    connectedCallback(){
        console.log('Rendered::'+this.QId);
        getApprval({QuotationId : this.QId}).then(result=>{
            console.log('Result::'+JSON.parse(JSON.stringify(result)));
            this.isAttachmentExist = JSON.parse(JSON.stringify(result));
            console.log('isAttachmentExist::'+this.isAttachmentExist);
            if(this.isAttachmentExist == false){
                this.notification()
            }
        }).catch(error =>{
            window.alert("error :"+JSON.stringify(error));
        })
    
    }

    submitapproval(){
        sendapproval({comment:this.cmnt,recId : this.QId}).then(result=>{
            console.log('Result::'+JSON.parse(JSON.stringify(result)));
            if(result)
                {
                    const saveMessage = new ShowToastEvent({
                        title :'Success !',
                        message :'Approval Sent !',
                        variant : 'success',
                        mode : 'dismissable'
                    })
                    this.dispatchEvent(saveMessage);
					location.replace("https://runwal.lightning.force.com/lightning/r/Quotation__c/"+this.QId+"/view")
                }
                else
                {
                    const saveMessage = new ShowToastEvent({
                        title :'Error !',
                        message :'Something went wrong',
                        variant : 'error',
                        mode : 'dismissable'
                    })
                    this.dispatchEvent(saveMessage);
                }
        })
				
				referralsendapproval({comment:this.cmnt,recId : this.QId}).then(result=>{
            console.log('Result::'+JSON.parse(JSON.stringify(result)));
            if(result)
                {
                    const saveMessage = new ShowToastEvent({
                        title :'Success !',
                        message :'Approval Sent !',
                        variant : 'success',
                        mode : 'dismissable'
                    })
                    this.dispatchEvent(saveMessage);
					location.replace("https://runwal.lightning.force.com/lightning/r/Quotation__c/"+this.QId+"/view")

                }
                else
                {
                    const saveMessage = new ShowToastEvent({
                        title :'Error !',
                        message :'Something went wrong',
                        variant : 'error',
                        mode : 'dismissable'
                    })
                    this.dispatchEvent(saveMessage);
                }
        })

        
    }
    notification() {
        const evt = new ShowToastEvent({
            title: "Message",
            message: 'Please upload Quotation Discount related document before sending it for approval',
            variant: "error",
            mode : 'dismissable'
        });
        this.dispatchEvent(evt);
    }
 notify() {
        const evt = new ShowToastEvent({
            title: "Message",
            message: 'Referral Passback% should be less than 1 before sending it for approval',
            variant: "error",
            mode : 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    handlecomment(event){
        this.cmnt = event.target.value;
    }

    back(){
		location.replace("https://runwal.lightning.force.com/lightning/r/Quotation__c/"+this.QId+"/view")

    }


}