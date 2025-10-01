import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, MessageContext, createMessageContext } from 'lightning/messageService';
import getOppRecords from '@salesforce/apex/Customer360.getOppRecords';
import getReceiptRecords  from '@salesforce/apex/Customer360.getReceiptRecords';
import getDemandRecords  from '@salesforce/apex/Customer360.getDemandRecords';
import sendReceiptEmail from '@salesforce/apex/EmailTemplateController.sendReceiptEmail'
import sendDemandEmail from '@salesforce/apex/EmailTemplateController.sendDemandEmail'
// import publishCasePlatformEvent from '@salesforce/apex/Customer360.publishCasePlatformEvent';
import shareVideoWithCustomer from '@salesforce/apex/Customer360.shareVideoWithCustomer';
import OPPORTUNITY_MESSAGE_CHANNEL from '@salesforce/messageChannel/OpportunityMessageChannel__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent
import getEmailTemplates from '@salesforce/apex/EmailTemplateController.getEmailTemplates';
import shareEmailTemplateWithCustomer from '@salesforce/apex/EmailTemplateController.shareEmailTemplateWithCustomer';
// import CASE_PLATFORM_EVENT from '@salesforce/schema/Case_Platform_Event__c';

export default class RightSectionComponent extends NavigationMixin(LightningElement) {
@api opportunityId;
@api recordId;
@track bookingData = [];
@track emailTemplates;
@track error;
@track showTable = false;
@wire(MessageContext)
messageContext;
subscription = null;
@track isSummaryActive = true;
@track isVideosActive = false;
@track isEmailActive = false;
@track isModalOpen = false;
videoIdToShare = null;
@track isEmailModalOpen = false;  
@track viewHtmlContent = false;
@track isReceiptModalOpen = false;
@track receiptData = []; 
@track demandData=[];
@track receipts;
@track receiptId;
@track bookingreceiptId;
@track bookingDemandId;
@track demand;
@track demands;
@track isDemandModalOpen=false;
@track selectedReceipts = new Set();
@track selectedDemandsIds;
@track selectedDemands=new Set();
@track selectedIds;

@track accountName;

emailTemplateIdToShare = null;
    subscription = null;
context = createMessageContext();
    @wire(MessageContext)
messageContext;
    @track selectedEmailContent = '';
get emailTabClass() {
return this.isEmailActive ? 'tab active' : 'tab';
}
// disconnectedCallback() {
//         releaseMessageContext(this.context);
//     }
showSummary() {
this.isSummaryActive = true;
this.isVideosActive = false;
this.isEmailActive = false;
}
showVideos() {
this.isSummaryActive = false;
this.isVideosActive = true;
this.isEmailActive = false;
}
showEmail() {
this.isSummaryActive = false;
this.isVideosActive = false;
this.isEmailActive = true;
this.loadEmailTemplates(); 
}
get summaryTabClass() {
return this.isSummaryActive ? 'tab active' : 'tab';
}

get videosTabClass() {
return this.isVideosActive ? 'tab active' : 'tab';
}

// subscribeToPlatformEvent() {
//         this.platformEventSubscription = subscribe(
//             this.context,
//             CASE_PLATFORM_EVENT,
//             (message) => this.handlePlatformEvent(message)
//         );
//     }
connectedCallback() {
this.subscribeToMessageChannel();
const params = new URLSearchParams(window.location.search);
if (params.has('c__var2')) {
    this.recordId = params.get('c__var2');
    console.log('recordId set from URL:', this.recordId);
}
if (params.has('c__var1')) {
    this.oppid = params.get('c__var1');
    console.log('oppid set from URL:', this.oppid);
}
}

subscribeToMessageChannel() {
if (!this.subscription) {
    this.subscription = subscribe(
        this.messageContext,
        OPPORTUNITY_MESSAGE_CHANNEL,
        (message) => this.handleMessage(message)
    );
}
}

navigateToNewAccountPage() {
this[NavigationMixin.Navigate]({
    type: 'standard__objectPage',
    attributes: {
        objectApiName: 'Case',
        actionName: 'new'
    },
});
}

navigateToNewReferralPage() {
this[NavigationMixin.Navigate]({
    type: 'standard__objectPage',
    attributes: {
        objectApiName: 'RW_Referral__c',
        actionName: 'new'
    },
});
}
handlePlatformEvent(message) {
    console.log('Platform event received:', message);
    this.loadBookingData();
}
handleMessage(message) {
this.opportunityId = message.opportunityId;
if (this.opportunityId) {
    this.loadBookingData();
} else {
    this.clearBookingData();
}
}

@api
loadBookingData() {
if (this.opportunityId) {
    getOppRecords({ oppId: this.opportunityId, accountId: this.recordId })
        .then(result => {
            // Parse and clone the result
            let bookingData = JSON.parse(JSON.stringify(result));

            // Sort the VideoWrapper data within each booking record by CreatedDate
            bookingData.forEach(bk => {
                if (bk.VideoWrapper) {
                    bk.VideoWrapper.sort((a, b) => new Date(a.CreatedDate) - new Date(b.CreatedDate));
                }
                this.accountName = bk.accName; // Added by Vinay 27-11-2024
                console.log('accName: ', this.accountName);
            });
            console.log('accName: ', this.accountName);
            // Assign the sorted data to this.bookingData
            this.bookingData = bookingData;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.bookingData = undefined;
        });
} else {
    this.clearBookingData();
}
}

clearBookingData() {
this.bookingData = [];
this.error = undefined;
}

handleShowRelatedItemRow(event) {
let bookingDataId = event.currentTarget.dataset.id;
console.log('handleShowRelatedItemRow bookingDataId : ', bookingDataId);

this.bookingData.forEach(ele => {
    ele.childset.forEach(echild => {
        if (echild.ObjectId == bookingDataId) {
            echild.isShowChild = !echild.isShowChild;
        }
    });
});
this.bookingData = JSON.parse(JSON.stringify(this.bookingData));
console.log('bookingData::::: ', JSON.parse(JSON.stringify(this.bookingData)));
}

toggleTable(event) {
this.showTable = !this.showTable;
const header = event.target;
header.classList.toggle('flip');
}

handleNavigateToRecord(event) {
let recordId = event.currentTarget.dataset.id;
console.log('handleNavigateToRecord');
this[NavigationMixin.GenerateUrl]({
    type: 'standard__recordPage',
    attributes: {
        recordId: recordId,
        actionName: 'view'
    }
}).then(generatedUrl => {
    window.open(generatedUrl);
});
}

handleNavigateToReceiptReport(event) {
let bId = event.currentTarget.dataset.id;
console.log('handleNavigateToRecord with RecordId:', bId);
const reportUrl = `https://runwal.lightning.force.com/lightning/r/Report/00OJ4000000FJKsMAO/view?fv0=${bId}`;
window.open(reportUrl, '_blank');
}
handleSendDemand(event)
{
    this.bookingDemandId = event.currentTarget.dataset.id;
    console.log('bId::::',this.bookingDemandId)
    this.isDemandModalOpen = true;
    
    getDemandRecords({ bookingId: this.bookingDemandId })
        .then(result => {
            this.demands = result.map(demand => ({
                ...demand,
                isSelected: false,  
                 formattedDemandDate: new Date(demand.Demand_Date__c).toLocaleDateString('en-GB'),
                 formattedDueDate: new Date(demand.Due_Date__c).toLocaleDateString('en-GB'),
            }));
        })
        .catch(error => {
            this.error = error;
            this.demands = [];
        });
        console.log('demands::::',this.demands)  
}
handleSendReciept(event) {
this.bookingreceiptId = event.currentTarget.dataset.id;
console.log('bId::::',this.bookingreceiptId)
this.isReceiptModalOpen = true;

getReceiptRecords({ bookingId: this.bookingreceiptId })
    .then(result => {
        this.receipts = result.map(receipt => ({
            ...receipt,
            isSelected: false  
        }));
    })
    .catch(error => {
        this.error = error;
        this.receipts = [];
    });
    console.log('Reciepts::::',this.receipts)
}
closeDemandModal(){
    this.isDemandModalOpen = false;
    this.selectedDemands.clear(); 
}
closeReceiptModal() {
this.isReceiptModalOpen = false;
this.selectedReceipts.clear();
}
handleDemandboxChange(event)
{
    const DemandId = event.target.dataset.id;
console.log('DemandId::',this.demandId)
if (event.target.checked) {
    this.selectedDemands.add(DemandId);
} else {
    this.selectedDemands.delete(DemandId);
}
console.log('selectedDemands::',this.selectedDemands)
}
handleCheckboxChange(event) {
const receiptId = event.target.dataset.id;
console.log('receiptId::',this.receiptId)
if (event.target.checked) {
    this.selectedReceipts.add(receiptId);
} else {
    this.selectedReceipts.delete(receiptId);
}
console.log('selectedReceipts::',this.selectedReceipts)

}
submitSelectedReceipts() {
const selectedIds = Array.from(this.selectedReceipts); // Convert Set to Array
console.log('selectedIds inside submit ::', selectedIds);

if (selectedIds.length === 0) {
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'No Receipts Selected',
            message: 'Please select at least one receipt to send.',
            variant: 'warning'
        })
    );
    return;
}

