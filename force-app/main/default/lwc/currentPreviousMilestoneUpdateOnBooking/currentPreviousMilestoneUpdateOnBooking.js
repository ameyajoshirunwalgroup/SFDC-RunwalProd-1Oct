import { LightningElement, api, wire } from 'lwc';
import updateMilestoneDetails from '@salesforce/apex/CurrentPreviousMilestoneUpdateOnBooking.updateMilestoneDetails';

export default class CurrentPreviousMilestoneUpdateOnBooking extends LightningElement {
    @api recordId;
    details;
    hasRun = false;

    /*@wire(updateMilestoneDetails, { bookingId: '$recordId' })
    milestoneDetails({ data, error }) {
        console.log('data : ', data);
        if (data) {
            this.details = data;
            
        } else if (error) {
            console.error(error);
        }
    }*/

    connectedCallback() {
        if (!this.hasRun) {
            this.hasRun = true;
            updateMilestoneDetails({ bookingId: this.recordId });
        }
    }
}