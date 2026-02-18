import { LightningElement, api, wire } from 'lwc';
import fetchCampaignDetailsById from '@salesforce/apex/showCampaignDetailsPageHelper.fetchCampaignDetailsById';
import addMemberToCampaign from '@salesforce/apex/showCampaignDetailsPageHelper.addMemberToCampaign';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class ShowCampaignDetailsPage extends NavigationMixin(LightningElement) {

    campaignsData;

    currentPageReference = null;
    urlStateParameters = null;
    alreadyMember = false;
    showConference = false;
    /* Params from Url */
    campaignId = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;

            this.setParametersBasedOnUrl();

            this.fetchCampaignDetailsByIdMethod();
        }
    }

    setParametersBasedOnUrl() {
        this.campaignId = this.urlStateParameters.campaignId || null;
    }

    participateInCampaign() {
        console.log('clicked-----------this.campaignId' + this.campaignId);
        //if (this.campaignName == 'Seminar / Conference') 
        //  if (this.campaignName.includes('Conference')) //text.includes("world");
        // {
        console.log('in if part----' + this.campaignId);
        addMemberToCampaign({
            campaignID: this.campaignId
        })
            .then(result => {
                const tevent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Successfully Added To Campaign',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(tevent);
                setTimeout(() => {
                    window.location.reload();
                }, 1000); // wait a sec so toast is visible
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Some unexpected error occured please contact Admin',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                setTimeout(() => {
                    window.location.reload();
                }, 1000); // wait a sec so toast is visible
            });

        //  this.addMemberToCampaign();

        /*} else {
            console.log('in else part-----------this.campaignLink' + this.campaignLink);
            if (this.campaignLink != null) {
                this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: this.campaignLink
                        }
                    },
                    true // Replaces the current page in your browser history with the URL
                );
            }
        }*/

    }

    fetchCampaignDetailsByIdMethod() {
        fetchCampaignDetailsById({
            campaignID: this.campaignId
        })
            .then(result => {
                this.campaignsData = result.oneCampaign;
                this.alreadyMember = result.isAlreadyMember;
                this.showConference = result.isConferance;

                console.log('campp daaaaattttaaaa----' + JSON.stringify(this.campaignsData));

            })
            .catch(error => {
                alert(JSON.stringify(error));

            });
    }


    get campaignName() {
        return this.campaignsData?.Name;
    }
    get campaignId() {
        return this.campaignsData?.Id;
    }
     get campaignDescription() {
        return this.campaignsData?.Event_Date_Time__c;
    }
   /* get campaignStartDate() {
        return this.campaignsData?.StartDate;
    }*/
 get campaignDescription() {
        return this.campaignsData?.Description;
    }
    
    goToHomePage() {
        // let newUrl = window.location.origin;
        let newUrl = window.location.origin + '/channelpartner/s/';
        window.open(newUrl);
    }

}