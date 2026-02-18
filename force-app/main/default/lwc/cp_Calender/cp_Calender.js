import { LightningElement, track } from 'lwc';
import getCampaignsForCurrentUser from '@salesforce/apex/Controller_CampaignCPPortal.getCampaignsForCurrentUser';
import fetchCampaignDetailsById from '@salesforce/apex/showCampaignDetailsPageHelper.fetchCampaignDetailsById';
import addMemberToCampaign from '@salesforce/apex/showCampaignDetailsPageHelper.addMemberToCampaign';
import saveDeclinedToCampaign from '@salesforce/apex/showCampaignDetailsPageHelper.saveDeclinedToCampaign';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import SP_Hub_Campign_Types from '@salesforce/label/c.CPMeetsCampaign';
import SPHubCampaignResource from '@salesforce/resourceUrl/SPHubCampaignResource';

export default class Cp_Calender extends NavigationMixin(LightningElement) {

    @track campaigns;
    @track numberOfEvents;

    connectedCallback() {
        this.loadUserCampaigns();
    }
loadUserCampaigns() {
    getCampaignsForCurrentUser()
        .then(data => {
            this.campaigns = JSON.parse(JSON.stringify(data));
            this.numberOfEvents = this.campaigns.length;

            this.campaigns.forEach(c => {
                fetchCampaignDetailsById({ campaignID: c.Id })
                    .then(res => {
                        // Set flags based on user's RSVP status
                        c.isAlreadyMember = res.isAlreadyMember; 
                        c.showSeeYouAtEvent = res.hasRSVPed; // show "See You At Event" if RSVP already yes
                        c.showRSVPButtons = res.isAlreadyMember && !res.hasRSVPed; // show RSVP buttons only if member but not RSVPed yet
                        c.showGuestPrompt = false; // hide additional attendees initially
                        c.guestCount = 1;
                        c.totalAttendees = res.totalAttendees;
c.showDeclineMsg= res.hasDeclined
                    })
                    .catch(err => console.error(err));
            });
        })
        .catch(err => console.error(err));
}

    handleGuestChange(event) {
        const id = event.currentTarget.dataset.id;
        const value = event.target.value;
        this.campaigns = this.campaigns.map(c => {
            if(c.Id === id) c.guestCount = value;
            return c;
        });
    }

    handleRSVPYes(event) {
        const id = event.currentTarget.dataset.id;
        this.campaigns = this.campaigns.map(c => {
            if(c.Id === id) {
                c.showGuestPrompt = true; // Show additional attendees input
                c.showRSVPButtons = false; // Hide RSVP buttons
            }
            return c;
        });
    }

    handleRSVPNo(event) {
        const id = event.currentTarget.dataset.id;
        this.campaigns = this.campaigns.map(c => {
            if(c.Id === id) {
                c.showRSVPButtons = false; // Hide RSVP buttons
                c.isAlreadyMember = false; // don't show "See You At Event"
                 c.showDeclineMsg = true;
            }
            return c;
        });
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Declined',
                message: 'You have declined to attend this event.',
                variant: 'info'
            })
        );
        saveDeclinedToCampaign({ campaignID: id })
    .then(() => console.log('Declined saved'))
    .catch(err => console.error(err));
    }

    handleShowRSVPAgain(event) {
        const id = event.currentTarget.dataset.id;
        this.campaigns = this.campaigns.map(c => {
            if (c.Id === id) {
                c.showRSVPButtons = true;
                c.showSeeYouAtEvent = false;
                c.showDeclineMsg = false;
            }
            return c;
        });
    }
    confirmRegistration(event) {
    const id = event.currentTarget.dataset.id;
    const selectedCampaign = this.campaigns.find(c => c.Id === id);
    const guestCount = parseInt(selectedCampaign.guestCount, 10) || 0;

    addMemberToCampaign({ campaignID: id, guestCount: guestCount })
        .then(res => {
            if(res) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Registered',
                        message: 'Registration Confirmed!',
                        variant: 'success'
                    })
                );

                // Update UI: hide RSVP and guest input, show "See You At Event"
                this.campaigns = this.campaigns.map(c => {
                    if(c.Id === id) {
                        c.showGuestPrompt = false;
                        c.showRSVPButtons = false;
                        c.showSeeYouAtEvent = true; // show after confirm
                        c.totalAttendees = guestCount;
                    }
                    return c;
                });
            }
        })
        .catch(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Some unexpected error occurred.',
                    variant: 'error'
                })
            );
        });
}

    // Navigation functions
    navigateToCampainDetailsLWC(event) {
        const campaignId = event.currentTarget.dataset.id;
        const prefix = window.location.href.includes("/channelpartner/") ? '/channelpartner/s/' : '/s/';
        const newUrl = window.location.origin + prefix + 'cp-event-detail-page?campaignId=' + campaignId;
        this[NavigationMixin.Navigate]({ type: 'standard__webPage', attributes: { url: newUrl } }, true);
    }

    navigateToAllEvents(event) {
        const isStrategicPartner = window.location.href.includes("/channelpartner/");
        const newUrl = isStrategicPartner
            ? window.location.origin + '/channelpartner/s/all-cp-events'
            : window.location.origin + '/s/all-cp-events';
        this[NavigationMixin.Navigate]({ type: 'standard__webPage', attributes: { url: newUrl } }, true);
    }

    navigateToPastEvents(event) {
        const isStrategicPartner = window.location.href.includes("/channelpartner/");
        const newUrl = isStrategicPartner
            ? window.location.origin + '/channelpartner/s/all-cp-past-events'
            : window.location.origin + '/s/all-cp-past-events';
        this[NavigationMixin.Navigate]({ type: 'standard__webPage', attributes: { url: newUrl } }, true);
    }
}