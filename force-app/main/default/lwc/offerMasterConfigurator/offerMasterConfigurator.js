import { LightningElement, track, wire, api } from 'lwc';
import createOffers from '@salesforce/apex/OfferMasterConfiguratorController.createOffers';
import getOffers from '@salesforce/apex/OfferMasterConfiguratorController.getOffers';
import getTowersByProject from '@salesforce/apex/OfferMasterConfiguratorController.getTowersByProject';
import getTypologyValues from '@salesforce/apex/OfferMasterConfiguratorController.getTypologyValues';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OfferMasterConfiguratorController extends LightningElement {

    @api projectId ;
    //@track selectedProjects =[] ;
    @track towerOptions = [];
    @track selectedTowers = [];
    @track allTowers = [];
    @track isDropdownVisible = false;
    @track filteredTowers = [];

    @track offers = [];
    @track selectedOfferIds =[];
    @track selectedRows =[];

    @track typologyOptions = [];
    @track filteredTypologies = [];
    @track selectedTypologies = [];
    @track isTypologyDropdownVisible = false;


    columns = [
        { label: 'Offer Name', fieldName: 'Name' },
        { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
        { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
        { label: 'Offer Value', fieldName: 'Offer_Value__c', type: 'number' },
        { label: 'Discount Category', fieldName: 'Discount_Category__c' },
        { label: 'Offer Type', fieldName: 'Offer_type__c' },
    ];
    

    @wire(getOffers)
    wiredOffers({ data, error }) {
        console.log('data',data);
        if (data) {
        this.offers = data;
        console.log('this.offers**',this.offers);
        } else if (error) {
            this.error = error;
            this.offers = [];
        }
    }

    connectedCallback() {
        this.loadTypologies();
        this.handleOutsideClick = this.handleOutsideClick.bind(this);
        document.addEventListener('click', this.handleOutsideClick);
    }

    // disconnectedCallback() {
    //     document.removeEventListener('click', this.handleOutsideClick);
    // }

    // handleOutsideClick(event) {
    //     const container = this.template.querySelector('.typology-container');

    //     if (container && !container.contains(event.target)) {
    //         this.isTypologyDropdownVisible = false;
    //     }
    // }

    handleOutsideClick = (event) => {
        const container = this.template.querySelector('.typology-container');
        if (container && !container.contains(event.target)) {
            this.isTypologyDropdownVisible = false;
        }
    };

    loadTypologies() {
        getTypologyValues()
            .then(result => {
                this.typologyOptions = result;
                this.filteredTypologies = result;
                console.log('filteredTypologies**',this.filteredTypologies);
                console.log('typologyOptions**',this.typologyOptions);
                console.log('result**',result);
            })
            .catch(error => {
                console.error(error);
            });
    }


    stopPropagation(event) {
        event.stopPropagation();
    }

    handleTypologySearch(event) {
        const searchKey = event.target.value.toLowerCase();

        // this.filteredTypologies = this.typologyOptions.filter(
        //     val => val.toLowerCase().includes(searchKey) &&
        //         !this.selectedTypologies.includes(val)
        // );

        this.filteredTypologies = this.typologyOptions.filter(opt =>
            opt.label.toLowerCase().includes(searchKey) &&
            !this.selectedTypologies.includes(opt.value)
        );

        this.isTypologyDropdownVisible = true;
    }

    get selectedTypologyLabels() {
        return this.typologyOptions.filter(opt =>
            this.selectedTypologies.includes(opt.value)
        );
    }

    handleTypologyFocus() {
        this.filteredTypologies = this.typologyOptions.filter(
            val => !this.selectedTypologies.includes(val)
        );
        console.log('filteredTypologies**',this.filteredTypologies);
        
        this.isTypologyDropdownVisible = true;
    }

    handleTypologySelect(event) {
        if (this.selectedTowers.length === 0) {
            this.showToast(
                'Error',
                'Please select Tower before selecting Typology.',
                'error'
            );
            this.isTypologyDropdownVisible = false;
            return;
        }
        const value = event.currentTarget.dataset.value;

        if (!this.selectedTypologies.includes(value)) {
            this.selectedTypologies = [...this.selectedTypologies, value];
        }
        

        this.isTypologyDropdownVisible = false;
    }

    handleRemoveTypology(event) {
        const value = event.target.name;

        this.selectedTypologies =
            this.selectedTypologies.filter(v => v !== value);
    }

    handleProjectChange(event) {
        //this.selectedProjects = event.detail.value;
        this.projectId  = event.detail.recordId;
        if (this.projectId) {
            this.loadTowers(this.projectId);
        } else {
            this.allTowers = [];
            this.selectedTowers = [];
        }
    }

    loadTowers(projectId) {
        getTowersByProject({ projectId: projectId, searchTerm: '' })
            .then(result => {
                this.allTowers = result;     
                this.selectedTowers = [];
            })
            .catch(error => {
                console.error(error);
                this.allTowers = [];
                this.selectedTowers = [];
            });
    }

    handleTowerSearch(event) {
        console.log('allTowers**',this.allTowers);
        const searchKey = event.target.value.toLowerCase();
        this.isDropdownVisible = true;
        
        // Filter by name and exclude already selected items
        this.filteredTowers = this.allTowers.filter(tower => 
            tower.Name.toLowerCase().includes(searchKey) && 
            !this.selectedTowers.some(selected => selected.Id === tower.Id)
        );
    }

    get availableTowers() {
        return this.allTowers.filter(tower => 
            !this.selectedTowers.some(selected => selected.Id === tower.Id)
        );
    }

    handleFocus() {
        if (this.projectId && this.allTowers.length > 0) {
            this.isDropdownVisible = true;
            this.filteredTowers = this.availableTowers;
        }
    }

     handleTowerSelect(event) {
        const id = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;

        // Add to selected list
        this.selectedTowers = [...this.selectedTowers, { Id: id, Name: name }];
        this.isDropdownVisible = false;
        
        // Clear filtered list for next search
        this.filteredTowers = this.allTowers.filter(t => 
            !this.selectedTowers.some(s => s.Id === t.Id)
        );
    }

    handleRemoveTower(event) {
        const idToRemove = event.detail.name;
        this.selectedTowers = this.selectedTowers.filter(item => item.Id !== idToRemove);
    }

    showDropdown() {
        this.isDropdownVisible = true;
    }    

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(row => row.Id);
        // const selectedRows = event.detail.selectedRows;
        // this.selectedOfferIds = selectedRows.map(row => row.Id);   
         this.selectedOfferIds = this.selectedRows;
     }

    handleSave() {
        if (!this.projectId.length || !this.selectedOfferIds.length) {
            this.showToast('Error', 'Select at least one project and one offer', 'error');
            return;
        }
        createOffers({
            projectIds: this.projectId,
            offerId: this.selectedOfferIds,
            towerIds :this.selectedTowers.map(t => t.Id),
            lstOfTypology : this.selectedTypologies
        })
        .then(() => {
            this.showToast('Success', 'Offers created successfully', 'success');           
            this.selectedTypologies = [];
            this.selectedTowers = [];
            this.selectedRows = [];
        })
        // .catch(error => {
        //     this.showFlowError(error);
        // });

        .catch(error => {
            // let message = error.body?.message || 'Error occurred';
            // this.showToast('Error', message, 'error');

            let message = 'Something went wrong';

            if (error?.body?.message) {
                message = error.body.message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
         });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}