import { api, LightningElement ,wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import sendapproval from '@salesforce/apex/SubmitforApprovalLwcInvoice.SendForApproval';

export default class cPInvoiceSubmitForApproval extends LightningElement {
	  @api recordId;
    @track cmnt;
    @track error;
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
								 this.isSpinner = true;
                 location.replace("https://runwal.lightning.force.com/lightning/r/Brokerage_Invoice__c/" + this.bId + "/view")

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

    handlecomment(event){
        this.cmnt = event.target.value;
    }

    back(){
             location.replace("https://runwal.lightning.force.com/lightning/r/Brokerage_Invoice__c/" + this.bId + "/view")
			

    }
}