import { LightningElement, api, track, wire } from 'lwc';
import getSigningURL from '@salesforce/apex/aadhar_integration_Helper.getBookingRecordID';
import getApplicants from '@salesforce/apex/aadhar_integration_Helper.getApplicants';
import downloadsignedPdf from '@salesforce/apex/aadhar_integration_Helper.downloadsignedPdf';
import downloadfinalPdf from '@salesforce/apex/aadhar_integration_Helper.downloadfinalPdf';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Aadhar_Verification_TrueSigned_LWC extends LightningElement {
    @api recordId;
    @track applicants = [];
    @track loading = true;
    uuid;
    cs;
    bookingId;


    
    
    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        this.uuid = urlParams.get('uuid');
        this.cs = urlParams.get('cs');
        this.bookingId = urlParams.get('bookingId');
        console.log('booking id in connected call back ==>', this.bookingId);
        this.recordId = this.bookingId;
       
         }
    
    
@wire(getApplicants, { srecordId: '$recordId' })
    wiredApplicants({ error, data }) {
        console.log('record id in wire method get applicant===>', this.recordId);
        console.log('in wire method get applicant');
        if (data) {
             console.log('in wire method get data', data);
            this.applicants = data;
            console.log(JSON.stringify(data));
        } else if (error) {
            console.error('Error loading applicants:', error);
        }
    }

  handleFirstSign(event) {
    var applicantNum = event.target.dataset.id;
    if(applicantNum==='Primary Applicant'){
        getSigningURL({ sRrecordId: this.recordId })
            .then((data) => {
                console.log('Signing URL from Apex:', data);
                if (data && data.startsWith('http')) {
                    this.dispatchEvent(new CloseActionScreenEvent());
                    window.location.href = data;
                } else {
                    this.loading = false;
                    console.error('Invalid signing URL received:', data);
                }
            })
            .catch((error) => {
                this.loading = false;
                console.error('Error fetching signing URL:', error);
            });
    }
      if (applicantNum === 'Second Applicant') {
          console.log('second applicant method ==>', applicantNum);
          console.log('UUID:', this.uuid);
          console.log('CS:', this.cs);
          console.log('Booking ID:', this.recordId);
          console.log('second applicant method ==>', applicantNum);
          downloadsignedPdf({ UUID: this.uuid, Cs: this.cs, bookingId: this.recordId })
              .then((data) => {
                  console.log('Signing URL from Apex:', JSON.stringify(data));
                  if (data && data.startsWith('http')) {
                      this.dispatchEvent(new CloseActionScreenEvent());
                      window.location.href = data;
                  } else {
                      this.loading = false;
                      console.error('Invalid signing URL received:', data);
                  }
              })
              .catch((error) => {
                  this.loading = false;
                  console.error('Error fetching signing URL:', error);
              });
      }
  }


    processSigningResult(){
        
    }
    

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleDownloadFinalPdf() {
    console.log('Download button clicked');

    const urlParams = new URLSearchParams(window.location.search);
    this.uuid = urlParams.get('uuid');
    this.cs = urlParams.get('cs');
    this.bookingId = urlParams.get('bookingId');

    console.log('UUID:', this.uuid);
    console.log('CS:', this.cs);
    console.log('Booking ID:', this.bookingId);

    // ✅ Use 'this.uuid' and 'this.cs' here, not 'uuid' and 'cs'
    downloadfinalPdf({ UUID: this.uuid, Cs: this.cs })
        .then(base64String => {
            console.log('Apex response received');

            if (base64String) {
                console.log('Base64 string received. Preparing download...');

                try {
                    const byteCharacters = atob(base64String);
                    const byteNumbers = new Array(byteCharacters.length);
                    for (let i = 0; i < byteCharacters.length; i++) {
                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                    }
                    const byteArray = new Uint8Array(byteNumbers);
                    const blob = new Blob([byteArray], { type: 'application/pdf' });
                    const blobUrl = URL.createObjectURL(blob);

                    const link = document.createElement('a');
                    link.href = blobUrl;
                    link.download = 'FinalSignedDocument.pdf';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    URL.revokeObjectURL(blobUrl);

                    console.log('Download triggered successfully');
                } catch (e) {
                    console.error('Error converting base64 to PDF:', e);
                }
            } else {
                console.error('Empty base64 string received from Apex');
            }
        })
        .catch(error => {
            console.error('Error calling Apex method:', error?.body?.message || error.message || JSON.stringify(error));
        });
}



   
}