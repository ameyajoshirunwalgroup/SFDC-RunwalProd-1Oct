import { LightningElement } from 'lwc';
import getMembersByCampaignName from '@salesforce/apex/Controller_CPMeetsMarkAttendence.getMembersByCampaignName';
import getCampaignNameSuggestions from '@salesforce/apex/Controller_CPMeetsMarkAttendence.getCampaignNameSuggestions';
import getMembersByCampaignIdAndName from '@salesforce/apex/Controller_CPMeetsMarkAttendence.getMembersByCampaignIdAndName';
import getMemberNameSuggestions from '@salesforce/apex/Controller_CPMeetsMarkAttendence.getMemberNameSuggestions';
import updateCampaignMemberStatus from '@salesforce/apex/Controller_CPMeetsMarkAttendence.updateCampaignMemberStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CpMeetsCheckAttendance extends LightningElement {

    // ------------------- State -------------------
    searchKey = '';               // Campaign name search box
    memberSearchKey = '';         // Member name search box
    selectedCampaignId = '';      // Stores Id of selected campaign

    suggestions = [];             // Campaign suggestions
    showSuggestions = false;

    memberSuggestions = [];       // Member suggestions (inside selected campaign)
    showMemberSuggestions = false;

    members = [];                 // Table rows
    error;
    isLoading = false;

    editedValues = new Map();     // Track edits before save

    // ------------------- Campaign Search -------------------
    handleInput(event) {
        this.searchKey = event.target.value;

        if (this.searchKey.length > 1) {
            getCampaignNameSuggestions({ searchKey: this.searchKey })
                .then(result => {
                    this.suggestions = result;
                    this.showSuggestions = result.length > 0;
                })
                .catch(err => {
                    this.error = err;
                    this.suggestions = [];
                    this.showSuggestions = false;
                });
        } else {
            this.showSuggestions = false;
        }
    }

    handleSuggestionSelect(event) {
        const name = event.currentTarget.dataset.name;
        const record = this.suggestions.find(s => s.Name === name);
        this.searchKey = name;
        this.selectedCampaignId = record?.Id || '';
        this.showSuggestions = false;
        this.fetchMembersByCampaign();
    }

    fetchMembersByCampaign() {
        if (!this.selectedCampaignId) {
            this.members = [];
            return;
        }
        this.isLoading = true;
        getMembersByCampaignName({ searchKey: this.searchKey })
            .then(data => this.prepareMembers(data))
            .catch(error => { this.error = error; this.members = []; })
            .finally(() => { this.isLoading = false; });
    }

    // ------------------- Member Search with Suggestions -------------------
    handleMemberInput(event) {
        this.memberSearchKey = event.target.value;

        if (this.memberSearchKey.length > 1 && this.selectedCampaignId) {

            // 1️⃣ show type-ahead suggestions
            getMemberNameSuggestions({
                campaignId: this.selectedCampaignId,
                searchKey: this.memberSearchKey
            })
                .then(result => {
                    this.memberSuggestions = result;
                    this.showMemberSuggestions = result.length > 0;
                })
                .catch(err => {
                    this.error = err;
                    this.memberSuggestions = [];
                    this.showMemberSuggestions = false;
                });

            // 2️⃣ refresh table as user types (keeps old behaviour)
            getMembersByCampaignIdAndName({
                campaignId: this.selectedCampaignId,
                searchKey: this.memberSearchKey
            })
                .then(data => this.prepareMembers(data))
                .catch(err => { this.error = err; });

        } else if (this.memberSearchKey.length === 0) {
            this.showMemberSuggestions = false;
            this.fetchMembersByCampaign(); // reset table to all members
        } else {
            this.showMemberSuggestions = false;
        }
    }

    handleMemberSuggestionSelect(event) {
        const name = event.currentTarget.dataset.name;
        this.memberSearchKey = name;
        this.showMemberSuggestions = false;

        getMembersByCampaignIdAndName({
            campaignId: this.selectedCampaignId,
            searchKey: name
        })
            .then(data => this.prepareMembers(data))
            .catch(err => { this.error = err; });
    }

    // ------------------- Table Mapper -------------------
    prepareMembers(data) {
        this.members = data.map(m => ({
            Id: m.Id,
            Status: m.Status,
            memberName: m.Contact ? m.Contact.Name : '',
            MobilePhone: m.MobilePhone,
            memberEmail: m.Contact ? m.Contact.Email : '',
            AdditionalAttendees: m.Additional_Attendees__c,
            CampaignName: m.Campaign ? m.Campaign.Name : '',
            isAttended: m.Is_Attended__c,
            totalAttendees: m.Total_Attendees__c
        }));
        this.error = undefined;
        this.editedValues.clear();
    }

    handleCheckboxChange(event) {
        const id = event.target.dataset.id;
        this.saveEdit(id, 'Is_Attended__c', event.target.checked);
    }

    handleAttendeesChange(event) {
        const id = event.target.dataset.id;
        let value = event.target.value;
        if (value < 0) {
            value = 0;
            event.target.value = 0;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Total Attendees cannot be negative.',
                    variant: 'error'
                })
            );
        }
        this.saveEdit(id, 'Total_Attendees__c', value);
    }

    saveEdit(id, field, value) {
        const row = this.editedValues.get(id) || { Id: id };
        row[field] = value;
        this.editedValues.set(id, row);
    }

    /*   handleSave() {
           if (this.editedValues.size === 0) return;
   
           updateCampaignMemberStatus({ lstMember: Array.from(this.editedValues.values()) })
               .then(() => {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Success',
                           message: 'Information updated successfully',
                           variant: 'success'
                       })
                   );
                   this.fetchMembersByCampaign();
               })
               .catch(error => {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Error updating records',
                           message: error.body.message,
                           variant: 'error'
                       })
                   );
               });
       }*/
    isSaved = false;
    handleSave() {
        if (this.editedValues.size === 0) return;

        const updates = Array.from(this.editedValues.values());
 // ---------------- Client-side Validation ----------------
    for (let row of updates) {
        if (row.Is_Attended__c && (!row.Total_Attendees__c && row.Total_Attendees__c !== 0)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Total Attendees is required when marking attended.',
                    variant: 'error'
                })
            );
            return; // Stop save if validation fails
        }
    }
        updateCampaignMemberStatus({ lstMember: updates })
            .then(() => {
                // 🔹 Update the local array with the same values we just saved
                updates.forEach(u => {
                    const row = this.members.find(m => m.Id === u.Id);
                    if (row) {
                        if ('Is_Attended__c' in u) row.isAttended = u.Is_Attended__c;
                        if ('Total_Attendees__c' in u) row.totalAttendees = u.Total_Attendees__c;
                        row.isSaved = true;
                    }
                });

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Information updated successfully',
                        variant: 'success'
                    })
                );

                this.editedValues.clear();   // clear the temporary edits
             
            })
            .catch(error => {
            // ---------------- Server-side Error Handling ----------------
            let message = 'Unknown error';
            if (error.body) {
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (error.body.message) {
                    message = error.body.message;
                }
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating records',
                    message: message,
                    variant: 'error'
                })
            );
        });
    }

}