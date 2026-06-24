import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import getOpportunities from '@salesforce/apex/Customer360.getOpportunities';
import getOppRecords from '@salesforce/apex/Customer360.getOppRecords';
// import getUserRelatedtoAccount from '@salesforce/apex/Customer360.getUserRelatedtoAccount';
// import getCurrentUserId from '@salesforce/apex/Customer360.getCurrentUserId';
import searchFAQs from '@salesforce/apex/Customer360.searchFAQs';
import { publish, subscribe, unsubscribe, createMessageContext, releaseMessageContext, MessageContext } from 'lightning/messageService';
import getPDFContentDocument from '@salesforce/apex/Customer360.getPDFContentDocument';
//import getQuestions from '@salesforce/apex/Customer360.getQuestions';
import getOppbasedonPercentage from '@salesforce/apex/Customer360.getOppbasedonPercentage';
import OPPORTUNITY_MESSAGE_CHANNEL from '@salesforce/messageChannel/OpportunityMessageChannel__c';
// import SEND_DATA_FROM_POPUP_TO_360 from '@salesforce/messageChannel/SendDatafromCustomer360toPopup__c';

export default class MyOpportunitiesComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    oppid;
    opportunities = [];
    bookingData = [];
    @track filesList = [];
    @track pdfDocument;
    @track showLoader = false;
    @track results = [];
    @track showPopup = false;
    searchInput = '';
    searchTerm = '';
    // @track questions = [];
    @track receivedMessage = '';
    @track myMessage = '';
    subscription = null;
    context = createMessageContext();
    @track accountUsedId;//to be sent to customer Popup
    @track currentType = 'Customer 360';// to be sent to customer popup

    @track popupopplist = [];
    @track shownewModal = false;
    @track newModal = false;
    @track completeness = 0;
    @track disableLink = false;
    opportunitydatabasedonPercentage;
    isPageRefreshed = false;
    
   
    constructor() {
        super();
    }



    connectedCallback() {
        const params = new URLSearchParams(window.location.search);

        if (params.has('c__var2')) {
            this.recordId = params.get('c__var2');
            console.log('recordId set from URL:', this.recordId);
        }
        if (params.has('c__var1')) {
            this.oppid = params.get('c__var1');
            console.log('oppid set from URL:', this.oppid);
        }
        console.log('inside connected call back');
        console.log('shownewModal' + this.shownewModal);
        this.shownewModal = false;
         
         
    }

  @wire(CurrentPageReference)
    get360PageRefrence(currentPageReference) {
        this.recordId =null;
        this.oppid =null;
        if (currentPageReference) {
            this.recordId = currentPageReference.state?.c__var2;
            this.oppid = currentPageReference.state?.c__var1;
        }}
    @wire(getOppbasedonPercentage, { accountId: '$recordId' })
    wiredOpprecordsbasedonPercentage(result) {
        this.opportunitydatabasedonPercentage = result;
        const { error, data } = result;
        if (data) {
            this.processOpportunityData(data);
        } else if (error) {
            console.error(error);
        }
    }



    updateCompletenessClass() {
        if (this.completeness === 100) {
            this.completenessClass = 'disabled-link';
        } else if (this.completeness >= 75 && this.completeness < 100) {
            this.completenessClass = 'high-completeness';
        } else if (this.completeness >= 0 && this.completeness < 75) {
            this.completenessClass = 'low-completeness';
        }
    }


    handlePopup() {
        console.log('shownewModal' + this.shownewModal);
        if (this.completeness === 100) {
            this.shownewModal = false;
            return;
        }
        this.shownewModal = true;
    }

    handleCloseModal() {
        this.shownewModal = false;
        console.log('Close Modal');
        this.refreshOpportunityData();
    }

    refreshOpportunityData() {
        getOppbasedonPercentage({ accountId: this.recordId })
            .then(data => {
                this.processOpportunityData(data);
            })
            .catch(error => {
                console.error('Error refreshing opportunity data:', error);
            });
    }

    processOpportunityData(data) {
        this.opplist = JSON.parse(JSON.stringify(data));
        console.log('this.opplist', this.opplist);
        console.log('opplist', JSON.stringify(this.opplist));
        let lowestValueItem = null;
        let lowestValue = Infinity;
        for (let key in this.opplist) {
            console.log('key', key);
            console.log('this.opplist[key]', this.opplist[key]);
            if (this.opplist[key] < lowestValue) {
                lowestValue = this.opplist[key];
                lowestValueItem = { id: key, value: this.opplist[key] };
            }
        }
        this.completeness = Math.round(lowestValue);
        this.updateCompletenessClass();
    }



    @wire(getPDFContentDocument)
    wiredResult({ error, data }) {
        if (data) {
            this.filesList = Object.keys(data).map(item => ({
                "label": data[item],
                "value": item,
                "url": `/sfc/servlet.shepherd/document/download/${item}`
            }));
        } else if (error) {
            console.error('Error fetching PDF document:', error);
        }
    }
    previewHandler(event) {
        const recordId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: recordId // your ContentDocumentId here
            }
        });
    }
    handleSearchInput(event) {
        this.searchInput = event.target.value;
    }
    closePopup() {
        this.showPopup = false;
    }

    @wire(searchFAQs, { searchTerm: '$searchTerm' })
    wiredFAQs({ error, data }) {
        if (data) {
            this.results = data;
        } else if (error) {
            console.error('Error fetching FAQs:', error);
            this.results = [];
        }
    }

    searchRecords() {
        console.log('inside search')
        if (!this.searchInput) {
            return;
        }

        this.searchTerm = this.searchInput;
        this.showPopup = true;
    }

    handlePopupClick(event) {
        if (event.target.classList.contains('popup')) {
            this.showPopup = false;
        }
    }


    @wire(getOpportunities, { accountId: '$recordId' })
    wiredOpportunities({ error, data }) {
        if (data) {
            let opportunitiesTemp = [];
            this.opportunitiesTemp = JSON.parse(JSON.stringify(data));
            console.log('opportunitiesTemp', this.opportunitiesTemp);
            this.opportunitiesTemp.forEach((op, ind) => {
                op.CustTabName = op.RW_Project__r.Name + '-' + op.Name;
            });
            this.opportunities = this.opportunitiesTemp;

            if (this.oppid) {
                this.currentSelectedOpportunityId = this.oppid;
                this.handelgetOppRecords(this.currentSelectedOpportunityId);
            } else if (this.opportunitiesTemp[0]) {
                this.currentSelectedOpportunityId = this.opportunitiesTemp[0].Id;
                this.handelgetOppRecords(this.currentSelectedOpportunityId);
            }
        } else if (error) {
            console.error(error);
        }
    }

    isOnce = true;

    renderedCallback() {
        this.handelNavActive();

        if (this.isOnce && this.currentSelectedOpportunityId) {
            this.isOnce = false;
            let Opp_checkbox = this.template.querySelectorAll('.Opp_checkbox');

            for (let i = 0; i < Opp_checkbox.length; i++) {
                if (Opp_checkbox[i].dataset.opportunityId.toLowerCase().trim() == this.currentSelectedOpportunityId.toLowerCase().trim()) {
                    Opp_checkbox[i].checked = true;
                } else {
                    Opp_checkbox[i].checked = false;
                }
            }

            let opportunityId = this.currentSelectedOpportunityId.trim();
            console.log('opportunityId' + opportunityId);
            const message = { opportunityId };
            console.log('message' + message);
            publish(this.context, OPPORTUNITY_MESSAGE_CHANNEL, message);
        }
    }

    @track currentSelectedOpportunityId = '';

    handelNavActive() {
        let navlist = this.template.querySelectorAll('.Nav-item');
        for (let i = 0; i < navlist.length; i++) {
            if (navlist[i].dataset.opportunityId == this.currentSelectedOpportunityId) {
                navlist[i].classList.add('Nav-item_active');
            } else {
                navlist[i].classList.remove('Nav-item_active');
            }
            let stagename = navlist[i].dataset.opportunityStage + '';

            if (stagename.toLowerCase() == 'cancelled') {
                navlist[i].classList.add('Nav-item_bg-red');
            } else {
                navlist[i].classList.add('Nav-item_bg-green');
            }
        }
    }

    handelgetOppRecords(opportunityid) {
        opportunityid = opportunityid.trim();

        getOppRecords({ oppId: opportunityid })
            .then(result => {
                console.log('getOppRecords::::: ', JSON.parse(JSON.stringify(result)));
                this.bookingData = JSON.parse(JSON.stringify(result));
                this.showLoader = true;
            })
            .catch(error => {
                alert(JSON.stringify(error));
                console.error('error');
                console.error(error);
                this.showLoader = true;
            });
    }

    handleCheckboxChange(event) {
        const currentCheckbox = event.target;
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"]');
        let isAnyChecked = false;

        checkboxes.forEach(checkbox => {
            if (checkbox !== currentCheckbox) {
                checkbox.checked = false;
            }
            if (checkbox.checked) {
                isAnyChecked = true;
                this.currentSelectedOpportunityId = checkbox.dataset.opportunityId;
            }
        });

        if (!isAnyChecked) {
            this.currentSelectedOpportunityId = null;
        }

        const opportunityId = this.currentSelectedOpportunityId;
        const message = { opportunityId };
        publish(this.context, OPPORTUNITY_MESSAGE_CHANNEL, message);
    }



    navigateToRecord(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

}