console.log('sendReceiptEmail to ids ::', selectedIds);

sendReceiptEmail({ receiptIds: selectedIds }) // Use the Array here
    .then(() => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Selected receipts have been sent successfully.',
                variant: 'success'
            })
        );
        this.closeReceiptModal();
    })
    .catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error sending receipts',
                message: error.body.message,
                variant: 'error'
            })
        );
    });
}
submitSelectedDemands() {
    const selectedDemandsIds = Array.from(this.selectedDemands); // Convert Set to Array
    console.log('selectedIds inside submit ::', selectedDemandsIds);
    
    if (selectedDemandsIds.length === 0) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'No Receipts Selected',
                message: 'Please select at least one demand to send.',
                variant: 'warning'
            })
        );
        return;
    }
    
    console.log('sendDemandEmail to ids ::', selectedDemandsIds);
    
    sendDemandEmail({ demandIds: selectedDemandsIds }) 
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected demands have been sent successfully.',
                    variant: 'success'
                })
            );
            this.closeDemandModal();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error sending receipts',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
handleNavigateToDemandReport(event) {
let bId = event.currentTarget.dataset.id;
console.log('handleNavigateToRecord with RecordId:', bId);
const reportUrl = `https://runwal.lightning.force.com/lightning/r/Report/00OJ4000000FJKtMAO/view?fv0=${bId}`;
window.open(reportUrl, '_blank');
}
navigateToApplicantReport(event) {
    let bId = event.currentTarget.dataset.id;
    console.log('handleNavigateToRecord with RecordId:', bId);
    const reportUrl = `https://runwal.lightning.force.com/lightning/r/Report/00OJ4000000FUu0MAG/view?fv0=${bId}`;
    window.open(reportUrl, '_blank');
}
navigateToCaseReport(event) {
let bId = event.currentTarget.dataset.id;
console.log('handleNavigateToRecord with RecordId:', bId);
const reportUrl = `https://runwal.lightning.force.com/lightning/r/Report/00OJ4000000FJKrMAO/view?fv0=${bId}`;
window.open(reportUrl, '_blank');
}

