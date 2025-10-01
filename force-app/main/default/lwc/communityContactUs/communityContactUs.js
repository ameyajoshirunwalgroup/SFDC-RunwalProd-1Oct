import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Contactus from '@salesforce/resourceUrl/ContactUsImage';
export default class CommunityContactUs extends NavigationMixin(LightningElement) {
 imagecon = Contactus;

 logacase(){
  this[NavigationMixin.Navigate]({
    type: 'comm__namedPage',
    attributes: {
        pageName: 'createnewcase'
    }
});
 }
}