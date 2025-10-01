import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import updateTaskLocation from '@salesforce/apex/CPTasklocationController.updateTaskLocation';
import getTaskById from '@salesforce/apex/CPTasklocationController.getTaskById';

export default class CpMeetingLocation extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    currentLocation = {};
    @track currentaddress = '';
    @track latitude;
    @track longitude;
    @track status;  // Track task status
    wiredTaskResult;

    // Getter to check if the task is completed
    get isTaskCompleted() {
        return this.status === 'Completed';
    }

    @wire(getTaskById, { taskId: '$recordId' })
    wiredTask({ error, data }) {
        if (data) {
            this.handleData(data);
        } else if (error) {
            this.handleError(error);
        }
    }

    handleData(task) {
        console.log('Task object:', JSON.stringify(task));
        
        // Extract latitude, longitude, and status
        this.latitude = task.CP_Meeting_Address__Latitude__s || null;
        this.longitude = task.CP_Meeting_Address__Longitude__s || null;
        this.status = task.Status || null;

        console.log('Extracted Latitude:', this.latitude);
        console.log('Extracted Longitude:', this.longitude);
        console.log('Task Status:', this.status);

        if (this.latitude && this.longitude) {
            this.currentaddress = `${this.latitude},${this.longitude}`;
        } else {
            this.currentaddress = 'Location is not updated';
        }
    }

    handleError(error) {
        console.error('Error received:', error);
        this.showToast('Error', 'Failed to retrieve task location data.', 'error');
        this.currentaddress = 'Location is not available';
    }

    handleButtonClick(event) {
        this.showSpinner = true;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                this.storePosition.bind(this),
                this.handleLocationError.bind(this),
                { enableHighAccuracy: true }
            );
        } else {
            this.showToast('Error', 'Geolocation is not supported by this browser.', 'error');
            this.showSpinner = false;
        }
    }

    storePosition(position) {
        this.currentLocation.latitude = position.coords.latitude;
        this.currentLocation.longitude = position.coords.longitude;
        this.currentaddress = `Latitude: ${this.currentLocation.latitude}, Longitude: ${this.currentLocation.longitude}`;
        this.updateTaskWithLocation(); 
    }

    async updateTaskWithLocation() {
        try {
            await updateTaskLocation({
                taskId: this.recordId,
                latitude: this.currentLocation.latitude,
                longitude: this.currentLocation.longitude
            });
            this.showSpinner = false;
            this.showToast('Success', 'Location updated on Task successfully!', 'success');
            setTimeout(() => {
                eval("$A.get('e.force:refreshView').fire();");
            }, 3000);

        } catch (error) {
            this.showSpinner = false;
            this.showToast('Error', 'Failed to update Task with location', 'error');
            console.error(error);
        }
    }

    handleLocationError(error) {
        this.showSpinner = false;
        let message = '';
        switch (error.code) {
            case error.PERMISSION_DENIED:
                message = 'Please enable your device location setting.';
                break;
            case error.POSITION_UNAVAILABLE:
                message = 'Location information is unavailable.';
                break;
            case error.TIMEOUT:
                message = 'The request to get user location timed out.';
                break;
            default:
                message = 'An unknown error occurred.';
                break;
        }
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}