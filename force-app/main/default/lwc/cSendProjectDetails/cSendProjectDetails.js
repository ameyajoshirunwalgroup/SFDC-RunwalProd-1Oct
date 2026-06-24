import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import getProjectList from '@salesforce/apex/PresalesProjectDetailsController.getProjectList'; 
import getSobjectType from '@salesforce/apex/PresalesProjectDetailsController.getSObjectTypeById';
import sendProjectDetailsCommunication from '@salesforce/apex/PresalesProjectDetailsController.sendProjectDetailsAsEmail';

export default class CSendProjectDetails extends NavigationMixin(LightningElement){  

    @api recordId;
    @track sObjectType;
    @track availableProjects = [];
    @track filteredProjects = [];
    @track selectedProjectTypes = [];
    @track selectedCommunicationModes = [];

    @track paginatedProjects = [];
    @track selectedProjectIds = [];    

    @track currentPage = 1; 
    @track pageSize = 6;
    @track paginatedProjects = [];
    @track showExistingProjectScreen = false;
    @track showCrossProjectScreen = false;
    @track showFirstScreen = true;

     // Selection management properties
    @track allSelectedRows = new Set(); 
    @track selectedRowIdsForCurrentPage = [];

    @track columns = [
        { label: 'Project Name', fieldName: 'name', type: 'text' }
    ];
        @track projectTypeOptions = [ 
        { label: 'Existing Project', value: 'Existing Project' },
        { label: 'Cross Project', value: 'Cross Project' }
    ];

    @track communicationOptions = [
        { label: 'WhatsApp', value: 'WhatsApp' },
        { label: 'Email', value: 'Email' }
    ];

connectedCallback() { 
    console.log('URL:', window.location.href);
    const currentUrl = window.location.href;

    if (currentUrl) {  
        this.fetchSObjectDetails(currentUrl);
    }
}

fetchSObjectDetails(url) {     
    getSobjectType({ url: url })  
        .then(result => {
            const [recordId, sObjectType] = result.split(',');  
            this.recordId = recordId;
            this.sObjectType = sObjectType;

            console.log('Record ID:', this.recordId);
            console.log('SObject Type:', this.sObjectType);
        })
        .catch(error => {
            console.error('Error fetching details:', error);
        });
}    

    // Handle Project Type Selection
    handleProjectTypeSelection(event) { 

    console.log('inside Checkbox selection event--');   
    //this.selectedProjectTypes = event.detail.value;
    const selectedValue = event.detail.value[0]; 
 
    if (this.selectedProjectTypes.includes(selectedValue)) {
        this.selectedProjectTypes = []; 
    } else {
        this.selectedProjectTypes = [selectedValue];
    }
    }

// Handle Next Button Click
handleNext() {
        if (this.selectedProjectTypes.includes('Existing Project')) {
            this.showExistingProjectScreen = true;
            this.showCrossProjectScreen = false;
            this.showFirstScreen = false;
        } else if (this.selectedProjectTypes.includes('Cross Project')) {
            this.showExistingProjectScreen = false;
            this.showCrossProjectScreen = true;
            this.showFirstScreen = false; 
            this.fetchProjectList();
        }
    }

fetchProjectList() {
    getProjectList({ recordId: this.recordId }) // Pass recordId to Apex
        .then((result) => {
            this.availableProjects = result.map((project) => ({
                id: project.Id,
                name: project.Name
            })); 
            this.filteredProjects = [...this.availableProjects];
            this.currentPage = 1;  
            this.paginateProjects();  
        })
        .catch((error) => {
            console.error('Error fetching project list:', error);
        });
} 

    // Modified search handler to optionally preserve selections
    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        
        this.filteredProjects = this.availableProjects
            .filter(project => project.name.toLowerCase().includes(searchTerm))
            .sort((a, b) => {
                const aStartsWith = a.name.toLowerCase().startsWith(searchTerm) ? -1 : 1;
                const bStartsWith = b.name.toLowerCase().startsWith(searchTerm) ? -1 : 1;
                return aStartsWith - bStartsWith;
            });
        
        this.currentPage = 1;
        this.paginateProjects();
    }

 paginateProjects() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        
        this.paginatedProjects = this.filteredProjects.slice(startIndex, endIndex);
        
        // Set selected rows for current page based on master set
        this.selectedRowIdsForCurrentPage = this.paginatedProjects
            .filter(row => this.allSelectedRows.has(row.id))
            .map(row => row.id);
    }

handleNextPage() {
    if (this.currentPage * this.pageSize < this.filteredProjects.length) {
        this.currentPage++;
        this.paginateProjects();
    }
}

handlePreviousPage() {
    if (this.currentPage > 1) {
        this.currentPage--;
        this.paginateProjects();
    }
}

    // Handle Communication Selection
