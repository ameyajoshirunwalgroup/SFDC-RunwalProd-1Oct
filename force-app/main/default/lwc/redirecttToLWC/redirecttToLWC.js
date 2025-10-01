import { LightningElement,api,wire} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import getaccountID from '@salesforce/apex/Customer360.getaccountID';
export default class RedirecttToLWC  extends NavigationMixin(LightningElement) {

@api recordId;
accountId;

@wire(getaccountID, {oppId:'$recordId' })
wiredaccountID({ error, data }) {
    console.log('inside get account Id');
    console.log('oppId',this.recordId);
    if (data) {
    data = JSON.parse(JSON.stringify(data));
    console.log('Id::::',data);
    this.accountId=data;
        this[NavigationMixin.Navigate]({
type: 'standard__webPage',
attributes: {
    url: '/lightning/n/customer360?c__var1='+this.recordId+' &c__var2='+this.accountId
}
});

    
    }
}
/*connectedCallback(){

    this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
        attributes: {
            apiName: 'customer360'
        },
        state: {
            c__recordId: recordId
        }
    });
}*/
}