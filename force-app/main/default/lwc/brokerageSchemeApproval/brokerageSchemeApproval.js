import { api, LightningElement ,wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getApprval from '@salesforce/apex/SubmitForApprovalLwc.CheckAttachment';
import sendapproval from '@salesforce/apex/SubmitForApprovalLwc.SendForApproval';
export default class BrokerageSchemeApproval extends LightningElement {
    @api recordId;
    @track cmnt;
    @track error;
    @track isAttachmentExist= false;
    // get URL Parameter
    currentPageReference = null; 
    urlStateParameters = null;
    /* Params from Url */
    bId = null;
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
       this.bId = this.urlStateParameters.c__bId || null;
    }
    connectedCallback(){
        console.log('Rendered::'+this.bId);
        getApprval({schemeId : this.bId}).then(result=>{
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
        sendapproval({comment:this.cmnt,recId : this.bId}).then(result=>{
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
                    location.replace("https://runwal.lightning.force.com/lightning/r/Brokerage_Scheme__c/"+this.bId+"/view")
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
        }).catch((error) => {
            this.error = error;
            const errMessage = new ShowToastEvent({
                title :'Error !',
                message :error.body.message,
                variant : 'error',
                mode : 'sticky'
            })
            this.dispatchEvent(errMessage);
            console.log('error-', JSON.stringify(this.error));
        });

        
    }
    notification() {
        const evt = new ShowToastEvent({
            title: "Message",
            message: 'Please upload Brokerage Scheme related document before sending it for approval',
            variant: "error",
            mode : 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handlecomment(event){
        this.cmnt = event.target.value;
    }

    back(){
        location.replace("https://runwal.lightning.force.com/lightning/r/Brokerage_Scheme__c/"+this.bId+"/view")
    }

}