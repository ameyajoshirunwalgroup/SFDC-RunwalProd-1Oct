import { LightningElement, track } from 'lwc';
import getSignedDocument from '@salesforce/apex/bulk_Aadhar_Verification_Integration.getsignedDocuments';
import getSignedStatus from '@salesforce/apex/bulk_Aadhar_Verification_Integration.getSignedStatus';
export default class AadharThankYouPage extends LightningElement {
    @track loading = true;
    uuid;
    cs;
    grp;
    status;
    miEncoded;
    
    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        this.uuid = urlParams.get('uuid');
        this.cs = urlParams.get('cs');
        this.grp = urlParams.get('grp');
        this.status = urlParams.get('status');
        this.miEncoded = urlParams.get('mi');

        
         if (this.uuid && this.cs && this.status === 'SIGNED') {
        // Instead of your old call, we decode miEncoded and call getSignedStatus with all info
        if (this.miEncoded) {
            try {
                const decodedMi = atob(this.miEncoded);
                const miJson = JSON.parse(decodedMi);
                console.log('Decoded mi JSON:', miJson);
                const signerEmail = miJson.signer;
                const signerName = miJson.signername;

                if (signerEmail && signerName) {
                    getSignedStatus({
                        uuid: this.uuid,
                        email: signerEmail,
                        name: signerName
                    })
                    .then(() => {
                        console.log(`Marked ${signerEmail} as signed.`);
                    })
                    .catch(error => {
                        console.error('Error updating applicant:', error);
                    });
                }
            } catch (e) {
                console.error('Error decoding mi:', e);
            }
        } else {
            console.error('mi parameter missing — cannot identify signer.');
        }
    }
        if (this.uuid && this.cs && this.grp=='COMPLETE') {
            getSignedDocument({ UUID: this.uuid, Cs: this.cs })
                .then((data) => {
                    console.log('Response from Apex:', data);
                    if (data && data.toLowerCase().includes('process complete')) {
                        this.loading = false;
                    } else {
                        this.loading = false;
                        console.error('Unexpected response:', data);
                    }
                })
                .catch((error) => {
                    this.loading = false;
                    console.error('Error calling Apex:', error);
                });
        } else {
            this.loading = false;
            console.error('Missing UUID or CS in URL');
        }
    }
}