navigateToReferralReport(event) {
let bId = event.currentTarget.dataset.id;
console.log('handleNavigateToRecord with RecordId:', bId);
console.log('handleNavigateToRecord with RecordId:', this.accountName);
let accName = this.accountName;
const reportUrl = `https://runwal.lightning.force.com/lightning/r/Report/00OJ4000000FuBzMAK/view?fv0=${accName}`;
window.open(reportUrl, '_blank');
}

loadEmailTemplates() {
    getEmailTemplates()
        .then(result => {
            this.emailTemplates = result;
            console.log('emailTemplates::::::',this.emailTemplates);
        })
        .catch(error => {
            this.error = error;
        });
}
handleShareClick(event) {
this.videoIdToShare = event.currentTarget.dataset.id;
this.isModalOpen = true;
}

closeModal() {
this.isModalOpen = false;
this.videoIdToShare = null;
}

confirmShare() {
console.log('this.videoIdToShare', this.videoIdToShare);
shareVideoWithCustomer({ videoId: this.videoIdToShare, OppId: this.opportunityId })
    .then(() => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'The video has been shared successfully.',
                variant: 'success'
            })
        );
        this.closeModal();
    })
    .catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error sharing video',
                message: error.body.message,
                variant: 'error'
            })
        );
    });
}
handleEmailShareClick(event) {
    this.emailTemplateIdToShare = event.currentTarget.dataset.id;
    this.isEmailModalOpen = true;
}

closeEmailModal() {
    this.isEmailModalOpen = false;
    this.emailTemplateIdToShare = null;
}
confirmRMEmailShare() {
    shareEmailTemplateWithRMCustomer({ templateId: this.emailTemplateIdToShare, OppId: this.opportunityId })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The email template has been shared successfully.',
                    variant: 'success'
                })
            );
            this.closeEmailModal();
        })
        .catch(error => {
                this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error sharing video',
                message: error.body.message,
                variant: 'error'
            })
        );
    });
}
confirmRMEmailOnly() {
    shareEmailTemplateWithRMOnly({ templateId: this.emailTemplateIdToShare, OppId: this.opportunityId })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The email template has been shared successfully.',
                    variant: 'success'
                })
            );
            this.closeEmailModal();
        })
        .catch(error => {
                this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error sharing video',
                message: error.body.message,
                variant: 'error'
            })
        );
    });
}
confirmEmailShare() {
    shareEmailTemplateWithCustomer({ templateId: this.emailTemplateIdToShare, OppId: this.opportunityId })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The email template has been shared successfully.',
                    variant: 'success'
                })
            );
            this.closeEmailModal();
        })
        .catch(error => {
                this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error sharing video',
                message: error.body.message,
                variant: 'error'
            })
        );
    });
}
previewHandler(event) {


const content = event.currentTarget.dataset.content;
this.selectedEmailContent = content.replace(/\s/,"");
console.log('view html', this.selectedEmailContent);
console.log('view html', this.selectedEmailContent.split('\n'));
this.viewHtmlContent = true;
}
closehtml()
{
    this.viewHtmlContent = false;
}
}