handleChangeCheckboxGroup(event) {    
        //this.selectedCommunicationModes = event.detail.value;
        const selectedMode = event.detail.value[0];
        if (this.selectedCommunicationModes.includes(selectedMode)) {
        this.selectedCommunicationModes = []; 
    } else {
        this.selectedCommunicationModes = [selectedMode];
    } 
        console.log('selected mode of communication==>'+ this.selectedCommunicationModes);
    }

        handleProjectChange(event) { 
        const selectedRows = event.detail.selectedRows;
        
        // Get all IDs on current page
        const currentPageIds = this.paginatedProjects.map(row => row.id);
        
        // Get selected IDs on current page
        const selectedIds = selectedRows.map(row => row.id);
        
        // Update master selection set
        currentPageIds.forEach(id => {
            if (selectedIds.includes(id)) {
                this.allSelectedRows.add(id); // Add if selected
            } else {
                this.allSelectedRows.delete(id); // Remove if deselected
            }  
        });
        
        // Update current page selections
        this.selectedRowIdsForCurrentPage = selectedIds;
        // DIRECTLY UPDATE selectedProjectIds (for Apex)
        this.selectedProjectIds = Array.from(this.allSelectedRows);
        
        console.log('All selected IDs:', Array.from(this.allSelectedRows));
    }
 
    // Handle previous action
    handlePrevious(){
        if( this.selectedProjectTypes == 'Cross Project'){  
            console.log('Inside select project for cross project--');
            this.showExistingProjectScreen = false; 
            this.showCrossProjectScreen = true;
        }
         if( this.selectedProjectTypes == 'Existing Project'){  
            console.log('Inside select project for existing project--'); 
            this.showExistingProjectScreen = false;
            this.showFirstScreen = true;    
        }  
    }

    handlePrevious2(){  
        this.showCrossProjectScreen = false;
        this.showFirstScreen = true;
    }

    // Handle Send Button Click
    handleSend(){ 
    // Ensure at least one communication mode is selected
    if (!this.selectedCommunicationModes || this.selectedCommunicationModes.length === 0) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please select at least one mode of communication (Email or WhatsApp) before sending.',
                variant: 'error'
            })
        );  
        return;   
    }
     // Ensure selected communication modes are passed correctly
    const selectedCommunicationModes = this.selectedCommunicationModes.length > 0 ? this.selectedCommunicationModes : [];

     // Check if project selection is available; pass as empty array if none selected
    const selectedProjectIds = this.selectedProjectIds && this.selectedProjectIds.length > 0 ? this.selectedProjectIds : [];
    console.log('selectedProjectIds==>', selectedProjectIds);   

    sendProjectDetailsCommunication({
    strLeadIdOROppIdORProspectID: this.recordId,
    strSObjectType: this.sObjectType,  
    ltsSelectedCheckBoxValueIs: selectedCommunicationModes,
    selectedProjectIds: selectedProjectIds
})
.then(result => {

    const sentProjects = result?.RW_ProjectDetails_Sent__c;
    const failedProjects = result?.RW_ProjectDetails_Send_Failed__c;
    
    let title, message, variant;

    if (sentProjects && failedProjects) {
        // Some succeeded, some failed
        title = 'Partial Success';
        message = `Successfully sent to: ${sentProjects}\nFailed to send to: ${failedProjects}`;
        variant = 'warning';
    } else if (sentProjects) {
        // All succeeded
        title = 'Success';
        message = `Successfully sent to: ${sentProjects}`;
        variant = 'success';
    } else if (failedProjects) {
        // All failed
        title = 'Failed';
        message = `Failed to send to: ${failedProjects}`;
        variant = 'error';
    } else {
        // No projects processed
        title = 'No Action';
        message = 'No projects were processed';
        variant = 'info';
    }

    this.dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        })
    );

    // Navigate to record if available
    const presalesRecordId = result?.Id;
    if (presalesRecordId) {
        this[NavigationMixin.Navigate]({ 
            type: 'standard__recordPage',
            attributes: {
                recordId: presalesRecordId, 
                actionName: 'view'
            }
        });
    }
})
.catch(error => {
        console.error('Error sending project details:', error);

            this.dispatchEvent( 
            new ShowToastEvent({
                title: 'Error',
                message: 'Failed to send Email/WhatsApp. Please verify the project brochure.',  
                variant: 'error'
            })
        );
    }); 
}

     handleSelectedProjects() {

         if (!this.selectedProjectIds || this.selectedProjectIds.length === 0) {  
            this.dispatchEvent(
                new ShowToastEvent({  
                    title: 'Error',
                    message: 'Please select at least one project before proceeding.',
                    variant: 'error'
                })
            );
            return;   
        }   
        this.showExistingProjectScreen = true;  
        this.showCrossProjectScreen = false; 
    }

    // Handle Cancel Button Click
    handleClose() {
        this.showExistingProjectScreen = false;
        this.showCrossProjectScreen = false;
        this.showFirstScreen = false;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'  
            }
        });
    }
}