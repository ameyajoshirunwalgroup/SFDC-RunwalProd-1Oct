import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import updateTaskLocation from '@salesforce/apex/CPTasklocationController.updateTaskLocation';
import getTaskById from '@salesforce/apex/CPTasklocationController.getTaskById';
import getRestrictedLocations from '@salesforce/apex/CPTasklocationController.getRestrictedLocations';
import FORM_FACTOR from "@salesforce/client/formFactor"

export default class CpMeetingLocation extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = false;
    currentLocation = {};
    @track currentaddress = '';
    @track latitude;
    @track longitude;
    @track status;  // Track task status
    wiredTaskResult;

    lstMarkers = [];
    zoomlevel = "1";
    @track latitudes;
    @track longitudes;
    @track isLoaded = false;
    latestLong;
    latestLatitude;
    isMobile = false;
    isDesktop = false;

    
    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.isDesktop = true;
        } else if (FORM_FACTOR === "Medium") {
            this.isMobile = true;
        } else if (FORM_FACTOR === "Small") {
            this.isMobile = true;
        }
    }

    // Getter to check if the task is completed
    get isTaskCompleted() {
        return this.status === 'Completed';
    }

    // @wire(getTaskById, { taskId: '$recordId' })
    // wiredTask({ error, data }) {
    //     if (data) {
    //         this.handleData(data);
    //     } else if (error) {
    //         this.handleError(error);
    //     }
    // }
    connectedCallback() {
        debugger;
        this.isLoaded = true;
        this.handleFormFactor();
        getRestrictedLocations({}).then(result => {
            this.restrictedLocations = result;
        }).catch(error=>{})
        getTaskById({ taskId: this.recordId }).then(result => {
            console.log('Check result--->',result);
            this.handleData(result);
        })
    }

    handleData(task) {
        console.log('Task object:', JSON.stringify(task));
        
        // Extract latitude, longitude, and status
        this.latestLatitude = task.CP_Meeting_Address__Latitude__s || null;
        this.latestLong = task.CP_Meeting_Address__Longitude__s || null;
        this.status = task.Event_Status__c || null;
        this.lstMarkers = [{
            location: {
                Latitude: task.CP_Meeting_Address__Latitude__s,
                Longitude: task.CP_Meeting_Address__Longitude__s
            },
            title: 'Check In Location'
        }
        ];
        this.zoomlevel = "15";
        this.isLoaded = false;
    }

    handleError(error) {
        console.error('Error received:', error);
        this.showToast('Error', 'Failed to retrieve Event location data.', 'error');
        this.currentaddress = 'Location is not available';
    }

    handleButtonClick(event) {
        this.isLoaded = true;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                this.storePosition.bind(this),
                this.handleLocationError.bind(this),
                { enableHighAccuracy: true }
            );
        } else {
            this.showToast('Error', 'Geolocation is not supported by this browser.', 'error');
            this.isLoaded = false;
        }
    }

    storePosition(position) {
        this.currentLocation.latitude = position.coords.latitude;
        this.currentLocation.longitude = position.coords.longitude;
        this.currentaddress = `Latitude: ${this.currentLocation.latitude}, Longitude: ${this.currentLocation.longitude}`;
        // 🚫 Check if user is near RCC or HO
        if (this.isInRestrictedArea(this.currentLocation.latitude, this.currentLocation.longitude)) {
            this.isLoaded = false;
            this.showToast('Error', 'You cannot capture location at HO or RCC address.', 'error');
            return;
        }
        this.updateTaskWithLocation(); 
    }

    // ❌ Restricted Coordinates (RCC & HO)
    restrictedLocations = [];

    // 📏 Allowed distance threshold in meters (100 m)
    restrictedRadius = 100;

    // 🧮 Haversine formula to calculate distance between two coordinates
    getDistanceFromLatLonInM(lat1, lon1, lat2, lon2) {
        const R = 6371000; // Earth's radius in meters
        const dLat = this.deg2rad(lat2 - lat1);
        const dLon = this.deg2rad(lon2 - lon1);
        const a =
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c; // Distance in meters
    }

    deg2rad(deg) {
        return deg * (Math.PI / 180);
    }

    // 🚫 Check if within restricted radius
    isInRestrictedArea(lat, lon) {
        return this.restrictedLocations.some(loc => {
            const distance = this.getDistanceFromLatLonInM(lat, lon, loc.latitude, loc.longitude);
            console.log(`Distance from ${loc.name}: ${distance} m`);
            return distance <= this.restrictedRadius;
        });
    }

    async updateTaskWithLocation() {
        try {
            await updateTaskLocation({
                taskId: this.recordId,
                latitude: this.currentLocation.latitude,
                longitude: this.currentLocation.longitude
            });
            this.isLoaded = false;
            this.showToast('Success', 'Location updated on Event successfully!', 'success');
            setTimeout(() => {
                window.location.reload();
            }, 1000);

        } catch (error) {
            this.isLoaded = false;
            this.showToast('Error', 'Failed to update Event with location', 'error');
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