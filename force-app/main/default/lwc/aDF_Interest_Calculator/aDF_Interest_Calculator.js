import { LightningElement, track, wire, api } from 'lwc';
import getProjects from '@salesforce/apex/Controller_ADFSICalculator.GetProjects';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SimpleInterestCalculator extends LightningElement {
    @track Principal;
    @track ROI;
    @track startDate;
    @track endDate;
    @track CalculatedInterest;
    @track TotalAmount;
    @track ADFThresholdAmount;
    @track ADFInterestRate;
    @api recordId;

   /* @wire(getProjects, { sBookingId: '$recordId' })
    wireProjectRec({ error, data }) {
        if (data) {
            console.log('in if>>>>', data);
            this.ROI = data[0].ADFInterestRate;
            this.ADFThresholdAmount = data[0].ADFThresholdAmount;
            console.log('This.ROI>>>> ', this.ROI);
        } else if (error) {
            console.error('Error retrieving data: ', error);
        }
    }*/

   handlePrincipalChange(event) {
    this.Principal = parseFloat(event.target.value) || 0;

    if (this.Principal > 0 && this.recordId) {
        getProjects({ sBookingId: this.recordId, principalAmount: this.Principal })
            .then(result => {
                if (result && result.length > 0) {
                //    this.ADFThresholdAmount = result[0].ADFThresholdAmount;
                    this.ROI = result[0].ADFInterestRate;
                }
            })
            .catch(error => {
                console.error('Error fetching project data: ', error);
            });
    }
}

    /* handleROIChange(event) {
         this.ROI = parseFloat(event.target.value) || 0;
     }
 */
    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    handleCalculations() {
        // Convert dates
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
       /* if (start < today) {
            this.CalculatedInterest = 'Start Date Must Be Today OR Later.';
            this.TotalAmount = '';
            return;
        }*/ 

        // Validate date order
        if (end <= start) {
            this.CalculatedInterest = 'End Date Must Be After Start Date.';
            this.TotalAmount = '';
           /* this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'End Date Must Be After Start Date.',
                    variant: 'error'
                })
            );*/
            return;
        }

        // Validate threshold
        if (this.Principal < this.ADFThresholdAmount) {
            this.CalculatedInterest = 'Please Enter Principal Amount Greater Than ADF Threshold Amount.';
            this.TotalAmount = '';
          /*  this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please Enter Principal Amount Greater Than ADF Threshold Amount.',
                    variant: 'error'
                })
            );*/
            return;
        }
 if (this.Principal > 0 && this.ROI > 0 && this.startDate && this.endDate) {
        // Perform interest calculation
        const diffTime = Math.abs(end - start);
        const diffYears = diffTime / (1000 * 60 * 60 * 24 * 365);

        const interest = (this.Principal * this.ROI * diffYears) / 100;
        this.CalculatedInterest = `Interest: Rs. ${interest.toFixed(2)}`;
        this.TotalAmount = `Total Amount: Rs. ${(this.Principal + interest).toFixed(2)}`;
 }
 else{
      this.CalculatedInterest = 'Please Enter All Values Correctly.';
            this.TotalAmount = '';
 }
    }
}