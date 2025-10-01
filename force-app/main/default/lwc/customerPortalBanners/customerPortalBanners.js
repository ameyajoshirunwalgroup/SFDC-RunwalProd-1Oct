import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import banners from "@salesforce/apex/CustomerPortalBannersController.banners";
import syncCustPortalToCpPortal from "@salesforce/apex/CustomerPortalBannersController.syncCustPortalToCpPortal";

export default class CustomerPortalBanners extends LightningElement {
  @api recordId;

  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }

  customerPortalBanners(event) {
    var uploadedFiles = event.detail.files;
    const file1 = event.detail.files[0];
    var docIds = [];
    console.log("File: ", file1);
    for (let i = 0; i < uploadedFiles.length; i++) {
      docIds.push(uploadedFiles[i].documentId);
      console.log("docIds: ", docIds);
    }
    banners({ documentIds: docIds, bannerType: "CommunityHeaders" })
    .then(result => {
      const eve = new ShowToastEvent({
        title: 'Success',
        variant: 'success',
        mode: 'dismissable', 
        message: uploadedFiles.length + " Files Uploaded Successfully"
      });
      this.dispatchEvent(eve);
    })
    .catch(error => {
      console.log('error: ', error);
      console.log('error: ', error.body.message);
      const eve = new ShowToastEvent({
        title: 'Error',
        variant: 'error',
        mode: 'dismissable', 
        message: error.body.message,
      });
      this.dispatchEvent(eve);
    })
  }

  cpPortalBanners(event) {
    var uploadedFiles = event.detail.files;
    const file1 = event.detail.files[0];
    var docIds = [];
    console.log("File: ", file1);
    for (let i = 0; i < uploadedFiles.length; i++) {
      docIds.push(uploadedFiles[i].documentId);
      console.log("docIds: ", docIds);
    }
    banners({ documentIds: docIds, bannerType: "PartnerPortalHeader" })
    .then(result => {
      const eve = new ShowToastEvent({
        title: 'Success',
        variant: 'success',
        mode: 'dismissable', 
        message: uploadedFiles.length + " Files Uploaded Successfully"
      });
      this.dispatchEvent(eve);
    })
    .catch(error => {
      console.log('error: ', error);
      console.log('error: ', error.body.message);
      const eve = new ShowToastEvent({
        title: 'Error',
        variant: 'error',
        mode: 'dismissable', 
        message: error.body.message,
      });
      this.dispatchEvent(eve);
    })
  }

  mobileAppBanners(event) {
    var uploadedFiles = event.detail.files;
    const file1 = event.detail.files[0];
    var docIds = [];
    console.log("File: ", file1);
    for (let i = 0; i < uploadedFiles.length; i++) {
      docIds.push(uploadedFiles[i].documentId);
      console.log("docIds: ", docIds);
    }
    banners({ documentIds: docIds, bannerType: "CustomerPortalMobileApp" })
    .then(result => {
      const eve = new ShowToastEvent({
        title: 'Success',
        variant: 'success',
        mode: 'dismissable', 
        message: uploadedFiles.length + " Files Uploaded Successfully"
      });
      this.dispatchEvent(eve);
    })
    .catch(error => {
      console.log('error: ', error);
      console.log('error: ', error.body.message);
      const eve = new ShowToastEvent({
        title: 'Error',
        variant: 'error',
        mode: 'dismissable', 
        message: error.body.message,
      });
      this.dispatchEvent(eve);
    })
  }

  syncCustToCp(event){
    var check = event.target.checked;
    console.log('check: ', check);
    if(check){
      syncCustPortalToCpPortal()
      .then(result => {
        const eve = new ShowToastEvent({
          title: 'Success',
          variant: 'success',
          mode: 'dismissable', 
          message: "Files Uploaded Successfully"
        });
        this.dispatchEvent(eve);
      })
      .catch(error => {
        console.log('error: ', error);
        console.log('error: ', error.body.message);
        const eve = new ShowToastEvent({
          title: 'Error',
          variant: 'error',
          mode: 'dismissable', // Remains visible until the user clicks the close button or 3 seconds has elapsed, whichever comes first.
          message: error.body.message,
        });
        this.dispatchEvent(eve);
      })
    }
  }

}